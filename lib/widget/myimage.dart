import 'package:flutter/material.dart';

// ignore: must_be_immutable
class MyImage extends StatelessWidget {
  double height;
  double width;
  String imagePath;
  Color? color;
  dynamic fit;
  bool? isAppIcon;

  MyImage(
      {super.key,
      required this.width,
      required this.height,
      required this.imagePath,
      this.color,
      this.isAppIcon,
      this.fit});

  @override
  Widget build(BuildContext context) {
    if (isAppIcon == true) {
      return Image.asset(
        "assets/appicon/$imagePath",
        height: height,
        color: color,
        width: width,
        fit: fit,
        errorBuilder: (context, url, error) {
          return Image.asset(
            "assets/images/no_image_port.png",
            width: width,
            height: height,
            fit: BoxFit.cover,
          );
        },
      );
    } else {
      return Image.asset(
        "assets/images/$imagePath",
        height: height,
        color: color,
        width: width,
        fit: fit,
        errorBuilder: (context, url, error) {
          return Image.asset(
            "assets/images/no_image_port.png",
            width: width,
            height: height,
            fit: BoxFit.cover,
          );
        },
      );
    }
  }
}
