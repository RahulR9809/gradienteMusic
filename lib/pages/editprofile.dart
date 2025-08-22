import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';
import 'package:yourappname/pages/home.dart';
import 'package:yourappname/provider/profileprovider.dart';
import 'package:yourappname/provider/updateprofileprovider.dart';
import 'package:yourappname/utils/color.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/utils/sharedpref.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/widget/myappbar.dart';
import 'package:yourappname/widget/myimage.dart';
import 'package:yourappname/widget/mynetworkimg.dart';
import 'package:yourappname/widget/mytext.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  SharedPref sharedPre = SharedPref();
  final ImagePicker picker = ImagePicker();
  XFile? _image;
  File? image;
  bool iseditimg = false;
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final numberController = TextEditingController();
  String mobilenumber = "", countrycode = "", countryname = "";
  late ProfileProvider profileProvider;

  @override
  void initState() {
    profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getApi();
    });
  }

  getApi() async {
    await profileProvider.getProfile(context);

    usernameController.text =
        profileProvider.profileModel.result?[0].fullName.toString() ?? "";
    emailController.text =
        profileProvider.profileModel.result?[0].email.toString() ?? "";
    numberController.text =
        profileProvider.profileModel.result?[0].mobileNumber.toString() ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            Stack(
              children: [
                // AppBar
                MyAppbar(
                  isSimpleappbar: 2,
                  title: "editprofile",
                  isMultiLang: true,
                  onBack: () {
                    Navigator.of(context).pop(false);
                    getApi();
                  },
                  icon: "back,png",
                ),
                // UserProfile And Change Image Icon
                Consumer<ProfileProvider>(
                    builder: (context, profileProvider, child) {
                  return Positioned.fill(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: _image == null
                                ? MyNetworkImage(
                                    fit: BoxFit.cover,
                                    imgWidth: 110,
                                    imgHeight: 110,
                                    imageUrl: profileProvider
                                            .profileModel.result?[0].image
                                            .toString() ??
                                        "")
                                : Image.file(
                                    File(_image!.path),
                                    fit: BoxFit.cover,
                                    width: 110,
                                    height: 110,
                                  ),
                          ),
                          Positioned.fill(
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: InkWell(
                                onTap: () async {
                                  // Select Image From Gallary and Camera
                                  var image = await picker.pickImage(
                                      source: ImageSource.gallery,
                                      imageQuality: 100);
                                  setState(() {
                                    _image = image;
                                    iseditimg = true;
                                  });
                                },
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: const BoxDecoration(
                                      color: colorAccent,
                                      shape: BoxShape.circle),
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.camera_alt_outlined,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
            // Body
            profilebody(),
          ],
        ),
      ),
    );
  }

  Widget profilebody() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.060),
          // Enter Username
          profileTextFields(
              Locales.string(context, "username"),
              "ic_user.png",
              usernameController,
              TextInputType.text,
              TextInputAction.next,
              false),
          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
          // Enter Email
          profileTextFields(Locales.string(context, "email"), "ic_email.png",
              emailController, TextInputType.text, TextInputAction.next, false),
          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
          // Enter MobileNumber
          profileTextFields(
              Locales.string(context, "mobile"),
              "ic_mobile.png",
              numberController,
              TextInputType.number,
              TextInputAction.next,
              true),
          SizedBox(height: MediaQuery.of(context).size.height * 0.20),
          // EditButton
          InkWell(
            onTap: () async {
              File image;
              String name = usernameController.text.toString();
              String email = emailController.text.toString();
              String mobile = numberController.text.toString();

              if (iseditimg) {
                image = File(_image?.path ?? "");
              } else {
                image = File("");
              }

              final updateprofileProvider =
                  Provider.of<UpdateProfileProvider>(context, listen: false);
              await updateprofileProvider.getUpdateProfile(
                  Constant.userID ?? "",
                  name,
                  email,
                  mobile,
                  countrycode,
                  countryname,
                  image);

              if (!updateprofileProvider.loading) {
                if (updateprofileProvider.updateprofileModel.status == 200) {
                  await sharedPre.save(
                      "username", usernameController.text.toString());
                  await sharedPre.save(
                      "useremail", emailController.text.toString());
                  await sharedPre.save(
                      "usermobile", numberController.text.toString());
                  await sharedPre.save("usercountryname", countryname);
                  await sharedPre.save("usercountrycode", countrycode);
                  await sharedPre.save(
                      "userimage",
                      updateprofileProvider.updateprofileModel.result?[0].image
                              .toString() ??
                          "");
                  Constant.userImage = await sharedPre.read('userimage');

                  if (!mounted) return;

                  Utils.showSnackbar(
                      context,
                      updateprofileProvider.updateprofileModel.message
                          .toString(),
                      false);

                  getApi();

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return const Home();
                      },
                    ),
                  );
                } else {
                  if (!mounted) return;
                  Utils.showSnackbar(
                      context,
                      updateprofileProvider.updateprofileModel.message
                          .toString(),
                      false);
                }
              }
            },
            child: Container(
              height: MediaQuery.of(context).size.height * 0.065,
              width: MediaQuery.of(context).size.width * 0.50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [colorAccent, colorPrimary],
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                  ),
                  borderRadius: BorderRadius.circular(50)),
              child: MyText(
                color: white,
                text: "save",
                fontwaight: FontWeight.w600,
                fontsize: Dimens.textBig,
                multilanguage: true,
                inter: 1,
                fontstyle: FontStyle.normal,
                maxline: 1,
                overflow: TextOverflow.ellipsis,
                textalign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

// Username,Email And Number Common TextField
  Widget profileTextFields(String hinttext, String icon, dynamic controller,
      dynamic keyboardtype, dynamic textinputAction, bool isMobile) {
    if (isMobile == false) {
      return TextFormField(
        keyboardType: keyboardtype,
        textInputAction: textinputAction,
        controller: controller,
        cursorColor: Theme.of(context).colorScheme.surface,
        style: Utils.googleFontStyle(1, 16, FontStyle.normal,
            Theme.of(context).colorScheme.surface, FontWeight.w500),
        decoration: InputDecoration(
          prefixIcon: Container(
            width: 15,
            height: 15,
            alignment: Alignment.center,
            child: MyImage(
              width: 23,
              height: 23,
              imagePath: icon,
              color: gray,
            ),
          ),
          filled: true,
          fillColor: Theme.of(context).secondaryHeaderColor,
          contentPadding: const EdgeInsets.all(12.0),
          focusedBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(7)),
            borderSide:
                BorderSide(width: 1, color: lightgray.withValues(alpha: 0.80)),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(7)),
            borderSide:
                BorderSide(width: 1, color: lightgray.withValues(alpha: 0.80)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(7)),
            borderSide:
                BorderSide(width: 1, color: lightgray.withValues(alpha: 0.80)),
          ),
          border: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(7)),
              borderSide: BorderSide(
                  width: 1, color: lightgray.withValues(alpha: 0.80))),
          hintText: hinttext,
          hintStyle: Utils.googleFontStyle(1, 16, FontStyle.normal,
              Theme.of(context).colorScheme.surface, FontWeight.w500),
        ),
      );
    } else {
      return IntlPhoneField(
        disableLengthCheck: true,
        textAlignVertical: TextAlignVertical.center,
        autovalidateMode: AutovalidateMode.disabled,
        controller: numberController,
        cursorColor: Theme.of(context).colorScheme.surface,
        style: Utils.googleFontStyle(1, 16, FontStyle.normal,
            Theme.of(context).colorScheme.surface, FontWeight.w500),
        showCountryFlag: true,
        showDropdownIcon: false,
        initialCountryCode:
            profileProvider.profileModel.result?[0].countryName == ""
                ? Constant.initialCountryCode
                : profileProvider.profileModel.result?[0].countryName
                        .toString() ??
                    Constant.initialCountryCode,
        dropdownTextStyle: Utils.googleFontStyle(
            1, 16, FontStyle.normal, gray, FontWeight.w500),
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          prefixIcon: Container(
            width: 15,
            height: 15,
            alignment: Alignment.center,
            child: MyImage(
              width: 23,
              height: 23,
              imagePath: icon,
              color: gray,
            ),
          ),
          filled: true,
          fillColor: Theme.of(context).secondaryHeaderColor,
          contentPadding: const EdgeInsets.all(12.0),
          focusedBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(7)),
            borderSide:
                BorderSide(width: 1, color: lightgray.withValues(alpha: 0.80)),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(7)),
            borderSide:
                BorderSide(width: 1, color: lightgray.withValues(alpha: 0.80)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(7)),
            borderSide:
                BorderSide(width: 1, color: lightgray.withValues(alpha: 0.80)),
          ),
          border: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(7)),
              borderSide: BorderSide(
                  width: 1, color: lightgray.withValues(alpha: 0.80))),
          hintText: hinttext,
          hintStyle: Utils.googleFontStyle(1, 16, FontStyle.normal,
              Theme.of(context).colorScheme.surface, FontWeight.w500),
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
}
