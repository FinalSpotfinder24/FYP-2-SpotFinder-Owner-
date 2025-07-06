import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:owner/constant/constant.dart';
import 'package:owner/controller/my_watchmen_list_controller.dart';
import 'package:owner/model/parking_model.dart';
import 'package:owner/model/user_model.dart';
import 'package:owner/themes/app_them_data.dart';
import 'package:owner/themes/common_ui.dart';
import 'package:owner/themes/responsive.dart';
import 'package:owner/themes/round_button_fill.dart';
import 'package:owner/ui/watchmen_screen/add_watchmen_details_screen.dart';
import 'package:owner/utils/dark_theme_provider.dart';
import 'package:owner/utils/fire_store_utils.dart';
import 'package:owner/utils/network_image_widget.dart';
import 'package:provider/provider.dart';

class MyWatchmenList extends StatelessWidget {
  final bool isBack;

  const MyWatchmenList({required this.isBack, super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: MyWatchmenListController(),
        builder: (controller) {
          return Scaffold(
            appBar: UiInterface().customAppBar(context, themeChange, 'My Watchman'.tr, isBack: isBack, actions: [
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 8, right: 8),
                child: RoundedButtonFill(
                  width: 30,
                  title: "Add Watchman".tr,
                  color: AppThemData.primary06,
                  onPress: () async {
                    Get.to(() => const AddWatchmenDetailsScreen(isEdit: false), arguments: '')?.then((value) {
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
                  : controller.watchmen.isEmpty
                      ? Constant.showEmptyView(message: "No watchmen added".tr)
                      : ListView.separated(
                          itemCount: controller.watchmen.length,
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemBuilder: (context, int index) {
                            UserModel watchmenData = controller.watchmen[index];
                            return InkWell(
                              onTap: () {
                                controller.isLoading.value = true;
                                Get.to(() => const AddWatchmenDetailsScreen(isEdit: true), arguments: watchmenData.id ?? '')?.then((value) {
                                  controller.getData();
                                });
                              },
                              child: Container(
                                height: Responsive.height(18, context),
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
                                        imageUrl: watchmenData.profilePic.toString(),
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
                                                    watchmenData.fullName.toString(),
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
                                              watchmenData.email.toString(),
                                              maxLines: 2,
                                              style: const TextStyle(color: AppThemData.grey07, fontSize: 12, fontFamily: AppThemData.regular, overflow: TextOverflow.ellipsis),
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            Text(
                                              "${watchmenData.countryCode} ${watchmenData.phoneNumber}",
                                              maxLines: 2,
                                              style: const TextStyle(color: AppThemData.grey07, fontSize: 12, fontFamily: AppThemData.regular, overflow: TextOverflow.ellipsis),
                                            ),
                                            const SizedBox(
                                              height: 8,
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  "Parking : ",
                                                  style: TextStyle(
                                                      color: themeChange.getThem() ? AppThemData.grey01 : AppThemData.grey07,
                                                      fontSize: 12,
                                                      fontFamily: AppThemData.bold,
                                                      overflow: TextOverflow.ellipsis),
                                                ),
                                                watchmenData.parkingId == null
                                                    ? Text(
                                                        "Parking Not assign",
                                                        style: TextStyle(
                                                            color: themeChange.getThem() ? AppThemData.grey01 : AppThemData.grey07,
                                                            fontSize: 12,
                                                            fontFamily: AppThemData.regular,
                                                            overflow: TextOverflow.ellipsis),
                                                      )
                                                    : FutureBuilder<ParkingModel?>(
                                                        future: FireStoreUtils.getParking(watchmenData.parkingId.toString()),
                                                        builder: (context, snapshot) {
                                                          switch (snapshot.connectionState) {
                                                            case ConnectionState.waiting:
                                                              return Container();
                                                            case ConnectionState.done:
                                                              if (snapshot.hasError) {
                                                                return Text(snapshot.error.toString());
                                                              } else {
                                                                ParkingModel parkingModel = snapshot.data!;
                                                                return Text(
                                                                  parkingModel.name.toString(),
                                                                  style: TextStyle(
                                                                      color: themeChange.getThem() ? AppThemData.grey01 : AppThemData.grey07,
                                                                      fontSize: 12,
                                                                      fontFamily: AppThemData.regular,
                                                                      overflow: TextOverflow.ellipsis),
                                                                );
                                                              }
                                                            default:
                                                              return Text('Error'.tr);
                                                          }
                                                        }),
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  "${Constant.amountShow(amount: watchmenData.salary.toString())}/month".tr,
                                                  style: const TextStyle(
                                                    color: AppThemData.blueLight07,
                                                    fontSize: 12,
                                                    fontFamily: AppThemData.semiBold,
                                                  ),
                                                ),
                                                const SizedBox(height: 18, child: VerticalDivider(thickness: 1, color: AppThemData.grey05)),
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: watchmenData.isActive == true ? AppThemData.success07 : AppThemData.error07,
                                                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                                                  ),
                                                  child: Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                      child: Text(
                                                        watchmenData.isActive == true ? "Active".tr : "Disable".tr,
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
