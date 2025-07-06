import 'package:get/get.dart';
import 'package:owner/model/parking_model.dart';
import 'package:owner/utils/fire_store_utils.dart';

class MyParkingListController extends GetxController {
  RxBool isLoading = true.obs;
  RxList<ParkingModel> parkingList = <ParkingModel>[].obs;

  getData() async {
    await FireStoreUtils.getMyParkingList().then((value) {
      if (value != null) {
        parkingList.value = value;
      }
    });
    isLoading.value = false;
  }

  @override
  void onInit() {
    getData();
    super.onInit();
  }
}
