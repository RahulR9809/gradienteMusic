import 'package:flutter/material.dart';
import 'package:yourappname/pages/selectlanguage.dart';
import 'package:yourappname/utils/color.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/utils/sharedpref.dart';
import 'package:yourappname/widget/mynetworkimg.dart';
import 'package:yourappname/widget/mytext.dart';
import 'package:yourappname/model/introscreenmodel.dart';

class Intro extends StatefulWidget {
  final List<Result>? introList;
  const Intro({super.key, required this.introList});

  @override
  State<Intro> createState() => _IntroState();
}

class _IntroState extends State<Intro> {
  SharedPref sharedPre = SharedPref();
  PageController pageController = PageController();
  int position = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: Stack(
          children: [
            Column(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: PageView.builder(
                    itemCount: widget.introList?.length ?? 0,
                    controller: pageController,
                    itemBuilder: (BuildContext context, int index) {
                      return Column(
                        children: [
                          MyNetworkImage(
                            fit: BoxFit.cover,
                            imageUrl:
                                widget.introList?[index].image.toString() ?? "",
                            imgWidth: MediaQuery.of(context).size.width,
                            imgHeight:
                                MediaQuery.of(context).size.height * 0.55,
                          ),
                          MyText(
                              color: colorAccent,
                              text: widget.introList?[index].title.toString() ??
                                  "",
                              textalign: TextAlign.center,
                              fontsize: Dimens.textlargeBig,
                              inter: 1,
                              maxline: 5,
                              multilanguage: false,
                              fontwaight: FontWeight.w300,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal),
                        ],
                      );
                    },
                    onPageChanged: (value) {
                      position = value;
                      setState(() {});
                    },
                  ),
                ),
              ],
            ),
            Positioned.fill(
              bottom: 80,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: InkWell(
                  onTap: () async {
                    if (position == (widget.introList?.length ?? 0) - 1) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return const SelectLanguage();
                          },
                        ),
                      );
                    } else {
                      pageController.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeIn);
                    }
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.07,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: colorPrimary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: MyText(
                        color: white,
                        text: "getstart",
                        fontsize: Dimens.textTitle,
                        multilanguage: true,
                        fontwaight: FontWeight.w500,
                        maxline: 1,
                        overflow: TextOverflow.ellipsis,
                        inter: 1,
                        textalign: TextAlign.center,
                        fontstyle: FontStyle.normal),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              bottom: 30,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: InkWell(
                  onTap: () async {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return const SelectLanguage();
                        },
                      ),
                    );
                  },
                  child: MyText(
                      color: black,
                      text: position == (widget.introList?.length ?? 0) - 1
                          ? "finish"
                          : "skip",
                      textalign: TextAlign.center,
                      fontsize: Dimens.textTitle,
                      multilanguage: true,
                      inter: 1,
                      fontwaight: FontWeight.w300,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
