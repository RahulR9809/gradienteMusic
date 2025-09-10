import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:yourappname/model/subscriptionmodel.dart';
import 'package:yourappname/pages/login.dart';
import 'package:yourappname/subscription/allpayment.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/pages/nodata.dart';
import 'package:yourappname/provider/subscriptionprovider.dart';
import 'package:yourappname/utils/color.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/utils/sharedpref.dart';
import 'package:yourappname/widget/myimage.dart';
import 'package:yourappname/widget/mytext.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

class Subscription extends StatefulWidget {
  final String openFrom;
  const Subscription({
    required this.openFrom,
    super.key,
  });

  @override
  State<Subscription> createState() => SubscriptionState();
}

class SubscriptionState extends State<Subscription> {
  late SubscriptionProvider subscriptionProvider;
  SharedPref sharedPre = SharedPref();
  String? userName, userEmail, userMobileNo, paymentId;
  CarouselSliderController pageController = CarouselSliderController();

  @override
  void initState() {
    subscriptionProvider =
        Provider.of<SubscriptionProvider>(context, listen: false);
    super.initState();
    _getData();
  }

  _getData() async {
    Utils.getCurrencySymbol();
    await subscriptionProvider.getPackages();
    await _getUserData();
    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    subscriptionProvider.clearProvider();
    super.dispose();
  }

  _checkAndPay(List<Result>? packageList, int index) async {
    if (Constant.userID != null) {
      for (var i = 0; i < (packageList?.length ?? 0); i++) {
        if (packageList?[i].isBuy == 1) {
          printLog("<============= Purchaged =============>");
          Utils.showSnackbar(context, "already_purchased", true);
          return;
        }
      }
      if (packageList?[index].isBuy == 0) {
        /* Update Required data for payment */
        if ((userName ?? "").isEmpty ||
            (userEmail ?? "").isEmpty ||
            (userMobileNo ?? "").isEmpty) {
          updateDataDialog(
            packageList,
            index,
            isNameReq: (userName ?? "").isEmpty,
            isEmailReq: (userEmail ?? "").isEmpty,
            isMobileReq: (userMobileNo ?? "").isEmpty,
          );
          return;
        }
        /* Update Required data for payment */

        await Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) {
              return AllPayment(
                payType: 'Package',
                itemId: packageList?[index].id.toString() ?? '',
                price: packageList?[index].price.toString() ?? '',
                itemTitle: packageList?[index].name.toString() ?? '',
                typeId: '',
                contentType: '',
                productPackage:
                    packageList?[index].androidProductPackage.toString() ?? '',
                currency: packageList?[index].type.toString() ?? '',
              );
            },
          ),
        );
      }
    } else {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return const Login();
          },
        ),
      );
    }
  }

  _getUserData() async {
    userName = await sharedPre.read("username");
    userEmail = await sharedPre.read("useremail");
    userMobileNo = await sharedPre.read("usermobile");
    printLog('getUserData userName ==> $userName');
    printLog('getUserData userEmail ==> $userEmail');
    printLog('getUserData userMobileNo ==> $userMobileNo');
  }

  updateDataDialog(List<Result>? packageList, int index,
      {required bool isNameReq,
      required bool isEmailReq,
      required bool isMobileReq}) async {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final mobileController = TextEditingController();
    if (!mounted) return;
    dynamic result = await showModalBottomSheet<dynamic>(
      context: context,
      backgroundColor: white,
      isScrollControlled: true,
      isDismissible: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (BuildContext context) {
        return Wrap(
          children: [
            Utils.dataUpdateDialog(
              context,
              isNameReq: isNameReq,
              isEmailReq: isEmailReq,
              isMobileReq: isMobileReq,
              nameController: nameController,
              emailController: emailController,
              mobileController: mobileController,
            ),
          ],
        );
      },
    );
    if (result != null) {
      await _getUserData();
      if ((userName ?? "").isNotEmpty &&
          (userEmail ?? "").isNotEmpty &&
          (userMobileNo ?? "").isNotEmpty) {
        _checkAndPay(packageList, index);
      }
      Future.delayed(Duration.zero).then((value) {
        if (!mounted) return;
        setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Scaffold(
        // backgroundColor: white,
        body: SingleChildScrollView(
          child: _buildSubscription(),
        ),
      );
    } else {
      return Scaffold(
        // backgroundColor: white,
        appBar: (widget.openFrom == 'player')
            ? Utils.myAppBarWithoutBack(context, "subsciption", true)
            : Utils.myAppBarWithBack(context, "subsciption", true),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: _buildSubscription(),
                ),
              ),
              /* Choose Plan */
              Container(
                margin: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: InkWell(
                  borderRadius: BorderRadius.circular(5),
                  onTap: () async {
                    printLog(
                        "purchasePos =========> ${subscriptionProvider.purchasePos}");
                    printLog(
                        "cPlanPosition =======> ${subscriptionProvider.cPlanPosition}");
                    if (subscriptionProvider.purchasePos != -1) {
                      Utils.showSnackbar(context, "already_purchased", true);
                      return;
                    }
                    if (subscriptionProvider.cPlanPosition == -1) {
                      Utils.showSnackbar(context, "select_sub_plan", true);
                      return;
                    }
                    _checkAndPay(subscriptionProvider.subscriptionModel.result,
                        subscriptionProvider.cPlanPosition);
                  },
                  child: Consumer<SubscriptionProvider>(
                    builder: (context, subscriptionProvider, child) {
                      return Container(
                        height: 45,
                        padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                        decoration: Utils.setBackground(
                            (subscriptionProvider.purchasePos == -1)
                                ? ((subscriptionProvider.cPlanPosition != -1)
                                    ? Colors.green
                                    : subscriptionBG)
                                : colorAccent,
                            6),
                        alignment: Alignment.center,
                        child: MyText(
                          color: (subscriptionProvider.purchasePos == -1)
                              ? ((subscriptionProvider.cPlanPosition != -1)
                                  ? white
                                  : gray)
                              : white,
                          text: (subscriptionProvider.purchasePos == -1)
                              ? ((subscriptionProvider.cPlanPosition != -1)
                                  ? "continue"
                                  : "chooseplan")
                              : "purchased",
                          textalign: TextAlign.center,
                          fontsize: Dimens.textMedium,
                          fontwaight: FontWeight.w700,
                          multilanguage: true,
                          maxline: 1,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildSubscription() {
    if (subscriptionProvider.loading) {
      return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.5,
        alignment: Alignment.center,
        child: Utils.pageLoader(),
      );
    } else {
      if (subscriptionProvider.subscriptionModel.status == 200) {
        return Column(
          children: [
            SizedBox(
                height: ((kIsWeb) && MediaQuery.of(context).size.width > 720)
                    ? 40
                    : 20),
            Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.only(left: 20, right: 20),
              alignment: Alignment.center,
              child: MyText(
                color: colorAccent,
                text: "subsciptionnotes",
                multilanguage: true,
                textalign: TextAlign.center,
                fontsize: Dimens.textTitle,
                maxline: 2,
                fontwaight: FontWeight.w600,
                overflow: TextOverflow.ellipsis,
                fontstyle: FontStyle.normal,
              ),
            ),
            SizedBox(
                height: ((kIsWeb) && MediaQuery.of(context).size.width > 720)
                    ? 40
                    : 20),

            /* Remaining Data */
            _buildItems(subscriptionProvider.subscriptionModel.result),
            const SizedBox(height: 20),
          ],
        );
      } else {
        return const NoData(text: "", subTitle: "");
      }
    }
  }

  Widget _buildItems(List<Result>? packageList) {
    if ((kIsWeb) && MediaQuery.of(context).size.width > 800) {
      return buildWebItem(packageList);
    } else {
      return buildMobileItem(packageList);
    }
  }

  Widget buildMobileItem(List<Result>? packageList) {
    if (packageList != null) {
      return Container(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: ResponsiveGridList(
          minItemWidth: MediaQuery.of(context).size.width,
          verticalGridSpacing: 15,
          horizontalGridSpacing: 6,
          minItemsPerRow: 1,
          maxItemsPerRow: 3,
          listViewBuilderOptions: ListViewBuilderOptions(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
          ),
          children: List.generate(
            (packageList.length),
            (index) {
              return Consumer<SubscriptionProvider>(
                builder: (context, subscriptionProvider, child) {
                  return Container(
                    decoration: Utils.setBGWithBorder(
                        (subscriptionProvider.purchasePos == -1)
                            ? ((subscriptionProvider.cPlanPosition == index)
                                ? Colors.green
                                : Theme.of(context).secondaryHeaderColor)
                            : ((subscriptionProvider.purchasePos == index)
                                ? Colors.green
                                : Theme.of(context).secondaryHeaderColor),
                        white,
                        6,
                        1),
                    child: InkWell(
                      onTap: () async {
                        printLog("Clicked on index =======> $index");
                        if (subscriptionProvider.purchasePos == -1) {
                          await subscriptionProvider.setCurrentPlan(index);
                        } else {
                          Utils.showSnackbar(
                              context, "already_purchased", true);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  MyText(
                                    color: (subscriptionProvider.purchasePos ==
                                            -1)
                                        ? (subscriptionProvider.cPlanPosition ==
                                                index
                                            ? white
                                            : colorPrimary)
                                        : ((subscriptionProvider.purchasePos ==
                                                index)
                                            ? white
                                            : colorPrimary),
                                    text: packageList[index].name ?? "",
                                    textalign: TextAlign.start,
                                    fontsize: Dimens.textlargeExtraBig,
                                    maxline: 1,
                                    multilanguage: false,
                                    overflow: TextOverflow.ellipsis,
                                    fontwaight: FontWeight.w700,
                                    fontstyle: FontStyle.normal,
                                  ),
                                  const SizedBox(height: 6),
                                  MyText(
                                    color: (subscriptionProvider.purchasePos ==
                                            -1)
                                        ? (subscriptionProvider.cPlanPosition ==
                                                index
                                            ? white
                                            : white)
                                        : ((subscriptionProvider.purchasePos ==
                                                index)
                                            ? white
                                            : white),
                                    text:
                                        "${Constant.currencySymbol}${packageList[index].price.toString()} / ${packageList[index].time.toString()} ${packageList[index].type.toString()}",
                                    textalign: TextAlign.start,
                                    fontsize: Dimens.textMedium,
                                    maxline: 1,
                                    multilanguage: false,
                                    overflow: TextOverflow.ellipsis,
                                    fontwaight: FontWeight.w700,
                                    fontstyle: FontStyle.normal,
                                  ),
                                ],
                              ),
                            ),
                            /* Tick Mark */
                            Container(
                              height: 24,
                              width: 24,
                              decoration: Utils.setBackground(
                                  (subscriptionProvider.purchasePos == -1)
                                      ? (subscriptionProvider.cPlanPosition ==
                                              index
                                          ? white
                                          : colorPrimary)
                                      : ((subscriptionProvider.purchasePos ==
                                              index)
                                          ? white
                                          : colorPrimary),
                                  20),
                              alignment: Alignment.center,
                              padding: const EdgeInsets.all(5),
                              child: MyImage(
                                imagePath: "ic_tick.png",
                                height: 12,
                                width: 12,
                                color: (subscriptionProvider.purchasePos == -1)
                                    ? (subscriptionProvider.cPlanPosition ==
                                            index
                                        ? colorPrimary
                                        : white)
                                    : ((subscriptionProvider.purchasePos ==
                                            index)
                                        ? colorPrimary
                                        : white),
                              ),
                            ),
                            const SizedBox(height: 15),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget buildWebItem(List<Result>? packageList) {
    if (packageList != null) {
      return Container(
        padding: const EdgeInsets.only(left: 30, right: 30, bottom: 15),
        child: ResponsiveGridList(
          minItemWidth: (MediaQuery.of(context).size.width > 720) ? 200 : 130,
          verticalGridSpacing: 8,
          horizontalGridSpacing: 6,
          minItemsPerRow: 1,
          maxItemsPerRow: 3,
          listViewBuilderOptions: ListViewBuilderOptions(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
          ),
          children: List.generate(
            (packageList.length),
            (index) {
              return Consumer<SubscriptionProvider>(
                builder: (context, subscriptionProvider, child) {
                  return Container(
                    decoration: Utils.setBGWithBorder(
                        (subscriptionProvider.purchasePos == -1)
                            ? ((subscriptionProvider.cPlanPosition == index)
                                ? colorPrimary
                                : subscriptionBG)
                            : ((subscriptionProvider.purchasePos == index)
                                ? colorPrimary
                                : subscriptionBG),
                        colorPrimary,
                        6,
                        1),
                    child: InkWell(
                      onTap: () async {
                        printLog("Clicked on index =======> $index");
                        if (subscriptionProvider.purchasePos == -1) {
                          await subscriptionProvider.setCurrentPlan(index);
                        } else {
                          Utils.showSnackbar(
                              context, "already_purchased", true);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  MyText(
                                    color: (subscriptionProvider.purchasePos ==
                                            -1)
                                        ? (subscriptionProvider.cPlanPosition ==
                                                index
                                            ? white
                                            : colorPrimary)
                                        : ((subscriptionProvider.purchasePos ==
                                                index)
                                            ? white
                                            : colorPrimary),
                                    text: packageList[index].name ?? "",
                                    textalign: TextAlign.start,
                                    fontsize: Dimens.textlargeExtraBig,
                                    maxline: 1,
                                    multilanguage: false,
                                    overflow: TextOverflow.ellipsis,
                                    fontwaight: FontWeight.w700,
                                    fontstyle: FontStyle.normal,
                                  ),
                                  const SizedBox(height: 6),
                                  MyText(
                                    color: (subscriptionProvider.purchasePos ==
                                            -1)
                                        ? (subscriptionProvider.cPlanPosition ==
                                                index
                                            ? white
                                            : colorPrimary)
                                        : ((subscriptionProvider.purchasePos ==
                                                index)
                                            ? white
                                            : colorPrimary),
                                    text:
                                        "${Constant.currencySymbol}${packageList[index].price.toString()} / ${packageList[index].time.toString()} ${packageList[index].type.toString()}",
                                    textalign: TextAlign.start,
                                    fontsize: Dimens.textMedium,
                                    maxline: 1,
                                    multilanguage: false,
                                    overflow: TextOverflow.ellipsis,
                                    fontwaight: FontWeight.w700,
                                    fontstyle: FontStyle.normal,
                                  ),
                                ],
                              ),
                            ),
                            /* Tick Mark */
                            Container(
                              height: 24,
                              width: 24,
                              decoration: Utils.setBackground(
                                  (subscriptionProvider.purchasePos == -1)
                                      ? (subscriptionProvider.cPlanPosition ==
                                              index
                                          ? white
                                          : colorPrimary)
                                      : ((subscriptionProvider.purchasePos ==
                                              index)
                                          ? white
                                          : colorPrimary),
                                  20),
                              alignment: Alignment.center,
                              padding: const EdgeInsets.all(5),
                              child: MyImage(
                                imagePath: "ic_tick.png",
                                height: 12,
                                width: 12,
                                color: (subscriptionProvider.purchasePos == -1)
                                    ? (subscriptionProvider.cPlanPosition ==
                                            index
                                        ? colorPrimary
                                        : white)
                                    : ((subscriptionProvider.purchasePos ==
                                            index)
                                        ? colorPrimary
                                        : white),
                              ),
                            ),
                            const SizedBox(height: 15),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
