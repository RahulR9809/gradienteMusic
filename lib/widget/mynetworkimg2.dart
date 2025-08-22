import 'package:flutter/material.dart';
import 'package:yourappname/widget/myimage.dart';

// ignore: must_be_immutable
class MyNetworkImg2 extends StatelessWidget {
  String imageUrl;
  double? imgHeight, imgWidth;
  dynamic fit;
  Color? color;

  MyNetworkImg2(
      {super.key,
      required this.imageUrl,
      required this.fit,
      this.color,
      this.imgHeight,
      this.imgWidth});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: imgHeight,
      width: imgWidth,
      child: Image.network(
        imageUrl,
        fit: fit,
        color: color,
        errorBuilder: (context, url, error) {
          return MyImage(
            width: imgWidth!,
            height: imgHeight!,
            imagePath: "no_image_port.png",
            fit: BoxFit.cover,
          );
        },
      ),
    );
  }
}
