import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:owner/constant/constant.dart';
import 'package:owner/constant/show_toast_dialog.dart';
import 'package:owner/controller/add_parking_details_controller.dart';
import 'package:owner/model/location_lat_lng.dart';
import 'package:owner/themes/app_them_data.dart';
import 'package:owner/themes/common_ui.dart';
import 'package:owner/themes/responsive.dart';
import 'package:owner/themes/round_button_fill.dart';
import 'package:owner/themes/text_field_widget.dart';
import 'package:owner/utils/dark_theme_provider.dart';
import 'package:owner/utils/network_image_widget.dart';
import 'package:owner/utils/place_picker_osm.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:provider/provider.dart';

class AddParkingDetailsScreen extends StatelessWidget {
  const AddParkingDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<AddParkingDetailsController>(
        init: AddParkingDetailsController(),
        builder: (controller) {
          return Scaffold(
            appBar: UiInterface().customAppBar(
              context,
              themeChange,
              'add_parking'.tr,
            ),
            body: controller.isLoading.value
                ? Constant.loader()
                : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Parking For'.tr, style: const TextStyle(fontFamily: AppThemData.semiBold, fontSize: 16, color: AppThemData.grey07)),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Expanded(
                                  child: Row(
                                children: [
                                  SvgPicture.asset("assets/icon/ic_bike.svg", color: AppThemData.grey08),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text("2 Wheel".tr, style: const TextStyle(color: AppThemData.grey08, fontFamily: AppThemData.medium)),
                                ],
                              )),
                              Radio<String>(
                                value: "2",
                                groupValue: controller.parkingType.value,
                                activeColor: AppThemData.primary07,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                visualDensity: const VisualDensity(
                                  horizontal: VisualDensity.minimumDensity,
                                  vertical: VisualDensity.minimumDensity,
                                ),
                                onChanged: controller.handleParkingChange,
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Expanded(
                                  child: Row(
                                children: [
                                  SvgPicture.asset("assets/icon/ic_car_fill.svg", color: AppThemData.grey08),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text("4 Wheel".tr, style: const TextStyle(color: AppThemData.grey08, fontFamily: AppThemData.medium)),
                                ],
                              )),
                              Radio<String>(
                                value: "4",
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                visualDensity: const VisualDensity(
                                  horizontal: VisualDensity.minimumDensity,
                                  vertical: VisualDensity.minimumDensity,
                                ),
                                groupValue: controller.parkingType.value,
                                activeColor: AppThemData.primary07,
                                onChanged: controller.handleParkingChange,
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          controller.parkingImage.value.isNotEmpty
                              ? InkWell(
                                  onTap: () {
                                    buildBottomSheet(
                                      context,
                                      controller,
                                    );
                                  },
                                  child: SizedBox(
                                    height: Responsive.height(20, context),
                                    width: Responsive.width(90, context),
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                                      child: Constant().hasValidUrl(controller.parkingImage.value) == false
                                          ? Image.file(
                                              File(controller.parkingImage.value),
                                              height: Responsive.height(20, context),
                                              width: Responsive.width(80, context),
                                              fit: BoxFit.fill,
                                            )
                                          : NetworkImageWidget(
                                              imageUrl: controller.parkingImage.value.toString(),
                                              fit: BoxFit.fill,
                                              height: Responsive.height(20, context),
                                              width: Responsive.width(80, context),
                                            ),
                                    ),
                                  ),
                                )
                              : InkWell(
                                  onTap: () {
                                    buildBottomSheet(
                                      context,
                                      controller,
                                    );
                                  },
                                  child: DottedBorder(
                                    borderType: BorderType.RRect,
                                    radius: const Radius.circular(12),
                                    dashPattern: const [6, 6, 6, 6],
                                    color: AppThemData.primary08,
                                    child: Container(
                                        color: AppThemData.primary01,
                                        height: Responsive.height(20, context),
                                        width: Responsive.width(90, context),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.image, color: AppThemData.primary08, size: 32),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            Text(
                                              "Upload image".tr,
                                              style: TextStyle(fontFamily: AppThemData.medium, color: themeChange.getThem() ? AppThemData.primary08 : AppThemData.primary08),
                                            )
                                          ],
                                        )),
                                  ),
                                ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextFieldWidget(
                            title: 'Parking Name'.tr,
                            onPress: () {},
                            controller: controller.nameController.value,
                            hintText: 'Enter Parking Name'.tr,
                            prefix: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: SvgPicture.asset(
                                "assets/icon/ic_parking_p.svg",
                                colorFilter: const ColorFilter.mode(AppThemData.grey07, BlendMode.srcIn),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () async {
                              if (Constant.selectedMapType == 'osm') {
                                Get.to(() => const LocationPicker())?.then((value) {
                                  if (value != null) {
                                    controller.addressController.value.text = value.displayName!.toString();
                                    controller.locationLatLng.value = LocationLatLng(latitude: value.lat, longitude: value.lon);
                                  }
                                });
                              } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PlacePicker(
                                    apiKey: Constant.mapAPIKey,
                                    onPlacePicked: (result) async {
                                      Get.back();
                                      controller.addressController.value.text = result.formattedAddress.toString();
                                      controller.locationLatLng.value = LocationLatLng(
                                        latitude: result.geometry!.location.lat,
                                        longitude: result.geometry!.location.lng,
                                      );
                                    },
                                    initialPosition: const LatLng(-33.8567844, 151.213108),
                                    useCurrentLocation: true,
                                    selectInitialPosition: true,
                                    usePinPointingSearch: true,
                                    usePlaceDetailSearch: true,
                                    zoomGesturesEnabled: true,
                                    zoomControlsEnabled: true,

                                    resizeToAvoidBottomInset: false, // only works in page mode, less flickery, remove if wrong offsets
                                  ),
                                ),
                              );
                              }
                            },
                            child: TextFieldWidget(
                              title: 'Address'.tr,
                              onPress: () {},
                              controller: controller.addressController.value,
                              hintText: 'Enter Address'.tr,
                              enable: false,
                              prefix: const Icon(Icons.location_on_outlined),
                            ),
                          ),
                          TextFieldWidget(
                            title: 'Description'.tr,
                            onPress: () {},
                            controller: controller.detailsController.value,
                            hintText: 'Enter Description'.tr,
                            maxLine: 5,
                          ),
                          TextFieldWidget(
                            title: 'Price'.tr,
                            onPress: () {},
                            textInputType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                            ],
                            controller: controller.priceController.value,
                            hintText: 'Enter Price'.tr,
                            prefix: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text(Constant.currencyModel!.symbol.toString(), style: const TextStyle(fontSize: 20, color: AppThemData.grey08)),
                            ),
                          ),
                          TextFieldWidget(
                            title: 'Parking Space'.tr,
                            onPress: () {},
                            controller: controller.parkingSpaceController.value,
                            textInputType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                            ],
                            hintText: 'Enter Parking Space'.tr,
                            prefix: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: SvgPicture.asset(
                                "assets/icon/ic_space.svg",
                                colorFilter: const ColorFilter.mode(AppThemData.grey07, BlendMode.srcIn),
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "open_close".tr,
                                style: TextStyle(fontFamily: AppThemData.semiBold, fontSize: 16, color: themeChange.getThem() ? AppThemData.grey07 : AppThemData.grey07),
                              ),
                              SizedBox(
                                width: 40,
                                height: 20,
                                child: Switch(
                                  value: controller.isOpen.value,
                                  onChanged: (value) {
                                    controller.isOpen(value);
                                  },
                                  activeColor: AppThemData.primary06,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Text(
                            'select_facilities'.tr,
                            style: TextStyle(fontFamily: AppThemData.semiBold, fontSize: 16, color: themeChange.getThem() ? AppThemData.grey07 : AppThemData.grey07),
                          ),
                          ListView(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            children: controller.parkingFacilitiesList
                                .map((item) => CheckboxListTile(
                                      contentPadding: EdgeInsets.zero,
                                      checkColor: themeChange.getThem() ? AppThemData.white : AppThemData.white,
                                      activeColor: AppThemData.primary07,
                                      value: controller.selectedParkingFacilitiesList.indexWhere((element) => element.id == item.id) == -1 ? false : true,
                                      dense: true,
                                      title: Row(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(20),
                                            child: NetworkImageWidget(
                                              imageUrl: item.image.toString(),
                                              height: 20,
                                              width: 20,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            item.name.toString(),
                                            style: TextStyle(
                                              fontFamily: AppThemData.medium,
                                              fontSize: 16,
                                              color: themeChange.getThem() ? AppThemData.grey01 : AppThemData.grey09,
                                            ),
                                          ),
                                        ],
                                      ),
                                      onChanged: (value) {
                                        if (value == true) {
                                          controller.selectedParkingFacilitiesList.add(item);
                                        } else {
                                          controller.selectedParkingFacilitiesList
                                              .removeAt(controller.selectedParkingFacilitiesList.indexWhere((element) => element.id == item.id));
                                        }
                                      },
                                    ))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
            bottomNavigationBar: Container(
              color: themeChange.getThem() ? AppThemData.grey10 : AppThemData.grey11,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: RoundedButtonFill(
                  title: "Save".tr,
                  color: AppThemData.primary06,
                  onPress: () {
                    if (controller.nameController.value.text.isEmpty) {
                      ShowToastDialog.showToast("Please enter parking name");
                    } else if (controller.addressController.value.text.isEmpty) {
                      ShowToastDialog.showToast("Please enter parking address");
                    } else if (controller.detailsController.value.text.isEmpty) {
                      ShowToastDialog.showToast("Please enter parking description");
                    } else if (controller.priceController.value.text.isEmpty) {
                      ShowToastDialog.showToast("Please enter parking pr hours price");
                    } else if (controller.parkingSpaceController.value.text.isEmpty) {
                      ShowToastDialog.showToast("Please enter parking space");
                    } else {
                      controller.saveDetails();
                    }
                  },
                ),
              ),
            ),
          );
        });
  }

  buildBottomSheet(BuildContext context, AddParkingDetailsController controller) {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return SizedBox(
              height: Responsive.height(22, context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: Text(
                      "please_select".tr,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IconButton(
                                onPressed: () => controller.pickFile(source: ImageSource.camera),
                                icon: const Icon(
                                  Icons.camera_alt,
                                  size: 32,
                                )),
                            Padding(
                              padding: const EdgeInsets.only(top: 3),
                              child: Text(
                                "camera".tr,
                                style: const TextStyle(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IconButton(
                                onPressed: () => controller.pickFile(source: ImageSource.gallery),
                                icon: const Icon(
                                  Icons.photo_library_sharp,
                                  size: 32,
                                )),
                            Padding(
                              padding: const EdgeInsets.only(top: 3),
                              child: Text(
                                "gallery".tr,
                                style: const TextStyle(),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
            );
          });
        });
  }
}
