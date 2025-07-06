import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:owner/constant/constant.dart';
import 'package:owner/constant/show_toast_dialog.dart';
import 'package:owner/model/order_model.dart';
import 'package:owner/model/parking_model.dart';
import 'package:owner/model/wallet_transaction_model.dart';
import 'package:owner/utils/fire_store_utils.dart';

class MyParkingBookingController extends GetxController {
  RxBool isLoading = true.obs;

  Rx<ParkingModel> selectedParkingModel = ParkingModel().obs;
  RxList<ParkingModel> parkingList = <ParkingModel>[].obs;
  Rx<DateTime> selectedDateTime = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).obs;

  @override
  void onInit() {
    // TODO: implement onInit
    getData();
    super.onInit();
  }

  RxInt selectedTabIndex = 0.obs;

  getData() async {
    await FireStoreUtils.getMyParkingList().then((value) {
      if (value != null) {
        parkingList.value = value;
        if (parkingList.isNotEmpty) {
          selectedParkingModel.value = parkingList.first;
        }
        print("selectedParkingModel${selectedParkingModel.value.id}");
      }
    });
    isLoading.value = false;
    update();
  }

  confirmPayment(OrderModel orderModel) async {
    RxDouble couponAmount = 0.0.obs;
    ShowToastDialog.showLoader("Please wait..");
    if (orderModel.coupon != null) {
      if (orderModel.coupon!.id != null) {
        if (orderModel.coupon!.type == "fix") {
          couponAmount.value = double.parse(orderModel.coupon!.amount.toString());
        } else {
          couponAmount.value = double.parse(orderModel.subTotal.toString()) * double.parse(orderModel.coupon!.amount.toString()) / 100;
        }
      }
    }
    orderModel.paymentCompleted = true;

    orderModel.adminCommission = Constant.adminCommission;

    WalletTransactionModel adminCommissionWallet = WalletTransactionModel(
        id: Constant.getUuid(),
        amount:
            "-${Constant.calculateAdminCommission(amount: (double.parse(orderModel.subTotal.toString()) - double.parse(couponAmount.toString())).toString(), adminCommission: orderModel.adminCommission)}",
        createdDate: Timestamp.now(),
        paymentType: orderModel.paymentType.toString(),
        transactionId: orderModel.id,
        isCredit: false,
        userId: orderModel.parkingDetails!.userId.toString(),
        note: "Admin commission debited");

    await FireStoreUtils.setWalletTransaction(adminCommissionWallet).then((value) async {
      if (value == true) {
        await FireStoreUtils.updateUserWallet(
          amount:
              "-${Constant.calculateAdminCommission(amount: (double.parse(orderModel.subTotal.toString()) - double.parse(couponAmount.toString())).toString(), adminCommission: orderModel.adminCommission)}",
        );
      }
    });

    await FireStoreUtils.setOrder(orderModel).then((value) {
      if (value == true) {
        ShowToastDialog.closeLoader();
      }
    });
  }
}
