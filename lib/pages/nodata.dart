import 'package:flutter/material.dart';
import 'package:yourappname/utils/color.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/widget/mytext.dart';
import '../widget/myimage.dart';

class NoData extends StatelessWidget {
  final String text;
  const NoData({super.key, required this.text, required String subTitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.5,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: transparent,
        borderRadius: BorderRadius.circular(12),
        shape: BoxShape.rectangle,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          MyImage(
            height: 80,
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.contain,
            imagePath: "ic_mic.png",
          ),
          const SizedBox(height: 10),
          MyText(
            color: Theme.of(context).colorScheme.surface,
            text: "whoops",
            multilanguage: true,
            textalign: TextAlign.center,
            fontsize: Dimens.textlargeExtraBig,
            inter: 1,
            maxline: 1,
            fontwaight: FontWeight.w600,
            overflow: TextOverflow.ellipsis,
            fontstyle: FontStyle.normal,
          ),
          const SizedBox(height: 8),
          MyText(
            color: gray,
            text: text,
            textalign: TextAlign.center,
            fontsize: Dimens.textMedium,
            multilanguage: false,
            inter: 1,
            maxline: 1,
            fontwaight: FontWeight.w500,
            overflow: TextOverflow.ellipsis,
            fontstyle: FontStyle.normal,
          ),
        ],
      ),
    );
  }
}
