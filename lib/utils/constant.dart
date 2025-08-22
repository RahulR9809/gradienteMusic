class Constant {
  final String baseurl = "https://royalblue-buffalo-226067.hostingersite.com/public/api/"; /* CHANGE YOUR BASEURL */

  static String appName = "Gradiente Music"; /*   CHANGE YOUR APPNAME */
  static String? appPackageName =
      "com.example.gradiente_music"; /* CHANGE PACKAGE NAME */
  static String? appleAppId = "";

  static String? appVersion = "1.0.0";
  static String? appBuildNumber = "1";

  /* SherdPrefrence OneSignal App ID keyId */
  static const String oneSignalAppIdKey = "onesignal_apid";

  static String? userID;
  static String? userImage;
  static String currencySymbol = "";
  static String currency = "";
  static bool isDark = false;
  static String radioType = "radio";
  static String podcastType = "podcast";

  // Toast Message All App

  static String androidAppShareUrlDesc =
      "Let me recommend you this application\n\n$androidAppUrl";
  static String iosAppShareUrlDesc =
      "Let me recommend you this application\n\n$iosAppUrl";

  static String androidAppUrl =
      "https://play.google.com/store/apps/details?id=${Constant.appPackageName}";
  static String iosAppUrl =
      "https://apps.apple.com/us/app/id${Constant.appleAppId}";

  static int fixFourDigit = 1317;
  static int fixSixDigit = 161613;
  static int bannerDuration = 10000; // in milliseconds
  static int animationDuration = 800; // in milliseconds

  /* Live Event ArrayList Static */

  /* Show Ad By Type */
  static String rewardAdType = "rewardAd";
  static String interstialAdType = "interstialAd";

  /* Show Ad By Type */
  static String initialCountryCode = "IN";
  static String otpLoginType = "1";
  static String googleLoginType = "2";
  static String appleLoginType = "3";
  static String normalLoginType = "4";
}
