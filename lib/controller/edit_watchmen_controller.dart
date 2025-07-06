import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:owner/constant/constant.dart';
import 'package:owner/constant/extension_data.dart';
import 'package:owner/constant/show_toast_dialog.dart';
import 'package:owner/model/parking_model.dart';
import 'package:owner/model/user_model.dart';
import 'package:owner/utils/fire_store_utils.dart';

class EditWatchmenController extends GetxController {
  RxBool isLoading = true.obs;
  Rx<UserModel> watchmenModel = UserModel().obs;

  Rx<TextEditingController> fullNameController = TextEditingController().obs;
  Rx<TextEditingController> emailController = TextEditingController().obs;
  Rx<TextEditingController> dateOfBirthController = TextEditingController().obs;
  Rx<TextEditingController> phoneNumberController = TextEditingController().obs;
  Rx<TextEditingController> countryCodeController = TextEditingController(text: "+1").obs;
  Rx<TextEditingController> passwordController = TextEditingController().obs;
  Rx<TextEditingController> salaryController = TextEditingController().obs;

  RxString gender = "Male".obs;

  RxBool isActive = true.obs;

  Rx<ParkingModel> selectedParkingModel = ParkingModel().obs;
  RxList<ParkingModel> parkingList = <ParkingModel>[].obs;

  GlobalKey<FormFieldState> key = GlobalKey<FormFieldState>();

  void handleGenderChange(String? value) {
    gender.value = value!;
  }

  @override
  void onInit() {
    Get.arguments;
    if (Get.arguments != '') {
      getData(watchmanId: Get.arguments);
    } else {
      isLoading.value = false;
    }
    getParkingDataComman();
    super.onInit();
  }

  getParkingDataComman() async {
    await getParkingData();
  }

  getData({required String watchmanId}) async {
    await FireStoreUtils.getWatchMen(watchmanId).then((value) {
      if (value != null) {
        watchmenModel.value = value;
        passwordController.value.text = watchmenModel.value.password.toString();
        phoneNumberController.value.text = watchmenModel.value.phoneNumber.toString();
        countryCodeController.value.text = watchmenModel.value.countryCode.toString();
        emailController.value.text = watchmenModel.value.email.toString();
        fullNameController.value.text = watchmenModel.value.fullName.toString();
        dateOfBirthController.value.text = watchmenModel.value.dateOfBirth.toString();
        profileImage.value = watchmenModel.value.profilePic.toString();
        gender.value = watchmenModel.value.gender!.capitalizeFirst ?? '';
        salaryController.value.text = watchmenModel.value.salary ?? '0';
        isActive.value = watchmenModel.value.isActive ?? true;
      }
    });

    isLoading.value = false;
  }

  getParkingData() async {
    await FireStoreUtils.getMyParkingList().then((value) {
      if (value != null) {
        parkingList.value = value;
        print("-=======>${parkingList.length}");
        for (var element in parkingList) {
          if (element.id == watchmenModel.value.parkingId) {
            selectedParkingModel.value = element;
          }
        }
      }
    });
    print("-=======>${parkingList.length}");
    isLoading.value = false;
    update();
  }

  final ImagePicker _imagePicker = ImagePicker();
  RxString profileImage = "".obs;

  Future pickFile({required ImageSource source}) async {
    try {
      XFile? image = await _imagePicker.pickImage(source: source);
      if (image == null) return;
      Get.back();
      profileImage.value = image.path;
    } on PlatformException catch (e) {
      ShowToastDialog.showToast("${"failed_to_pick".tr} : \n $e");
    }
  }

  addWatchmen() async {
    ShowToastDialog.showLoader("please_wait".tr);
    UserModel watchmenModelData = watchmenModel.value;
    try {
      if (Get.arguments == '') {
        FirebaseApp secondaryApp = await Firebase.initializeApp(name: "SecondaryApp", options: Firebase.app().options);

        UserCredential result =
            await FirebaseAuth.instanceFor(app: secondaryApp).createUserWithEmailAndPassword(email: emailController.value.text, password: passwordController.value.text);

        watchmenModelData.id = result.user?.uid ?? "";
      } else {
        watchmenModelData.id = watchmenModelData.id ?? "";
        if (passwordController.value.text != watchmenModelData.password) {
          FirebaseApp secondaryApp = await Firebase.initializeApp(name: "SecondaryApp", options: Firebase.app().options);

          UserCredential result =
              await FirebaseAuth.instanceFor(app: secondaryApp).signInWithEmailAndPassword(email: emailController.value.text, password: watchmenModelData.password.toString());

          await result.user!
              .reauthenticateWithCredential(EmailAuthProvider.credential(email: emailController.value.text, password: watchmenModelData.password.toString()))
              .then((value) {
            UserCredential authResult = value;
            authResult.user!.updatePassword(passwordController.value.text).then((_) {});
          });
        }
      }

      if (Constant().hasValidUrl(profileImage.value) == false && profileImage.value.isNotEmpty) {
        profileImage.value = await Constant.uploadUserImageToFireStorage(
          File(profileImage.value),
          "watchmenImage/${FireStoreUtils.getCurrentUid()}",
          File(profileImage.value).path.split('/').last,
        );
      }

      watchmenModelData.fullName = fullNameController.value.text;
      watchmenModelData.profilePic = profileImage.value;
      watchmenModelData.dateOfBirth = dateOfBirthController.value.text;
      watchmenModelData.gender = gender.value;
      watchmenModelData.ownerId = FireStoreUtils.getCurrentUid();
      watchmenModelData.parkingId = selectedParkingModel.value.id;
      watchmenModelData.createdAt = Timestamp.fromDate(DateTime.now());
      watchmenModelData.isActive = isActive.value;
      watchmenModelData.password = passwordController.value.text;
      watchmenModelData.phoneNumber = phoneNumberController.value.text;
      watchmenModelData.countryCode = countryCodeController.value.text;
      watchmenModelData.email = emailController.value.text;
      watchmenModelData.salary = salaryController.value.text ?? '0';
      watchmenModelData.role = 'security';
      watchmenModelData.loginType = 'emailPassword';
      watchmenModelData.fcmToken = '';
      FireStoreUtils.updateWatchmen(watchmenModelData).then(
        (value) {
          ShowToastDialog.closeLoader();
          ShowToastDialog.showToast(
            Get.arguments != '' ? "Watchmen updated successfully".tr : "Watchmen added successfully".tr,
          );
          Get.back();
          update();
        },
      );
    } catch (e) {
      log("Error :: $e");
      ShowToastDialog.closeLoader();
    }
  }

  checkValidation() {
    if (fullNameController.value.text == '') {
      return 'Please Enter Valid Full Name';
    } else if (isEmail(emailController.value.text) == false) {
      return "Please Enter Valid email";
    } else if (passwordController.value.text.length < 6) {
      return 'Please Enter 6 length password';
    } else if (phoneNumberController.value.text.isEmpty) {
      return 'Please Enter phone number';
    } else if (salaryController.value.text.isEmpty || salaryController.value.text == '0') {
      return 'Please Enter valid Salary';
    } else {
      return null;
    }
  }
}
