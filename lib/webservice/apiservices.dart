import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:yourappname/model/bannermodel.dart';
import 'package:yourappname/model/commentlistmodel.dart';
import 'package:yourappname/model/introscreenmodel.dart';
import 'package:yourappname/model/podcastsectiondetailmodel.dart';
import 'package:yourappname/model/registermodel.dart';
import 'package:yourappname/model/sectiondetailmodel.dart';
import 'package:yourappname/model/sectionlistmodel.dart';
import 'package:yourappname/model/sociallinkmodel.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:yourappname/model/citymodel.dart';
import 'package:yourappname/model/audiomodel.dart';
import 'package:yourappname/model/getepisodebypodcastmodel.dart';
import 'package:yourappname/model/historymodel.dart';
import 'package:yourappname/model/languagemodel.dart';
import 'package:yourappname/model/generalsettingmodel.dart';
import 'package:yourappname/model/liveeventmodel.dart';
import 'package:yourappname/model/loginmodel.dart';
import 'package:yourappname/model/notificationlistmodel.dart';
import 'package:yourappname/model/pagesmodel.dart';
import 'package:yourappname/model/paymentoptionmodel.dart';
import 'package:yourappname/model/paytmmodel.dart';
import 'package:yourappname/model/podcastsectionmodel.dart';
import 'package:yourappname/model/profilemodel.dart';
import 'package:yourappname/model/searchmodel.dart';
import 'package:yourappname/model/subscriptionmodel.dart';
import 'package:yourappname/model/successmodel.dart';
import 'package:yourappname/model/updateprofilemodel.dart';
import 'package:yourappname/utils/constant.dart';

class ApiService {
  String baseurl = Constant().baseurl;
  late Dio dio;

  Options optHeaders = Options(headers: <String, dynamic>{
    'Content-Type': 'application/json',
  });
  ApiService() {
    dio = Dio();
    if (kDebugMode) {
      dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: true,
          error: true,
          compact: true,
        ),
      );
    }
  }

  /*  =========================== General Api Start =========================== */

  Future<GeneralsettingModel> generalSetting() async {
    GeneralsettingModel generalsettingModel;
    String generalsetting = 'general_setting';
    Response response = await dio.post(
      '$baseurl$generalsetting',
      options: optHeaders,
    );
    generalsettingModel = GeneralsettingModel.fromJson((response.data));
    return generalsettingModel;
  }

  Future<IntroScreenModel> getOnboardingScreen() async {
    IntroScreenModel introScreenModel;
    String apiName = "get_onboarding_screen";
    Response response = await dio.post(
      '$baseurl$apiName',
    );
    introScreenModel = IntroScreenModel.fromJson(response.data);
    return introScreenModel;
  }

  Future<PagesModel> getPages() async {
    PagesModel pagesModel;
    String getPagesAPI = "get_pages";
    Response response = await dio.post(
      '$baseurl$getPagesAPI',
      options: optHeaders,
    );
    pagesModel = PagesModel.fromJson(response.data);
    return pagesModel;
  }

  Future<RegisterModel> register(type, fullName, email, mobile, password,
      countryCode, countryName, deviceToken, deviceType) async {
    RegisterModel registerModel;
    String generalsetting = 'register';
    Response response = await dio.post(
      '$baseurl$generalsetting',
      data: FormData.fromMap({
        'type': type,
        'full_name': fullName,
        'email': email,
        'mobile_number': mobile,
        'password': password,
        'country_code': countryCode,
        'country_name': countryName,
        'device_token': deviceToken,
        'device_type': deviceType,
      }),
      options: optHeaders,
    );
    registerModel = RegisterModel.fromJson((response.data));
    return registerModel;
  }

  Future<LoginModel> login(type, mobile, email, password, deviceToken,
      deviceType, countryCode, countryName) async {
    LoginModel loginModel;
    String login = "login";
    Response response = await dio.post(
      '$baseurl$login',
      data: FormData.fromMap({
        'type': type,
        'mobile_number': mobile,
        'email': email,
        'password': password,
        'device_token': deviceToken,
        'device_type': deviceType,
        'country_code': countryCode,
        'country_name': countryName,
      }),
      options: optHeaders,
    );
    loginModel = LoginModel.fromJson(response.data);
    return loginModel;
  }

  Future<SocialLinkModel> getSocialLink() async {
    SocialLinkModel socialLinkModel;
    String apiname = "get_social_link";
    Response response = await dio.post('$baseurl$apiname');
    socialLinkModel = SocialLinkModel.fromJson(response.data);
    return socialLinkModel;
  }

  /* =========================== General Api End =========================== */

  /* =========================== Home Section Api End =========================== */

  Future<BannerModel> getBanner(pageNo) async {
    BannerModel bannerModel;
    String login = "get_banner";
    Response response = await dio.post(
      '$baseurl$login',
      data: FormData.fromMap({
        'page_no': pageNo,
      }),
      options: optHeaders,
    );
    bannerModel = BannerModel.fromJson(response.data);
    return bannerModel;
  }

  Future<SectionListModel> sectionList(pageNo) async {
    SectionListModel sectionListModel;
    String login = "get_section_list";
    Response response = await dio.post(
      '$baseurl$login',
      data: FormData.fromMap({
        'page_no': pageNo,
      }),
      options: optHeaders,
    );
    sectionListModel = SectionListModel.fromJson(response.data);
    return sectionListModel;
  }

  Future<SectionDetailModel> sectionDetail(sectionId, pageNo) async {
    SectionDetailModel sectionDetailModel;
    String apiName = "get_section_detail";
    Response response = await dio.post(
      '$baseurl$apiName',
      data: FormData.fromMap({
        'section_id': sectionId,
        'page_no': pageNo,
      }),
      options: optHeaders,
    );
    sectionDetailModel = SectionDetailModel.fromJson(response.data);
    return sectionDetailModel;
  }

  /* =========================== Home Sections Api End =========================== */

  /* =========================== User Profile & Update Profile Start =========================== */

  Future<ProfileModel> profile() async {
    ProfileModel profileModel;
    String profile = 'get_profile';
    Response response = await dio.post(
      '$baseurl$profile',
      data: FormData.fromMap({
        'user_id': Constant.userID ?? "",
      }),
      options: optHeaders,
    );
    profileModel = ProfileModel.fromJson((response.data));
    return profileModel;
  }

  Future<UpdateprofileModel> updateprofile(String userid, String name,
      String email, String mobile, countryCode, countryName, File image) async {
    UpdateprofileModel updateprofileModel;
    String updateprofile = 'update_profile';
    Response response = await dio.post(
      '$baseurl$updateprofile',
      data: FormData.fromMap({
        'user_id': Constant.userID ?? "",
        'full_name': name,
        'email': email,
        'mobile_number': mobile,
        'country_code': countryCode,
        'country_name': countryName,
        if (image.path.isNotEmpty)
          "image": await MultipartFile.fromFile(image.path,
              filename: basename(image.path)),
      }),
      options: optHeaders,
    );
    updateprofileModel = UpdateprofileModel.fromJson((response.data));
    return updateprofileModel;
  }

  Future<UpdateprofileModel> updateDataForPayment(name, email, mobile) async {
    UpdateprofileModel responseModel;
    String apiName = 'update_profile';
    Response response = await dio.post(
      '$baseurl$apiName',
      data: FormData.fromMap({
        'user_id': Constant.userID ?? "",
        'full_name': name,
        'email': email,
        'mobile_number': mobile,
      }),
      options: optHeaders,
    );
    responseModel = UpdateprofileModel.fromJson((response.data));
    return responseModel;
  }

  /* =========================== User Profile & Update Profile End =========================== */

  Future<LanguageModel> language(String pageno) async {
    LanguageModel languageModel;
    String language = 'get_language';
    Response response = await dio.post(
      '$baseurl$language',
      data: FormData.fromMap({
        'page_no': pageno,
      }),
      options: optHeaders,
    );
    languageModel = LanguageModel.fromJson((response.data));
    return languageModel;
  }

  Future<CityModel> city(pageno) async {
    CityModel cityModel;
    String city = 'get_city';
    Response response = await dio.post(
      '$baseurl$city',
      data: FormData.fromMap({
        'page_no': pageno.toString(),
      }),
      options: optHeaders,
    );
    cityModel = CityModel.fromJson((response.data));
    return cityModel;
  }

  Future<NotificationModel> notification(String userid) async {
    NotificationModel notificationModel;
    String notification = 'get_notification';
    Response response = await dio.post(
      '$baseurl$notification',
      data: FormData.fromMap({
        'user_id': Constant.userID ?? "",
      }),
      options: optHeaders,
    );
    notificationModel = NotificationModel.fromJson((response.data));
    return notificationModel;
  }

  Future<SearchModel> search(searchText, type, pageNo) async {
    SearchModel searchModel;
    String apiname = 'search_content';
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({
        'name': searchText,
        'type': type,
        'page_no': pageNo,
      }),
      options: optHeaders,
    );
    searchModel = SearchModel.fromJson((response.data));
    return searchModel;
  }

  Future<AudioModel> radiobyartist(String artistid, String pageno) async {
    AudioModel getradiobyartistModel;
    String getradiobyartist = 'get_radio_by_artist';
    Response response = await dio.post(
      '$baseurl$getradiobyartist',
      data: FormData.fromMap({
        'user_id': Constant.userID ?? "",
        'artist_id': artistid,
        'page_no': pageno,
      }),
      options: optHeaders,
    );
    getradiobyartistModel = AudioModel.fromJson((response.data));
    return getradiobyartistModel;
  }

  Future<AudioModel> radiobycity(
      String cityid, String languageid, String pageno) async {
    AudioModel responseModel;
    String apiName = 'get_radio_by_city';
    Response response = await dio.post(
      '$baseurl$apiName',
      data: FormData.fromMap({
        'user_id': Constant.userID ?? "",
        'city_id': cityid,
        'language_id': languageid,
        'page_no': pageno,
      }),
      options: optHeaders,
    );
    responseModel = AudioModel.fromJson((response.data));
    return responseModel;
  }

  Future<AudioModel> radiobycategory(
      String categoryid, String languageid, String pageno) async {
    AudioModel responseModel;
    String apiName = 'get_radio_by_category';
    Response response = await dio.post(
      '$baseurl$apiName',
      data: FormData.fromMap({
        'user_id': Constant.userID ?? "",
        'category_id': categoryid,
        'language_id': languageid,
        'page_no': pageno,
      }),
    );
    responseModel = AudioModel.fromJson((response.data));
    return responseModel;
  }

  Future<AudioModel> radiobylanguage(String languageid, String pageno) async {
    AudioModel responseModel;
    String apiName = 'get_radio_by_language';
    Response response = await dio.post(
      '$baseurl$apiName',
      data: FormData.fromMap({
        'user_id': Constant.userID ?? "",
        'language_id': languageid,
        'page_no': pageno,
      }),
      options: optHeaders,
    );
    responseModel = AudioModel.fromJson((response.data));
    return responseModel;
  }

  Future<SuccessModel> addfavourite(String userid, String songid) async {
    SuccessModel successModel;
    String addfavourite = 'add_remove_favorite';
    Response response = await dio.post(
      '$baseurl$addfavourite',
      data: FormData.fromMap({
        'user_id': Constant.userID ?? "",
        'song_id': songid,
      }),
      options: optHeaders,
    );
    successModel = SuccessModel.fromJson((response.data));
    return successModel;
  }

  /*  ======================== Payment Related Api Start ======================== */

  Future<SubscriptionModel> getPackage() async {
    SubscriptionModel subscriptionModel;
    String getPackageAPI = "get_package";
    Response response = await dio.post(
      '$baseurl$getPackageAPI',
      data: FormData.fromMap({
        'user_id': Constant.userID,
      }),
      options: optHeaders,
    );
    subscriptionModel = SubscriptionModel.fromJson(response.data);
    return subscriptionModel;
  }

  Future<PaymentOptionModel> getPaymentOption() async {
    PaymentOptionModel paymentOptionModel;
    String paymentOption = "get_payment_option";
    printLog("paymentOption API :==> $baseurl$paymentOption");
    Response response = await dio.post(
      '$baseurl$paymentOption',
      options: optHeaders,
    );

    paymentOptionModel = PaymentOptionModel.fromJson(response.data);
    return paymentOptionModel;
  }

  Future<SuccessModel> addTransaction(
      packageId, description, amount, paymentId) async {
    printLog('add_transaction userID =======>>> ${Constant.userID}');
    printLog('add_transaction packageId ====>>> $packageId');
    printLog('add_transaction description ==>>> $description');
    printLog('add_transaction amount =======>>> $amount');
    printLog('add_transaction paymentId ====>>> $paymentId');
    SuccessModel successModel;
    String transactionAPI = "add_transaction";
    Response response = await dio.post(
      '$baseurl$transactionAPI',
      data: FormData.fromMap({
        'user_id': Constant.userID,
        'package_id': packageId,
        'price': amount,
        'description': description,
        'transaction_id': paymentId,
      }),
      options: optHeaders,
    );
    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }

  Future<SuccessModel> addLiveEventTransaction(
      eventId, type, amount, transectionId, discription) async {
    printLog('add_transaction userID =======>>> ${Constant.userID}');
    printLog('add_transaction packageId ====>>> $eventId');
    printLog('add_transaction description ==>>> $type');
    printLog('add_transaction amount =======>>> $amount');
    printLog('add_transaction paymentId ====>>> $transectionId');
    printLog('add_transaction currencyCode =>>> $discription');
    SuccessModel successModel;
    String apiname = "join_live_event";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({
        'user_id': Constant.userID,
        'live_event_id': eventId,
        'type': type,
        'price': amount,
        'transaction_id': transectionId,
        'description': discription,
      }),
      options: optHeaders,
    );
    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }

  Future<HistoryModel> transactionList() async {
    HistoryModel historyModel;
    String subscriptionListAPI = "transaction_list";
    Response response = await dio.post(
      '$baseurl$subscriptionListAPI',
      data: FormData.fromMap({
        'user_id': Constant.userID,
      }),
      options: optHeaders,
    );
    historyModel = HistoryModel.fromJson(response.data);
    return historyModel;
  }

  Future<PayTmModel> getPaytmToken(merchantID, orderId, custmoreID, channelID,
      txnAmount, website, callbackURL, industryTypeID) async {
    PayTmModel payTmModel;
    String paytmToken = "get_payment_token";
    printLog("paytmToken API :==> $baseurl$paytmToken");
    Response response = await dio.post(
      '$baseurl$paytmToken',
      data: FormData.fromMap({
        'MID': merchantID,
        'order_id': orderId,
        'CUST_ID': custmoreID,
        'CHANNEL_ID': channelID,
        'TXN_AMOUNT': txnAmount,
        'WEBSITE': website,
        'CALLBACK_URL': callbackURL,
        'INDUSTRY_TYPE_ID': industryTypeID,
      }),
      options: optHeaders,
    );

    payTmModel = PayTmModel.fromJson(response.data);
    printLog("getPaytmToken payTmModel ==> $payTmModel");
    return payTmModel;
  }

  /*  ======================== Payment Related Api End ======================== */

/* Version 1.5 Intigrate New Api Start */

  Future<LiveEventModel> liveEventList(pageNo) async {
    LiveEventModel liveEventModel;
    String apiname = "get_live_event";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({
        'user_id': Constant.userID,
        'page_no': pageNo,
      }),
      options: optHeaders,
    );
    liveEventModel = LiveEventModel.fromJson(response.data);
    return liveEventModel;
  }

  Future<PodcastSectionModel> podcastSectionList(pageNo) async {
    PodcastSectionModel podcastSectionModel;
    String apiname = "get_podcast_section_list";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({
        'user_id': Constant.userID,
        'page_no': pageNo,
      }),
      options: optHeaders,
    );
    podcastSectionModel = PodcastSectionModel.fromJson(response.data);
    return podcastSectionModel;
  }

  Future<PodcastSectionDetailModel> podcastSectionDetailList(
      sectionId, pageNo) async {
    PodcastSectionDetailModel podcastSectionDetailModel;
    String apiname = "get_podcast_section_detail";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({
        'user_id': Constant.userID == null ? "0" : Constant.userID ?? "0",
        'section_id': sectionId,
        'page_no': pageNo,
      }),
      options: optHeaders,
    );
    podcastSectionDetailModel =
        PodcastSectionDetailModel.fromJson(response.data);
    return podcastSectionDetailModel;
  }

  Future<GetEpisodeByPodcstModel> getEpisodebyPodcast(podcastId, pageNo) async {
    GetEpisodeByPodcstModel getEpisodeByPodcstModel;
    String apiname = "get_episode_by_podcast";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({
        'podcast_id': podcastId,
        'user_id': Constant.userID,
        'page_no': pageNo,
      }),
      options: optHeaders,
    );
    getEpisodeByPodcstModel = GetEpisodeByPodcstModel.fromJson(response.data);
    return getEpisodeByPodcstModel;
  }

  Future<CommentListModel> commentList(type, songId, episodeId, pageNo) async {
    CommentListModel commentListModel;
    String apiname = "get_comment";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({
        'type': type,
        'song_id': songId,
        'episode_id': episodeId,
        'page_no': pageNo,
      }),
      options: optHeaders,
    );
    commentListModel = CommentListModel.fromJson(response.data);
    return commentListModel;
  }

  Future<SuccessModel> addComment(songId, comment, type, episodeId) async {
    SuccessModel successModel;
    String apiname = "add_comment";
    Response response = await dio.post(
      '$baseurl$apiname',
      data: FormData.fromMap({
        'user_id': Constant.userID,
        'song_id': songId,
        'comment': comment,
        'type': type,
        'episode_id': episodeId,
      }),
      options: optHeaders,
    );
    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }

/* Version 1.5 Intigrate New Api  End */
}
