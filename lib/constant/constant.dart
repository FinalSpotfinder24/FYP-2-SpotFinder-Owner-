import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:owner/model/admin_commission.dart';
import 'package:owner/model/currency_model.dart';
import 'package:owner/model/language_model.dart';
import 'package:owner/model/location_lat_lng.dart';
import 'package:owner/model/tax_model.dart';
import 'package:owner/themes/app_them_data.dart';
import 'package:owner/utils/preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

class Constant {
  static const String phoneLoginType = "phone";
  static const String googleLoginType = "google";
  static const String appleLoginType = "apple";
  static const String roleType = "owner";

  static String mapAPIKey = "";
  static String senderId = '';
  static String jsonNotificationFileURL = '';
  static String radius = "";
  static String distanceType = "";

  static String termsAndConditions = "";
  static String privacyPolicy = "";
  static String supportURL = "";
  static String minimumAmountToDeposit = "0";
  static String minimumAmountToWithdrawal = "0";
  static String? referralAmount = "0";
  static String? mapType = "";
  static String selectedMapType = 'osm';

  static LocationLatLng? currentLocation = LocationLatLng(latitude: 23.0225, longitude: 72.5714);
  static List<TaxModel>? taxList;
  static String? country;
  static AdminCommission? adminCommission;

  static CurrencyModel? currencyModel;

  static const String placed = "placed";
  static const String onGoing = "onGoing";
  static const String completed = "completed";
  static const String canceled = "canceled";

  static const globalUrl = "https://foodie.siswebapp.com/";

  static String amountShow({required String? amount}) {
    if (Constant.currencyModel!.symbolAtRight == true) {
      return "${double.parse(amount.toString()).toStringAsFixed(Constant.currencyModel!.decimalDigits!)}${Constant.currencyModel!.symbol.toString()}";
    } else {
      return "${Constant.currencyModel!.symbol.toString()}${double.parse(amount.toString()).toStringAsFixed(Constant.currencyModel!.decimalDigits!)}";
    }
  }

  double calculateTax({String? amount, TaxModel? taxModel}) {
    double taxAmount = 0.0;
    if (taxModel != null && taxModel.enable == true) {
      if (taxModel.type == "fix") {
        taxAmount = double.parse(taxModel.tax.toString());
      } else {
        taxAmount = (double.parse(amount.toString()) * double.parse(taxModel.tax!.toString())) / 100;
      }
    }
    return taxAmount;
  }

  static String calculateReview({required String? reviewCount, required String? reviewSum}) {
    if (reviewCount == "0.0" && reviewSum == "0.0") {
      return "0.0";
    }
    return (double.parse(reviewSum.toString()) / double.parse(reviewCount.toString())).toStringAsFixed(1);
  }

  static const userPlaceHolder = 'assets/images/user_placeholder.png';

  static String getUuid() {
    return const Uuid().v4();
  }

  static Widget loader() {
    return const Center(
      child: CircularProgressIndicator(color: AppThemData.primary09),
    );
  }

  static Widget showEmptyView({required String message}) {
    return Center(
      child: Text(message, style: const TextStyle(fontFamily: AppThemData.medium, fontSize: 18)),
    );
  }

  static String getReferralCode() {
    var rng = math.Random();
    return (rng.nextInt(900000) + 100000).toString();
  }

  static LanguageModel getLanguage() {
    final String user = Preferences.getString(Preferences.languageCodeKey);
    Map<String, dynamic> userMap = jsonDecode(user);
    log(userMap.toString());
    return LanguageModel.fromJson(userMap);
  }

  String? validateRequired(String? value, String type) {
    if (value!.isEmpty) {
      return '$type required';
    }
    return null;
  }

  String? validateEmail(String? value) {
    String pattern = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = RegExp(pattern);
    if (value == null || value.isEmpty) {
      return "Email is Required";
    } else if (!regExp.hasMatch(value)) {
      return "Invalid Email";
    } else {
      return null;
    }
  }

  bool hasValidUrl(String value) {
    String pattern = r'(http|https)://[\w-]+(\.[\w-]+)+([\w.,@?^=%&amp;:/~+#-]*[\w@?^=%&amp;/~+#-])?';
    RegExp regExp = RegExp(pattern);
    if (value.isEmpty) {
      return false;
    } else if (!regExp.hasMatch(value)) {
      return false;
    }
    return true;
  }

  static Future<String> uploadUserImageToFireStorage(File image, String filePath, String fileName) async {
    Reference upload = FirebaseStorage.instance.ref().child('$filePath/$fileName');
    UploadTask uploadTask = upload.putFile(image);
    var downloadUrl = await (await uploadTask.whenComplete(() {})).ref.getDownloadURL();
    return downloadUrl.toString();
  }

  static Future<void> makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  launchURL(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }

  // static Future<MapModel?> getDurationDistance(
  //     LatLng departureLatLong, LatLng destinationLatLong) async {
  //   String url = 'https://maps.googleapis.com/maps/api/distancematrix/json';
  //   http.Response restaurantToCustomerTime = await http.get(Uri.parse(
  //       '$url?units=metric&origins=${departureLatLong.latitude},'
  //       '${departureLatLong.longitude}&destinations=${destinationLatLong.latitude},${destinationLatLong.longitude}&key=${Constant.mapAPIKey}'));

  //   log(restaurantToCustomerTime.body.toString());
  //   MapModel mapModel =
  //       MapModel.fromJson(jsonDecode(restaurantToCustomerTime.body));

  //   if (mapModel.status == 'OK' &&
  //       mapModel.rows!.first.elements!.first.status == "OK") {
  //     return mapModel;
  //   } else {
  //     ShowToastDialog.showToast(mapModel.errorMessage);
  //   }
  //   return null;
  // }

  static Future<TimeOfDay?> selectTime(context) async {
    FocusScope.of(context).requestFocus(FocusNode()); //remove focus
    TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (newTime != null) {
      return newTime;
    }
    return null;
  }

  static Future<DateTime?> selectDate(context) async {
    DateTime? pickedDate = await showDatePicker(
        context: context,
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: AppThemData.primary06, // header background color
                onPrimary: AppThemData.grey11, // header text color
                onSurface: AppThemData.grey11, // body text color
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: AppThemData.grey11, // button text color
                ),
              ),
            ),
            child: child!,
          );
        },
        initialDate: DateTime.now(),
        //get today's date
        firstDate: DateTime(1900),
        //DateTime.now() - not to allow to choose before today.
        lastDate: DateTime(2101));
    return pickedDate;
  }

  static String timestampToDate(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('MMM dd,yyyy').format(dateTime);
  }

  static String timestampToTime(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('HH:mm aa').format(dateTime);
  }

  static String timestampToDateChat(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('dd/MM/yyyy').format(dateTime);
  }

  static double calculateAdminCommission({String? amount, AdminCommission? adminCommission}) {
    double taxAmount = 0.0;
    if (adminCommission != null && adminCommission.enable == true) {
      if (adminCommission.type == "fix") {
        taxAmount = double.parse(adminCommission.amount.toString());
      } else {
        taxAmount = (double.parse(amount.toString()) * double.parse(adminCommission.amount!.toString())) / 100;
      }
    }
    return taxAmount;
  }

//   static String? googleMapStyle = '''
//     [
// {
//     "elementType": "labels.icon",
//     "stylers": [
//       {
//         "visibility": "on",
//         "color": "#4448AE"
//       }
//     ]
//   },
//    {
//     "elementType": "geometry",
//     "stylers": [
//       {
//         "color": "#F3F6FF"
//       }
//     ]
//   },
//   {
//     "featureType": "road",
//     "elementType": "geometry",
//     "stylers": [
//       {
//         "color": "#E9ECFD"
//       }
//     ]
//   },
//   {
//     "featureType": "water",
//     "elementType": "labels.text.fill",
//     "stylers": [
//       {
//         "color": "#9e9e9e"
//       }
//     ]
//   },{
//     "featureType": "water",
//     "elementType": "geometry",
//     "stylers": [
//       {
//         "color": "#87CEEB"
//       }
//     ]
//   },
//    {
//     "featureType": "transit.line",
//     "elementType": "geometry",
//     "stylers": [
//       {
//         "color": "#e5e5e5"
//       }
//     ]
//   },
//   {
//     "featureType": "transit.station",
//     "elementType": "geometry",
//     "stylers": [
//       {
//         "color": "#eeeeee"
//       }
//     ]
//   }
//   ],
//     ''';
}
