import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:owner/constant/constant.dart';
import 'package:owner/constant/show_toast_dialog.dart';
import 'package:owner/model/user_model.dart';
import 'package:owner/ui/dashboard_screen.dart';
import 'package:owner/utils/fire_store_utils.dart';
import 'package:owner/utils/notification_service.dart';

class InformationController extends GetxController {
  Rx<TextEditingController> fullNameController = TextEditingController().obs;
  Rx<TextEditingController> emailController = TextEditingController().obs;
  Rx<TextEditingController> phoneNumberController = TextEditingController().obs;
  Rx<TextEditingController> countryCode = TextEditingController().obs;
  RxString loginType = "".obs;
  final ImagePicker imagePicker = ImagePicker();
  RxString profileImage = "".obs;

  @override
  void onInit() {
    getArgument();
    super.onInit();
  }

  Rx<UserModel> userModel = UserModel().obs;

  getArgument() async {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      userModel.value = argumentData['userModel'];
      loginType.value = userModel.value.loginType.toString();
      if (loginType.value == Constant.phoneLoginType) {
        phoneNumberController.value.text = userModel.value.phoneNumber.toString();
        countryCode.value.text = userModel.value.countryCode.toString();
      } else {
        emailController.value.text = userModel.value.email.toString();
        fullNameController.value.text = userModel.value.fullName.toString();
      }
    }
    update();
  }

  createAccount() async {
    ShowToastDialog.showLoader("please_wait".tr);
    String fcmToken = await NotificationService.getToken();
    if (profileImage.value.isNotEmpty) {
      profileImage.value = await Constant.uploadUserImageToFireStorage(
        File(profileImage.value),
        "profileImage/${FireStoreUtils.getCurrentUid()}",
        File(profileImage.value).path.split('/').last,
      );
    }

    UserModel userModelData = userModel.value;
    userModelData.fullName = fullNameController.value.text;
    userModelData.email = emailController.value.text;
    userModelData.countryCode = countryCode.value.text;
    userModelData.phoneNumber = phoneNumberController.value.text;
    userModelData.profilePic = profileImage.value;
    userModelData.fcmToken = fcmToken;
    userModelData.createdAt = Timestamp.now();
    userModelData.isActive = true;
    userModelData.role = Constant.roleType;

    await FireStoreUtils.updateUser(userModelData).then((value) {
      ShowToastDialog.closeLoader();
      if (value == true) {
        Get.offAll(const DashBoardScreen());
      }
    });
  }

  Future pickFile({required ImageSource source}) async {
    try {
      XFile? image = await imagePicker.pickImage(source: source);
      if (image == null) return;
      Get.back();
      profileImage.value = image.path;
    } on PlatformException catch (e) {
      ShowToastDialog.showToast("${"failed_to_pick".tr} : \n $e");
    }
  }
}
