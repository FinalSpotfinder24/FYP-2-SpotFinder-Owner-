import 'package:get/get.dart';
// import 'package:owner/ui/home/home_screen.dart';
// import 'package:owner/ui/my_booking/my_booking_screen.dart';
import 'package:owner/ui/parking_add/my_parking_booking_screen.dart';
// import 'package:owner/ui/parking_add/my_parking_booking_screen.dart';
import 'package:owner/ui/parking_add/my_parking_list.dart';
import 'package:owner/ui/profile/profile_screen.dart';
// import 'package:owner/ui/saved/saved_screen.dart';
import 'package:owner/ui/wallet/wallet_screen.dart';

class DashboardScreenController extends GetxController {
  RxInt selectedIndex = 0.obs;

  RxList pageList = [
    const MyParkingBooingScreen(isBack: false),
    const MyParkingList(isBack: false),
    const WalletScreen(isBack: false),
    const ProfileScreen(),
  ].obs;
}
