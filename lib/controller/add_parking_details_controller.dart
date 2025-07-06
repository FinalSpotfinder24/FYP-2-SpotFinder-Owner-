import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:owner/constant/constant.dart';
import 'package:owner/constant/show_toast_dialog.dart';
import 'package:owner/model/location_lat_lng.dart';
import 'package:owner/model/parking_facilities_model.dart';
import 'package:owner/model/parking_model.dart';
import 'package:owner/model/positions_model.dart';
import 'package:owner/utils/fire_store_utils.dart';
import 'package:owner/widgets/geoflutterfire/src/geoflutterfire.dart';
import 'package:owner/widgets/geoflutterfire/src/models/point.dart';

class AddParkingDetailsController extends GetxController {
  Rx<TextEditingController> nameController = TextEditingController().obs;
  Rx<TextEditingController> detailsController = TextEditingController().obs;
  Rx<TextEditingController> addressController = TextEditingController().obs;
  Rx<TextEditingController> parkingSpaceController = TextEditingController().obs;
  Rx<TextEditingController> priceController = TextEditingController().obs;
  final ImagePicker imagePicker = ImagePicker();
  RxString parkingImage = "".obs;

  Rx<LocationLatLng> locationLatLng = LocationLatLng().obs;
  RxList<ParkingFacilitiesModel> parkingFacilitiesList = <ParkingFacilitiesModel>[].obs;
  RxList<ParkingFacilitiesModel> selectedParkingFacilitiesList = <ParkingFacilitiesModel>[].obs;
  RxBool isOpen = false.obs;
  RxBool isLoading = true.obs;

  RxString parkingType = "2".obs;

  void handleParkingChange(String? value) {
    parkingType.value = value!;
  }

  @override
  void onInit() {
    getArgument();
    getData();
    super.onInit();
  }

  Rx<ParkingModel> parkingModel = ParkingModel().obs;

  getArgument() async {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      parkingModel.value = argumentData['parkingModel'];
      await FireStoreUtils.getUserParkingDetails(parkingModel.value.id.toString()).then((value) {
        if (value != null) {
          parkingModel.value = value;
          nameController.value.text = value.name.toString();
          detailsController.value.text = value.description.toString();
          addressController.value.text = value.address.toString();
          parkingImage.value = value.image.toString();
          locationLatLng.value = value.location!;
          isOpen.value = value.isEnable!;

          priceController.value.text = value.perHrPrice.toString();
          parkingSpaceController.value.text = value.parkingSpace.toString();
          parkingType.value = value.parkingType.toString();

          if (parkingModel.value.facilities != null) {
            for (var element in parkingModel.value.facilities!) {
              selectedParkingFacilitiesList.add(element);
            }
          }
        }
      });
    }
    isLoading.value = false;
    update();
  }

  getData() async {
    parkingFacilitiesList.value = await FireStoreUtils.getParkingFacilities();
    update();
  }

  final geo = Geoflutterfire();
  saveDetails() async {
    ShowToastDialog.showLoader("Please wait");
    String imageFileName = File(parkingImage.value).path.split('/').last;

    if (parkingImage.value.isNotEmpty && Constant().hasValidUrl(parkingImage.value) == false) {
      parkingImage.value = await Constant.uploadUserImageToFireStorage(File(parkingImage.value), "parkingImages/${FireStoreUtils.getCurrentUid()}", imageFileName);
    }

    if (parkingModel.value.id == null || parkingModel.value.userId == null) {
      parkingModel.value.id = Constant.getUuid();
      parkingModel.value.userId = FireStoreUtils.getCurrentUid();
    }
    parkingModel.value.name = nameController.value.text;
    parkingModel.value.description = detailsController.value.text;
    parkingModel.value.address = addressController.value.text;
    parkingModel.value.image = parkingImage.value;
    parkingModel.value.isEnable = isOpen.value;
    parkingModel.value.location = locationLatLng.value;
    parkingModel.value.facilities = selectedParkingFacilitiesList;
    parkingModel.value.perHrPrice = priceController.value.text;
    parkingModel.value.parkingSpace = parkingSpaceController.value.text;
    parkingModel.value.parkingType = parkingType.value;

    GeoFirePoint position = geo.point(latitude: locationLatLng.value.latitude!, longitude: locationLatLng.value.longitude!);
    parkingModel.value.position = Positions(geoPoint: position.geoPoint, geohash: position.hash);
    await FireStoreUtils.saveParkingDetails(parkingModel.value).then((value) {
      Get.back(result: true);

      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast("Parking Information save");
    });
  }

  Future pickFile({
    required ImageSource source,
  }) async {
    try {
      XFile? image = await imagePicker.pickImage(source: source);
      if (image == null) return;
      Get.back();

      parkingImage.value = image.path;
    } on PlatformException catch (e) {
      ShowToastDialog.showToast("Failed to Pick : \n $e");
    }
  }
}
