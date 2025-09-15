import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:just_audio/just_audio.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:yourappname/pages/liveevent.dart';
import 'package:yourappname/pages/nodata.dart';
import 'package:yourappname/pages/podcast.dart';
import 'package:yourappname/pages/viewall.dart';
import 'package:yourappname/pages/radiobyid.dart';
import 'package:yourappname/pages/login.dart';
import 'package:yourappname/pages/commonpage.dart';
import 'package:yourappname/music/musicdetails.dart';
import 'package:yourappname/pages/notification.dart';
import 'package:yourappname/pages/profile.dart';
import 'package:yourappname/pages/search.dart';
import 'package:yourappname/provider/generalprovider.dart';
import 'package:yourappname/provider/homeprovider.dart';
import 'package:yourappname/provider/musicdetailprovider.dart';
import 'package:yourappname/provider/profileprovider.dart';
import 'package:yourappname/provider/themeprovider.dart';
import 'package:yourappname/subscription/allpayment.dart';
import 'package:yourappname/subscription/subscription.dart';
import 'package:yourappname/utils/adhelper.dart';
import 'package:yourappname/utils/color.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/customwidget.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/utils/sharedpref.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/widget/myimage.dart';
import 'package:yourappname/widget/mynetworkimg.dart';
import 'package:yourappname/widget/mynetworkimg2.dart';
import 'package:yourappname/widget/mytext.dart';
import 'package:yourappname/model/sectionlistmodel.dart' as section;

ValueNotifier<AudioPlayer?> currentlyPlaying = ValueNotifier(null);
const double playerMinHeight = 100;
const miniplayerPercentageDeclaration = 0.6;
late ConcatenatingAudioSource playlist;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  SharedPref sharedpre = SharedPref();
  late ScrollController _scrollController;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String aboutus = "";
  String termscondition = "";
  String privacypolicy = "";
  final GlobalKey<ScaffoldState> drawerkey = GlobalKey<ScaffoldState>();
  double ratingValue = 0.0;
  CarouselSliderController pageController = CarouselSliderController();
  late ConcatenatingAudioSource playlist;

  /* Provider */
  late GeneralProvider generalProvider;
  late HomeProvider homeProvider;
  late ProfileProvider profileprovider;

  @override
  initState() {
    super.initState();
    generalProvider = Provider.of<GeneralProvider>(context, listen: false);
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    profileprovider = Provider.of<ProfileProvider>(context, listen: false);
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getApi();
    });
    if (!kIsWeb) {
      OneSignal.Notifications.addClickListener(_handleNotificationOpened);
    }
  }

  getApi() async {
    pushNotification();
    homeProvider.setLoading(true);
    if (Constant.userID != null) {
      await profileprovider.getProfile(context);
    } else {
      profileprovider.clearProvider();
      Utils.updatePremium("0");
      if (!mounted) return;
      Utils.loadAds(context);
    }
    /* Radio Api */
    try {
      _fetchData(0);
      await generalProvider.getPages();
      await generalProvider.getSocialLink();
      homeProvider.setLoading(false);
    } catch (e) {
      printLog("Error Api ====>${e.toString()}");
      homeProvider.setLoading(false);
    }
  }

  pushNotification() async {
    String oneSignalAppId = await sharedpre.read(Constant.oneSignalAppIdKey);
    /*  Push Notification Method OneSignal Start */
    if (!kIsWeb) {
      OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
      // Initialize OneSignal
      printLog("OneSignal PushNotification===> $oneSignalAppId");
      OneSignal.initialize(oneSignalAppId);
      OneSignal.Notifications.requestPermission(false);
      OneSignal.Notifications.addPermissionObserver((state) {
        printLog("Has permission ==> $state");
      });
      OneSignal.User.pushSubscription.addObserver((state) {
        printLog(
            "pushSubscription state ==> ${state.current.jsonRepresentation()}");
      });
      OneSignal.Notifications.addForegroundWillDisplayListener((event) {
        /// preventDefault to not display the notification
        event.preventDefault();
        // Do async work
        /// notification.display() to display after preventing default
        event.notification.display();
      });
    }
/*  Push Notification Method OneSignal End */
  }

  // What to do when the user opens/taps on a notification
  _handleNotificationOpened(OSNotificationClickEvent result) {
    /* id, image, name, song_url */

    printLog(
        "setNotificationOpenedHandler additionalData ===> ${result.notification.additionalData.toString()}");
    printLog(
        "setNotificationOpenedHandler id ===> ${result.notification.additionalData?['id']}");
    printLog(
        "setNotificationOpenedHandler image ===> ${result.notification.additionalData?['image']}");
    printLog(
        "setNotificationOpenedHandler name ===> ${result.notification.additionalData?['name']}");
    printLog(
        "setNotificationOpenedHandler song_url ===> ${result.notification.additionalData?['song_url']}");

    if (result.notification.additionalData?['id'] != null &&
        result.notification.additionalData?['song_url'] != null) {
      String? songID =
          result.notification.additionalData?['id'].toString() ?? "";
      String? songImage =
          result.notification.additionalData?['image'].toString() ?? "";
      String? songName =
          result.notification.additionalData?['name'].toString() ?? "";
      String? songUrl =
          result.notification.additionalData?['song_url'].toString() ?? "";
      printLog("songID    =====> $songID");
      printLog("songImage =====> $songImage");
      printLog("songName  =====> $songName");
      printLog("songUrl   =====> $songUrl");
      musicManager.playSingleSong(songID, songName, songUrl, songImage, "");
    }
  }

  _scrollListener() async {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange &&
        (homeProvider.sectioncurrentPage ?? 0) <
            (homeProvider.sectiontotalPage ?? 0)) {
      await homeProvider.setLoadMore(true);
      _fetchData(homeProvider.sectioncurrentPage ?? 0);
    }
  }

  Future<void> _fetchData(int? nextPage) async {
    printLog("isMorePage  ======> ${homeProvider.sectionisMorePage}");
    printLog("currentPage ======> ${homeProvider.sectioncurrentPage}");
    printLog("totalPage   ======> ${homeProvider.sectiontotalPage}");
    printLog("nextpage   ======> $nextPage");
    printLog("Call MyCourse");
    printLog("Pageno:== ${(nextPage ?? 0) + 1}");
    await homeProvider.getBanner(0);
   
    await homeProvider.getSeactionList((nextPage ?? 0) + 1);
    await homeProvider.setLoadMore(false);
  }

  @override
  void dispose() {
    super.dispose();
    homeProvider.clearProvider();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        exitDilog(context);
      },
      child: Stack(
        children: [
          Scaffold(
            key: drawerkey,
            drawerEnableOpenDragGesture: true,
            drawer: buildDrawer(),
            body: Column(
              children: [
                appBar(context),
                Consumer<HomeProvider>(builder: (context, homeprovider, child) {
                  if ((homeprovider.bannerModel.result == null ||
                          (homeprovider.bannerModel.result?.length ?? 0) ==
                              0) &&
                      (homeprovider.sectionList?.length ?? 0) == 0 &&
                      !homeprovider.bannerLoading &&
                      !homeprovider.sectionLoading) {
                    return const Center(
                      child: NoData(text: "", subTitle: ""),
                    );
                  } else {
                    return Expanded(
                      child: RefreshIndicator(
                        backgroundColor: white,
                        color: colorAccent,
                        displacement: 70,
                        edgeOffset: 1.0,
                        triggerMode: RefreshIndicatorTriggerMode.anywhere,
                        strokeWidth: 3,
                        onRefresh: () async {
                          homeProvider.clearProvider();
                          _fetchData(0);
                        },
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          controller: _scrollController,
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            children: [
                              banner(),
                              buildPage(),
                              Utils.showBannerAd(context),
                              ValueListenableBuilder(
                                valueListenable: currentlyPlaying,
                                builder: (BuildContext context,
                                    AudioPlayer? audioObject, Widget? child) {
                                  if (audioObject?.audioSource != null) {
                                    return const SizedBox(height: 100);
                                  } else {
                                    return const SizedBox.shrink();
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                }),
              ],
            ),
          ),
          _buildMusicPanel(context),
        ],
      ),
    );
  }

  /* Drawer & AppBar Start */

  Widget buildDrawer() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(30),
        bottomRight: Radius.circular(30),
      ),
      child: Drawer(
        elevation: 0,
        width: MediaQuery.of(context).size.width * 0.80,
        child: Column(
          children: [
            Expanded(
              child: SafeArea(
                child: Consumer<GeneralProvider>(
                    builder: (context, themeprovider, child) {
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        Consumer<ThemeProvider>(
                            builder: (context, themeprovider, child) {
                          return InkWell(
                            focusColor: transparent,
                            splashColor: transparent,
                            hoverColor: transparent,
                            highlightColor: transparent,
                            onTap: () {},
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                              height: 60,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        MyImage(
                                          width: 25,
                                          height: 25,
                                          imagePath: "ic_darkmode.png",
                                          color: colorPrimary,
                                        ),
                                        SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.05),
                                        MyText(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .surface,
                                          text: "darkmode",
                                          textalign: TextAlign.center,
                                          multilanguage: true,
                                          fontsize: Dimens.textTitle,
                                          inter: 1,
                                          maxline: 2,
                                          fontwaight: FontWeight.w500,
                                          overflow: TextOverflow.ellipsis,
                                          fontstyle: FontStyle.normal,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Switch(
                                    activeColor: black,
                                    activeTrackColor: gray,
                                    inactiveTrackColor: gray,
                                    value: Constant.isDark,
                                    onChanged: (value) async {
                                      themeprovider.changeTheme(value);
                                      await sharedpre.remove("isdark");
                                      await sharedpre.saveBool("isdark", value);

                                      printLog(
                                          "ISDARK==> ${sharedpre.readBool("isdark").toString()}");
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                        buildDrawerItem(
                          "ic_podcast.png",
                          "",
                          "playlist",
                          true,
                          () {
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            }
                            AdHelper.showFullscreenAd(
                              context,
                              Constant.rewardAdType,
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return const Podcast();
                                    },
                                  ),
                                );
                              },
                            );
                          },
                        ),
                        divider(),
                        buildDrawerItem(
                          "ic_liveevent.png",
                          "",
                          "myfavorites",
                          true,
                          () async {
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            }
                            AdHelper.showFullscreenAd(
                              context,
                              Constant.rewardAdType,
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return const LiveEvent();
                                    },
                                  ),
                                );
                              },
                            );
                          },
                        ),
                        divider(),
                        buildDrawerItem(
                          "ic_subscription.png",
                          "",
                          "subsciption",
                          true,
                          () async {
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            }
                            AdHelper.showFullscreenAd(
                              context,
                              Constant.rewardAdType,
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return const Subscription(openFrom: '');
                                    },
                                  ),
                                );
                              },
                            );
                          },
                        ),
                        divider(),
                        buildDrawerItem(
                            "ic_language.png", "", "changelanguage", true, () {
                          _languageChangeDialog();
                        }),
                        divider(),
                        buildDrawerItem("ic_rateapp.png", "", "rateapp", true,
                            () {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          }
                          showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) {
                                return Dialog(
                                  elevation: 5,
                                  insetPadding: const EdgeInsets.all(30),
                                  insetAnimationCurve: Curves.easeInExpo,
                                  insetAnimationDuration:
                                      const Duration(seconds: 1),
                                  backgroundColor: Colors.transparent,
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: MediaQuery.of(context).size.height *
                                        0.35,
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: white,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        RatingBar(
                                          initialRating: 0.0,
                                          direction: Axis.horizontal,
                                          allowHalfRating: true,
                                          itemSize: 45,
                                          glowColor: colorPrimary,
                                          unratedColor: gray,
                                          glow: false,
                                          itemCount: 5,
                                          ratingWidget: RatingWidget(
                                            full: const Icon(
                                              Icons.star,
                                              color: colorPrimary,
                                            ),
                                            half: const Icon(Icons.star_half,
                                                color: colorPrimary),
                                            empty: const Icon(Icons.star_border,
                                                color: lightgray),
                                          ),
                                          onRatingUpdate: (double value) {
                                            printLog("rating=> $value");
                                            ratingValue = value;
                                          },
                                        ),
                                        MyText(
                                            color: black,
                                            text: "enjoyingmyradio",
                                            textalign: TextAlign.center,
                                            fontsize: Dimens.textBig,
                                            maxline: 1,
                                            multilanguage: true,
                                            inter: 1,
                                            fontwaight: FontWeight.w700,
                                            overflow: TextOverflow.ellipsis,
                                            fontstyle: FontStyle.normal),
                                        MyText(
                                            color: lightgray,
                                            text:
                                                "tapastartorateitontheappstore",
                                            textalign: TextAlign.center,
                                            multilanguage: true,
                                            fontsize: Dimens.textMedium,
                                            inter: 1,
                                            maxline: 2,
                                            fontwaight: FontWeight.w500,
                                            overflow: TextOverflow.ellipsis,
                                            fontstyle: FontStyle.normal),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            InkWell(
                                              focusColor: transparent,
                                              splashColor: transparent,
                                              hoverColor: transparent,
                                              highlightColor: transparent,
                                              onTap: () async {
                                                if (ratingValue == 0.0) {
                                                  Utils.showToast(
                                                      "Please Enter Your Rating");
                                                } else {
                                                  // App Rating Api Call After Button Click
                                                  printLog(
                                                      "Clicked on rateApp");
                                                  await Utils.redirectToStore();
                                                }
                                              },
                                              child: Container(
                                                width: 120,
                                                height: 45,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  gradient:
                                                      const LinearGradient(
                                                          colors: [
                                                        colorAccent,
                                                        colorPrimary
                                                      ],
                                                          begin: Alignment
                                                              .centerLeft,
                                                          end: Alignment
                                                              .centerRight),
                                                  borderRadius:
                                                      BorderRadius.circular(50),
                                                ),
                                                child: MyText(
                                                    color: white,
                                                    text: "submit",
                                                    textalign: TextAlign.center,
                                                    fontsize: Dimens.textTitle,
                                                    inter: 1,
                                                    multilanguage: true,
                                                    maxline: 2,
                                                    fontwaight: FontWeight.w600,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    fontstyle:
                                                        FontStyle.normal),
                                              ),
                                            ),
                                            InkWell(
                                              focusColor: transparent,
                                              splashColor: transparent,
                                              hoverColor: transparent,
                                              highlightColor: transparent,
                                              onTap: () {
                                                Navigator.pop(context);
                                              },
                                              child: Container(
                                                width: 120,
                                                height: 45,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: gray, width: 1),
                                                  borderRadius:
                                                      BorderRadius.circular(50),
                                                ),
                                                child: MyText(
                                                    color: gray,
                                                    text: "cancel",
                                                    textalign: TextAlign.center,
                                                    fontsize: Dimens.textTitle,
                                                    multilanguage: true,
                                                    inter: 1,
                                                    maxline: 2,
                                                    fontwaight: FontWeight.w600,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    fontstyle:
                                                        FontStyle.normal),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              });
                        }),
                        divider(),
                        buildDrawerItem("ic_share.png", "", "shareapp", true,
                            () async {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          }
                          await Utils.shareApp(Platform.isIOS
                              ? Constant.iosAppShareUrlDesc
                              : Constant.androidAppShareUrlDesc);
                        }),
                        divider(),
                        _buildPages(),
                        _buildSocialLink(),
                      ],
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 10),
            InkWell(
              focusColor: transparent,
              splashColor: transparent,
              hoverColor: transparent,
              highlightColor: transparent,
              onTap: () {
                printLog("userid=>${Constant.userID}");
                if (Constant.userID == null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return const Login();
                      },
                    ),
                  );
                } else {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(25),
                      ),
                    ),
                    builder: (context) {
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.25,
                        color: white,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            MyText(
                              color: black,
                              text: "areyousurewanttologout",
                              multilanguage: true,
                              textalign: TextAlign.center,
                              fontsize: Dimens.textBig,
                              inter: 1,
                              maxline: 6,
                              fontwaight: FontWeight.w500,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                InkWell(
                                  focusColor: transparent,
                                  splashColor: transparent,
                                  hoverColor: transparent,
                                  highlightColor: transparent,
                                  onTap: () async {
                                    // Firebase Signout
                                    await _auth.signOut();
                                    await GoogleSignIn().signOut();
                                    await Utils.setUserId(null);
                                    getApi();
                                    if (!context.mounted) return;
                                    Navigator.pop(context);
                                    if (!mounted) return;
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return const Login();
                                        },
                                      ),
                                    );
                                  },
                                  child: Container(
                                    width: 100,
                                    height: MediaQuery.of(context).size.height *
                                        0.05,
                                    alignment: Alignment.center,
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          colorPrimary,
                                          colorPrimary,
                                        ],
                                        end: Alignment.bottomLeft,
                                        begin: Alignment.bottomRight,
                                      ),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(50)),
                                    ),
                                    child: MyText(
                                        color: white,
                                        text: "yes",
                                        multilanguage: true,
                                        textalign: TextAlign.center,
                                        fontsize: Dimens.textTitle,
                                        inter: 1,
                                        maxline: 6,
                                        fontwaight: FontWeight.w600,
                                        overflow: TextOverflow.ellipsis,
                                        fontstyle: FontStyle.normal),
                                  ),
                                ),
                                InkWell(
                                  focusColor: transparent,
                                  splashColor: transparent,
                                  hoverColor: transparent,
                                  highlightColor: transparent,
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    width: 100,
                                    height: MediaQuery.of(context).size.height *
                                        0.05,
                                    alignment: Alignment.center,
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          colorPrimary,
                                          colorPrimary,
                                        ],
                                        end: Alignment.bottomLeft,
                                        begin: Alignment.bottomRight,
                                      ),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(50)),
                                    ),
                                    child: MyText(
                                        color: white,
                                        text: "no",
                                        multilanguage: true,
                                        textalign: TextAlign.center,
                                        fontsize: Dimens.textTitle,
                                        inter: 1,
                                        maxline: 6,
                                        fontwaight: FontWeight.w600,
                                        overflow: TextOverflow.ellipsis,
                                        fontstyle: FontStyle.normal),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      );
                    },
                  );
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
                child: Consumer<HomeProvider>(
                  builder: (context, homeprovider, child) {
                    return MyText(
                      color: white,
                      multilanguage: true,
                      text: Constant.userID != null ? "logout" : "login",
                      fontwaight: FontWeight.w600,
                      fontsize: Dimens.textBig,
                      inter: 1,
                      fontstyle: FontStyle.normal,
                      maxline: 1,
                      overflow: TextOverflow.ellipsis,
                      textalign: TextAlign.center,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),
            MyText(
              color: lightgray,
              text: "App Version : ${Constant.appVersion}",
              fontwaight: FontWeight.w500,
              fontsize: Dimens.textSmall,
              inter: 1,
              fontstyle: FontStyle.normal,
              maxline: 1,
              overflow: TextOverflow.ellipsis,
              textalign: TextAlign.center,
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget buildDrawerItem(String icon, String iconType, String name,
      bool isMultilang, dynamic onTap) {
    return InkWell(
      focusColor: transparent,
      splashColor: transparent,
      hoverColor: transparent,
      highlightColor: transparent,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
        height: 60,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: transparent,
              ),
              child: (iconType == "url")
                  ? MyNetworkImg2(
                      imgWidth: 30,
                      imgHeight: 30,
                      imageUrl: icon,
                      fit: BoxFit.contain,
                      // color: Theme.of(context).colorScheme.surface,
                      color: colorPrimary,
                    )
                  : MyImage(
                      width: 30,
                      height: 30,
                      imagePath: icon,
                      color: colorPrimary,
                    ),
            ),
            SizedBox(width: MediaQuery.of(context).size.width * 0.05),
            MyText(
              color: Theme.of(context).colorScheme.surface,
              text: name,
              textalign: TextAlign.center,
              multilanguage: isMultilang,
              fontsize: Dimens.textTitle,
              inter: 1,
              maxline: 2,
              fontwaight: FontWeight.w500,
              overflow: TextOverflow.ellipsis,
              fontstyle: FontStyle.normal,
            ),
          ],
        ),
      ),
    );
  }


Widget appBar(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  final screenHeight = MediaQuery.of(context).size.height;

  return Container(
    width: double.infinity,
    constraints: const BoxConstraints(minHeight: 0),
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [colorBlack, colorGolden],
        end: Alignment.bottomLeft,
        begin: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(25),
        bottomRight: Radius.circular(25),
      ),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppBar(
          backgroundColor: transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: transparent,
          systemOverlayStyle:
              const SystemUiOverlayStyle(statusBarColor: colorPrimary),
          titleSpacing: screenWidth * 0.02, 
          leading: IconButton(
            icon: Icon(Icons.menu, color: white, size: screenWidth * 0.07),
            onPressed: () {
              drawerkey.currentState?.openDrawer();
            },
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              MyText(
                color: white,
                multilanguage: true,
                text: "Gradiente Music",
                textalign: TextAlign.center,
                fontsize: screenWidth * 0.05, // responsive font size
                inter: 1,
                maxline: 2,
                fontwaight: FontWeight.w500,
                overflow: TextOverflow.ellipsis,
                fontstyle: FontStyle.normal,
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  if (Constant.userID == null) {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => const Login()));
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const NotificationPage()),
                    );
                  }
                },
                icon: Icon(
                  Icons.notifications_outlined,
                  color: white,
                  size: screenWidth * 0.07, // responsive icon size
                ),
              ),
              SizedBox(width: screenWidth * 0.01),
              InkWell(
                focusColor: transparent,
                splashColor: transparent,
                hoverColor: transparent,
                highlightColor: transparent,
                onTap: () {
                  if (Constant.userID == null) {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => const Login()));
                  } else {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Profile()));
                  }
                },
                child: Constant.userID == null
                    ? MyImage(
                        width: screenWidth * 0.08,
                        height: screenWidth * 0.08,
                        imagePath: "ic_userprofile.png",
                      )
                    : Container(
                        padding: EdgeInsets.all(screenWidth * 0.005),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(
                            color: white,
                            width: screenWidth * 0.005,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: MyNetworkImage(
                            imgWidth: screenWidth * 0.08,
                            imgHeight: screenWidth * 0.08,
                            fit: BoxFit.cover,
                            imageUrl: Constant.userImage ?? "",
                          ),
                        ),
                      ),
              ),
              SizedBox(width: screenWidth * 0.01),
            ],
          ),
          centerTitle: false,
        ),
        SizedBox(height: screenHeight * 0.01), // responsive spacing
        Container(
          width: screenWidth,
          padding: EdgeInsets.fromLTRB(
              screenWidth * 0.04, 0, screenWidth * 0.04, screenHeight * 0.015),
          alignment: Alignment.center,
          child: TextFormField(
            textAlign: TextAlign.left,
            keyboardType: TextInputType.text,
            readOnly: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return const Search();
                  },
                ),
              );
            },
            decoration: InputDecoration(
              prefixIcon: Container(
                width: screenWidth * 0.1,
                alignment: Alignment.center,
                child: MyImage(
                  width: screenWidth * 0.05,
                  height: screenWidth * 0.05,
                  imagePath: "ic_search.png",
                  color: lightgray,
                ),
              ),
              hintText: Locales.string(context, "search"),
              hintStyle: Utils.googleFontStyle(
                  1,
                  screenWidth * 0.045, // responsive hint text
                  FontStyle.normal,
                  lightgray,
                  FontWeight.w400),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(screenWidth * 0.08),
                borderSide: BorderSide.none,
              ),
              filled: true,
              contentPadding: EdgeInsets.all(screenWidth * 0.025),
              fillColor: white,
            ),
          ),
        ),
      ],
    ),
  );
}


  /* Drawer & AppBar End */

  Widget buildPage() {
    return Consumer<HomeProvider>(builder: (context, homeprovider, child) {
      if (homeprovider.sectionLoading && !homeprovider.loadmore) {
        return commanShimmer();
      } else {
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              setSectioByType(),
              if (homeProvider.loadmore)
                SizedBox(
                  height: 50,
                  child: Utils.pageLoader(),
                )
              else
                const SizedBox.shrink(),
            ],
          ),
        );
      }
    });
  }

  Widget setSectioByType() {
    if (homeProvider.sectionListModel.status == 200 &&
        homeProvider.sectionList != null) {
      if ((homeProvider.sectionList?.length ?? 0) > 0) {
        return MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: ListView.builder(
            itemCount: homeProvider.sectionList?.length ?? 0,
            shrinkWrap: true,
            reverse: false,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (BuildContext context, int index) {
              if (homeProvider.sectionList?[index].data != null &&
                  (homeProvider.sectionList?[index].data?.length ?? 0) > 0) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 25, 15, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                 const SizedBox(height: 18),
                                 ///changed herrrreeeeeeeeeeeeeeeeeeeeeeeeee==================================>
                                 //////changed herrrreeeeeeeeeeeeeeeeeeeeeeeeee===============================>
                                 //////changed herrrreeeeeeeeeeeeeeeeeeeeeeeeee===============================>
                                 //////changed herrrreeeeeeeeeeeeeeeeeeeeeeeeee===============================>
                                 //////changed herrrreeeeeeeeeeeeeeeeeeeeeeeeee===============================>
                                 //////changed herrrreeeeeeeeeeeeeeeeeeeeeeeeee===============================>
                                 ///changed herrrreeeeeeeeeeeeeeeeeeeeeeeeee==================================>
                                MyText(
                                    color:
                                        Theme.of(context).colorScheme.surface,
                                    text: homeProvider.sectionList?[index].title
                                            .toString() ??
                                        "",
                                    fontsize: Dimens.textBig,
                                    fontwaight: FontWeight.w600,
                                    maxline: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textalign: TextAlign.start,
                                    fontstyle: FontStyle.normal,
                                    multilanguage: false),
                                const SizedBox(height: 5),
                                MyText(
                                    color: gray,
                                    multilanguage: false,
                                    text: homeProvider
                                            .sectionList?[index].subTitle
                                            .toString() ??
                                        "",
                                    textalign: TextAlign.center,
                                    fontsize: Dimens.textExtraSmall,
                                    maxline: 1,
                                    fontwaight: FontWeight.w400,
                                    overflow: TextOverflow.ellipsis,
                                    fontstyle: FontStyle.normal),
                              ],
                            ),
                          ),
                          homeProvider.sectionList?[index].viewAll == 1
                              ? InkWell(
                                  onTap: () {
                                    AdHelper.showFullscreenAd(
                                        context, Constant.interstialAdType, () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return ViewAll(
                                              sectionId: homeProvider
                                                      .sectionList?[index].id
                                                      .toString() ??
                                                  "",
                                              appbarTitle: homeProvider
                                                      .sectionList?[index].title
                                                      .toString() ??
                                                  "",
                                              isTitleMultiLang: false,
                                              screenLayout: homeProvider
                                                      .sectionList?[index]
                                                      .screenLayout
                                                      .toString() ??
                                                  "",
                                              sectionType: homeProvider
                                                      .sectionList?[index]
                                                      .type ??
                                                  0,
                                            );
                                          },
                                        ),
                                      );
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: MyText(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surface,
                                        text: "viewall",
                                        fontsize: Dimens.textMedium,
                                        fontwaight: FontWeight.w500,
                                        maxline: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textalign: TextAlign.right,
                                        fontstyle: FontStyle.normal,
                                        multilanguage: true),
                                  ))
                              : const SizedBox.shrink(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: getRemainingDataHeight(
                          sectionindex: index,
                          screenLayout: homeProvider
                                  .sectionList?[index].screenLayout
                                  .toString() ??
                              "",
                          type: homeProvider.sectionList?[index].type ?? 0,
                          sectionList: homeProvider.sectionList ?? []),
                      child: setSectionData(
                          index: index,
                          type: homeProvider.sectionList?[index].type ?? 0,
                          sectionList: homeProvider.sectionList ?? []),
                    ),
                  ],
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
        );
      } else {
        return const SizedBox.shrink();
      }
    } else {
      return const SizedBox.shrink();
    }
  }

  double getRemainingDataHeight(
      {int? sectionindex,
      int? type,
      String? screenLayout,
      List<section.Result>? sectionList}) {
    if (type == 1) {
      if (screenLayout == "sqaure") {
        return Dimens.squareRadioHeight;
      } else if (screenLayout == "landscape") {
        return Dimens.landscapRadioHeight;
      } else if (screenLayout == "portrait") {
        return Dimens.portraitRadioHeight;
      } else {
        return 0.0;
      }
    } else if (type == 2) {
      if (screenLayout == "sqaure") {
        return Dimens.squarePodcastHeight;
      } else if (screenLayout == "landscape") {
        return Dimens.landscapPodcastHeight;
      } else if (screenLayout == "portrait") {
        return Dimens.portraitPodcastHeight;
      } else {
        return 0.0;
      }
    } else {
      if (screenLayout == "category") {
        return Dimens.categoryheight;
      } else if (screenLayout == "language") {
        return Dimens.languageheight;
      } else if (screenLayout == "artist") {
        return Dimens.artistheight;
      } else if (screenLayout == "city") {
        return Dimens.cityheight;
      } else if (screenLayout == "live_event") {
        return Dimens.liveEventheight;
      } else {
        return 0.0;
      }
    }
  }

  Widget setSectionData(
      {required int index,
      required int type,
      required List<section.Result>? sectionList}) {
    if (type == 1) {
      if ((sectionList?[index].screenLayout.toString() ?? "") == "sqaure") {
        return squareRadio(index, sectionList);
      } else if ((sectionList?[index].screenLayout.toString() ?? "") ==
          "landscape") {
        return landscapRadio(index, sectionList);
      } else if ((sectionList?[index].screenLayout.toString() ?? "") ==
          "portrait") {
        return portraitRadio(index, sectionList);
      } else {
        return const SizedBox.shrink();
      }
    } else if (type == 2) {
      if ((sectionList?[index].screenLayout.toString() ?? "") == "sqaure") {
        return squarePodcast(index, sectionList);
      } else if ((sectionList?[index].screenLayout.toString() ?? "") ==
          "landscape") {
        return landscapPodcast(index, sectionList);
      } else if ((sectionList?[index].screenLayout.toString() ?? "") ==
          "portrait") {
        return portraitPodcast(index, sectionList);
      } else {
        return const SizedBox.shrink();
      }
    } else {
      if ((sectionList?[index].screenLayout.toString() ?? "") == "category") {
        return category(index, sectionList);
      } else if ((sectionList?[index].screenLayout.toString() ?? "") ==
          "language") {
        return language(index, sectionList);
      } else if ((sectionList?[index].screenLayout.toString() ?? "") ==
          "artist") {
        return artist(index, sectionList);
      } else if ((sectionList?[index].screenLayout.toString() ?? "") ==
          "city") {
        return city(index, sectionList);
      } else if ((sectionList?[index].screenLayout.toString() ?? "") ==
          "live_event") {
        return liveEvent(index, sectionList);
      } else {
        return const SizedBox.shrink();
      }
    }
  }

  /* ================= Banner Layout Start ================= */

  Widget banner() {
    return Consumer<HomeProvider>(builder: (context, homeprovider, child) {
      if (homeprovider.bannerLoading) {
        return bannerShimmer();
      } else {
        if (homeProvider.bannerModel.status == 200 &&
            homeProvider.bannerModel.result != null) {
          if ((homeProvider.bannerModel.result?.length ?? 0) > 0) {
            return SizedBox(
              width: MediaQuery.of(context).size.width,
              height: Dimens.homeBannerHeight,
              child: CarouselSlider.builder(
                itemCount: (homeprovider.bannerModel.result?.length ?? 0),
                carouselController: pageController,
                options: CarouselOptions(
                  initialPage: 0,
                  height: Dimens.homeBannerHeight,
                  enlargeCenterPage: false,
                  autoPlay: true,
                  autoPlayCurve: Curves.easeInOutQuart,
                  enableInfiniteScroll: false,
                  viewportFraction: 1.0,
                  autoPlayInterval:
                      Duration(milliseconds: Constant.bannerDuration),
                  autoPlayAnimationDuration:
                      Duration(milliseconds: Constant.animationDuration),
                  onPageChanged: (val, _) async {
                    await homeProvider.setCurrentBanner(val);
                  },
                ),
                itemBuilder:
                    (BuildContext context, int index, int pageViewIndex) {
                  return Container(
                    padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                    child: InkWell(
                      focusColor: transparent,
                      splashColor: transparent,
                      hoverColor: transparent,
                      highlightColor: transparent,
                      onTap: () async {










                        if (homeprovider.bannerModel.result?[index].type == 1) {
                          /* Radio Banner */
                          Utils.playAudio(
                              context,
                              "radio",
                              homeprovider
                                      .bannerModel.result?[index].isPremium ??
                                  0,
                              homeprovider.bannerModel.result?[index].isBuy ??
                                  0,
                              homeprovider.bannerModel.result?[index].image
                                      .toString() ??
                                  "",
                              homeprovider
                                      .bannerModel.result?[index].name
                                      .toString() ??
                                  "",
                              'homebanner',
                              homeprovider.bannerModel.result?[index].songUrl
                                      .toString() ??
                                  "",
                              homeprovider.bannerModel.result?[index].name
                                      .toString() ??
                                  "",
                              homeprovider
                                      .bannerModel.result?[index].name
                                      .toString() ??
                                  "",
                              homeprovider.bannerModel.result?[index].id
                                      .toString() ??
                                  "",
                              "",
                              index,
                              homeprovider.bannerModel.result?.toList() ?? []);
                        } else {
                          /* Podcast Banner */
                          final musicdetailProvider =
                              Provider.of<MusicDetailProvider>(context,
                                  listen: false);
                          await musicdetailProvider.getEpisodebyPodcastList(
                              homeprovider.bannerModel.result?[index].id
                                      .toString() ??
                                  "",
                              0);
                          if (!musicdetailProvider.loading) {
                            if (musicdetailProvider
                                        .getEpisodeByPodcstModel.status ==
                                    200 &&
                                ((musicdetailProvider.getEpisodeByPodcstModel
                                            .result?.length ??
                                        0) >
                                    0)) {
                              if (!context.mounted) return;
                              Utils.playAudio(
                                  context,
                                  "podcast",
                                  homeprovider.bannerModel.result?[index]
                                          .isPremium ??
                                      0,
                                  homeprovider
                                          .bannerModel.result?[index].isBuy ??
                                      0,
                                  homeprovider
                                          .bannerModel.result?[index].image
                                          .toString() ??
                                      "",
                                  homeprovider
                                          .bannerModel.result?[index].title
                                          .toString() ??
                                      "",
                                  '',
                                  musicdetailProvider
                                          .episodeList?[0].episodeAudio
                                          .toString() ??
                                      "",
                                  "",
                                  "",
                                  musicdetailProvider.episodeList?[0].id
                                          .toString() ??
                                      "",
                                  homeprovider.bannerModel.result?[index].id
                                          .toString() ??
                                      "",
                                  0,
                                  musicdetailProvider.episodeList?.toList() ??
                                      []);
                            }
                          }
                        }
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Stack(
                          children: [
                            MyNetworkImage(
                                fit: BoxFit.cover,
                                imgWidth: MediaQuery.of(context).size.width,
                                imgHeight: MediaQuery.of(context).size.height,
                                imageUrl: homeprovider
                                            .bannerModel.result?[index].type ==
                                        1
                                    ? (homeprovider
                                            .bannerModel.result?[index].image
                                            .toString() ??
                                        "")
                                    : (homeprovider.bannerModel.result?[index]
                                            .landscapeImg
                                            .toString() ??
                                        "")),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.center,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    transparent,
                                    transparent,
                                  ],
                                ),
                              ),
                            ),
                            Positioned.fill(
                              bottom: 13,
                              left: 13,
                              right: 13,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.fromLTRB(
                                            5, 1, 5, 1),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [colorAccent, colorPrimary],
                                            end: Alignment.bottomLeft,
                                            begin: Alignment.bottomRight,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(02),
                                        ),
                                        child: Center(
                                          child: MyText(
                                            color: white,
                                            text: homeprovider.bannerModel
                                                    .result?[index].languageName
                                                    .toString() ??
                                                "",
                                            textalign: TextAlign.center,
                                            fontsize: Dimens.textExtraSmall,
                                            inter: 1,
                                            maxline: 2,
                                            fontwaight: FontWeight.w400,
                                            overflow: TextOverflow.ellipsis,
                                            fontstyle: FontStyle.normal,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.50,
                                        child: MyText(
                                          color: white,
                                          text: homeprovider.bannerModel
                                                      .result?[index].type ==
                                                  1
                                              ? (homeprovider.bannerModel
                                                      .result?[index].name
                                                      .toString() ??
                                                  "")
                                              : (homeprovider.bannerModel
                                                      .result?[index].title
                                                      .toString() ??
                                                  ""),
                                          textalign: TextAlign.left,
                                          fontsize: Dimens.textTitle,
                                          inter: 1,
                                          maxline: 1,
                                          fontwaight: FontWeight.w700,
                                          overflow: TextOverflow.ellipsis,
                                          fontstyle: FontStyle.normal,
                                        ),
                                      ),
                                      MyText(
                                        color: white,
                                        text: homeprovider.bannerModel
                                                .result?[index].artistName
                                                .toString() ??
                                            "",
                                        textalign: TextAlign.center,
                                        fontsize: Dimens.textSmall,
                                        inter: 1,
                                        maxline: 2,
                                        fontwaight: FontWeight.w600,
                                        overflow: TextOverflow.ellipsis,
                                        fontstyle: FontStyle.normal,
                                      ),
                                    ],
                                  ),
                                  homeprovider.bannerModel.result?[index]
                                              .type !=
                                          1
                                      ? Container(
                                          height: 40,
                                          width: 40,
                                          alignment: Alignment.center,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: colorPrimary,
                                          ),
                                          child: MyImage(
                                            imagePath: "ic_podcast.png",
                                            height: 20,
                                            color: white,
                                            width: 20,
                                          ),
                                        )
                                      : MyImage(
                                          imagePath: "ic_play.png",
                                          height: 35,
                                          width: 35,
                                        ),
                                ],
                              ),
                            ),
                            homeprovider.bannerModel.result?[index].isPremium ==
                                        1 &&
                                    homeprovider
                                            .bannerModel.result?[index].isBuy ==
                                        0
                                ? Positioned.fill(
                                    top: 15,
                                    left: 15,
                                    right: 15,
                                    child: Align(
                                      alignment: Alignment.topLeft,
                                      child: MyImage(
                                          width: 20,
                                          height: 15,
                                          color: colorPrimary,
                                          imagePath: "ic_primium.png"),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          } else {
            return const SizedBox.shrink();
          }
        } else {
          return const SizedBox.shrink();
        }
      }
    });
  }

  Widget bannerShimmer() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
      child: CustomWidget.roundcorner(height: Dimens.homeBannerHeight),
    );
  }

  /* ================= Banner Layout End ================= */

  /* ================ Radio Layout's ================= */

  Widget squareRadio(int sectionindex, List<section.Result>? sectionList) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: Dimens.squareRadioHeight,
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: ListView.separated(
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
            scrollDirection: Axis.horizontal,
            itemCount: sectionList?[sectionindex].data?.length ?? 0,
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              return InkWell(
                focusColor: transparent,
                splashColor: transparent,
                hoverColor: transparent,
                highlightColor: transparent,
                onTap: () {
                  Utils.playAudio(
                      context,
                      "radio",
                      sectionList?[sectionindex].data?[index].isPremium ?? 0,
                      sectionList?[sectionindex].data?[index].isBuy ?? 0,
                      sectionList?[sectionindex]
                              .data?[index]
                              .image
                              .toString() ??
                          "",
                      sectionList?[sectionindex].data?[index].name.toString() ??
                          "",
                      'homebanner',
                      sectionList?[sectionindex]
                              .data?[index]
                              .songUrl
                              .toString() ??
                          "",
                      sectionList?[sectionindex]
                              .data?[index]
                              .languageName
                              .toString() ??
                          "",
                      sectionList?[sectionindex]
                              .data?[index]
                              .artistName
                              .toString() ??
                          "",
                      sectionList?[sectionindex].data?[index].id.toString() ??
                          "",
                      "",
                      index,
                      sectionList?[sectionindex].data ?? []);
                },
                child: Container(
                  alignment: Alignment.center,
                  width: Dimens.squareRadiowidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: MyNetworkImage(
                              imgWidth: MediaQuery.of(context).size.width,
                              imgHeight: 130,
                              imageUrl: sectionList?[sectionindex]
                                      .data?[index]
                                      .image
                                      .toString() ??
                                  "",
                              fit: BoxFit.cover,
                            ),
                          ),
                          sectionList?[sectionindex].data?[index].isPremium ==
                                      1 &&
                                  sectionList?[sectionindex]
                                          .data?[index]
                                          .isBuy ==
                                      0
                              ? Positioned.fill(
                                  top: 8,
                                  left: 8,
                                  right: 8,
                                  child: Align(
                                    alignment: Alignment.topLeft,
                                    child: Container(
                                        width: 30,
                                        height: 30,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                          color: colorPrimary,
                                        ),
                                        child: MyImage(
                                            width: 15,
                                            height: 15,
                                            color: white,
                                            imagePath: "ic_primium.png")),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ],
                      ),
                      const SizedBox(height: 8),
                      MyText(
                        color: Theme.of(context).colorScheme.surface,
                        text: sectionList?[sectionindex]
                                .data?[index]
                                .name
                                .toString() ??
                            "",
                        textalign: TextAlign.center,
                        fontsize: Dimens.textMedium,
                        inter: 1,
                        maxline: 2,
                        fontwaight: FontWeight.w500,
                        overflow: TextOverflow.ellipsis,
                        fontstyle: FontStyle.normal,
                      ),
                    ],
                  ),
                ),
              );
            }),
      ),
    );
  }

  Widget landscapRadio(int sectionindex, List<section.Result>? sectionList) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: Dimens.landscapRadioHeight,
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: ListView.separated(
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
            scrollDirection: Axis.horizontal,
            itemCount: sectionList?[sectionindex].data?.length ?? 0,
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              return InkWell(
                focusColor: transparent,
                splashColor: transparent,
                hoverColor: transparent,
                highlightColor: transparent,
                onTap: () async {
                  Utils.playAudio(
                      context,
                      "radio",
                      sectionList?[sectionindex].data?[index].isPremium ?? 0,
                      sectionList?[sectionindex].data?[index].isBuy ?? 0,
                      sectionList?[sectionindex]
                              .data?[index]
                              .image
                              .toString() ??
                          "",
                      sectionList?[sectionindex].data?[index].name.toString() ??
                          "",
                      'homebanner',
                      sectionList?[sectionindex]
                              .data?[index]
                              .songUrl
                              .toString() ??
                          "",
                      sectionList?[sectionindex]
                              .data?[index]
                              .languageName
                              .toString() ??
                          "",
                      sectionList?[sectionindex]
                              .data?[index]
                              .artistName
                              .toString() ??
                          "",
                      sectionList?[sectionindex].data?[index].id.toString() ??
                          "",
                      "",
                      index,
                      sectionList?[sectionindex].data?.toList() ?? []);
                },
                child: SizedBox(
                  width: Dimens.landscapRadiowidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: MyNetworkImage(
                              imgWidth: MediaQuery.of(context).size.width,
                              imgHeight: 100,
                              imageUrl: sectionList?[sectionindex]
                                      .data?[index]
                                      .image
                                      .toString() ??
                                  "",
                              fit: BoxFit.cover,
                            ),
                          ),
                          sectionList?[sectionindex].data?[index].isPremium ==
                                      1 &&
                                  sectionList?[sectionindex]
                                          .data?[index]
                                          .isBuy ==
                                      0
                              ? Positioned.fill(
                                  top: 5,
                                  left: 5,
                                  right: 5,
                                  child: Align(
                                    alignment: Alignment.topLeft,
                                    child: Container(
                                        width: 30,
                                        height: 30,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                          color: colorPrimary,
                                        ),
                                        child: MyImage(
                                            width: 15,
                                            height: 15,
                                            color: white,
                                            imagePath: "ic_primium.png")),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ],
                      ),
                      const SizedBox(height: 8),
                      MyText(
                        color: Theme.of(context).colorScheme.surface,
                        text: sectionList?[sectionindex]
                                .data?[index]
                                .name
                                .toString() ??
                            "",
                        textalign: TextAlign.left,
                        fontsize: Dimens.textMedium,
                        inter: 1,
                        maxline: 2,
                        fontwaight: FontWeight.w500,
                        overflow: TextOverflow.ellipsis,
                        fontstyle: FontStyle.normal,
                      ),
                    ],
                  ),
                ),
              );
            }),
      ),
    );
  }

  Widget portraitRadio(int sectionindex, List<section.Result>? sectionList) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: Dimens.portraitRadioHeight,
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: ListView.separated(
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
            scrollDirection: Axis.horizontal,
            itemCount: sectionList?[sectionindex].data?.length ?? 0,
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              return InkWell(
                focusColor: transparent,
                splashColor: transparent,
                hoverColor: transparent,
                highlightColor: transparent,
                onTap: () {
                  Utils.playAudio(
                      context,
                      "radio",
                      sectionList?[sectionindex].data?[index].isPremium ?? 0,
                      sectionList?[sectionindex].data?[index].isBuy ?? 0,
                      sectionList?[sectionindex]
                              .data?[index]
                              .image
                              .toString() ??
                          "",
                      sectionList?[sectionindex].data?[index].name.toString() ??
                          "",
                      'homebanner',
                      sectionList?[sectionindex]
                              .data?[index]
                              .songUrl
                              .toString() ??
                          "",
                      sectionList?[sectionindex]
                              .data?[index]
                              .languageName
                              .toString() ??
                          "",
                      sectionList?[sectionindex]
                              .data?[index]
                              .artistName
                              .toString() ??
                          "",
                      sectionList?[sectionindex].data?[index].id.toString() ??
                          "",
                      "",
                      index,
                      sectionList?[sectionindex].data ?? []);
                },
                child: SizedBox(
                  width: Dimens.portraitRadiowidth,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: MyNetworkImage(
                              imgWidth: MediaQuery.of(context).size.width,
                              imgHeight: 150,
                              imageUrl: sectionList?[sectionindex]
                                      .data?[index]
                                      .image
                                      .toString() ??
                                  "",
                              fit: BoxFit.cover,
                            ),
                          ),
                          sectionList?[sectionindex].data?[index].isPremium ==
                                      1 &&
                                  sectionList?[sectionindex]
                                          .data?[index]
                                          .isBuy ==
                                      0
                              ? Positioned.fill(
                                  top: 8,
                                  left: 8,
                                  right: 8,
                                  child: Align(
                                    alignment: Alignment.topLeft,
                                    child: Container(
                                        width: 30,
                                        height: 30,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                          color: colorPrimary,
                                        ),
                                        child: MyImage(
                                            width: 15,
                                            height: 15,
                                            color: white,
                                            imagePath: "ic_primium.png")),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ],
                      ),
                      const SizedBox(height: 8),
                      MyText(
                        color: Theme.of(context).colorScheme.surface,
                        text: sectionList?[sectionindex]
                                .data?[index]
                                .name
                                .toString() ??
                            "",
                        textalign: TextAlign.center,
                        fontsize: Dimens.textMedium,
                        inter: 1,
                        maxline: 2,
                        fontwaight: FontWeight.w500,
                        overflow: TextOverflow.ellipsis,
                        fontstyle: FontStyle.normal,
                      ),
                    ],
                  ),
                ),
              );
            }),
      ),
    );
  }

  /* ================== Radio Layout's ================= */

  /* ================ Podcast Layout's ================ */

  Widget squarePodcast(int sectionindex, List<section.Result>? sectionList) {
    return ListView.separated(
      separatorBuilder: (context, index) => const SizedBox(width: 8),
      scrollDirection: Axis.horizontal,
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
      itemCount: sectionList?[sectionindex].data?.length ?? 0,
      itemBuilder: (BuildContext context, int index) {
        return InkWell(
          onTap: () async {
            final musicdetailProvider =
                Provider.of<MusicDetailProvider>(context, listen: false);
            await musicdetailProvider.getEpisodebyPodcastList(
                sectionList?[sectionindex].data?[index].id.toString() ?? "", 0);

            if (!musicdetailProvider.loading) {
              if (musicdetailProvider.getEpisodeByPodcstModel.status == 200 &&
                  ((musicdetailProvider
                              .getEpisodeByPodcstModel.result?.length ??
                          0) >
                      0)) {
                if (!context.mounted) return;
                Utils.playAudio(
                    context,
                    "podcast",
                    sectionList?[sectionindex].data?[index].isPremium ?? 0,
                    sectionList?[sectionindex].data?[index].isBuy ?? 0,
                    sectionList?[sectionindex]
                            .data?[index]
                            .landscapeImg
                            .toString() ??
                        "",
                    sectionList?[sectionindex].data?[index].title.toString() ??
                        "",
                    '',
                    musicdetailProvider.episodeList?[0].episodeAudio
                            .toString() ??
                        "",
                    "",
                    "",
                    musicdetailProvider.episodeList?[0].id.toString() ?? "",
                    sectionList?[sectionindex].data?[index].id.toString() ?? "",
                    0,
                    musicdetailProvider.episodeList?.toList() ?? []);
              }
            }
          },
          child: SizedBox(
            width: 145,
            height: MediaQuery.sizeOf(context).height,
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      width: MediaQuery.sizeOf(context).width,
                      height: 145,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: colorPrimary.withValues(alpha: 0.40),
                      ),
                    ),
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          width: MediaQuery.sizeOf(context).width,
                          height: 140,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: colorPrimary.withValues(alpha: 0.30),
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: MyNetworkImage(
                              imgWidth: MediaQuery.sizeOf(context).width,
                              imgHeight: 135,
                              fit: BoxFit.cover,
                              imageUrl: sectionList?[sectionindex]
                                      .data?[index]
                                      .portraitImg
                                      .toString() ??
                                  ""),
                        ),
                      ),
                    ),
                    sectionList?[sectionindex].data?[index].isPremium == 1 &&
                            sectionList?[sectionindex].data?[index].isBuy == 0
                        ? Positioned.fill(
                            top: 8,
                            left: 8,
                            right: 8,
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Container(
                                  width: 30,
                                  height: 30,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    color: colorPrimary,
                                  ),
                                  child: MyImage(
                                      width: 15,
                                      height: 15,
                                      color: white,
                                      imagePath: "ic_primium.png")),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: MyText(
                      color: Theme.of(context).colorScheme.surface,
                      text: sectionList?[sectionindex]
                              .data?[index]
                              .title
                              .toString() ??
                          "",
                      fontsize: Dimens.textMedium,
                      fontwaight: FontWeight.w500,
                      maxline: 2,
                      overflow: TextOverflow.ellipsis,
                      textalign: TextAlign.left,
                      fontstyle: FontStyle.normal),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget landscapPodcast(int sectionindex, List<section.Result>? sectionList) {
    return ListView.separated(
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
        itemCount: sectionList?[sectionindex].data?.length ?? 0,
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            focusColor: transparent,
            splashColor: transparent,
            hoverColor: transparent,
            highlightColor: transparent,
            onTap: () async {
              final musicdetailProvider =
                  Provider.of<MusicDetailProvider>(context, listen: false);
              await musicdetailProvider.getEpisodebyPodcastList(
                  sectionList?[sectionindex].data?[index].id.toString() ?? "",
                  0);

              if (!musicdetailProvider.loading) {
                if (musicdetailProvider.getEpisodeByPodcstModel.status == 200 &&
                    ((musicdetailProvider
                                .getEpisodeByPodcstModel.result?.length ??
                            0) >
                        0)) {
                  if (!context.mounted) return;
                  Utils.playAudio(
                      context,
                      "podcast",
                      sectionList?[sectionindex].data?[index].isPremium ?? 0,
                      sectionList?[sectionindex].data?[index].isBuy ?? 0,
                      sectionList?[sectionindex]
                              .data?[index]
                              .landscapeImg
                              .toString() ??
                          "",
                      sectionList?[sectionindex]
                              .data?[index]
                              .title
                              .toString() ??
                          "",
                      '',
                      musicdetailProvider
                              .episodeList?[0].episodeAudio
                              .toString() ??
                          "",
                      "",
                      musicdetailProvider.episodeList?[0].description
                              .toString() ??
                          "",
                      musicdetailProvider.episodeList?[0].id.toString() ?? "",
                      sectionList?[sectionindex].data?[index].id.toString() ??
                          "",
                      0,
                      musicdetailProvider.episodeList?.toList() ?? []);
                }
              }
            },
            child: Container(
              width: 185,
              height: 150,
              margin: const EdgeInsets.fromLTRB(5, 0, 5, 0),
              alignment: Alignment.centerLeft,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: MyNetworkImage(
                            imgWidth: MediaQuery.sizeOf(context).width,
                            imgHeight: 110,
                            fit: BoxFit.cover,
                            imageUrl: sectionList?[sectionindex]
                                    .data?[index]
                                    .landscapeImg
                                    .toString() ??
                                ""),
                      ),
                      sectionList?[sectionindex].data?[index].isPremium == 1 &&
                              sectionList?[sectionindex].data?[index].isBuy == 0
                          ? Positioned.fill(
                              top: 15,
                              left: 15,
                              right: 15,
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: Container(
                                    width: 30,
                                    height: 30,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      color: colorPrimary,
                                    ),
                                    child: MyImage(
                                        width: 15,
                                        height: 15,
                                        color: white,
                                        imagePath: "ic_primium.png")),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Expanded(
                    child: MyText(
                        color: Theme.of(context).colorScheme.surface,
                        multilanguage: false,
                        text: sectionList?[sectionindex]
                                .data?[index]
                                .title
                                .toString() ??
                            "",
                        textalign: TextAlign.left,
                        fontsize: Dimens.textMedium,
                        inter: 1,
                        maxline: 2,
                        fontwaight: FontWeight.w500,
                        overflow: TextOverflow.ellipsis,
                        fontstyle: FontStyle.normal),
                  ),
                ],
              ),
            ),
          );
        });
  }

  Widget portraitPodcast(int sectionindex, List<section.Result>? sectionList) {
    return ListView.separated(
      separatorBuilder: (context, index) => const SizedBox(width: 8),
      scrollDirection: Axis.horizontal,
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
      itemCount: sectionList?[sectionindex].data?.length ?? 0,
      itemBuilder: (BuildContext context, int index) {
        return InkWell(
          onTap: () async {
            final musicdetailProvider =
                Provider.of<MusicDetailProvider>(context, listen: false);
            await musicdetailProvider.getEpisodebyPodcastList(
                sectionList?[sectionindex].data?[index].id.toString() ?? "", 0);

            if (!musicdetailProvider.loading) {
              if (musicdetailProvider.getEpisodeByPodcstModel.status == 200 &&
                  ((musicdetailProvider
                              .getEpisodeByPodcstModel.result?.length ??
                          0) >
                      0)) {
                if (!context.mounted) return;
                Utils.playAudio(
                    context,
                    "podcast",
                    sectionList?[sectionindex].data?[index].isPremium ?? 0,
                    sectionList?[sectionindex].data?[index].isBuy ?? 0,
                    sectionList?[sectionindex]
                            .data?[index]
                            .landscapeImg
                            .toString() ??
                        "",
                    sectionList?[sectionindex].data?[index].title.toString() ??
                        "",
                    '',
                    musicdetailProvider.episodeList?[0].episodeAudio
                            .toString() ??
                        "",
                    "",
                    "",
                    musicdetailProvider.episodeList?[0].id.toString() ?? "",
                    sectionList?[sectionindex].data?[index].id.toString() ?? "",
                    0,
                    musicdetailProvider.episodeList?.toList() ?? []);
              }
            }
          },
          child: SizedBox(
            width: 135,
            height: MediaQuery.sizeOf(context).height,
            child: Column(
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: MyNetworkImage(
                          imgWidth: MediaQuery.sizeOf(context).width,
                          imgHeight: 170,
                          fit: BoxFit.cover,
                          imageUrl: sectionList?[sectionindex]
                                  .data?[index]
                                  .portraitImg
                                  .toString() ??
                              ""),
                    ),
                    sectionList?[sectionindex].data?[index].isPremium == 1 &&
                            sectionList?[sectionindex].data?[index].isBuy == 0
                        ? Positioned.fill(
                            top: 8,
                            left: 8,
                            right: 8,
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Container(
                                  width: 30,
                                  height: 30,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    color: colorPrimary,
                                  ),
                                  child: MyImage(
                                      width: 15,
                                      height: 15,
                                      color: white,
                                      imagePath: "ic_primium.png")),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: MyText(
                      color: Theme.of(context).colorScheme.surface,
                      text: sectionList?[sectionindex]
                              .data?[index]
                              .title
                              .toString() ??
                          "",
                      fontsize: Dimens.textMedium,
                      inter: 1,
                      fontwaight: FontWeight.w500,
                      maxline: 2,
                      overflow: TextOverflow.ellipsis,
                      textalign: TextAlign.left,
                      fontstyle: FontStyle.normal),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

/* ============================ Podcast Layout's ============================ */

/* ============================ Other Layout Start ======================= */

  /* Category */
  Widget category(int sectionindex, List<section.Result>? sectionList) {
    return Column(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: Dimens.categoryheight,
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(9, 0, 9, 0),
              scrollDirection: Axis.horizontal,
              itemCount: sectionList?[sectionindex].data?.length ?? 0,
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: InkWell(
                    focusColor: transparent,
                    splashColor: transparent,
                    hoverColor: transparent,
                    highlightColor: transparent,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return RadioById(
                              itemId: sectionList?[sectionindex]
                                      .data?[index]
                                      .id
                                      .toString() ??
                                  "",
                              viewType: "category",
                              title: sectionList?[sectionindex]
                                      .data?[index]
                                      .name
                                      .toString() ??
                                  "",
                              languagegId: "",
                            );
                          },
                        ),
                      );
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.19,
                      height: MediaQuery.of(context).size.height * 0.15,
                      decoration: BoxDecoration(
                          color: Theme.of(context).secondaryHeaderColor,
                          borderRadius: BorderRadius.circular(25)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          MyNetworkImage(
                            imgWidth: 45,
                            imgHeight: 45,
                            imageUrl: sectionList?[sectionindex]
                                    .data?[index]
                                    .image
                                    .toString() ??
                                "",
                            fit: BoxFit.cover,
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.01),
                          Container(
                            padding: const EdgeInsets.fromLTRB(7, 0, 7, 0),
                            child: MyText(
                                color: Theme.of(context).colorScheme.surface,
                                text: sectionList?[sectionindex]
                                        .data?[index]
                                        .name
                                        .toString() ??
                                    "",
                                textalign: TextAlign.center,
                                fontsize: Dimens.textSmall,
                                inter: 1,
                                maxline: 1,
                                fontwaight: FontWeight.w500,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  /* Language */
  Widget language(int sectionindex, List<section.Result>? sectionList) {
    return SizedBox(
      height: Dimens.languageheight,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
        scrollDirection: Axis.horizontal,
        child: Wrap(spacing: -1, direction: Axis.vertical, children: [
          ...List.generate(
            sectionList?[sectionindex].data?.length ?? 0,
            (index) => InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return RadioById(
                        itemId: sectionList?[sectionindex]
                                .data?[index]
                                .id
                                .toString() ??
                            "",
                        viewType: "language",
                        title: sectionList?[sectionindex]
                                .data?[index]
                                .name
                                .toString() ??
                            "",
                        languagegId: sectionList?[sectionindex]
                                .data?[index]
                                .id
                                .toString() ??
                            "",
                      );
                    },
                  ),
                );
              },
              child: Stack(
                children: [
                  Container(
                    width: 140,
                    height: 40,
                    margin: const EdgeInsets.all(5),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: MyNetworkImage(
                          imgWidth: MediaQuery.of(context).size.width,
                          imgHeight: MediaQuery.of(context).size.height,
                          imageUrl: sectionList?[sectionindex]
                                  .data?[index]
                                  .image
                                  .toString() ??
                              "",
                          fit: BoxFit.cover),
                    ),
                  ),
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.center,
                      child: MyText(
                          color: white,
                          text: (sectionList?[sectionindex].data?[index].name ==
                                      "" ||
                                  sectionList?[sectionindex]
                                          .data?[index]
                                          .name
                                          .toString() ==
                                      "false")
                              ? "-"
                              : sectionList?[sectionindex]
                                      .data?[index]
                                      .name
                                      .toString() ??
                                  "",
                          fontsize: Dimens.textSmall,
                          overflow: TextOverflow.ellipsis,
                          maxline: 1,
                          fontwaight: FontWeight.w600,
                          textalign: TextAlign.center,
                          fontstyle: FontStyle.normal),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }

  /* City */
  Widget city(int sectionindex, List<section.Result>? sectionList) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: Dimens.cityheight,
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: ListView.separated(
          separatorBuilder: (context, index) => const SizedBox(width: 8),
          padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
          scrollDirection: Axis.horizontal,
          itemCount: sectionList?[sectionindex].data?.length ?? 0,
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            return InkWell(
              focusColor: transparent,
              splashColor: transparent,
              hoverColor: transparent,
              highlightColor: transparent,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return RadioById(
                        itemId: sectionList?[sectionindex]
                                .data?[index]
                                .id
                                .toString() ??
                            "",
                        viewType: "category",
                        title: sectionList?[sectionindex]
                                .data?[index]
                                .name
                                .toString() ??
                            "",
                        languagegId: "",
                      );
                    },
                  ),
                );
              },
              child: Container(
                width: 95,
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                    color: Theme.of(context).secondaryHeaderColor,
                    borderRadius: BorderRadius.circular(15)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                      child: MyNetworkImage(
                        imgWidth: MediaQuery.of(context).size.width,
                        imgHeight: 85,
                        imageUrl: sectionList?[sectionindex]
                                .data?[index]
                                .image
                                .toString() ??
                            "",
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.fromLTRB(7, 0, 7, 0),
                      child: MyText(
                          color: Theme.of(context).colorScheme.surface,
                          text: sectionList?[sectionindex]
                                  .data?[index]
                                  .name
                                  .toString() ??
                              "",
                          textalign: TextAlign.center,
                          fontsize: Dimens.textSmall,
                          inter: 1,
                          maxline: 1,
                          fontwaight: FontWeight.w500,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /* Artist */
  Widget artist(int sectionindex, List<section.Result>? sectionList) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: Dimens.artistheight,
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: sectionList?[sectionindex].data?.length,
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            return InkWell(
              focusColor: transparent,
              splashColor: transparent,
              hoverColor: transparent,
              highlightColor: transparent,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return RadioById(
                        itemId: sectionList?[sectionindex]
                                .data?[index]
                                .id
                                .toString() ??
                            "",
                        viewType: "artist",
                        title: sectionList?[sectionindex]
                                .data?[index]
                                .name
                                .toString() ??
                            "",
                        languagegId: "",
                      );
                    },
                  ),
                );
              },
              radius: 60.0,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(60),
                      child: MyNetworkImage(
                        imgWidth: 90,
                        imageUrl: sectionList?[sectionindex]
                                .data?[index]
                                .image
                                .toString() ??
                            "",
                        imgHeight: 90,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 0.005),
                    Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width * 0.25,
                      child: MyText(
                          color: Theme.of(context).colorScheme.surface,
                          inter: 1,
                          text: sectionList?[sectionindex]
                                  .data?[index]
                                  .name
                                  .toString() ??
                              "",
                          fontsize: Dimens.textMedium,
                          fontwaight: FontWeight.w500,
                          maxline: 1,
                          overflow: TextOverflow.ellipsis,
                          textalign: TextAlign.center,
                          fontstyle: FontStyle.normal),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /* Live Event  */
  Widget liveEvent(int sectionindex, List<section.Result>? sectionList) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: Dimens.liveEventheight,
      alignment: Alignment.centerLeft,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
        itemCount: sectionList?[sectionindex].data?.length ?? 0,
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          return InkWell(
            focusColor: transparent,
            splashColor: transparent,
            hoverColor: transparent,
            highlightColor: transparent,
            onTap: () async {
              if (Constant.userID == null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return const Login();
                    },
                  ),
                );
              } else {
                if (sectionList?[sectionindex].data?[index].isPaid == 1 &&
                    sectionList?[sectionindex].data?[index].isJoin == 0) {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return AllPayment(
                          payType: 'liveevent',
                          itemId: sectionList?[sectionindex]
                                  .data?[index]
                                  .id
                                  .toString() ??
                              '',
                          price: sectionList?[sectionindex]
                                  .data?[index]
                                  .price
                                  .toString() ??
                              '',
                          itemTitle: sectionList?[sectionindex]
                                  .data?[index]
                                  .title
                                  .toString() ??
                              '',
                          typeId: '',
                          contentType: sectionList?[sectionindex]
                                  .data?[index]
                                  .type
                                  .toString() ??
                              '',
                          productPackage: '',
                          currency: '',
                        );
                      },
                    ),
                  );
                } else {
                  if (sectionList?[sectionindex].data?[index].type == 1) {
                    /* Audio */
                    musicManager.playSingleSong(
                        sectionList?[sectionindex].data?[index].id.toString() ??
                            "",
                            
                        sectionList?[sectionindex]
                                .data?[index]
                                .title
                                .toString() ??
                            "",
                        sectionList?[sectionindex]
                                .data?[index]
                                .songUrl
                                .toString() ??
                            "",
                        sectionList?[sectionindex]
                                .data?[index]
                                .landscapeImg
                                .toString() ??
                            "",
                        "");
                  } else {
                    /* Video */
                    Utils.openPlayer(
                        context: context,
                        videoId: sectionList?[sectionindex]
                                .data?[index]
                                .id
                                .toString() ??
                            "",
                        videoUrl: sectionList?[sectionindex]
                                .data?[index]
                                .songUrl
                                .toString() ??
                            "",
                        vUploadType: "external",
                        videoThumb: sectionList?[sectionindex]
                                .data?[index]
                                .landscapeImg
                                .toString() ??
                            "",
                        stoptime: "",
                        iscontinueWatching: false);
                  }
                }
              }
            },
            child: Container(
              width: Dimens.liveEventWidth,
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: MyNetworkImage(
                            imgHeight: 140,
                            imageUrl: sectionList?[sectionindex]
                                    .data?[index]
                                    .landscapeImg
                                    .toString() ??
                                "",
                            fit: BoxFit.cover),
                      ),
                      Positioned.fill(
                        top: 5,
                        left: 5,
                        right: 5,
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                            width: 70,
                            height: 25,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: colorPrimary,
                            ),
                            child: MyText(
                                color: white,
                                multilanguage: true,
                                text: "live",
                                textalign: TextAlign.left,
                                fontsize: Dimens.textSmall,
                                maxline: 2,
                                fontwaight: FontWeight.w600,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal),
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          MyText(
                              color: Theme.of(context).colorScheme.surface,
                              multilanguage: false,
                              text: sectionList?[sectionindex]
                                      .data?[index]
                                      .title
                                      .toString() ??
                                  "",
                              textalign: TextAlign.left,
                              fontsize: Dimens.textSmall,
                              maxline: 2,
                              fontwaight: FontWeight.w600,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal),
                          const SizedBox(height: 5),
                          if (sectionList?[sectionindex]
                                      .data?[index]
                                      .isPaid
                                      .toString() ==
                                  "1" &&
                              sectionList?[sectionindex]
                                      .data?[index]
                                      .isJoin
                                      .toString() ==
                                  "0")
                            MyText(
                              color: colorPrimary,
                              inter: 1,
                              text:
                                  "${Constant.currencySymbol}${sectionList?[sectionindex].data?[index].price.toString() ?? ""}",
                              fontsize: Dimens.textTitle,
                              fontwaight: FontWeight.w700,
                              maxline: 2,
                              overflow: TextOverflow.ellipsis,
                              textalign: TextAlign.left,
                              fontstyle: FontStyle.normal,
                            )
                          else if (sectionList?[sectionindex]
                                      .data?[index]
                                      .isPaid
                                      .toString() ==
                                  "1" &&
                              sectionList?[sectionindex]
                                      .data?[index]
                                      .isJoin
                                      .toString() ==
                                  "1")
                            Container(
                              padding: const EdgeInsets.fromLTRB(5, 3, 5, 3),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: colorPrimary),
                              child: MyText(
                                color: white,
                                inter: 1,
                                text: "playyourevent",
                                fontsize: Dimens.textSmall,
                                multilanguage: true,
                                fontwaight: FontWeight.w600,
                                maxline: 2,
                                overflow: TextOverflow.ellipsis,
                                textalign: TextAlign.left,
                                fontstyle: FontStyle.normal,
                              ),
                            )
                          else
                            MyText(
                              color: colorPrimary,
                              inter: 1,
                              text: "free",
                              fontsize: Dimens.textTitle,
                              multilanguage: true,
                              fontwaight: FontWeight.w600,
                              maxline: 2,
                              overflow: TextOverflow.ellipsis,
                              textalign: TextAlign.left,
                              fontstyle: FontStyle.normal,
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

/* =================== Other Layout End ======================= */

  Widget divider() {
    return Container(
      color: lightgray,
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.fromLTRB(15, 0, 15, 0),
      height: 1,
    );
  }

  exitDilog(BuildContext buildContext) {
    return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          elevation: 16,
          backgroundColor: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.28,
            decoration: BoxDecoration(
                color: white, borderRadius: BorderRadius.circular(20)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                MyImage(
                  width: 70,
                  height: 70,
                  isAppIcon: true,
                  imagePath: "appicon.png",
                  fit: BoxFit.fill,
                ),
                const SizedBox(height: 15),
                MyText(
                  color: black,
                  text: "areyousurewanttoexit",
                  maxline: 1,
                  multilanguage: true,
                  fontwaight: FontWeight.w500,
                  fontsize: Dimens.textTitle,
                  overflow: TextOverflow.ellipsis,
                  textalign: TextAlign.center,
                  fontstyle: FontStyle.normal,
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    InkWell(
                      focusColor: transparent,
                      splashColor: transparent,
                      hoverColor: transparent,
                      highlightColor: transparent,
                      onTap: () {
                        exit(0);
                      },
                      child: Container(
                        width: 100,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                colorPrimary,
                                colorPrimary,
                              ],
                              end: Alignment.bottomLeft,
                              begin: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(50)),
                        child: MyText(
                          color: white,
                          text: "done",
                          multilanguage: true,
                          maxline: 1,
                          fontwaight: FontWeight.w500,
                          fontsize: Dimens.textMedium,
                          overflow: TextOverflow.ellipsis,
                          textalign: TextAlign.center,
                          fontstyle: FontStyle.normal,
                        ),
                      ),
                    ),
                    InkWell(
                      focusColor: transparent,
                      splashColor: transparent,
                      hoverColor: transparent,
                      highlightColor: transparent,
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 100,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                colorPrimary,
                                colorPrimary,
                              ],
                              end: Alignment.bottomLeft,
                              begin: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(50)),
                        child: MyText(
                          color: white,
                          text: "cancel",
                          multilanguage: true,
                          maxline: 1,
                          fontwaight: FontWeight.w500,
                          fontsize: Dimens.textMedium,
                          overflow: TextOverflow.ellipsis,
                          textalign: TextAlign.center,
                          fontstyle: FontStyle.normal,
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 5),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMusicPanel(context) {
    return ValueListenableBuilder(
      valueListenable: currentlyPlaying,
      builder: (BuildContext context, AudioPlayer? audioObject, Widget? child) {
        if (audioObject?.audioSource != null) {
          return const MusicDetails(
            ishomepage: true,
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  _languageChangeDialog() {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      backgroundColor: transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, state) {
            return DraggableScrollableSheet(
              initialChildSize: 0.55,
              minChildSize: 0.4,
              maxChildSize: 0.9,
              builder: (context, scrollController) {
                return ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    color: Theme.of(context).bottomSheetTheme.backgroundColor,
                    padding: const EdgeInsets.all(23),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyText(
                          color: Theme.of(context).colorScheme.surface,
                          text: "selectlanguage",
                          multilanguage: true,
                          textalign: TextAlign.start,
                          fontsize: Dimens.textTitle,
                          fontwaight: FontWeight.bold,
                          maxline: 1,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal,
                        ),

                        /* English */
                        Expanded(
                          child: SingleChildScrollView(
                            controller: scrollController,
                            child: Column(
                              children: [
                                const SizedBox(height: 20),
                                _buildLanguage(
                                  langName: "English",
                                  onClick: () {
                                    state(() {});
                                    LocaleNotifier.of(context)?.change('en');
                                    Navigator.pop(context);
                                  },
                                ),

                                /* Afrikaans */
                                const SizedBox(height: 20),
                                _buildLanguage(
                                  langName: "Afrikaans",
                                  onClick: () {
                                    state(() {});
                                    LocaleNotifier.of(context)?.change('af');
                                    Navigator.pop(context);
                                  },
                                ),

                                /* Arabic */
                                const SizedBox(height: 20),
                                _buildLanguage(
                                  langName: "Arabic",
                                  onClick: () {
                                    state(() {});
                                    LocaleNotifier.of(context)?.change('ar');
                                    Navigator.pop(context);
                                  },
                                ),

                                /* German */
                                const SizedBox(height: 20),
                                _buildLanguage(
                                  langName: "German",
                                  onClick: () {
                                    state(() {});
                                    LocaleNotifier.of(context)?.change('de');
                                    Navigator.pop(context);
                                  },
                                ),

                                /* Spanish */
                                const SizedBox(height: 20),
                                _buildLanguage(
                                  langName: "Spanish",
                                  onClick: () {
                                    state(() {});
                                    LocaleNotifier.of(context)?.change('es');
                                    Navigator.pop(context);
                                  },
                                ),

                                /* French */
                                const SizedBox(height: 20),
                                _buildLanguage(
                                  langName: "French",
                                  onClick: () {
                                    state(() {});
                                    LocaleNotifier.of(context)?.change('fr');
                                    Navigator.pop(context);
                                  },
                                ),

                                /* Gujarati */
                                const SizedBox(height: 20),
                                _buildLanguage(
                                  langName: "Gujarati",
                                  onClick: () {
                                    state(() {});
                                    LocaleNotifier.of(context)?.change('gu');
                                    Navigator.pop(context);
                                  },
                                ),

                                /* Hindi */
                                const SizedBox(height: 20),
                                _buildLanguage(
                                  langName: "Hindi",
                                  onClick: () {
                                    state(() {});
                                    LocaleNotifier.of(context)?.change('hi');
                                    Navigator.pop(context);
                                  },
                                ),

                                /* Indonesian */
                                const SizedBox(height: 20),
                                _buildLanguage(
                                  langName: "Indonesian",
                                  onClick: () {
                                    state(() {});
                                    LocaleNotifier.of(context)?.change('id');
                                    Navigator.pop(context);
                                  },
                                ),

                                /* Dutch */
                                const SizedBox(height: 20),
                                _buildLanguage(
                                  langName: "Dutch",
                                  onClick: () {
                                    state(() {});
                                    LocaleNotifier.of(context)?.change('nl');
                                    Navigator.pop(context);
                                  },
                                ),

                                /* Portuguese (Brazil) */
                                const SizedBox(height: 20),
                                _buildLanguage(
                                  langName: "Portuguese (Brazil)",
                                  onClick: () {
                                    state(() {});
                                    LocaleNotifier.of(context)?.change('pt');
                                    Navigator.pop(context);
                                  },
                                ),

                                /* Albanian */
                                const SizedBox(height: 20),
                                _buildLanguage(
                                  langName: "Albanian",
                                  onClick: () {
                                    state(() {});
                                    LocaleNotifier.of(context)?.change('sq');
                                    Navigator.pop(context);
                                  },
                                ),

                                /* Turkish */
                                const SizedBox(height: 20),
                                _buildLanguage(
                                  langName: "Turkish",
                                  onClick: () {
                                    state(() {});
                                    LocaleNotifier.of(context)?.change('tr');
                                    Navigator.pop(context);
                                  },
                                ),

                                /* Vietnamese */
                                const SizedBox(height: 20),
                                _buildLanguage(
                                  langName: "Vietnamese",
                                  onClick: () {
                                    state(() {});
                                    LocaleNotifier.of(context)?.change('vi');
                                    Navigator.pop(context);
                                  },
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildLanguage({
    required String langName,
    required Function() onClick,
  }) {
    return InkWell(
      onTap: onClick,
      borderRadius: BorderRadius.circular(5),
      child: Container(
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width,
        ),
        height: 48,
        padding: const EdgeInsets.only(left: 10, right: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.surface,
            width: .5,
          ),
          // color: colorPrimaryDark,
          borderRadius: BorderRadius.circular(5),
        ),
        child: MyText(
          color: Theme.of(context).colorScheme.surface,
          text: langName,
          textalign: TextAlign.center,
          fontsize: Dimens.textTitle,
          multilanguage: false,
          maxline: 1,
          overflow: TextOverflow.ellipsis,
          fontwaight: FontWeight.w500,
          fontstyle: FontStyle.normal,
        ),
      ),
    );
  }

  Widget _buildPages() {
    if (generalProvider.loading) {
      return const SizedBox.shrink();
    } else {
      if (generalProvider.pagesModel.status == 200 &&
          generalProvider.pagesModel.result != null) {
        return AlignedGridView.count(
          shrinkWrap: true,
          crossAxisCount: 1,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          itemCount: (generalProvider.pagesModel.result?.length ?? 0),
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (BuildContext context, int position) {
            return Column(
              children: [
                buildDrawerItem(
                  generalProvider.pagesModel.result?[position].icon ?? '',
                  "url",
                  generalProvider.pagesModel.result?[position].title ?? '',
                  false,
                  () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CommonPage(
                          title: generalProvider
                                  .pagesModel.result?[position].title ??
                              '',
                          url: generalProvider
                                  .pagesModel.result?[position].url ??
                              '',
                        ),
                      ),
                    );
                  },
                ),
                divider(),
              ],
            );
          },
        );
      } else {
        return const SizedBox.shrink();
      }
    }
  }

  Widget _buildSocialLink() {
    if (generalProvider.loading) {
      return const SizedBox.shrink();
    } else {
      if (generalProvider.socialLinkModel.status == 200 &&
          generalProvider.socialLinkModel.result != null) {
        return AlignedGridView.count(
          shrinkWrap: true,
          crossAxisCount: 1,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          itemCount: (generalProvider.socialLinkModel.result?.length ?? 0),
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (BuildContext context, int position) {
            return Column(
              children: [
                buildDrawerItem(
                  generalProvider.socialLinkModel.result?[position].image ?? '',
                  "url",
                  generalProvider.socialLinkModel.result?[position].name ?? '',
                  false,
                  () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CommonPage(
                          title: generalProvider
                                  .socialLinkModel.result?[position].name ??
                              '',
                          url: generalProvider
                                  .socialLinkModel.result?[position].url ??
                              '',
                        ),
                      ),
                    );
                  },
                ),
                divider(),
              ],
            );
          },
        );
      } else {
        return const SizedBox.shrink();
      }
    }
  }

  Widget commanShimmer() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 25, 20, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomWidget.roundrectborder(height: 8, width: 150),
                  SizedBox(height: 5),
                  CustomWidget.roundrectborder(height: 8, width: 80),
                ],
              ),
              CustomWidget.roundrectborder(height: 5, width: 50),
            ],
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 120,
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: ListView.separated(
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
              scrollDirection: Axis.horizontal,
              itemCount: 10,
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                return Container(
                  width: 95,
                  height: MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(
                      color: Theme.of(context).secondaryHeaderColor,
                      borderRadius: BorderRadius.circular(15)),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CustomWidget.roundcorner(height: 85),
                      SizedBox(height: 5),
                      CustomWidget.roundcorner(
                        height: 5,
                        width: 50,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 15),
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 25, 20, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomWidget.roundrectborder(height: 10, width: 150),
                  SizedBox(height: 5),
                  CustomWidget.roundrectborder(height: 10, width: 80),
                ],
              ),
              CustomWidget.roundrectborder(height: 10, width: 50),
            ],
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 180,
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: ListView.separated(
                separatorBuilder: (context, index) => const SizedBox(width: 10),
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                scrollDirection: Axis.horizontal,
                itemCount: 10,
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  return Container(
                    alignment: Alignment.center,
                    width: 130,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        CustomWidget.roundrectborder(
                          width: MediaQuery.of(context).size.width,
                          height: 130,
                        ),
                        const SizedBox(height: 8),
                        CustomWidget.roundrectborder(
                          width: MediaQuery.of(context).size.width,
                          height: 5,
                        ),
                        CustomWidget.roundrectborder(
                          width: MediaQuery.of(context).size.width,
                          height: 5,
                        ),
                      ],
                    ),
                  );
                }),
          ),
        ),
        const SizedBox(height: 15),
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 25, 20, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomWidget.roundrectborder(height: 10, width: 150),
                  SizedBox(height: 5),
                  CustomWidget.roundrectborder(height: 10, width: 80),
                ],
              ),
              CustomWidget.roundrectborder(height: 10, width: 50),
            ],
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 180,
          child: ListView.separated(
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
              itemCount: 10,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  width: 185,
                  height: 150,
                  margin: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                  alignment: Alignment.centerLeft,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CustomWidget.roundrectborder(
                              width: MediaQuery.sizeOf(context).width,
                              height: 110,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      const CustomWidget.roundrectborder(height: 5),
                      const CustomWidget.roundrectborder(height: 5)
                    ],
                  ),
                );
              }),
        ),
      ],
    );
  }
}
