import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:owner/constant/constant.dart';
import 'package:owner/controller/my_parking_list_controller.dart';
import 'package:owner/model/parking_model.dart';
import 'package:owner/themes/app_them_data.dart';
import 'package:owner/themes/common_ui.dart';
import 'package:owner/themes/responsive.dart';
import 'package:owner/themes/round_button_fill.dart';
import 'package:owner/ui/parking_add/add_parking_details_screen.dart';
import 'package:owner/utils/dark_theme_provider.dart';
import 'package:owner/utils/network_image_widget.dart';
import 'package:provider/provider.dart';

class MyParkingList extends StatelessWidget {
  final bool isBack;
  const MyParkingList({required this.isBack, super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: MyParkingListController(),
        builder: (controller) {
          return Scaffold(
            appBar: UiInterface().customAppBar(context, themeChange, 'My Parking'.tr, isBack: isBack, actions: [
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 8, right: 8),
                child: RoundedButtonFill(
                  width: 30,
                  title: "Add Parking".tr,
                  color: AppThemData.primary06,
                  onPress: () async {
                    Get.to(() => const AddParkingDetailsScreen())?.then((value) {
                      controller.getData();
                    });
                  },
                ),
              ),
            ]),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: controller.isLoading.value
                  ? Constant.loader()
                  : controller.parkingList.isEmpty
                      ? Constant.showEmptyView(message: "No parking added".tr)
                      : ListView.separated(
                          itemCount: controller.parkingList.length,
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemBuilder: (context, int index) {
                            ParkingModel parkingModel = controller.parkingList[index];
                            return InkWell(
                              onTap: () {
                                Get.to(() => const AddParkingDetailsScreen(), arguments: {"parkingModel": parkingModel})?.then((value) {
                                  controller.getData();
                                });
                              },
                              child: Container(
                                height: Responsive.height(15, context),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: themeChange.getThem() ? AppThemData.grey10 : AppThemData.white,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
                                      child: NetworkImageWidget(
                                        fit: BoxFit.cover,
                                        imageUrl: parkingModel.image.toString(),
                                        height: Responsive.height(100, context),
                                        width: 100,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    parkingModel.name.toString(),
                                                    style: TextStyle(
                                                      color: themeChange.getThem() ? AppThemData.grey01 : AppThemData.grey10,
                                                      fontSize: 14,
                                                      fontFamily: AppThemData.semiBold,
                                                    ),
                                                  ),
                                                ),
                                                const Icon(
                                                  Icons.edit,
                                                  color: AppThemData.warning08,
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            Text(
                                              parkingModel.address.toString(),
                                              maxLines: 2,
                                              style: const TextStyle(color: AppThemData.grey07, fontSize: 12, fontFamily: AppThemData.regular, overflow: TextOverflow.ellipsis),
                                            ),
                                            const SizedBox(
                                              height: 8,
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  "${Constant.amountShow(amount: parkingModel.perHrPrice.toString())}/hour".tr,
                                                  style: const TextStyle(
                                                    color: AppThemData.blueLight07,
                                                    fontSize: 12,
                                                    fontFamily: AppThemData.semiBold,
                                                  ),
                                                ),
                                                const SizedBox(height: 18, child: VerticalDivider(thickness: 1, color: AppThemData.grey05)),
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: parkingModel.isEnable == true ? AppThemData.success07 : AppThemData.error07,
                                                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                                                  ),
                                                  child: Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                      child: Text(
                                                        parkingModel.isEnable == true ? "Open".tr : "Close".tr,
                                                        style: const TextStyle(fontSize: 12, color: AppThemData.white, fontFamily: AppThemData.medium),
                                                      )),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          separatorBuilder: (context, index) {
                            return const SizedBox(
                              height: 8,
                            );
                          },
                        ),
            ),
          );
        });
  }
}
