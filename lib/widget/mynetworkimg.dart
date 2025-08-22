import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:yourappname/widget/myimage.dart';

// ignore: must_be_immutable
class MyNetworkImage extends StatelessWidget {
  String imageUrl;
  double? imgHeight, imgWidth;
  dynamic fit;
  Color? color;

  MyNetworkImage(
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
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: fit,
        imageBuilder: (context, imageProvider) => Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: imageProvider,
              fit: fit,
            ),
          ),
        ),
        placeholder: (context, url) {
          return MyImage(
            width: imgWidth ?? 0.0,
            height: imgHeight ?? 0.0,
            imagePath: "no_image_land.png",
            fit: BoxFit.cover,
          );
        },
        errorWidget: (context, url, error) {
          return MyImage(
            width: imgWidth ?? 0.0,
            height: imgHeight ?? 0.0,
            imagePath: "no_image_land.png",
            fit: BoxFit.cover,
          );
        },
      ),
    );
  }
}
