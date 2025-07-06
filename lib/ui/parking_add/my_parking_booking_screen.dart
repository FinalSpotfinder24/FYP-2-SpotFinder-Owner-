import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:owner/constant/collection_name.dart';
import 'package:owner/constant/constant.dart';
import 'package:owner/constant/show_toast_dialog.dart';
import 'package:owner/controller/my_parking_booking_controller.dart';
import 'package:owner/model/order_model.dart';
import 'package:owner/model/parking_model.dart';
import 'package:owner/themes/app_them_data.dart';
import 'package:owner/themes/common_ui.dart';
import 'package:owner/themes/round_button_fill.dart';
import 'package:owner/ui/parking_add/my_summery_screen.dart';
import 'package:owner/ui/qr_code_scan_screen/qr_code_scan_screen.dart';
import 'package:owner/utils/dark_theme_provider.dart';
import 'package:owner/utils/fire_store_utils.dart';
import 'package:provider/provider.dart';

class MyParkingBooingScreen extends StatelessWidget {
  final bool isBack;

  const MyParkingBooingScreen({required this.isBack, super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: MyParkingBookingController(),
        builder: (controller) {
          return Scaffold(
            appBar: UiInterface().customAppBar(isBack: isBack, context, themeChange, "My Booking List".tr),
            body: controller.isLoading.value
                ? Constant.loader()
                : controller.selectedParkingModel.value.id == null
                    ? Constant.showEmptyView(message: "Parking Not available")
                    : DefaultTabController(
                        length: 3,
                        child: Column(
                          children: [
                            Container(
                              color: themeChange.getThem() ? AppThemData.grey09 : AppThemData.white,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Text("Select Parking".tr),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    DropdownButtonFormField<ParkingModel>(
                                        isExpanded: true,
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
                                        onChanged: (value) {
                                          controller.selectedParkingModel.value = value!;
                                          controller.update();
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
                                      height: 10,
                                    ),
                                    DatePicker(
                                      DateTime.now(),
                                      height: 95,
                                      width: 76,
                                      initialSelectedDate: controller.selectedDateTime.value,
                                      selectionColor: AppThemData.primary07,
                                      selectedTextColor: AppThemData.primary11,
                                      onDateChange: (date) {
                                        controller.selectedDateTime.value = date;
                                      },
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    TabBar(
                                      onTap: (value) {
                                        controller.selectedTabIndex.value = value;
                                        controller.update();
                                      },
                                      labelStyle: const TextStyle(fontFamily: AppThemData.semiBold),
                                      labelColor: themeChange.getThem() ? AppThemData.primary06 : AppThemData.grey10,
                                      unselectedLabelStyle: const TextStyle(fontFamily: AppThemData.medium),
                                      unselectedLabelColor: themeChange.getThem() ? AppThemData.grey11 : AppThemData.grey06,
                                      indicatorColor: AppThemData.primary06,
                                      indicatorWeight: 1,
                                      tabs: [
                                        Tab(
                                          text: "ongoing".tr,
                                        ),
                                        Tab(
                                          text: "completed".tr,
                                        ),
                                        Tab(
                                          text: "canceled".tr,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: TabBarView(
                                children: [
                                  StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection(CollectionName.bookedParkingOrder)
                                        .where('status', whereIn: [Constant.placed, Constant.onGoing])
                                        .where('bookingDate', isEqualTo: Timestamp.fromDate(controller.selectedDateTime.value))
                                        .where('parkingId', isEqualTo: controller.selectedParkingModel.value.id)
                                        .orderBy('createdAt', descending: true)
                                        .snapshots(),
                                    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                      if (snapshot.hasError) {
                                        return Center(child: Text('Something went wrong'.tr));
                                      }
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return Constant.loader();
                                      }
                                      return snapshot.data!.docs.isEmpty
                                          ? Constant.showEmptyView(message: "No active booking found".tr)
                                          : ListView.builder(
                                              itemCount: snapshot.data!.docs.length,
                                              scrollDirection: Axis.vertical,
                                              shrinkWrap: true,
                                              itemBuilder: (context, index) {
                                                OrderModel orderModel = OrderModel.fromJson(snapshot.data!.docs[index].data() as Map<String, dynamic>);
                                                print(orderModel.bookingDate!.toDate());
                                                return Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(12),
                                                      color: themeChange.getThem() ? AppThemData.grey10 : AppThemData.white,
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Expanded(
                                                              child: Text(
                                                                "ID: ${orderModel.id}".tr,
                                                                style: TextStyle(
                                                                    fontSize: 14,
                                                                    fontFamily: AppThemData.semiBold,
                                                                    color: themeChange.getThem() ? AppThemData.grey01 : AppThemData.grey08),
                                                              ),
                                                            ),
                                                            Visibility(
                                                              visible: orderModel.status == Constant.placed,
                                                              child: InkWell(
                                                                onTap: () {
                                                                  Get.to(QrCodeScanScreen(
                                                                    orderId: orderModel.id,
                                                                  ));
                                                                },
                                                                child: Padding(
                                                                  padding: const EdgeInsets.only(right: 10),
                                                                  child: Icon(Icons.qr_code_scanner, color: themeChange.getThem() ? AppThemData.blueLight : AppThemData.blueLight),
                                                                ),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                        const Divider(thickness: 1, color: AppThemData.grey04),
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                        Row(
                                                          children: [
                                                            Expanded(
                                                              child: Row(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  const Icon(Icons.calendar_today, color: AppThemData.grey07, size: 20),
                                                                  const SizedBox(
                                                                    width: 10,
                                                                  ),
                                                                  Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: [
                                                                      Text(
                                                                        Constant.timestampToDate(orderModel.bookingDate!),
                                                                        style: TextStyle(
                                                                          color: themeChange.getThem() ? AppThemData.grey06 : AppThemData.grey09,
                                                                          fontSize: 16,
                                                                          fontFamily: AppThemData.medium,
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        height: 5,
                                                                      ),
                                                                      Text(
                                                                        "${Constant.timestampToTime(orderModel.bookingStartTime!)} - ${Constant.timestampToTime(orderModel.bookingEndTime!)}",
                                                                        style: const TextStyle(
                                                                          color: AppThemData.grey07,
                                                                          fontSize: 12,
                                                                          fontFamily: AppThemData.regular,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            Expanded(
                                                              child: Row(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  const Icon(Icons.local_parking, color: AppThemData.grey07, size: 20),
                                                                  const SizedBox(
                                                                    width: 10,
                                                                  ),
                                                                  Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: [
                                                                      Text(
                                                                        orderModel.parkingSlotId.toString(),
                                                                        style: TextStyle(
                                                                          color: themeChange.getThem() ? AppThemData.grey06 : AppThemData.grey09,
                                                                          fontSize: 16,
                                                                          fontFamily: AppThemData.medium,
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        height: 5,
                                                                      ),
                                                                      Text(
                                                                        "Parking Slot".tr,
                                                                        style: const TextStyle(
                                                                          color: AppThemData.grey07,
                                                                          fontSize: 12,
                                                                          fontFamily: AppThemData.regular,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                        Row(
                                                          children: [
                                                            Expanded(
                                                              child: Row(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  SvgPicture.asset("assets/icon/ic_car_image.svg", height: 24, width: 24),
                                                                  const SizedBox(
                                                                    width: 10,
                                                                  ),
                                                                  Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: [
                                                                      Text(
                                                                        orderModel.userVehicle!.vehicleModel!.name.toString(),
                                                                        style: TextStyle(
                                                                          color: themeChange.getThem() ? AppThemData.grey06 : AppThemData.grey09,
                                                                          fontSize: 16,
                                                                          fontFamily: AppThemData.medium,
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        height: 5,
                                                                      ),
                                                                      Text(
                                                                        "vehicle Detail".tr,
                                                                        style: const TextStyle(
                                                                          color: AppThemData.grey07,
                                                                          fontSize: 12,
                                                                          fontFamily: AppThemData.regular,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            Expanded(
                                                              child: Row(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  const Icon(Icons.access_time_rounded, color: AppThemData.grey07, size: 20),
                                                                  const SizedBox(
                                                                    width: 10,
                                                                  ),
                                                                  Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: [
                                                                      Text(
                                                                        "${orderModel.duration.toString()} hours".tr,
                                                                        style: TextStyle(
                                                                          color: themeChange.getThem() ? AppThemData.grey06 : AppThemData.grey09,
                                                                          fontSize: 16,
                                                                          fontFamily: AppThemData.medium,
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        height: 5,
                                                                      ),
                                                                      Text(
                                                                        "Time Durations".tr,
                                                                        style: const TextStyle(
                                                                          color: AppThemData.grey07,
                                                                          fontSize: 12,
                                                                          fontFamily: AppThemData.regular,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          height: 12,
                                                        ),
                                                        Row(
                                                          children: [
                                                            Expanded(
                                                              child: RoundedButtonFill(
                                                                title: "Summary".tr,
                                                                color: AppThemData.primary06,
                                                                height: 5.5,
                                                                onPress: () {
                                                                  Get.to(() => const MySummaryScreen(), arguments: {"orderModel": orderModel});
                                                                },
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 10,
                                                            ),
                                                            orderModel.paymentCompleted! == false && orderModel.paymentType.toString().toLowerCase() == 'cash'.toLowerCase()
                                                                ? Expanded(
                                                                    child: RoundedButtonFill(
                                                                      title: "Confirm cash payment".tr,
                                                                      color: AppThemData.primary06,
                                                                      height: 5.5,
                                                                      onPress: () {
                                                                        controller.confirmPayment(orderModel);
                                                                      },
                                                                    ),
                                                                  )
                                                                : orderModel.status == Constant.onGoing
                                                                    ? Expanded(
                                                                        child: RoundedButtonFill(
                                                                        title: "Mark as Completed".tr,
                                                                        color: themeChange.getThem() ? AppThemData.grey09 : AppThemData.grey03,
                                                                        height: 5.5,
                                                                        onPress: () async {
                                                                          ShowToastDialog.showLoader("Please wait".tr);
                                                                          orderModel.status = Constant.completed;
                                                                          await FireStoreUtils.setOrder(orderModel).then((value) {
                                                                            ShowToastDialog.closeLoader();
                                                                          });
                                                                        },
                                                                      ))
                                                                    : Container()
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              });
                                    },
                                  ),
                                  StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection(CollectionName.bookedParkingOrder)
                                        .where('status', whereIn: [Constant.completed])
                                        .where('bookingDate', isEqualTo: Timestamp.fromDate(controller.selectedDateTime.value))
                                        .where('parkingId', isEqualTo: controller.selectedParkingModel.value.id.toString())
                                        .orderBy("createdAt", descending: true)
                                        .snapshots(),
                                    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                      if (snapshot.hasError) {
                                        return Center(child: Text('Something went wrong'.tr));
                                      }
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return Constant.loader();
                                      }
                                      return snapshot.data!.docs.isEmpty
                                          ? Constant.showEmptyView(message: "No Completed Booking Found")
                                          : ListView.builder(
                                              itemCount: snapshot.data!.docs.length,
                                              scrollDirection: Axis.vertical,
                                              shrinkWrap: true,
                                              padding: EdgeInsets.zero,
                                              itemBuilder: (context, index) {
                                                OrderModel orderModel = OrderModel.fromJson(snapshot.data!.docs[index].data() as Map<String, dynamic>);
                                                return Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(12),
                                                      color: themeChange.getThem() ? AppThemData.grey10 : AppThemData.white,
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Expanded(
                                                              child: Text(
                                                                "ID: ${orderModel.id}".tr,
                                                                style: TextStyle(
                                                                    fontSize: 14,
                                                                    fontFamily: AppThemData.semiBold,
                                                                    color: themeChange.getThem() ? AppThemData.grey01 : AppThemData.grey08),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                        const Divider(thickness: 1, color: AppThemData.grey04),
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                        Row(
                                                          children: [
                                                            Expanded(
                                                              child: Row(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  const Icon(Icons.calendar_today, color: AppThemData.grey07, size: 20),
                                                                  const SizedBox(
                                                                    width: 10,
                                                                  ),
                                                                  Column(
                                                                    children: [
                                                                      Text(
                                                                        Constant.timestampToDate(orderModel.bookingDate!),
                                                                        style: TextStyle(
                                                                          color: themeChange.getThem() ? AppThemData.grey06 : AppThemData.grey09,
                                                                          fontSize: 16,
                                                                          fontFamily: AppThemData.medium,
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        height: 5,
                                                                      ),
                                                                      Text(
                                                                        "${Constant.timestampToTime(orderModel.bookingStartTime!)} - ${Constant.timestampToTime(orderModel.bookingEndTime!)}",
                                                                        style: const TextStyle(
                                                                          color: AppThemData.grey07,
                                                                          fontSize: 12,
                                                                          fontFamily: AppThemData.regular,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            Expanded(
                                                              child: Row(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  const Icon(Icons.local_parking, color: AppThemData.grey07, size: 20),
                                                                  const SizedBox(
                                                                    width: 10,
                                                                  ),
                                                                  Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: [
                                                                      Text(
                                                                        orderModel.parkingSlotId.toString(),
                                                                        style: TextStyle(
                                                                          color: themeChange.getThem() ? AppThemData.grey06 : AppThemData.grey09,
                                                                          fontSize: 16,
                                                                          fontFamily: AppThemData.medium,
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        height: 5,
                                                                      ),
                                                                      Text(
                                                                        "Parking Slot".tr,
                                                                        style: const TextStyle(
                                                                          color: AppThemData.grey07,
                                                                          fontSize: 12,
                                                                          fontFamily: AppThemData.regular,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                        Row(
                                                          children: [
                                                            Expanded(
                                                              child: Row(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  SvgPicture.asset("assets/icon/ic_car_image.svg", height: 24, width: 24),
                                                                  const SizedBox(
                                                                    width: 10,
                                                                  ),
                                                                  Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: [
                                                                      Text(
                                                                        orderModel.userVehicle!.vehicleModel!.name.toString(),
                                                                        style: TextStyle(
                                                                          color: themeChange.getThem() ? AppThemData.grey06 : AppThemData.grey09,
                                                                          fontSize: 16,
                                                                          fontFamily: AppThemData.medium,
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        height: 5,
                                                                      ),
                                                                      Text(
                                                                        "vehicle Detail".tr,
                                                                        style: const TextStyle(
                                                                          color: AppThemData.grey07,
                                                                          fontSize: 12,
                                                                          fontFamily: AppThemData.regular,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            Expanded(
                                                              child: Row(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  const Icon(Icons.access_time_rounded, color: AppThemData.grey07, size: 20),
                                                                  const SizedBox(
                                                                    width: 10,
                                                                  ),
                                                                  Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: [
                                                                      Text(
                                                                        "${orderModel.duration.toString()} hours".tr,
                                                                        style: TextStyle(
                                                                          color: themeChange.getThem() ? AppThemData.grey06 : AppThemData.grey09,
                                                                          fontSize: 16,
                                                                          fontFamily: AppThemData.medium,
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        height: 5,
                                                                      ),
                                                                      Text(
                                                                        "Time Durations".tr,
                                                                        style: const TextStyle(
                                                                          color: AppThemData.grey07,
                                                                          fontSize: 12,
                                                                          fontFamily: AppThemData.regular,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          height: 20,
                                                        ),
                                                        RoundedButtonFill(
                                                          title: "Summary".tr,
                                                          color: AppThemData.primary06,
                                                          height: 5.5,
                                                          onPress: () {
                                                            Get.to(() => const MySummaryScreen(), arguments: {"orderModel": orderModel});
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              });
                                    },
                                  ),
                                  StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection(CollectionName.bookedParkingOrder)
                                        .where('status', whereIn: [Constant.canceled])
                                        .where('bookingDate', isEqualTo: Timestamp.fromDate(controller.selectedDateTime.value))
                                        .where('parkingId', isEqualTo: controller.selectedParkingModel.value.id.toString())
                                        .orderBy("createdAt", descending: true)
                                        .snapshots(),
                                    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                      if (snapshot.hasError) {
                                        return Center(child: Text('Something went wrong'.tr));
                                      }
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return Constant.loader();
                                      }
                                      return snapshot.data!.docs.isEmpty
                                          ? Constant.showEmptyView(message: "No Canceled Booking Found")
                                          : ListView.builder(
                                              itemCount: snapshot.data!.docs.length,
                                              scrollDirection: Axis.vertical,
                                              shrinkWrap: true,
                                              itemBuilder: (context, index) {
                                                OrderModel orderModel = OrderModel.fromJson(snapshot.data!.docs[index].data() as Map<String, dynamic>);
                                                return Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(12),
                                                      color: themeChange.getThem() ? AppThemData.grey10 : AppThemData.white,
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Expanded(
                                                              child: Text(
                                                                "ID: ${orderModel.id}".tr,
                                                                style: TextStyle(
                                                                    fontSize: 14,
                                                                    fontFamily: AppThemData.semiBold,
                                                                    color: themeChange.getThem() ? AppThemData.grey01 : AppThemData.grey08),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                        const Divider(thickness: 1, color: AppThemData.grey04),
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                        Row(
                                                          children: [
                                                            Expanded(
                                                              child: Row(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  const Icon(Icons.calendar_today, color: AppThemData.grey07, size: 20),
                                                                  const SizedBox(
                                                                    width: 10,
                                                                  ),
                                                                  Column(
                                                                    children: [
                                                                      Text(
                                                                        Constant.timestampToDate(orderModel.bookingDate!),
                                                                        style: TextStyle(
                                                                          color: themeChange.getThem() ? AppThemData.grey06 : AppThemData.grey09,
                                                                          fontSize: 16,
                                                                          fontFamily: AppThemData.medium,
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        height: 5,
                                                                      ),
                                                                      Text(
                                                                        "${Constant.timestampToTime(orderModel.bookingStartTime!)} - ${Constant.timestampToTime(orderModel.bookingEndTime!)}",
                                                                        style: const TextStyle(
                                                                          color: AppThemData.grey07,
                                                                          fontSize: 12,
                                                                          fontFamily: AppThemData.regular,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            Expanded(
                                                              child: Row(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  const Icon(Icons.local_parking, color: AppThemData.grey07, size: 20),
                                                                  const SizedBox(
                                                                    width: 10,
                                                                  ),
                                                                  Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: [
                                                                      Text(
                                                                        orderModel.parkingSlotId.toString(),
                                                                        style: TextStyle(
                                                                          color: themeChange.getThem() ? AppThemData.grey06 : AppThemData.grey09,
                                                                          fontSize: 16,
                                                                          fontFamily: AppThemData.medium,
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        height: 5,
                                                                      ),
                                                                      Text(
                                                                        "Parking Slot".tr,
                                                                        style: const TextStyle(
                                                                          color: AppThemData.grey07,
                                                                          fontSize: 12,
                                                                          fontFamily: AppThemData.regular,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                        Row(
                                                          children: [
                                                            Expanded(
                                                              child: Row(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  SvgPicture.asset("assets/icon/ic_car_image.svg", height: 24, width: 24),
                                                                  const SizedBox(
                                                                    width: 10,
                                                                  ),
                                                                  Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: [
                                                                      Text(
                                                                        orderModel.userVehicle!.vehicleModel!.name.toString(),
                                                                        style: TextStyle(
                                                                          color: themeChange.getThem() ? AppThemData.grey06 : AppThemData.grey09,
                                                                          fontSize: 16,
                                                                          fontFamily: AppThemData.medium,
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        height: 5,
                                                                      ),
                                                                      Text(
                                                                        "vehicle Detail".tr,
                                                                        style: const TextStyle(
                                                                          color: AppThemData.grey07,
                                                                          fontSize: 12,
                                                                          fontFamily: AppThemData.regular,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            Expanded(
                                                              child: Row(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  const Icon(Icons.access_time_rounded, color: AppThemData.grey07, size: 20),
                                                                  const SizedBox(
                                                                    width: 10,
                                                                  ),
                                                                  Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: [
                                                                      Text(
                                                                        "${orderModel.duration.toString()} hours".tr,
                                                                        style: TextStyle(
                                                                          color: themeChange.getThem() ? AppThemData.grey06 : AppThemData.grey09,
                                                                          fontSize: 16,
                                                                          fontFamily: AppThemData.medium,
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        height: 5,
                                                                      ),
                                                                      Text(
                                                                        "Time Durations".tr,
                                                                        style: const TextStyle(
                                                                          color: AppThemData.grey07,
                                                                          fontSize: 12,
                                                                          fontFamily: AppThemData.regular,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            )
                                                          ],
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              });
                                    },
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
          );
        });
  }
}
