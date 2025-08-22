import 'dart:developer';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:yourappname/pages/home.dart';
import 'package:yourappname/provider/generalprovider.dart';
import 'package:yourappname/utils/color.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/widget/myimage.dart';
import 'package:yourappname/widget/mytext.dart';

class OTP extends StatefulWidget {
  final String fullnumber, countrycode, countryName, number;
  const OTP({
    super.key,
    required this.fullnumber,
    required this.countrycode,
    required this.countryName,
    required this.number,
  });

  @override
  State<OTP> createState() => _OTPState();
}

class _OTPState extends State<OTP> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  late GeneralProvider generalProvider;
  final pinPutController = TextEditingController();
  String? strDeviceType, strDeviceToken;
  bool codeResended = false;
  int? forceResendingToken;
  String? verificationId;

  @override
  void initState() {
    printLog("Full Number==> ${widget.fullnumber}");
    printLog("Number==> ${widget.number}");
    generalProvider = Provider.of<GeneralProvider>(context, listen: false);
    super.initState();
    _getDeviceToken();
    codeSend();
  }

  _getDeviceToken() async {
    try {
      if (Platform.isAndroid) {
        strDeviceType = "1";
        strDeviceToken = await FirebaseMessaging.instance.getToken();
      } else {
        strDeviceType = "2";
        strDeviceToken = OneSignal.User.pushSubscription.id.toString();
      }
    } catch (e) {
      printLog("_getDeviceToken Exception ===> $e");
    }
    printLog("===>strDeviceToken $strDeviceToken");
    printLog("===>strDeviceType $strDeviceType");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        // backgroundColor: white,
        elevation: 0,
        centerTitle: false,
        leading: InkWell(
          onTap: () {
            Navigator.of(context).pop(false);
          },
          child: MyImage(
            width: 15,
            height: 15,
            imagePath: "back.png",
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              MyText(
                  color: black,
                  text: "verifyphonenumber",
                  multilanguage: true,
                  fontsize: Dimens.textExtralargeBig,
                  maxline: 1,
                  inter: 3,
                  overflow: TextOverflow.ellipsis,
                  textalign: TextAlign.center,
                  fontstyle: FontStyle.normal,
                  fontwaight: FontWeight.w600),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              MyText(
                  color: lightgray,
                  text: "wehavesentcodetoyournumber",
                  fontsize: Dimens.textTitle,
                  multilanguage: true,
                  maxline: 1,
                  inter: 1,
                  overflow: TextOverflow.ellipsis,
                  textalign: TextAlign.center,
                  fontstyle: FontStyle.normal,
                  fontwaight: FontWeight.w400),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              MyText(
                  color: lightgray,
                  text: widget.fullnumber,
                  fontsize: Dimens.textTitle,
                  maxline: 1,
                  inter: 1,
                  overflow: TextOverflow.ellipsis,
                  textalign: TextAlign.center,
                  fontstyle: FontStyle.normal,
                  fontwaight: FontWeight.w400),
              SizedBox(height: MediaQuery.of(context).size.height * 0.039),
              Pinput(
                length: 6,
                keyboardType: TextInputType.number,
                controller: pinPutController,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                defaultPinTheme: PinTheme(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    border: Border.all(color: colorPrimary, width: 1),
                    shape: BoxShape.rectangle,
                    color: appBgColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  textStyle: Utils.googleFontStyle(
                      1, 16, FontStyle.normal, black, FontWeight.w500),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.020,
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.040),
              Consumer<GeneralProvider>(
                  builder: (context, generalprovider, child) {
                if (generalprovider.isProgressLoading) {
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.07,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: colorPrimary,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(
                        color: white,
                        strokeWidth: 2.5,
                      ),
                    ),
                  );
                } else {
                  return InkWell(
                    onTap: () {
                      if (pinPutController.text.isEmpty) {
                        Utils.showSnackbar(context, "pleaseemteryourotp", true);
                      } else {
                        generalprovider.setLoading(true);
                        checkOTPAndLogin();
                      }
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.07,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: const LinearGradient(
                          colors: [colorAccent, colorPrimary],
                          end: Alignment.topRight,
                          begin: Alignment.topLeft,
                        ),
                      ),
                      child: MyText(
                          color: white,
                          text: "confirm",
                          fontsize: Dimens.textBig,
                          multilanguage: true,
                          maxline: 1,
                          inter: 3,
                          overflow: TextOverflow.ellipsis,
                          textalign: TextAlign.center,
                          fontstyle: FontStyle.normal,
                          fontwaight: FontWeight.bold),
                    ),
                  );
                }
              }),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.031,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {},
                    child: MyText(
                        color: black,
                        text: "resend",
                        fontsize: Dimens.textMedium,
                        multilanguage: true,
                        maxline: 1,
                        inter: 1,
                        overflow: TextOverflow.ellipsis,
                        textalign: TextAlign.center,
                        fontstyle: FontStyle.normal,
                        fontwaight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

/* ====================== Send OTP Start ========================== */

  codeSend() async {
    generalProvider.setLoading(true);
    await phoneSignIn(phoneNumber: widget.fullnumber);
    if (!mounted) return;
    generalProvider.setLoading(false);
  }

  Future<void> phoneSignIn({required String phoneNumber}) async {
    await auth.verifyPhoneNumber(
      timeout: const Duration(seconds: 60),
      phoneNumber: phoneNumber,
      forceResendingToken: forceResendingToken,
      verificationCompleted: _onVerificationCompleted,
      verificationFailed: _onVerificationFailed,
      codeSent: _onCodeSent,
      codeAutoRetrievalTimeout: _onCodeTimeout,
    );
  }

  _onVerificationCompleted(PhoneAuthCredential authCredential) async {
    log("verification completed ======> ${authCredential.smsCode}");
    User? user = FirebaseAuth.instance.currentUser;
    log("user phoneNumber =====> ${user?.phoneNumber}");
  }

  _onVerificationFailed(FirebaseAuthException exception) {
    if (exception.code == 'invalid-phone-number') {
      log("The phone number entered is invalid!");
      Utils.showSnackbar(context, "thephonenumberenteredisinvalid", true);
      if (!mounted) return;
      generalProvider.setLoading(false);
    }
  }

  _onCodeSent(String verificationId, int? forceResendingToken) {
    this.verificationId = verificationId;
    this.forceResendingToken = forceResendingToken;
    log("verificationId =======> $verificationId");
    log("resendingToken =======> ${forceResendingToken.toString()}");
    log("code sent");
    Utils.showSnackbar(context, "coderesendsuccsessfully", true);
    generalProvider.setLoading(false);
  }

  _onCodeTimeout(String verificationId) {
    log("_onCodeTimeout verificationId =======> $verificationId");
    this.verificationId = verificationId;
    if (!mounted) return;
    generalProvider.setLoading(false);
    return null;
  }

/* ====================== Send OTP End ========================== */

  checkOTPAndLogin() async {
    bool error = false;
    UserCredential? userCredential;

    log("_checkOTPAndLogin verificationId =====> $verificationId");
    // Create a PhoneAuthCredential with the code
    PhoneAuthCredential? phoneAuthCredential = PhoneAuthProvider.credential(
      verificationId: verificationId ?? "",
      smsCode: pinPutController.text.toString(),
    );

    log("phoneAuthCredential.smsCode   =====> ${phoneAuthCredential.smsCode}");
    log("phoneAuthCredential.verificationId =====> ${phoneAuthCredential.verificationId}");
    try {
      userCredential = await auth.signInWithCredential(phoneAuthCredential);
      log("_checkOTPAndLogin userCredential =====> ${userCredential.user?.phoneNumber ?? ""}");
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      generalProvider.setLoading(false);
      log("_checkOTPAndLogin error Code =====> ${e.code}");
      if (e.code == 'invalid-verification-code' ||
          e.code == 'invalid-verification-id') {
        if (!mounted) return;
        Utils.showSnackbar(context, "entervalidotp", true);
        return;
      } else if (e.code == 'session-expired') {
        if (!mounted) return;
        Utils.showSnackbar(context, "otpsessionexpired", true);
        return;
      } else {
        error = true;
      }
    }
    log("Firebase Verification Complated & phoneNumber => ${userCredential?.user?.phoneNumber} and isError => $error");
    if (!error && userCredential != null) {
      // Call Login Api
      loginApi(widget.number.toString());
    } else {
      if (!mounted) return;
      generalProvider.setLoading(false);
      Utils.showSnackbar(context, "loginfail", true);
    }
  }

  loginApi(mobile) async {
    await generalProvider.getLogin(Constant.otpLoginType, mobile, "", "",
        strDeviceToken, strDeviceType, widget.countrycode, widget.countryName);

    if (!generalProvider.loading) {
      if (generalProvider.loginModel.status == 200 &&
          (generalProvider.loginModel.result?.length ?? 0) > 0) {
        Utils.saveUserCreds(
          userID: generalProvider.loginModel.result?[0].id.toString(),
          userName: generalProvider.loginModel.result?[0].fullName.toString(),
          userEmail: generalProvider.loginModel.result?[0].email.toString(),
          usercountrycode:
              generalProvider.loginModel.result?[0].countryCode.toString(),
          usercountryname:
              generalProvider.loginModel.result?[0].countryName.toString(),
          userMobile:
              generalProvider.loginModel.result?[0].mobileNumber.toString(),
          userImage: generalProvider.loginModel.result?[0].image.toString(),
          userPremium: generalProvider.loginModel.result?[0].isBuy.toString(),
          userType: generalProvider.loginModel.result?[0].type.toString(),
        );

        // Set UserID for Next
        Constant.userID = generalProvider.loginModel.result?[0].id.toString();
        generalProvider.setLoading(false);
        if (!mounted) return;

        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const Home()),
            (Route route) => false);
      } else {
        generalProvider.setLoading(false);
      }
    }
  }
}
