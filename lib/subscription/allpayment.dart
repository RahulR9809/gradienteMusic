import 'dart:async';
import 'dart:convert';
import 'dart:io';
// import 'package:flutterwave_standard/core/flutterwave.dart';
// import 'package:flutterwave_standard/models/requests/customer.dart';
// import 'package:flutterwave_standard/models/requests/customizations.dart';
// import 'package:flutterwave_standard/models/responses/charge_response.dart';
import 'package:yourappname/music/musicdetails.dart';
import 'package:yourappname/provider/liveeventsprovider.dart';
import 'package:yourappname/pages/home.dart';
import 'package:yourappname/pages/nodata.dart';
import 'package:yourappname/provider/paymentprovider.dart';
import 'package:yourappname/utils/color.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/utils/sharedpref.dart';
import 'package:yourappname/utils/strings.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/widget/myimage.dart';
import 'package:yourappname/widget/mytext.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_paypal/flutter_paypal.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:provider/provider.dart';
// import 'package:razorpay_web/razorpay_web.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
// import 'package:uuid/uuid.dart';

final bool _kAutoConsume = Platform.isIOS || true;

class AllPayment extends StatefulWidget {
  final String? payType,
      itemId,
      price,
      itemTitle,
      typeId,
      contentType,
      productPackage,
      currency;
  const AllPayment({
    super.key,
    required this.payType,
    required this.itemId,
    required this.price,
    required this.itemTitle,
    required this.typeId,
    required this.contentType,
    required this.productPackage,
    required this.currency,
  });

  @override
  State<AllPayment> createState() => AllPaymentState();
}

class AllPaymentState extends State<AllPayment> {
  final couponController = TextEditingController();
  late ProgressDialog prDialog;
  late PaymentProvider paymentProvider;
  SharedPref sharedPref = SharedPref();
  String? userName, userEmail, userMobileNo, paymentId;
  String? strCouponCode = "";
  bool isPaymentDone = false;

  /* InApp Purchase */
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  late List<String> _kProductIds;
  final List<PurchaseDetails> _purchases = <PurchaseDetails>[];

  /* Paytm */
  String paytmResult = "";

  /* Stripe */
  Map<String, dynamic>? paymentIntent;

  @override
  void initState() {
    prDialog = ProgressDialog(context);
    _getData();

    if (!kIsWeb) {
      /* InApp Purchase PG */
      _kProductIds = <String>[widget.productPackage ?? ""];
      final Stream<List<PurchaseDetails>> purchaseUpdated =
          _inAppPurchase.purchaseStream;
      _subscription =
          purchaseUpdated.listen((List<PurchaseDetails> purchaseDetailsList) {
        _listenToPurchaseUpdated(purchaseDetailsList);
      }, onDone: () {
        _subscription.cancel();
      }, onError: (Object error) {
        // handle error here.
        printLog("onError ============> ${error.toString()}");
      });
      initStoreInfo();
    }
    super.initState();
  }

  bool checkKeysAndContinue({
    required String isLive,
    required bool isBothKeyReq,
    required String liveKey1,
    required String liveKey2,
    required String testKey1,
    required String testKey2,
  }) {
    if (isLive == "1") {
      if (isBothKeyReq) {
        if (liveKey1 == "" || liveKey2 == "") {
          Utils.showSnackbar(context, "payment_not_processed", true);
          return false;
        }
      } else {
        if (liveKey1 == "") {
          Utils.showSnackbar(context, "payment_not_processed", true);
          return false;
        }
      }
      return true;
    } else {
      if (isBothKeyReq) {
        if (testKey1 == "" || testKey2 == "") {
          Utils.showSnackbar(context, "payment_not_processed", true);
          return false;
        }
      } else {
        if (testKey1 == "") {
          Utils.showSnackbar(context, "payment_not_processed", true);
          return false;
        }
      }
      return true;
    }
  }

  _getData() async {
    paymentProvider = Provider.of<PaymentProvider>(context, listen: false);
    await paymentProvider.getPaymentOption();
    await paymentProvider.setFinalAmount(widget.price ?? "");
    /* PaymentID */
    paymentId = Utils.generateRandomOrderID();
    print('paymentId =====================> $paymentId');

    userName = await sharedPref.read("username");
    userEmail = await sharedPref.read("useremail");
    userMobileNo = await sharedPref.read("usermobile");
    print('getUserData userName ==> $userName');
    print('getUserData userEmail ==> $userEmail');
    print('getUserData userMobileNo ==> $userMobileNo');

    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    paymentProvider.clearProvider();
    couponController.dispose();
    if (!kIsWeb) {
      if (Platform.isIOS) {
        final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
            _inAppPurchase
                .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
        iosPlatformAddition.setDelegate(null);
      }
      _subscription.cancel();
    }
    super.dispose();
  }

  /* add_transaction API */
  Future addTransaction(
      packageId, description, amount, paymentId, currencyCode) async {
    Utils().showProgress(context);
    await paymentProvider.addTransaction(
        packageId, description, amount, paymentId);

    if (!paymentProvider.payLoading) {
      prDialog.hide();

      if (paymentProvider.successModel.status == 200) {
        prDialog.hide();
        isPaymentDone = true;
        currentlyPlaying.value = null;
        await audioPlayer.pause();
        await audioPlayer.stop();
        musicManager.clearMusicPlayer();
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const Home()),
            (Route route) => false);
      } else {
        prDialog.hide();
        isPaymentDone = false;
        if (!mounted) return;
        Utils.showSnackbar(
            context, paymentProvider.successModel.message ?? "", false);
      }
    }
  }

  Future joinEventTransection(
      eventId, type, amount, transectionId, discription) async {
    Utils().showProgress(context);
    await paymentProvider.joinLiveEventTransaction(
        eventId, type, amount, transectionId, discription);

    if (!paymentProvider.payLoading) {
      await prDialog.hide();

      if (paymentProvider.successModel.status == 200) {
        isPaymentDone = true;
        if (!mounted) return;
        Navigator.pop(context, isPaymentDone);

        final liveEventProvider =
            Provider.of<LiveEventProvider>(context, listen: false);
        liveEventProvider.clearProvider();
        await liveEventProvider.getLiveEventList("1");
      } else {
        isPaymentDone = false;
        if (!mounted) return;
        Utils.showSnackbar(
            context, paymentProvider.successModel.message ?? "", false);
      }
    }
  }

  openPayment({required String pgName}) async {
    printLog("finalAmount =============> ${paymentProvider.finalAmount}");
    if (paymentProvider.finalAmount != "0") {
      if (pgName == "inapp") {
        _initInAppPurchase();
      } else if (pgName == "paypal") {
        _paypalInit();
      } else if (pgName == "razorpay") {
        printLog("Enter Razerpay");
        _initializeRazorpay();
      } else if (pgName == "flutterwave") {
        // _flutterwaveinit();
      } else if (pgName == "stripe") {
        _stripeInit();
      } else if (pgName == "cash") {
        if (!mounted) return;
        Utils.showSnackbar(context, "cash_payment_msg", true);
      }
    } else {
      if (widget.payType == "Package") {
        addTransaction(widget.itemId, widget.itemTitle,
            paymentProvider.finalAmount, paymentId, widget.currency);
      } else {
        joinEventTransection(widget.itemId, widget.contentType,
            paymentProvider.finalAmount, paymentId, widget.itemTitle);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: onBackPressed,
      child: _buildPage(),
    );
  }

  Widget _buildPage() {
    return Scaffold(
      backgroundColor: appBgColor,
      appBar: (kIsWeb)
          ? null
          : Utils.myAppBarWithBack(context, "payment_details", true),
      body: SafeArea(
        child: Center(
          child: _buildMobilePage(),
        ),
      ),
    );
  }

  Widget _buildMobilePage() {
    return Container(
      width: ((kIsWeb) && MediaQuery.of(context).size.width > 720)
          ? MediaQuery.of(context).size.width * 0.5
          : MediaQuery.of(context).size.width,
      margin: (kIsWeb)
          ? const EdgeInsets.fromLTRB(50, 0, 50, 50)
          : const EdgeInsets.all(0),
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: (kIsWeb) ? 40 : 0),
          /* Total Amount */
          Container(
            width: MediaQuery.of(context).size.width,
            constraints: const BoxConstraints(minHeight: 50),
            decoration: Utils.setBackground(colorPrimary, 0),
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
            alignment: Alignment.centerLeft,
            child: Consumer<PaymentProvider>(
              builder: (context, paymentProvider, child) {
                return RichText(
                  textAlign: TextAlign.start,
                  text: TextSpan(
                    text: payableAmountIs,
                    style: GoogleFonts.inter(
                      textStyle: const TextStyle(
                        color: appBgColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.normal,
                        letterSpacing: 0.5,
                      ),
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text:
                            "${Constant.currencySymbol}${paymentProvider.finalAmount ?? ""}",
                        style: GoogleFonts.inter(
                          textStyle: const TextStyle(
                            color: white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            fontStyle: FontStyle.normal,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          /* PGs */
          Expanded(
            child: SingleChildScrollView(
                child: paymentProvider.loading
                    ? Container(
                        height: 230,
                        padding: const EdgeInsets.all(20),
                        child: Utils.pageLoader(),
                      )
                    : paymentProvider.paymentOptionModel.status == 200
                        ? paymentProvider.paymentOptionModel.result != null
                            ? ((kIsWeb)
                                ? _buildWebPayments()
                                : _buildPayments())
                            : const NoData(text: "", subTitle: "")
                        : const NoData(text: "", subTitle: "")),
          ),
        ],
      ),
    );
  }

  Widget _buildPayments() {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 20, 15, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          MyText(
            color: black,
            text: "payment_methods",
            fontsize: Dimens.textMedium,
            maxline: 1,
            multilanguage: true,
            overflow: TextOverflow.ellipsis,
            fontwaight: FontWeight.w600,
            textalign: TextAlign.center,
            fontstyle: FontStyle.normal,
          ),
          const SizedBox(height: 5),
          MyText(
            color: gray,
            text: "choose_a_payment_methods_to_pay",
            multilanguage: true,
            fontsize: Dimens.textMedium,
            maxline: 2,
            overflow: TextOverflow.ellipsis,
            fontwaight: FontWeight.w500,
            textalign: TextAlign.center,
            fontstyle: FontStyle.normal,
          ),
          const SizedBox(height: 15),
          MyText(
            color: colorAccent,
            text: "pay_with",
            multilanguage: true,
            fontsize: Dimens.textTitle,
            maxline: 1,
            overflow: TextOverflow.ellipsis,
            fontwaight: FontWeight.w700,
            textalign: TextAlign.center,
            fontstyle: FontStyle.normal,
          ),
          const SizedBox(height: 20),

          /* /* Payments */ */
          (!kIsWeb)
              ? (Platform.isIOS ? _buildIOSPG() : _buildAndroidPG())
              : const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _buildWebPayments() {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 20, 15, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          MyText(
            color: black,
            text: "payment_methods",
            fontsize: Dimens.textMedium,
            maxline: 1,
            multilanguage: true,
            overflow: TextOverflow.ellipsis,
            fontwaight: FontWeight.w600,
            textalign: TextAlign.center,
            fontstyle: FontStyle.normal,
          ),
          const SizedBox(height: 5),
          MyText(
            color: gray,
            text: "choose_a_payment_methods_to_pay",
            multilanguage: true,
            fontsize: Dimens.textMedium,
            maxline: 2,
            overflow: TextOverflow.ellipsis,
            fontwaight: FontWeight.w500,
            textalign: TextAlign.center,
            fontstyle: FontStyle.normal,
          ),
          const SizedBox(height: 15),
          MyText(
            color: colorAccent,
            text: "pay_with",
            multilanguage: true,
            fontsize: Dimens.textTitle,
            maxline: 1,
            overflow: TextOverflow.ellipsis,
            fontwaight: FontWeight.w700,
            textalign: TextAlign.center,
            fontstyle: FontStyle.normal,
          ),
          const SizedBox(height: 20),

          /* Razorpay */
          paymentProvider.paymentOptionModel.result?.razorpay != null
              ? paymentProvider
                          .paymentOptionModel.result?.razorpay?.visibility ==
                      "1"
                  ? _buildPGButton(
                      "pg_razorpay.png",
                      "Razorpay",
                      35,
                      130,
                      onClick: () async {
                        await paymentProvider.setCurrentPayment("razorpay");
                        openPayment(pgName: "razorpay");
                      },
                    )
                  : const SizedBox.shrink()
              : const NoData(text: "", subTitle: "")
        ],
      ),
    );
  }

  Widget _buildAndroidPG() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        /* /* Payments */ */
        /* In-App purchase */
        paymentProvider.paymentOptionModel.result?.inAppPurchageAndroid != null
            ? paymentProvider.paymentOptionModel.result?.inAppPurchageAndroid
                        ?.visibility ==
                    "1"
                ? _buildPGButton(
                    "pg_inapp.png",
                    "InApp Purchase",
                    35,
                    110,
                    onClick: () async {
                      await paymentProvider.setCurrentPayment("inapp");
                      openPayment(pgName: "inapp");
                    },
                  )
                : const SizedBox.shrink()
            : const SizedBox.shrink(),

        /* Paypal */
        paymentProvider.paymentOptionModel.result?.paypal != null
            ? paymentProvider.paymentOptionModel.result?.paypal?.visibility ==
                    "1"
                ? _buildPGButton(
                    "pg_paypal.png",
                    "Paypal",
                    35,
                    130,
                    onClick: () async {
                      await paymentProvider.setCurrentPayment("paypal");
                      openPayment(pgName: "paypal");
                    },
                  )
                : const SizedBox.shrink()
            : const SizedBox.shrink(),

        /* Razorpay */
        paymentProvider.paymentOptionModel.result?.razorpay != null
            ? paymentProvider.paymentOptionModel.result?.razorpay?.visibility ==
                    "1"
                ? _buildPGButton(
                    "pg_razorpay.png",
                    "Razorpay",
                    35,
                    130,
                    onClick: () async {
                      await paymentProvider.setCurrentPayment("razorpay");
                      openPayment(pgName: "razorpay");
                    },
                  )
                : const SizedBox.shrink()
            : const SizedBox.shrink(),

        /* Paytm */
        paymentProvider.paymentOptionModel.result?.payTm != null
            ? paymentProvider.paymentOptionModel.result?.payTm?.visibility ==
                    "1"
                ? _buildPGButton(
                    "pg_paytm.png",
                    "Paytm",
                    30,
                    90,
                    onClick: () async {
                      await paymentProvider.setCurrentPayment("paytm");
                      openPayment(pgName: "paytm");
                    },
                  )
                : const SizedBox.shrink()
            : const SizedBox.shrink(),

        /* Flutterwave */
        paymentProvider.paymentOptionModel.result?.flutterWave != null
            ? paymentProvider
                        .paymentOptionModel.result?.flutterWave?.visibility ==
                    "1"
                ? _buildPGButton(
                    "pg_flutterwave.png",
                    "Flutterwave",
                    35,
                    130,
                    onClick: () async {
                      await paymentProvider.setCurrentPayment("flutterwave");
                      openPayment(pgName: "flutterwave");
                    },
                  )
                : const SizedBox.shrink()
            : const SizedBox.shrink(),

        /* Stripe */
        paymentProvider.paymentOptionModel.result?.stripe != null
            ? paymentProvider.paymentOptionModel.result?.stripe?.visibility ==
                    "1"
                ? _buildPGButton(
                    "pg_stripe.png",
                    "Stripe",
                    35,
                    100,
                    onClick: () async {
                      await paymentProvider.setCurrentPayment("stripe");
                      openPayment(pgName: "stripe");
                    },
                  )
                : const SizedBox.shrink()
            : const SizedBox.shrink(),
      ],
    );
  }

  Widget _buildIOSPG() {
    if (paymentProvider.paymentOptionModel.result?.inAppPurchageIos != null) {
      if (paymentProvider
              .paymentOptionModel.result?.inAppPurchageIos?.visibility ==
          "1") {
        return _buildIOSPGButton(
          "In-App Purchase",
          35,
          110,
          onClick: () async {
            await paymentProvider.setCurrentPayment("inapp");
            openPayment(pgName: "inapp");
          },
        );
      } else {
        return const SizedBox.shrink();
      }
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildIOSPGButton(String pgName, double imgHeight, double imgWidth,
      {required Function() onClick}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      child: Card(
        semanticContainer: true,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        elevation: 5,
        color: white,
        shadowColor: black.withValues(alpha: 0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onClick,
          child: Container(
            constraints: const BoxConstraints(minHeight: 85),
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: MyText(
                    color: colorPrimary,
                    text: pgName,
                    multilanguage: false,
                    fontsize: Dimens.textlargeExtraBig,
                    maxline: 2,
                    overflow: TextOverflow.ellipsis,
                    fontwaight: FontWeight.w600,
                    textalign: TextAlign.start,
                    fontstyle: FontStyle.normal,
                  ),
                ),
                const SizedBox(width: 20),
                MyImage(
                  imagePath: "ic_arrow_right.png",
                  fit: BoxFit.contain,
                  height: 22,
                  width: 20,
                  color: white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPGButton(
      String imageName, String pgName, double imgHeight, double imgWidth,
      {required Function() onClick}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      child: Card(
        semanticContainer: true,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        elevation: 5,
        color: white,
        shadowColor: black.withValues(alpha: 0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onClick,
          child: Container(
            constraints: const BoxConstraints(minHeight: 85),
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                MyImage(
                  imagePath: imageName,
                  fit: BoxFit.fill,
                  height: imgHeight,
                  width: imgWidth,
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: MyText(
                    color: colorPrimary,
                    text: pgName,
                    multilanguage: false,
                    fontsize: Dimens.textMedium,
                    maxline: 2,
                    overflow: TextOverflow.ellipsis,
                    fontwaight: FontWeight.w600,
                    textalign: TextAlign.end,
                    fontstyle: FontStyle.normal,
                  ),
                ),
                const SizedBox(width: 15),
                MyImage(
                  imagePath: "ic_arrow_right.png",
                  fit: BoxFit.fill,
                  height: 22,
                  width: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /* ********* InApp purchase START ********* */
  Future<void> initStoreInfo() async {
    final bool isAvailable = await _inAppPurchase.isAvailable();
    if (!isAvailable) {
      setState(() {});
      return;
    }

    if (Platform.isIOS) {
      final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
          _inAppPurchase
              .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      await iosPlatformAddition.setDelegate(ExamplePaymentQueueDelegate());
    }

    final ProductDetailsResponse productDetailResponse =
        await _inAppPurchase.queryProductDetails(_kProductIds.toSet());
    if (productDetailResponse.error != null) {
      setState(() {});
      return;
    }

    if (productDetailResponse.productDetails.isEmpty) {
      setState(() {});
      return;
    }
    setState(() {});
  }

  _initInAppPurchase() async {
    printLog(
        "_initInAppPurchase _kProductIds ============> ${_kProductIds[0].toString()}");
    final ProductDetailsResponse response =
        await InAppPurchase.instance.queryProductDetails(_kProductIds.toSet());
    if (response.notFoundIDs.isNotEmpty) {
      Utils.showToast("Please check SKU");
      return;
    }
    printLog("productID ============> ${response.productDetails[0].id}");
    late PurchaseParam purchaseParam;
    if (Platform.isAndroid) {
      purchaseParam =
          GooglePlayPurchaseParam(productDetails: response.productDetails[0]);
    } else {
      purchaseParam = PurchaseParam(productDetails: response.productDetails[0]);
    }
    _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
  }

  Future<void> _listenToPurchaseUpdated(
      List<PurchaseDetails> purchaseDetailsList) async {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        showPendingUI();
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          printLog(
              "purchaseDetails ============> ${purchaseDetails.error.toString()}");
          handleError(purchaseDetails.error!);
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          printLog("===> status ${purchaseDetails.status}");
          final bool valid = await _verifyPurchase(purchaseDetails);
          if (valid) {
            deliverProduct(purchaseDetails);
          } else {
            _handleInvalidPurchase(purchaseDetails);
            return;
          }
        }
        if (Platform.isAndroid) {
          if (!_kAutoConsume && purchaseDetails.productID == _kProductIds[0]) {
            final InAppPurchaseAndroidPlatformAddition androidAddition =
                _inAppPurchase.getPlatformAddition<
                    InAppPurchaseAndroidPlatformAddition>();
            await androidAddition.consumePurchase(purchaseDetails);
          }
        }
        if (purchaseDetails.pendingCompletePurchase) {
          printLog(
              "===> pendingCompletePurchase ${purchaseDetails.pendingCompletePurchase}");
          await _inAppPurchase.completePurchase(purchaseDetails);
        }
      }
    }
  }

  Future<void> deliverProduct(PurchaseDetails purchaseDetails) async {
    printLog("===> productID ${purchaseDetails.productID}");
    if (purchaseDetails.productID == _kProductIds[0]) {
      if (widget.payType == "Package") {
        addTransaction(widget.itemId, widget.itemTitle,
            paymentProvider.finalAmount, paymentId, widget.currency);
      } else {
        joinEventTransection(widget.itemId, widget.contentType,
            paymentProvider.finalAmount, paymentId, widget.itemTitle);
      }
      setState(() {});
    } else {
      printLog("===> consumables else $purchaseDetails");
      setState(() {
        _purchases.add(purchaseDetails);
      });
    }
  }

  void showPendingUI() {
    setState(() {});
  }

  void handleError(IAPError error) {
    setState(() {});
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) {
    return Future<bool>.value(true);
  }

  void _handleInvalidPurchase(PurchaseDetails purchaseDetails) {
    printLog("invalid Purchase ===> $purchaseDetails");
  }
  /* ********* InApp purchase END ********* */

  /* ********* Razorpay START ********* */
  void _initializeRazorpay() {
    printLog("message");
    printLog(
        "livekey===> ${paymentProvider.paymentOptionModel.result?.razorpay?.key1}");
    printLog(
        "testkey====> ${paymentProvider.paymentOptionModel.result?.razorpay?.key1}");
    if (paymentProvider.paymentOptionModel.result?.razorpay != null) {
      /* Check Keys */
      bool isContinue = checkKeysAndContinue(
        isLive:
            (paymentProvider.paymentOptionModel.result?.razorpay?.isLive ?? ""),
        isBothKeyReq: false,
        liveKey1:
            (paymentProvider.paymentOptionModel.result?.razorpay?.key1 ?? ""),
        liveKey2:
            (paymentProvider.paymentOptionModel.result?.razorpay?.key2 ?? ""),
        testKey1:
            (paymentProvider.paymentOptionModel.result?.razorpay?.key1 ?? ""),
        testKey2:
            (paymentProvider.paymentOptionModel.result?.razorpay?.key2 ?? ""),
      );
      if (!isContinue) return;
      printLog("checkin Complite");
      /* Check Keys */
      Razorpay razorpay = Razorpay();
      var options = {
        'key': paymentProvider.paymentOptionModel.result?.razorpay?.isLive ==
                "1"
            ? paymentProvider.paymentOptionModel.result?.razorpay?.key1 ?? ""
            : paymentProvider.paymentOptionModel.result?.razorpay?.key1 ?? "",
        'currency': Constant.currency.toUpperCase(),
        'amount': (double.parse(paymentProvider.finalAmount ?? "") * 100),
        'name': widget.itemTitle ?? "",
        'description': widget.itemTitle ?? "",
        'retry': {'enabled': true, 'max_count': 1},
        'send_sms_hash': true,
        'prefill': {'contact': userMobileNo, 'email': userEmail},
        'external': {
          'wallets': ['paytm']
        }
      };
      razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentErrorResponse);
      razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccessResponse);
      razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handleExternalWalletSelected);

      try {
        razorpay.open(options);
      } catch (e) {
        printLog('Razorpay Error :=========> $e');
      }
    } else {
      Utils.showSnackbar(context, "payment_not_processed", true);
    }
  }

  void handlePaymentErrorResponse(PaymentFailureResponse response) async {
    /*
    * PaymentFailureResponse contains three values:
    * 1. Error Code
    * 2. Error Description
    * 3. Metadata
    * */
    Utils.showSnackbar(context, "payment_fail", true);
    await paymentProvider.setCurrentPayment("");
  }

  void handlePaymentSuccessResponse(PaymentSuccessResponse response) {
    /*
    * Payment Success Response contains three values:
    * 1. Order ID
    * 2. Payment ID
    * 3. Signature
    * */
    // paymentId = response.paymentId;
    printLog("paymentId ========> $paymentId");
    Utils.showSnackbar(context, "payment_success", true);
    if (widget.payType == "Package") {
      addTransaction(widget.itemId, widget.itemTitle,
          paymentProvider.finalAmount, paymentId, widget.currency);
    } else {
      joinEventTransection(widget.itemId, widget.contentType,
          paymentProvider.finalAmount, paymentId, widget.itemTitle);
    }
  }

  void handleExternalWalletSelected(ExternalWalletResponse response) {
    printLog("============ External Wallet Selected ============");
  }
  /* ********* Razorpay END ********* */

  /* ********* Paypal START ********* */
  Future<void> _paypalInit() async {
    if (paymentProvider.paymentOptionModel.result?.paypal != null) {
      /* Check Keys */
      bool isContinue = checkKeysAndContinue(
        isLive:
            (paymentProvider.paymentOptionModel.result?.paypal?.isLive ?? ""),
        isBothKeyReq: true,
        liveKey1:
            (paymentProvider.paymentOptionModel.result?.paypal?.key1 ?? ""),
        liveKey2:
            (paymentProvider.paymentOptionModel.result?.paypal?.key2 ?? ""),
        testKey1:
            (paymentProvider.paymentOptionModel.result?.paypal?.key1 ?? ""),
        testKey2:
            (paymentProvider.paymentOptionModel.result?.paypal?.key2 ?? ""),
      );
      if (!isContinue) return;
      /* Check Keys */
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (BuildContext context) => UsePaypal(
              sandboxMode:
                  (paymentProvider.paymentOptionModel.result?.paypal?.isLive ??
                              "") ==
                          "1"
                      ? false
                      : true,
              clientId: paymentProvider
                          .paymentOptionModel.result?.paypal?.isLive ==
                      "1"
                  ? paymentProvider.paymentOptionModel.result?.paypal?.key1 ??
                      ""
                  : paymentProvider.paymentOptionModel.result?.paypal?.key1 ??
                      "",
              secretKey: paymentProvider
                          .paymentOptionModel.result?.paypal?.isLive ==
                      "1"
                  ? paymentProvider.paymentOptionModel.result?.paypal?.key2 ??
                      ""
                  : paymentProvider.paymentOptionModel.result?.paypal?.key2 ??
                      "",
              returnURL: "return.divinetechs.com",
              cancelURL: "cancel.divinetechs.com",
              transactions: [
                {
                  "amount": {
                    "total": '${paymentProvider.finalAmount}',
                    "currency": Constant.currency,
                    "details": {
                      "subtotal": '${paymentProvider.finalAmount}',
                      "shipping": '0',
                      "shipping_discount": 0
                    }
                  },
                  "description": "The payment transaction description.",
                  "item_list": {
                    "items": [
                      {
                        "name": "${widget.itemTitle}",
                        "quantity": 1,
                        "price": '${paymentProvider.finalAmount}',
                        "currency": Constant.currency
                      }
                    ],
                  }
                }
              ],
              note: "Contact us for any questions on your order.",
              onSuccess: (params) async {
                printLog("onSuccess: ${params["paymentId"]}");
                if (widget.payType == "Package") {
                  addTransaction(
                      widget.itemId,
                      widget.itemTitle,
                      paymentProvider.finalAmount,
                      params["paymentId"],
                      widget.currency);
                } else {
                  joinEventTransection(widget.itemId, widget.contentType,
                      paymentProvider.finalAmount, paymentId, widget.itemTitle);
                }
              },
              onError: (params) {
                printLog("onError: ${params["message"]}");
                Utils.showSnackbar(
                    context, params["message"].toString(), false);
              },
              onCancel: (params) {
                printLog('cancelled: $params');
                Utils.showSnackbar(context, params.toString(), false);
              }),
        ),
      );
    } else {
      Utils.showSnackbar(context, "payment_not_processed", true);
    }
  }
  /* ********* Paypal END ********* */

  /* ********* Stripe START ********* */
  Future<void> _stripeInit() async {
    if (paymentProvider.paymentOptionModel.result?.stripe != null) {
      /* Check Keys */
      bool isContinue = checkKeysAndContinue(
        isLive:
            (paymentProvider.paymentOptionModel.result?.stripe?.isLive ?? ""),
        isBothKeyReq: true,
        liveKey1:
            (paymentProvider.paymentOptionModel.result?.stripe?.key1 ?? ""),
        liveKey2:
            (paymentProvider.paymentOptionModel.result?.stripe?.key2 ?? ""),
        testKey1:
            (paymentProvider.paymentOptionModel.result?.stripe?.key1 ?? ""),
        testKey2:
            (paymentProvider.paymentOptionModel.result?.stripe?.key2 ?? ""),
      );
      if (!isContinue) return;
      /* Check Keys */
      stripe.Stripe.publishableKey =
          paymentProvider.paymentOptionModel.result?.stripe?.isLive == "1"
              ? paymentProvider.paymentOptionModel.result?.stripe?.key1 ?? ""
              : paymentProvider.paymentOptionModel.result?.stripe?.key1 ?? "";
      try {
        //STEP 1: Create Payment Intent
        paymentIntent = await createPaymentIntent(
            paymentProvider.finalAmount ?? "", Constant.currency);

        //STEP 2: Initialize Payment Sheet

        await stripe.Stripe.instance
            .initPaymentSheet(
                paymentSheetParameters: stripe.SetupPaymentSheetParameters(
              merchantDisplayName: Constant.appName,
              paymentIntentClientSecret: paymentIntent?['client_secret'],
              style: ThemeMode.light,
            ))
            .then((value) {});
        //STEP 3: Display Payment sheet
        displayPaymentSheet();
      } catch (err) {
        throw Exception(err);
      }
    } else {
      Utils.showSnackbar(context, "payment_not_processed", true);
    }
  }

  createPaymentIntent(String amount, String currency) async {
    try {
      //Request body
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currency,
        'description': widget.itemTitle,
      };

      //Make post request to Stripe
      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization':
              'Bearer ${paymentProvider.paymentOptionModel.result?.stripe?.isLive == "1" ? paymentProvider.paymentOptionModel.result?.stripe?.key2 ?? "" : paymentProvider.paymentOptionModel.result?.stripe?.key2 ?? ""}',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );
      print("--------------------------------${json.decode(response.body)}");
      return json.decode(response.body);
    } catch (err) {
      throw Exception(err.toString());
    }
  }

  calculateAmount(String amount) {
    final calculatedAmout = (int.parse(amount)) * 100;
    return calculatedAmout.toString();
  }

  displayPaymentSheet() async {
    try {
      await stripe.Stripe.instance.presentPaymentSheet().then((value) {
        Utils.showSnackbar(context, "payment_success", true);
        if (widget.payType == "Package") {
          addTransaction(widget.itemId, widget.itemTitle,
              paymentProvider.finalAmount, paymentId, widget.currency);
        } else {
          joinEventTransection(widget.itemId, widget.contentType,
              paymentProvider.finalAmount, paymentId, widget.itemTitle);
        }

        paymentIntent = null;
      }).onError((error, stackTrace) {
        throw Exception(error);
      });
    } on stripe.StripeException catch (e) {
      printLog('Error is:---> $e');
      const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  Icons.cancel,
                  color: Colors.red,
                ),
                Text("Payment Failed"),
              ],
            ),
          ],
        ),
      );
    } catch (e) {
      printLog('$e');
    }
  }
  /* ********* Stripe END ********* */

  /* ********  Fluttter Wave START ********** */
  /*  Future<void> _flutterwaveinit() async {
    if (paymentProvider.paymentOptionModel.result?.flutterWave != null) {
      printLog(
          "public key =${paymentProvider.paymentOptionModel.result?.flutterWave?.key1} ");
      printLog(
          "secret key =${paymentProvider.paymentOptionModel.result?.flutterWave?.key2} ");
      /* Check Keys */
      bool isContinue = checkKeysAndContinue(
        isLive:
            (paymentProvider.paymentOptionModel.result?.flutterWave?.isLive ??
                ""),
        isBothKeyReq: false,
        liveKey1:
            (paymentProvider.paymentOptionModel.result?.flutterWave?.key2 ??
                ""),
        liveKey2: "",
        testKey1:
            (paymentProvider.paymentOptionModel.result?.flutterWave?.key2 ??
                ""),
        testKey2: "",
      );
      if (!isContinue) return;
      /* Check Keys */
      handlePaymentInitialization();
    } else {
      Utils.showSnackbar(context, "payment_not_processed", true);
    }
  }

  handlePaymentInitialization() async {
    final Customer customer = Customer(
        name: userName.toString(),
        phoneNumber: userMobileNo.toString(),
        email: userEmail.toString());

    final Flutterwave flutterwave = Flutterwave(
      context: context,
      publicKey: paymentProvider
                  .paymentOptionModel.result?.flutterWave?.isLive ==
              "1"
          ? paymentProvider.paymentOptionModel.result?.flutterWave?.key1 ?? ""
          : paymentProvider.paymentOptionModel.result?.flutterWave?.key1 ?? "",
      currency: Constant.currency,
      redirectUrl: "https://divinetechs.com",
      txRef: const Uuid().v1(),
      amount: widget.price ?? "",
      customer: customer,
      paymentOptions: "ussd, card, barter, payattitude",
      customization: Customization(title: "My Payment"),
      isTestMode:
          paymentProvider.paymentOptionModel.result?.flutterWave?.isLive != "1",
    );
    final ChargeResponse response = await flutterwave.charge();
    if (response.status == "success") {
      if (widget.payType == "Package") {
        addTransaction(widget.itemId, widget.itemTitle,
            paymentProvider.finalAmount, paymentId, widget.currency);
      } else {
        joinEventTransection(widget.itemId, widget.contentType,
            paymentProvider.finalAmount, paymentId, widget.itemTitle);
      }
    }
    showLoading(response.status.toString());
  }

  Future<void> showLoading(String message) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            margin: const EdgeInsets.fromLTRB(30, 20, 30, 20),
            width: double.infinity,
            height: 50,
            child: Text(message),
          ),
        );
      },
    );
  } */
  /* ********  Fluttter Wave END ********** */

  Future<void> onBackPressed(didPop) async {
    if (didPop) return;
    if (!mounted) return;
    if (Navigator.canPop(context)) {
      Navigator.pop(context, isPaymentDone);
    }
  }
}

class ExamplePaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(
      SKPaymentTransactionWrapper transaction, SKStorefrontWrapper storefront) {
    return true;
  }

  @override
  bool shouldShowPriceConsent() {
    return false;
  }
}
