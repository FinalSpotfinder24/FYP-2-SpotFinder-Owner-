import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:owner/controller/splash_controller.dart';
import 'package:owner/themes/app_them_data.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashController>(
        init: SplashController(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: AppThemData.primary06,
            body: Container(
              decoration: const BoxDecoration(image: DecorationImage(image: AssetImage("assets/images/splash_bg.png"), fit: BoxFit.fill)),
              child: Center(
                child: SvgPicture.asset("assets/images/ic_splash_logo.svg"),
              ),
            ),
          );
        });
  }
}
