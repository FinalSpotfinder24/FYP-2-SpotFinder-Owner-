import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:owner/constant/constant.dart';
import 'package:owner/constant/show_toast_dialog.dart';
import 'package:owner/controller/edit_watchmen_controller.dart';
import 'package:owner/model/parking_model.dart';
import 'package:owner/themes/app_them_data.dart';
import 'package:owner/themes/common_ui.dart';
import 'package:owner/themes/mobile_number_textfield.dart';
import 'package:owner/themes/responsive.dart';
import 'package:owner/themes/round_button_fill.dart';
import 'package:owner/utils/dark_theme_provider.dart';
import 'package:owner/utils/fire_store_utils.dart';
import 'package:owner/utils/network_image_widget.dart';
import 'package:provider/provider.dart';

import '../../themes/text_field_widget.dart';

class AddWatchmenDetailsScreen extends StatelessWidget {
  final bool isEdit;

  const AddWatchmenDetailsScreen({required this.isEdit, super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<EditWatchmenController>(
      init: EditWatchmenController(),
      builder: (controller) {
        return Scaffold(
          appBar: UiInterface().customAppBar(
            context,
            themeChange,
            isEdit ? "Edit Watchman".tr : 'Add Watchman'.tr,
          ),
          body: Column(
            children: [
              Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Center(
                      child: controller.profileImage.isEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(60),
                              child: Image.asset(
                                Constant.userPlaceHolder,
                                height: Responsive.width(30, context),
                                width: Responsive.width(30, context),
                                fit: BoxFit.fill,
                              ),
                            )
                          : Constant().hasValidUrl(controller.profileImage.value) == false
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(60),
                                  child: Image.file(
                                    File(controller.profileImage.value),
                                    height: Responsive.width(30, context),
                                    width: Responsive.width(30, context),
                                    fit: BoxFit.fill,
                                  ),
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(60),
                                  child: NetworkImageWidget(
                                    imageUrl: controller.profileImage.value.toString(),
                                    height: Responsive.width(30, context),
                                    width: Responsive.width(30, context),
                                  ),
                                )),
                  Positioned(
                    right: Responsive.width(34, context),
                    child: InkWell(
                      onTap: () {
                        buildBottomSheet(context, controller);
                      },
                      child: SvgPicture.asset(
                        "assets/images/ic_profile_edit.svg",
                        width: 40,
                        height: 40,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              Expanded(
                child: controller.isLoading.value
                    ? Constant.loader()
                    : Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextFieldWidget(
                                title: 'Full Name'.tr,
                                onPress: () {},
                                controller: controller.fullNameController.value,
                                hintText: 'Enter Full Name'.tr,
                                textInputType: TextInputType.emailAddress,
                                prefix: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: SvgPicture.asset("assets/icon/ic_account.svg", color: const Color(0xff697586)),
                                ),
                              ),
                              TextFieldWidget(
                                title: 'Email Address'.tr,
                                onPress: () {},
                                controller: controller.emailController.value,
                                hintText: 'Enter Email Address'.tr,
                                textInputType: TextInputType.emailAddress,
                                enable: true,
                                prefix: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: SvgPicture.asset(
                                    "assets/icon/ic_email.svg",
                                  ),
                                ),
                              ),
                              TextFieldWidget(
                                title: 'Password'.tr,
                                onPress: () {},
                                controller: controller.passwordController.value,
                                hintText: 'Enter Password'.tr,
                                enable: true,
                                prefix: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: SvgPicture.asset("assets/icon/ic_lock.svg", color: const Color(0xff697586), fit: BoxFit.cover, width: 7, height: 7),
                                ),
                              ),
                              InkWell(
                                onTap: () async {
                                  await Constant.selectDate(context).then((value) {
                                    if (value != null) {
                                      controller.dateOfBirthController.value.text = DateFormat('MMMM dd,yyyy').format(value);
                                    }
                                  });
                                },
                                child: TextFieldWidget(
                                  title: 'Date of Birth'.tr,
                                  onPress: () async {},
                                  controller: controller.dateOfBirthController.value,
                                  hintText: 'Select Date of Birth'.tr,
                                  enable: false,
                                  prefix: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: SvgPicture.asset(
                                      "assets/icon/ic_cake.svg",
                                    ),
                                  ),
                                ),
                              ),
                              MobileNumberTextField(
                                title: "Phone Number".tr,
                                controller: controller.phoneNumberController.value,
                                countryCodeController: controller.countryCodeController.value,
                                onPress: () {},
                              ),
                              Text("Gender".tr, style: const TextStyle(fontFamily: AppThemData.medium, fontSize: 14, color: AppThemData.grey07)),
                              const SizedBox(
                                height: 5,
                              ),
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: themeChange.getThem() ? AppThemData.grey09 : AppThemData.grey03,
                                          borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12))),
                                      child: Row(
                                        children: [
                                          Radio<String>(
                                            value: "Male".tr,
                                            groupValue: controller.gender.value,
                                            activeColor: AppThemData.primary07,
                                            onChanged: controller.handleGenderChange,
                                          ),
                                          Text("Male".tr),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: themeChange.getThem() ? AppThemData.grey10 : AppThemData.grey03,
                                          borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12))),
                                      child: Row(
                                        children: [
                                          Radio<String>(
                                            value: "Female".tr,
                                            groupValue: controller.gender.value,
                                            activeColor: AppThemData.primary07,
                                            onChanged: controller.handleGenderChange,
                                          ),
                                          Text("Female".tr),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Text("Select Parking".tr, style: const TextStyle(fontFamily: AppThemData.medium, fontSize: 14, color: AppThemData.grey07)),
                              const SizedBox(
                                height: 5,
                              ),
                              DropdownButtonFormField<ParkingModel>(
                                  isExpanded: true,
                                  key: controller.key,
                                  decoration: InputDecoration(
                                    errorStyle: const TextStyle(color: Colors.red),
                                    isDense: true,
                                    filled: true,
                                    fillColor: themeChange.getThem() ? AppThemData.grey10 : AppThemData.grey03,
                                    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
                                    prefixIcon: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: SvgPicture.asset("assets/icon/ic_car_image.svg", height: 24, width: 24),
                                    ),
                                    disabledBorder: UnderlineInputBorder(
                                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                                      borderSide: BorderSide(color: themeChange.getThem() ? AppThemData.grey09 : AppThemData.grey04, width: 1),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                                      borderSide: BorderSide(color: themeChange.getThem() ? AppThemData.primary06 : AppThemData.primary06, width: 1),
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                                      borderSide: BorderSide(color: themeChange.getThem() ? AppThemData.grey09 : AppThemData.grey04, width: 1),
                                    ),
                                    errorBorder: UnderlineInputBorder(
                                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                                      borderSide: BorderSide(color: themeChange.getThem() ? AppThemData.grey09 : AppThemData.grey04, width: 1),
                                    ),
                                    border: UnderlineInputBorder(
                                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                                      borderSide: BorderSide(color: themeChange.getThem() ? AppThemData.grey09 : AppThemData.grey04, width: 1),
                                    ),
                                    hintStyle: TextStyle(
                                        fontSize: 14,
                                        color: themeChange.getThem() ? AppThemData.grey06 : AppThemData.grey06,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: AppThemData.medium),
                                  ),
                                  value: controller.selectedParkingModel.value.id == null ? null : controller.selectedParkingModel.value,
                                  onChanged: (value) async {
                                    if (value != null) {
                                      await FireStoreUtils.parkingAssignCheck(value.id.toString(), controller.watchmenModel.value.id.toString()).then((value0) {
                                        print("=====>");
                                        print(value0);
                                        print(controller.selectedParkingModel.value.id);
                                        if (value0 == true) {
                                          controller.selectedParkingModel.value = ParkingModel();
                                          // controller.key.currentState!.reset();
                                          ShowToastDialog.showToast("This parking already assign to another watchman");
                                        } else {
                                          controller.selectedParkingModel.value = value;
                                          controller.update();
                                        }
                                      });
                                    }
                                  },
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: themeChange.getThem() ? AppThemData.grey02 : AppThemData.grey08,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: AppThemData.medium),
                                  hint: Text(
                                    "Select Your Parking".tr,
                                    style: TextStyle(color: themeChange.getThem() ? AppThemData.grey07 : AppThemData.grey07),
                                  ),
                                  items: controller.parkingList.map((item) {
                                    return DropdownMenuItem<ParkingModel>(
                                      value: item,
                                      child: Text(item.name.toString(), style: const TextStyle()),
                                    );
                                  }).toList()),
                              const SizedBox(
                                height: 20,
                              ),
                              TextFieldWidget(
                                title: 'Salary (Monthly)'.tr,
                                onPress: () {},
                                textInputType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                                ],
                                controller: controller.salaryController.value,
                                hintText: 'Enter Salary'.tr,
                                prefix: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Text(Constant.currencyModel!.symbol.toString(), style: const TextStyle(fontSize: 20, color: AppThemData.grey08)),
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Active".tr, style: const TextStyle(fontFamily: AppThemData.medium, fontSize: 14, color: AppThemData.grey07)),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: SizedBox(
                                      width: 40,
                                      height: 20,
                                      child: Switch(
                                        value: controller.isActive.value,
                                        onChanged: (value) {
                                          controller.isActive(value);
                                        },
                                        activeColor: AppThemData.primary06,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 40,
                              ),
                              RoundedButtonFill(
                                title: "Save".tr,
                                color: AppThemData.primary06,
                                onPress: () {
                                  if (controller.checkValidation() != null) {
                                    ShowToastDialog.showToast(controller.checkValidation().toString());
                                  } else {
                                    controller.addWatchmen();
                                  }
                                },
                              )
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  buildBottomSheet(BuildContext context, EditWatchmenController controller) {
    return showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return SizedBox(
              height: Responsive.height(22, context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: Text("please_select".tr,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        )),
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
          },
        );
      },
    );
  }
}
