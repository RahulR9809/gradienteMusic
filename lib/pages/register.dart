import 'package:flutter_locales/flutter_locales.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';
import 'package:yourappname/pages/normallogin.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:yourappname/provider/generalprovider.dart';
import 'package:yourappname/utils/color.dart';
import 'package:yourappname/utils/sharedpref.dart';
import 'package:yourappname/widget/myimage.dart';
import 'package:yourappname/widget/mytext.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => RegisterState();
}

class RegisterState extends State<Register> {
  late GeneralProvider generalProvider;
  SharedPref sharedPre = SharedPref();
  final fullnameController = TextEditingController();
  final emailController = TextEditingController();
  final numberController = TextEditingController();
  final passwordController = TextEditingController();

  bool showHidePassword = true;
  String mobilenumber = "", countrycode = "", countryname = "";

  @override
  void initState() {
    generalProvider = Provider.of<GeneralProvider>(context, listen: false);
    super.initState();
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
              // const SizedBox(height: 10),
              Center(
                child: MyImage(
                    imagePath: "appicon.png",
                    isAppIcon: true,
                    height: 150,
                    width: 150),
              ),
              // const SizedBox(height: 30),
              // Welcome Back Text
              Center(
                child: MyText(
                    color: Theme.of(context).colorScheme.surface,
                    text: "createaccount",
                    multilanguage: true,
                    fontsize: 27,
                    maxline: 1,
                    inter: 1,
                    overflow: TextOverflow.ellipsis,
                    textalign: TextAlign.left,
                    fontstyle: FontStyle.normal,
                    fontwaight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              // Enter Mobilenumber Text
              Center(
                child: MyText(
                    color: gray,
                    text: "enteryouremailandpasswordtologin",
                    multilanguage: true,
                    fontsize: Dimens.textMedium,
                    maxline: 1,
                    inter: 1,
                    overflow: TextOverflow.ellipsis,
                    textalign: TextAlign.left,
                    fontstyle: FontStyle.normal,
                    fontwaight: FontWeight.w400),
              ),
              const SizedBox(height: 40),
              textField(
                  controller: fullnameController,
                  title: "full_name",
                  icon: Icons.person,
                  isMobileNumber: false,
                  isPassword: false,
                  textInputAction: TextInputAction.next,
                  textInputType: TextInputType.text),
              const SizedBox(height: 15),
              textField(
                  controller: emailController,
                  title: "email",
                  icon: Icons.email,
                  isMobileNumber: false,
                  isPassword: false,
                  textInputAction: TextInputAction.next,
                  textInputType: TextInputType.text),
              const SizedBox(height: 15),
              textField(
                  controller: numberController,
                  title: "mobile_number",
                  icon: Icons.phone,
                  isMobileNumber: true,
                  isPassword: false,
                  textInputAction: TextInputAction.next,
                  textInputType: TextInputType.number),
              const SizedBox(height: 15),
              textField(
                  controller: passwordController,
                  title: "password",
                  isPassword: true,
                  isMobileNumber: false,
                  icon: Icons.lock,
                  textInputAction: TextInputAction.done,
                  textInputType: TextInputType.text),
              const SizedBox(height: 40),
              loginButton(),
              const SizedBox(height: 20),
              orSection(),
              const SizedBox(height: 20),
              goingLogin(),
            ],
          ),
        ),
      ),
    );
  }

  Widget textField(
      {required controller,
      required String title,
      required icon,
      required isPassword,
      required isMobileNumber,
      required TextInputAction textInputAction,
      required TextInputType textInputType}) {
    if (isMobileNumber == false) {
      return TextFormField(
        obscureText: isPassword ? showHidePassword : false,
        textAlignVertical: TextAlignVertical.center,
        obscuringCharacter: "*",
        controller: controller,
        cursorColor: Theme.of(context).colorScheme.surface,
        style: Utils.googleFontStyle(1, 14, FontStyle.normal,
            Theme.of(context).colorScheme.surface, FontWeight.w500),
        keyboardType: textInputType,
        textInputAction: textInputAction,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          suffixIcon: isPassword == true
              ? InkWell(
                  focusColor: transparent,
                  splashColor: transparent,
                  highlightColor: transparent,
                  hoverColor: transparent,
                  onTap: () {
                    setState(() {
                      showHidePassword = !showHidePassword;
                    });
                  },
                  child: Container(
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    child: Icon(
                      size: 20,
                      showHidePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: gray,
                    ),
                  ),
                )
              : const SizedBox.shrink(),
          filled: false,
          labelStyle: Utils.googleFontStyle(
              1, 14, FontStyle.normal, gray, FontWeight.w500),
          labelText: Locales.string(context, title),
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
      );
    } else {
      return IntlPhoneField(
        disableLengthCheck: true,
        obscureText: isPassword ? showHidePassword : false,
        textAlignVertical: TextAlignVertical.center,
        controller: controller,
        cursorColor: Theme.of(context).colorScheme.surface,
        style: Utils.googleFontStyle(1, Dimens.textMedium, FontStyle.normal,
            Theme.of(context).colorScheme.surface, FontWeight.w500),
        keyboardType: textInputType,
        textInputAction: textInputAction,
        showCountryFlag: true,
        showDropdownIcon: false,
        initialCountryCode: Constant.initialCountryCode,
        dropdownTextStyle: GoogleFonts.inter(
            fontSize: Dimens.textMedium,
            fontStyle: FontStyle.normal,
            letterSpacing: 1.0,
            color: gray,
            fontWeight: FontWeight.w400),
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          suffixIcon: isPassword == true
              ? InkWell(
                  focusColor: transparent,
                  splashColor: transparent,
                  highlightColor: transparent,
                  hoverColor: transparent,
                  onTap: () {
                    setState(() {
                      showHidePassword = !showHidePassword;
                    });
                  },
                  child: Container(
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    child: Icon(
                      size: 20,
                      showHidePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: gray,
                    ),
                  ),
                )
              : const SizedBox.shrink(),
          filled: false,
          labelStyle: Utils.googleFontStyle(
              1, 14, FontStyle.normal, gray, FontWeight.w500),
          labelText: Locales.string(context, title),
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
      );
    }
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
            color: lightgray,
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

  Widget goingLogin() {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return const NormalLogin();
            },
          ),
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          MyText(
              color: gray,
              text: "alreadyhaveanaccount",
              fontsize: Dimens.textSmall,
              maxline: 1,
              fontwaight: FontWeight.w400,
              overflow: TextOverflow.ellipsis,
              textalign: TextAlign.center,
              fontstyle: FontStyle.normal,
              multilanguage: true),
          const SizedBox(width: 5),
          MyText(
              color: colorPrimary,
              text: "login",
              fontsize: Dimens.textSmall,
              maxline: 1,
              fontwaight: FontWeight.w500,
              overflow: TextOverflow.ellipsis,
              textalign: TextAlign.center,
              fontstyle: FontStyle.normal,
              multilanguage: true),
        ],
      ),
    );
  }

  loginButton() {
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
          onTap: () async {
            bool emailValidation = RegExp(
                    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                .hasMatch(emailController.text);

            if (fullnameController.text.isEmpty) {
              Utils.showSnackbar(context, "pleasenterfullname", true);
            } else if (emailController.text.isEmpty) {
              Utils.showSnackbar(context, "pleasenteremail", true);
            } else if (numberController.text.isEmpty) {
              Utils.showSnackbar(context, "pleaseenteryourmobile", true);
            } else if (passwordController.text.isEmpty) {
              Utils.showSnackbar(context, "pleaseenteryourpassword", true);
            } else if (passwordController.text.length < 6) {
              Utils.showSnackbar(
                  context, "pleaseenterpasswordonlysixdigit", true);
            } else if (!emailValidation) {
              Utils.showSnackbar(context, "invalidemailaddress", true);
            } else {
              /* Device Token And Device Type Not Parsing Other All Filed Passing in This Api */
              await generalProvider.getRegister(
                  Constant.normalLoginType,
                  fullnameController.text,
                  emailController.text,
                  numberController.text,
                  passwordController.text,
                  countrycode,
                  countryname,
                  "",
                  "");

              generalProvider.setLoading(true);

              if (!generalProvider.loading) {
                if (generalProvider.registerModel.status == 200 &&
                    (generalProvider.registerModel.result != null ||
                        ((generalProvider.registerModel.result?.length ?? 0) >
                            0))) {
                  generalprovider.setLoading(false);
                  if (!context.mounted) return;
                  Utils.showSnackbar(context,
                      generalProvider.registerModel.message ?? "", false);
                  Navigator.pop(context);
                } else {
                  generalprovider.setLoading(false);
                  if (!context.mounted) return;
                  Utils.showSnackbar(context,
                      generalProvider.registerModel.message ?? "", false);
                }
              }
            }
          },
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 60,
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
}
