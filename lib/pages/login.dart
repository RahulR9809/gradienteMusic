import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:yourappname/pages/home.dart';
import 'package:yourappname/pages/normallogin.dart';
import 'package:yourappname/pages/otp.dart';
import 'package:yourappname/provider/generalprovider.dart';
import 'package:yourappname/provider/likeprovider.dart';
import 'package:yourappname/utils/color.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/utils/sharedpref.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/widget/myimage.dart';
import 'package:yourappname/widget/mytext.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  late GeneralProvider generalProvider;
  final FirebaseAuth auth = FirebaseAuth.instance;
  SharedPref sharedPre = SharedPref();
  final numberController = TextEditingController();
  String mobilenumber = "", countrycode = "", countryname = "";
  String userEmail = "";
  int? forceResendingToken;
  String? verificationId;
  String? strDeviceType, strDeviceToken;

  @override
  void initState() {
    generalProvider = Provider.of<GeneralProvider>(context, listen: false);
    super.initState();
    _getDeviceToken();
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
      body: SafeArea(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: MyImage(
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  imagePath: "back.png",
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: MyImage(
                    imagePath: "appicon.png",
                    isAppIcon: true,
                    height: 100,
                    width: 100),
              ),
              const SizedBox(height: 30),
              // Welcome Back Text
              MyText(
                  color: Theme.of(context).colorScheme.surface,
                  text: "welcomeback",
                  multilanguage: true,
                  fontsize: 27,
                  maxline: 1,
                  inter: 1,
                  overflow: TextOverflow.ellipsis,
                  textalign: TextAlign.left,
                  fontstyle: FontStyle.normal,
                  fontwaight: FontWeight.bold),
              const SizedBox(height: 10),
              // Enter Mobile Number Text
              MyText(
                  color: gray,
                  text: "enteryourmobilenumbertologin",
                  multilanguage: true,
                  fontsize: Dimens.textMedium,
                  maxline: 1,
                  inter: 1,
                  overflow: TextOverflow.ellipsis,
                  textalign: TextAlign.left,
                  fontstyle: FontStyle.normal,
                  fontwaight: FontWeight.w400),
              const SizedBox(height: 30),
              // Mobile Number TextField
              phonetextfield(),
              const SizedBox(height: 15),
              // Login Button
              loginbutton(),
              const SizedBox(height: 20),
              // Or Text
              orSection(),
              const SizedBox(height: 17),
              // Google Signin Button (Show Only Android Devices)
              buildButton(
                  imagePath: "google.png",
                  title: "loginwithgoogle",
                  onTap: () {
                    if (!generalProvider.isProgressLoading) {
                      gmailLogin();
                    }
                  }),
              // Apple Signin Button (Show Only IOS and macOS Devices)
              Platform.isIOS || Platform.isMacOS
                  ? buildButton(
                      imagePath: "ic_apple.png",
                      title: "loginwithapple",
                      onTap: () async {
                        if (!generalProvider.isProgressLoading) {
                          signInWithApple();
                        }
                      })
                  : const SizedBox.shrink(),
              buildButton(
                imagePath: "normallogin.png",
                title: "loginwithnormal",
                onTap: () {
                  if (!generalProvider.isProgressLoading) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return const NormalLogin();
                        },
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget phonetextfield() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.08,
      child: IntlPhoneField(
        disableLengthCheck: true,
        textAlignVertical: TextAlignVertical.center,
        autovalidateMode: AutovalidateMode.disabled,
        controller: numberController,
        cursorColor: Theme.of(context).colorScheme.surface,
        style: Utils.googleFontStyle(1, 16, FontStyle.normal,
            Theme.of(context).colorScheme.surface, FontWeight.w500),
        showCountryFlag: true,
        showDropdownIcon: false,
        initialCountryCode: Constant.initialCountryCode,
        dropdownTextStyle: Utils.googleFontStyle(
            1, 16, FontStyle.normal, gray, FontWeight.w500),
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          filled: false,
          hintStyle: Utils.googleFontStyle(
              1, 14, FontStyle.normal, gray, FontWeight.w500),
          hintText: Locales.string(context, "enteryourmobilenumber"),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12.0)),
            borderSide: BorderSide(color: gray, width: 2),
          ),
          disabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12.0)),
            borderSide: BorderSide(color: gray, width: 2),
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12.0)),
            borderSide: BorderSide(color: gray, width: 2),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12.0)),
            borderSide: BorderSide(color: colorPrimary, width: 2),
          ),
        ),
        onChanged: (phone) {
          mobilenumber = phone.completeNumber;
          countryname = phone.countryISOCode;
          countrycode = phone.countryCode;
        },
        onCountryChanged: (country) {
          countryname = country.code.replaceAll('+', '');
          countrycode = "+${country.dialCode.toString()}";
        },
      ),
    );
  }

  loginbutton() {
    return Consumer<GeneralProvider>(
        builder: (context, generalprovider, child) {
      if (generalprovider.isProgressLoading) {
        return Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.07,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [colorAccent, colorPrimary],
              end: Alignment.topRight,
              begin: Alignment.topLeft,
            ),
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
            if (numberController.text.toString().isEmpty) {
              Utils.showSnackbar(context, "pleaseenteryourmobilenumber", true);
            } else {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => OTP(
                    fullnumber: mobilenumber,
                    countrycode: countrycode,
                    countryName: countryname,
                    number: numberController.text,
                  ),
                ),
              );
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
                text: "login",
                fontsize: Dimens.textBig,
                maxline: 1,
                multilanguage: true,
                inter: 3,
                overflow: TextOverflow.ellipsis,
                textalign: TextAlign.center,
                fontstyle: FontStyle.normal,
                fontwaight: FontWeight.w600),
          ),
        );
      }
    });
  }

  Row orSection() {
    return Row(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(left: 88.0, right: 15.0),
            child: const Divider(
              color: gray,
            ),
          ),
        ),
        MyText(
            color: gray,
            text: "or",
            multilanguage: true,
            fontsize: Dimens.textMedium,
            maxline: 1,
            inter: 1,
            overflow: TextOverflow.ellipsis,
            textalign: TextAlign.center,
            fontstyle: FontStyle.normal,
            fontwaight: FontWeight.w400),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(left: 15.0, right: 88.0),
            child: const Divider(
              color: gray,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildButton({required imagePath, required title, required onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 60,
        margin: const EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: lightgray,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            MyImage(
              height: 25,
              imagePath: imagePath,
              width: 25,
            ),
            const SizedBox(width: 25),
            MyText(
                color: black,
                text: title,
                fontsize: Dimens.textMedium,
                maxline: 1,
                multilanguage: true,
                inter: 1,
                overflow: TextOverflow.ellipsis,
                textalign: TextAlign.center,
                fontstyle: FontStyle.normal,
                fontwaight: FontWeight.w600),
          ],
        ),
      ),
    );
  }

  // Login With Google
  Future<void> gmailLogin() async {
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return;

    GoogleSignInAccount user = googleUser;

    printLog('GoogleSignIn ===> id : ${user.id}');
    printLog('GoogleSignIn ===> email : ${user.email}');
    printLog('GoogleSignIn ===> displayName : ${user.displayName}');
    printLog('GoogleSignIn ===> photoUrl : ${user.photoUrl}');

    final likeProvider = Provider.of<LikeProvider>(context, listen: false);
    likeProvider.setCurrentUser(user.id);

    if (!mounted) return;
    generalProvider.setLoading(true);

    UserCredential userCredential;
    try {
      GoogleSignInAuthentication googleSignInAuthentication =
          await user.authentication;
      AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      userCredential = await auth.signInWithCredential(credential);
      assert(await userCredential.user?.getIdToken() != null);
      printLog("User Name: ${userCredential.user?.displayName}");
      printLog("User Email ${userCredential.user?.email}");
      printLog("User photoUrl ${userCredential.user?.photoURL}");
      printLog("uid ===> ${userCredential.user?.uid}");
      String firebasedid = userCredential.user?.uid ?? "";
      printLog('firebasedid :===> $firebasedid');
      // Call Login Api
      if (!mounted) return;
      generalProvider.setLoading(true);
      loginApi(Constant.googleLoginType, "", user.email);
    } on FirebaseAuthException catch (e) {
      printLog('===>Exp${e.code.toString()}');
      printLog('===>Exp${e.message.toString()}');
      if (!mounted) return;
      generalProvider.setLoading(false);
    }
  }

  /* Apple Login */
  /// Returns the sha256 hash of [input] in hex notation.
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> signInWithApple() async {
    // To prevent replay attacks with the credential returned from Apple, we
    // include a nonce in the credential request. When signing in in with
    // Firebase, the nonce in the id token returned by Apple, is expected to
    // match the sha256 hash of `rawNonce`.
    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);

    try {
      // Request credential for the currently signed in Apple account.
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      printLog(appleCredential.authorizationCode);

      // Create an `OAuthCredential` from the credential returned by Apple.
      final oauthCredential = OAuthProvider("apple.com").credential(
          idToken: appleCredential.identityToken,
          rawNonce: rawNonce,
          accessToken: appleCredential.authorizationCode);

      // Sign in the user with Firebase. If the nonce we generated earlier does
      // not match the nonce in `appleCredential.identityToken`, sign in will fail.
      final authResult = await auth.signInWithCredential(oauthCredential);

      String? displayName =
          '${appleCredential.givenName} ${appleCredential.familyName}';
      userEmail = authResult.user?.email.toString() ?? "";
      printLog("===>userEmail $userEmail");
      printLog("===>displayName $displayName");

      final firebaseUser = authResult.user;

      dynamic firebasedId;
      if (userEmail.isNotEmpty || userEmail != 'null') {
        await firebaseUser?.updateDisplayName(displayName);
        await firebaseUser
            ?.updateEmail(authResult.user?.email.toString() ?? "");
      } else {
        userEmail = firebaseUser?.email.toString() ?? "";
        firebasedId = firebaseUser?.uid.toString();
        displayName = firebaseUser?.displayName.toString();
        printLog("===>userEmail-else $userEmail");
        printLog("===>displayName-else $displayName");
      }
        final likeProvider = Provider.of<LikeProvider>(context, listen: false);
    likeProvider.setCurrentUser(firebasedId ?? firebaseUser?.uid.toString() ?? "");

      printLog("userEmail =====FINAL==> $userEmail");
      printLog("firebasedId ===FINAL==> $firebasedId");
      printLog("displayName ===FINAL==> $displayName");

      loginApi(Constant.appleLoginType, "", userEmail);
    } catch (exception) {
      printLog("Apple Login exception =====> $exception");
      if (!mounted) return;
      generalProvider.setLoading(false);
    }
  }

  loginApi(type, mobile, email) async {
    generalProvider.setLoading(true);
    await generalProvider.getLogin(
        type, mobile, email, "", strDeviceToken, strDeviceType, "", "");

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

       final likeProvider = Provider.of<LikeProvider>(context, listen: false);
    likeProvider.setCurrentUser(generalProvider.loginModel.result?[0].id.toString());

        generalProvider.setLoading(false);
        if (!mounted) return;

        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const Home()),
            (Route route) => false);
      } else {
        generalProvider.setLoading(false);
        if (!mounted) return;
        Utils.showSnackbar(
            context, "${generalProvider.loginModel.message}", false);
      }
    }
  }
}
