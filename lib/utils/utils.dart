import 'dart:io';
import 'dart:math' as number;
import 'package:email_validator/email_validator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradient_borders/gradient_borders.dart';
import 'package:intl/intl.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';
import 'package:yourappname/pages/login.dart';
import 'package:yourappname/music/musicdetails.dart';
import 'package:yourappname/players/player_video.dart';
import 'package:yourappname/players/player_vimeo.dart';
import 'package:yourappname/players/player_youtube.dart';
import 'package:yourappname/provider/updateprofileprovider.dart';
import 'package:yourappname/subscription/subscription.dart';
import 'package:yourappname/utils/adhelper.dart';
import 'package:yourappname/utils/color.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/utils/sharedpref.dart';
import 'package:yourappname/widget/myimage.dart';
import 'package:yourappname/widget/mytext.dart';
import 'package:screen_protector/screen_protector.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

printLog(String message) {
  if (kDebugMode) {
    return print(message);
  }
}

class Utils {
  ProgressDialog? prDialog;
  static void enableScreenCapture() async {
    await ScreenProtector.preventScreenshotOn();
    if (Platform.isIOS) {
      await ScreenProtector.protectDataLeakageWithBlur();
    } else if (Platform.isAndroid) {
      await ScreenProtector.protectDataLeakageOn();
    }
  }

  /* Update Required profile data before Payment START ************************/
  static Widget dataUpdateDialog(
    BuildContext context, {
    required bool isNameReq,
    required bool isEmailReq,
    required bool isMobileReq,
    required TextEditingController nameController,
    required TextEditingController emailController,
    required TextEditingController mobileController,
  }) {
    return AnimatedPadding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      duration: const Duration(milliseconds: 100),
      curve: Curves.decelerate,
      child: Container(
        padding: const EdgeInsets.all(23),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /* Title & Subtitle */
            Container(
              alignment: Alignment.centerLeft,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyText(
                    color: black,
                    text: "update_profile",
                    multilanguage: true,
                    textalign: TextAlign.start,
                    fontsize: Dimens.textTitle,
                    fontwaight: FontWeight.w700,
                    maxline: 1,
                    overflow: TextOverflow.ellipsis,
                    fontstyle: FontStyle.normal,
                  ),
                  const SizedBox(height: 3),
                  MyText(
                    color: lightgray,
                    text: "update_profile_desc",
                    multilanguage: true,
                    textalign: TextAlign.start,
                    fontsize: Dimens.textMedium,
                    fontwaight: FontWeight.w500,
                    maxline: 3,
                    overflow: TextOverflow.ellipsis,
                    fontstyle: FontStyle.normal,
                  )
                ],
              ),
            ),

            /* Fullname */
            const SizedBox(height: 30),
            if (isNameReq)
              _buildTextFormField(
                controller: nameController,
                hintText: "full_name",
                inputType: TextInputType.name,
                readOnly: false,
              ),

            /* Email */
            if (isEmailReq)
              _buildTextFormField(
                controller: emailController,
                hintText: "email_address",
                inputType: TextInputType.emailAddress,
                readOnly: false,
              ),

            /* Mobile */
            if (isMobileReq)
              _buildTextFormField(
                controller: mobileController,
                hintText: "mobile_number",
                inputType: const TextInputType.numberWithOptions(
                    signed: false, decimal: false),
                readOnly: false,
              ),
            const SizedBox(height: 5),

            /* Cancel & Update Buttons */
            Container(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  /* Cancel */
                  InkWell(
                    onTap: () {
                      final profileEditProvider =
                          Provider.of<UpdateProfileProvider>(context,
                              listen: false);
                      if (!profileEditProvider.loadingUpdate) {
                        Navigator.pop(context, false);
                      }
                    },
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 75),
                      height: 50,
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: lightgray,
                          width: .5,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: MyText(
                        color: lightgray,
                        text: "Cancel",
                        multilanguage: false,
                        textalign: TextAlign.center,
                        fontsize: Dimens.textTitle,
                        maxline: 1,
                        overflow: TextOverflow.ellipsis,
                        fontwaight: FontWeight.w500,
                        fontstyle: FontStyle.normal,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),

                  /* Submit */
                  Consumer<UpdateProfileProvider>(
                    builder: (context, updateProfileProvider, child) {
                      if (updateProfileProvider.loadingUpdate) {
                        return Container(
                          width: 100,
                          height: 50,
                          padding: const EdgeInsets.fromLTRB(10, 3, 10, 3),
                          alignment: Alignment.center,
                          child: pageLoader(),
                        );
                      }
                      return InkWell(
                        onTap: () async {
                          SharedPref sharedPref = SharedPref();
                          final fullName =
                              nameController.text.toString().trim();
                          final emailAddress =
                              emailController.text.toString().trim();
                          final mobileNumber =
                              mobileController.text.toString().trim();

                          printLog(
                              "fullName =======> $fullName ; required ========> $isNameReq");
                          printLog(
                              "emailAddress ===> $emailAddress ; required ====> $isEmailReq");
                          printLog(
                              "mobileNumber ===> $mobileNumber ; required ====> $isMobileReq");
                          if (isNameReq && fullName.isEmpty) {
                            Utils.showSnackbar(
                                context, "Enter your name", true);
                          } else if (isEmailReq && emailAddress.isEmpty) {
                            showToast("Enter email");
                          } else if (isMobileReq && mobileNumber.isEmpty) {
                            Utils.showSnackbar(
                                context, "Enter mobile number", true);
                          } else if (isEmailReq &&
                              !EmailValidator.validate(emailAddress)) {
                            Utils.showSnackbar(
                                context, "Enter valid email", true);
                          } else {
                            final profileEditProvider =
                                Provider.of<UpdateProfileProvider>(context,
                                    listen: false);
                            await profileEditProvider.setUpdateLoading(true);

                            await profileEditProvider.getUpdateDataForPayment(
                                fullName, emailAddress, mobileNumber);
                            if (!profileEditProvider.loadingUpdate) {
                              await profileEditProvider.setUpdateLoading(false);
                              if (profileEditProvider
                                      .updateprofileModel.status ==
                                  200) {
                                if (isNameReq) {
                                  await sharedPref.save('username', fullName);
                                }
                                if (isEmailReq) {
                                  await sharedPref.save(
                                      'useremail', emailAddress);
                                }
                                if (isMobileReq) {
                                  await sharedPref.save(
                                      'usermobile', mobileNumber);
                                }
                                if (context.mounted) {
                                  Navigator.pop(context, true);
                                }
                              }
                            }
                          }
                        },
                        child: Container(
                          constraints: const BoxConstraints(minWidth: 75),
                          height: 50,
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: colorPrimary,
                            borderRadius: BorderRadius.circular(5),
                            shape: BoxShape.rectangle,
                          ),
                          child: MyText(
                            color: black,
                            text: "Submit",
                            textalign: TextAlign.center,
                            fontsize: Dimens.textTitle,
                            multilanguage: false,
                            maxline: 1,
                            overflow: TextOverflow.ellipsis,
                            fontwaight: FontWeight.w700,
                            fontstyle: FontStyle.normal,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildTextFormField({
    required TextEditingController controller,
    required String hintText,
    required TextInputType inputType,
    required bool readOnly,
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: 45),
      margin: const EdgeInsets.only(bottom: 25),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        textInputAction: TextInputAction.next,
        obscureText: false,
        maxLines: 1,
        readOnly: readOnly,
        cursorColor: colorAccent,
        cursorRadius: const Radius.circular(2),
        decoration: InputDecoration(
          filled: true,
          isDense: false,
          fillColor: transparent,
          focusedBorder: const GradientOutlineInputBorder(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [colorPrimary, colorPrimary],
            ),
            width: 1,
          ),
          border: GradientOutlineInputBorder(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                colorPrimary.withValues(alpha: 0.5),
                colorPrimary.withValues(alpha: 0.5)
              ],
            ),
            width: 1,
          ),
          label: MyText(
            multilanguage: true,
            color: lightgray,
            text: hintText,
            textalign: TextAlign.start,
            fontstyle: FontStyle.normal,
            fontsize: Dimens.textMedium,
            fontwaight: FontWeight.w600,
          ),
        ),
        textAlign: TextAlign.start,
        textAlignVertical: TextAlignVertical.center,
        style: GoogleFonts.inter(
          textStyle: const TextStyle(
            fontSize: 14,
            color: black,
            fontWeight: FontWeight.w600,
            fontStyle: FontStyle.normal,
          ),
        ),
      ),
    );
  }

  /* *********************** Update Required profile data before Payment END */

  static Future<void> playAudio(
    BuildContext context,
    String type,
    int isPremium,
    int isBuy,
    String imgurl,
    String title,
    String songFrom,
    String audiourl,
    String albumn,
    String discription,
    String audioid,
    String podcastid,
    int position,
    List audioList,
  ) async {
    printLog("audiourl ==========> $audiourl");
    printLog("songFrom ==========> $songFrom");
    printLog("audioID ==========[[[[[[[[[[[]]]]]]]]]]]> $audioid");
    printLog("albumn ============> $albumn");
    printLog("isPremium =========> $isPremium");
    printLog("isBuy =============> $isBuy");
    printLog("audioList =========> ${audioList.length}");
    SharedPref sharedPref = SharedPref();
await sharedPref.save("current_audio_id", audioid);
    if (type == "radio") {
      if (isPremium == 1) {
        if (Constant.userID != null) {
          if (isBuy == 1) {
            musicManager.setInitialPlaylist(
                position, songFrom, albumn, audioList, type);
          } else {
            AdHelper.showFullscreenAd(context, Constant.interstialAdType, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return const Subscription(openFrom: '');
                  },
                ),
              );
            });
          }
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return const Login();
              },
            ),
          );
        }
      } else {
        AdHelper.showFullscreenAd(context, Constant.interstialAdType, () {
          musicManager.setInitialPlaylist(
              position, songFrom, albumn, audioList, type);
        });
      }
    } else {
      if (isPremium == 1) {
        if (Constant.userID != null) {
          if (isBuy == 1) {
            musicManager.setInitialPodcast(
                position, songFrom, albumn, audioList, podcastid, type);
          } else {
            AdHelper.showFullscreenAd(context, Constant.interstialAdType, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return const Subscription(openFrom: '');
                  },
                ),
              );
            });
          }
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return const Login();
              },
            ),
          );
        }
      } else {
        AdHelper.showFullscreenAd(context, Constant.interstialAdType, () {
          musicManager.setInitialPodcast(
              position, songFrom, albumn, audioList, podcastid, type);
        });
      }
    }
  }

  static BoxDecoration setBackground(Color color, double radius) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      shape: BoxShape.rectangle,
    );
  }

  static Widget showBannerAd(BuildContext context) {
    if (!kIsWeb) {
      return Container(
        constraints: BoxConstraints(
          minHeight: 0,
          minWidth: 0,
          maxWidth: MediaQuery.of(context).size.width,
        ),
        child: AdHelper.bannerAd(context),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  static loadAds(BuildContext context) async {
    bool? isPremiumBuy = await Utils.checkPremiumUser();
    printLog("loadAds isPremiumBuy :==> $isPremiumBuy");
    if (context.mounted) {
      AdHelper.getAds(context);
    }
    if (!kIsWeb && !isPremiumBuy) {
      AdHelper.createInterstitialAd();
      AdHelper.createRewardedAd();
    }
  }

  static dateformat(DateTime date) {
    String formattedDate = DateFormat('EEE, d MMM').format(date);
    return formattedDate;
  }

  // FontFamily All app Text
  static TextStyle googleFontStyle(int inter, double fontsize,
      FontStyle fontstyle, Color color, FontWeight fontwaight) {
    if (inter == 1) {
      return GoogleFonts.poppins(
          fontSize: fontsize,
          fontStyle: fontstyle,
          color: color,
          fontWeight: fontwaight);
    } else if (inter == 2) {
      return GoogleFonts.lobster(
          fontSize: fontsize,
          fontStyle: fontstyle,
          color: color,
          fontWeight: fontwaight);
    } else if (inter == 3) {
      return GoogleFonts.rubik(
          fontSize: fontsize,
          fontStyle: fontstyle,
          color: color,
          fontWeight: fontwaight);
    } else {
      return GoogleFonts.inter(
          fontSize: fontsize,
          fontStyle: fontstyle,
          color: color,
          fontWeight: fontwaight);
    }
  }

  static saveUserCreds({
    required userID,
    required userName,
    required userEmail,
    required userMobile,
    required usercountryname,
    required usercountrycode,
    required userImage,
    required userPremium,
    required userType,
  }) async {
    SharedPref sharedPref = SharedPref();
    if (userID != null) {
      await sharedPref.save("userid", userID);
      await sharedPref.save("username", userName);
      await sharedPref.save("useremail", userEmail);
      await sharedPref.save("usermobile", userMobile);
      await sharedPref.save("usercountryname", usercountryname);
      await sharedPref.save("usercountrycode", usercountrycode);
      await sharedPref.save("userimage", userImage);
      await sharedPref.save("userpremium", userPremium);
      await sharedPref.save("usertype", userType);
    } else {
      await sharedPref.remove("userid");
      await sharedPref.remove("username");
      await sharedPref.remove("userimage");
      await sharedPref.remove("useremail");
      await sharedPref.remove("usermobile");
      await sharedPref.remove("usercountryname");
      await sharedPref.remove("usercountrycode");
      await sharedPref.remove("userpremium");
      await sharedPref.remove("usertype");
    }
    Constant.userID = await sharedPref.read("userid");
    Constant.userImage = await sharedPref.read("userimage");
    printLog('setUserId userID ==> ${Constant.userID}');
  }

  static Future<bool> checkPremiumUser() async {
    SharedPref sharedPre = SharedPref();
    String? isPremiumBuy = await sharedPre.read("userpremium");
    printLog('checkPremiumUser isPremiumBuy ==> $isPremiumBuy');
    if (isPremiumBuy != null && isPremiumBuy == "1") {
      return true;
    } else {
      return false;
    }
  }

  static void updatePremium(String isPremiumBuy) async {
    printLog('updatePremium isPremiumBuy ==> $isPremiumBuy');
    SharedPref sharedPre = SharedPref();
    await sharedPre.save("userpremium", isPremiumBuy);
    String? isPremium = await sharedPre.read("userpremium");
    printLog('updatePremium ===============> $isPremium');
  }

  static setUserId(userID) async {
    SharedPref sharedPref = SharedPref();
    if (userID != null) {
      await sharedPref.save("userid", userID);
    } else {
      await sharedPref.remove("userid");
      await sharedPref.remove("username");
      await sharedPref.remove("userimage");
      await sharedPref.remove("useremail");
      await sharedPref.remove("usermobile");
      await sharedPref.remove("usercountryname");
      await sharedPref.remove("usercountrycode");
      await sharedPref.remove("userpremium");
      await sharedPref.remove("usertype");
    }
    Constant.userID = await sharedPref.read("userid");
    printLog('setUserId userID ==> ${Constant.userID}');
  }

  static void getCurrencySymbol() async {
    SharedPref sharedPref = SharedPref();
    Constant.currencySymbol = await sharedPref.read("currency_code") ?? "";
    printLog('Constant currencySymbol ==> ${Constant.currencySymbol}');
    Constant.currency = await sharedPref.read("currency") ?? "";
    printLog('Constant currency ==> ${Constant.currency}');
  }

  static AppBar myAppBarWithBack(
      BuildContext context, String appBarTitle, bool multilanguage) {
    return AppBar(
      elevation: 5,
      backgroundColor: colorPrimary,
      centerTitle: true,
      systemOverlayStyle:
          const SystemUiOverlayStyle(statusBarColor: colorPrimary),
      leading: IconButton(
        autofocus: true,
        focusColor: white.withValues(alpha: 0.5),
        onPressed: () {
          Navigator.pop(context);
        },
        icon: MyImage(
          imagePath: "back.png",
          fit: BoxFit.contain,
          height: 100,
          width: 100,
        ),
      ),
      title: MyText(
        text: appBarTitle,
        multilanguage: multilanguage,
        fontsize: Dimens.textTitle,
        fontstyle: FontStyle.normal,
        fontwaight: FontWeight.w700,
        textalign: TextAlign.center,
        color: white,
      ),
    );
  }

  static AppBar myAppBarWithoutBack(
      BuildContext context, String appBarTitle, bool multilanguage) {
    return AppBar(
      elevation: 5,
      backgroundColor: colorPrimary,
      centerTitle: true,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: colorPrimary,
      ),
      automaticallyImplyLeading: false,
      title: MyText(
        text: appBarTitle,
        multilanguage: multilanguage,
        fontsize: Dimens.textTitle,
        fontstyle: FontStyle.normal,
        fontwaight: FontWeight.w700,
        textalign: TextAlign.center,
        color: white,
      ),
    );
  }

  static Widget buildBackBtnDesign(BuildContext context) {
    return MyImage(
      height: 30,
      width: 30,
      imagePath: "back.png",
    );
  }

  static showToast(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 2,
        backgroundColor: colorPrimary,
        textColor: white,
        fontSize: 14);
  }

  static Widget myAppbar(
      BuildContext context, String title, String icon, onBack) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.14,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorAccent,
            colorPrimary,
          ],
          end: Alignment.bottomLeft,
          begin: Alignment.topRight,
        ),
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(25), bottomRight: Radius.circular(25)),
      ),
      child: Column(
        children: [
          // Category AppBar With BackButton
          AppBar(
            backgroundColor: transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            titleSpacing: 10,
            leading: InkWell(
              onTap: onBack,
              child: MyImage(width: 15, height: 15, imagePath: icon),
            ),
            title: MyText(
                color: white,
                text: title,
                textalign: TextAlign.center,
                fontsize: Dimens.textlargeExtraBig,
                inter: 1,
                maxline: 2,
                fontwaight: FontWeight.w500,
                overflow: TextOverflow.ellipsis,
                fontstyle: FontStyle.normal),
            centerTitle: true,
          ),
        ],
      ),
    );
  }

  static Widget pageLoader() {
    return const Align(
      alignment: Alignment.center,
      child: CircularProgressIndicator(
        color: colorPrimary,
      ),
    );
  }

  static BoxDecoration setBGWithBorder(
      Color color, Color borderColor, double radius, double border) {
    return BoxDecoration(
      color: color,
      border: Border.all(
        color: borderColor,
        width: border,
      ),
      borderRadius: BorderRadius.circular(radius),
      shape: BoxShape.rectangle,
    );
  }

  static void showSnackbar(
      BuildContext context, String message, bool multilanguage) {
    final snackBar = SnackBar(
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      elevation: 0,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      backgroundColor: Colors.transparent,
      width: kIsWeb
          ? ((MediaQuery.of(context).size.width > 1000)
              ? (MediaQuery.of(context).size.width * 0.3)
              : (MediaQuery.of(context).size.width))
          : (MediaQuery.of(context).size.width),
      content: Container(
        constraints: const BoxConstraints(minHeight: kIsWeb ? 60 : 50),
        alignment: Alignment.center,
        decoration: Utils.setBackground(colorAccent, 5),
        padding: const EdgeInsets.all(kIsWeb ? 15 : 10),
        child: MyText(
          text: message,
          multilanguage: multilanguage,
          fontstyle: FontStyle.normal,
          fontsize: Dimens.textMedium,
          maxline: 5,
          overflow: TextOverflow.ellipsis,
          fontwaight: FontWeight.w500,
          color: white,
          textalign: TextAlign.center,
        ),
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  // Global Progress Dilog
  void showProgress(BuildContext context) async {
    prDialog = ProgressDialog(context);
    prDialog = ProgressDialog(context,
        type: ProgressDialogType.normal, isDismissible: false, showLogs: false);

    prDialog!.style(
      message: Locales.string(context, "pleasewait"),
      borderRadius: 5,
      progressWidget: Container(
        padding: const EdgeInsets.all(8),
        child: const CircularProgressIndicator(),
      ),
      maxProgress: 100,
      progressTextStyle: const TextStyle(
        color: Colors.black,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      backgroundColor: white,
      insetAnimCurve: Curves.easeInOut,
      messageTextStyle: const TextStyle(
        color: black,
        fontSize: 14,
        fontWeight: FontWeight.normal,
      ),
    );

    await prDialog!.show();
  }

  void hideProgress(BuildContext context) async {
    prDialog = ProgressDialog(context);
    if (prDialog!.isShowing()) {
      prDialog!.hide();
    }
  }

// KMB Text Generator Method
  static String kmbGenerator(int num) {
    if (num > 999 && num < 99999) {
      return "${(num / 1000).toStringAsFixed(1)} K";
    } else if (num > 99999 && num < 999999) {
      return "${(num / 1000).toStringAsFixed(0)} K";
    } else if (num > 999999 && num < 999999999) {
      return "${(num / 1000000).toStringAsFixed(1)} M";
    } else if (num > 999999999) {
      return "${(num / 1000000000).toStringAsFixed(1)} B";
    } else {
      return num.toString();
    }
  }

  static Future<void> redirectToUrl(String url) async {
    printLog("_launchUrl url ===> $url");
    if (await canLaunchUrl(Uri.parse(url.toString()))) {
      await launchUrl(
        Uri.parse(url.toString()),
        mode: LaunchMode.platformDefault,
      );
    } else {
      throw "Could not launch $url";
    }
  }

  static Future<void> redirectToStore() async {
    final appId =
        Platform.isAndroid ? Constant.appPackageName : Constant.appleAppId;
    final url = Uri.parse(
      Platform.isAndroid
          ? "market://details?id=$appId"
          : "https://apps.apple.com/app/id$appId",
    );
    printLog("_launchUrl url ===> $url");
    if (await canLaunchUrl(Uri.parse(url.toString()))) {
      await launchUrl(
        Uri.parse(url.toString()),
        mode: LaunchMode.platformDefault,
      );
    } else {
      throw "Could not launch $url";
    }
  }

  static Future<void> shareApp(String shareMessage) async {
    try {
      await Share.share(shareMessage);
    } catch (e) {
      print("shareApp Exception ===> $e");
    }
  }

  static openPlayer({
    required BuildContext context,
    required String videoId,
    required String videoUrl,
    required String vUploadType,
    required String videoThumb,
    required String stoptime,
    required bool iscontinueWatching,
  }) {
    if (kIsWeb) {
      /* Normal, Vimeo & Youtube Player */
      if (!context.mounted) return;
      if (vUploadType == "youtube") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return PlayerYoutube(videoId, videoUrl, vUploadType, videoThumb,
                  stoptime, iscontinueWatching);
            },
          ),
        );
      } else if (vUploadType == "external") {
        if (videoUrl.contains('youtube')) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return PlayerYoutube(videoId, videoUrl, vUploadType, videoThumb,
                    stoptime, iscontinueWatching);
              },
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return PlayerVideo(videoId, videoUrl, vUploadType, videoThumb,
                    stoptime, iscontinueWatching);
              },
            ),
          );
        }
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return PlayerVideo(videoId, videoUrl, vUploadType, videoThumb,
                  stoptime, iscontinueWatching);
            },
          ),
        );
      }
    } else {
      /* Better, Youtube & Vimeo Players */
      if (vUploadType == "youtube") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return PlayerYoutube(videoId, videoUrl, vUploadType, videoThumb,
                  stoptime, iscontinueWatching);
            },
          ),
        );
      } else if (vUploadType == "vimeo") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return PlayerVimeo(videoId, videoUrl, vUploadType, videoThumb);
            },
          ),
        );
      } else if (vUploadType == "external") {
        if (videoUrl.contains('youtube')) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return PlayerYoutube(videoId, videoUrl, vUploadType, videoThumb,
                    stoptime, iscontinueWatching);
              },
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return PlayerVideo(videoId, videoUrl, vUploadType, videoThumb,
                    stoptime, iscontinueWatching);
              },
            ),
          );
        }
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return PlayerVideo(videoId, videoUrl, vUploadType, videoThumb,
                  stoptime, iscontinueWatching);
            },
          ),
        );
      }
    }
  }

  /* ***************** generate Unique OrderID START ***************** */
  static String generateRandomOrderID() {
    int getRandomNumber;
    String? finalOID;
    printLog("fixFourDigit =>>> ${Constant.fixFourDigit}");
    printLog("fixSixDigit =>>> ${Constant.fixSixDigit}");

    number.Random r = number.Random();
    int ran5thDigit = r.nextInt(9);
    printLog("Random ran5thDigit =>>> $ran5thDigit");

    int randomNumber = number.Random().nextInt(9999999);
    printLog("Random randomNumber =>>> $randomNumber");
    if (randomNumber < 0) {
      randomNumber = -randomNumber;
    }
    getRandomNumber = randomNumber;
    printLog("getRandomNumber =>>> $getRandomNumber");

    finalOID = "${Constant.fixFourDigit.toInt()}"
        "$ran5thDigit"
        "${Constant.fixSixDigit.toInt()}"
        "$getRandomNumber";
    printLog("finalOID =>>> $finalOID");

    return finalOID;
  }
  /* ***************** generate Unique OrderID END ***************** */

  static Widget buildLoadMoreBtn({
    required BuildContext context,
    required Function() onClick,
  }) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        margin: const EdgeInsets.fromLTRB(50, 50, 50, 50),
        child: FittedBox(
          child: InkWell(
            onTap: onClick,
            borderRadius: BorderRadius.circular(5),
            child: Container(
              alignment: Alignment.center,
              height: 45,
              decoration: BoxDecoration(
                color: colorPrimary,
                border: Border.all(
                  color: colorPrimary,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(5),
                shape: BoxShape.rectangle,
              ),
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: MyText(
                multilanguage: true,
                text: "moreitem",
                textalign: TextAlign.center,
                fontstyle: FontStyle.normal,
                fontsize: Dimens.textMedium,
                fontwaight: FontWeight.w500,
                maxline: 1,
                overflow: TextOverflow.ellipsis,
                color: white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
