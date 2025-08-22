import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yourappname/utils/color.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/widget/myimage.dart';
import 'package:yourappname/widget/mytext.dart';

class MyAppbar extends StatelessWidget {
  final dynamic onBack;
  final String? icon, title;
  final int isSimpleappbar;
  final bool? isMultiLang;

  const MyAppbar({
    super.key,
    this.onBack,
    this.icon,
    this.title,
    this.isMultiLang,
    required this.isSimpleappbar,
  });

  @override
  Widget build(BuildContext context) {
    return appBar(context);
  }

  Widget appBar(BuildContext context) {
    if (isSimpleappbar == 1) {
      return Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorPrimary,
              colorPrimary,
            ],
            end: Alignment.bottomLeft,
            begin: Alignment.topRight,
          ),
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25)),
        ),
        child: Stack(
          children: [
            Column(
              children: [
                // Category AppBar With BackButton
                AppBar(
                  backgroundColor: transparent,
                  elevation: 0,
                  automaticallyImplyLeading: false,
                  titleSpacing: 10,
                  scrolledUnderElevation: 0,
                  surfaceTintColor: transparent,
                  systemOverlayStyle:
                      const SystemUiOverlayStyle(statusBarColor: colorPrimary),
                  leading: InkWell(
                    onTap: onBack,
                    child: MyImage(
                        width: 15, height: 15, imagePath: icon.toString()),
                  ),
                  title: MyText(
                    color: white,
                    text: title.toString(),
                    textalign: TextAlign.center,
                    fontsize: Dimens.textlargeExtraBig,
                    inter: 1,
                    multilanguage:
                        (isMultiLang != null && (isMultiLang ?? true))
                            ? true
                            : false,
                    maxline: 1,
                    fontwaight: FontWeight.w500,
                    overflow: TextOverflow.ellipsis,
                    fontstyle: FontStyle.normal,
                  ),
                  centerTitle: true,
                ),
              ],
            ),
          ],
        ),
      );
    } else if (isSimpleappbar == 2) {
      return Column(
        children: [
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.25,
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorPrimary,
                  colorPrimary,
                ],
                end: Alignment.bottomLeft,
                begin: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25)),
            ),
            child: Column(
              children: [
                AppBar(
                  backgroundColor: transparent,
                  elevation: 0,
                  titleSpacing: 0,
                  automaticallyImplyLeading: false,
                  leading: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child:
                        MyImage(width: 15, height: 15, imagePath: "back.png"),
                  ),
                  title: MyText(
                    color: white,
                    text: title.toString(),
                    textalign: TextAlign.center,
                    fontsize: Dimens.textlargeExtraBig,
                    inter: 1,
                    maxline: 2,
                    multilanguage:
                        (isMultiLang != null && (isMultiLang ?? true))
                            ? true
                            : false,
                    fontwaight: FontWeight.w500,
                    overflow: TextOverflow.ellipsis,
                    fontstyle: FontStyle.normal,
                  ),
                  centerTitle: true,
                ),
              ],
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.060,
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
            // color: colorAccent,
          )
        ],
      );
    } else {
      return Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorPrimary,
              colorPrimary,
            ],
            end: Alignment.bottomLeft,
            begin: Alignment.topRight,
          ),
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25)),
        ),
        child: Stack(
          children: [
            Column(
              children: [
                // Category AppBar With BackButton
                AppBar(
                  backgroundColor: transparent,
                  elevation: 0,
                  automaticallyImplyLeading: false,
                  titleSpacing: 0,
                  leadingWidth: 0,
                  title: Container(
                    alignment: Alignment.center,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            MyText(
                                color: white,
                                text: title.toString(),
                                textalign: TextAlign.center,
                                fontsize: Dimens.textlargeExtraBig,
                                inter: 1,
                                maxline: 1,
                                fontwaight: FontWeight.w500,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal),
                            const SizedBox(width: 5),
                            MyText(
                                color: white,
                                text: "radio",
                                textalign: TextAlign.center,
                                fontsize: Dimens.textlargeExtraBig,
                                inter: 1,
                                multilanguage: true,
                                maxline: 1,
                                fontwaight: FontWeight.w500,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal),
                          ],
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: InkWell(
                            onTap: onBack,
                            child: MyImage(
                                width: 60,
                                height: 60,
                                imagePath: icon.toString()),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
  }
}
