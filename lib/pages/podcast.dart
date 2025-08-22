import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:yourappname/music/musicdetails.dart';
import 'package:yourappname/pages/home.dart';
import 'package:yourappname/pages/podcastviewall.dart';
import 'package:yourappname/provider/musicdetailprovider.dart';
import 'package:yourappname/provider/podcastprovider.dart';
import 'package:yourappname/utils/adhelper.dart';
import 'package:yourappname/utils/color.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/customwidget.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/widget/myappbar.dart';
import 'package:yourappname/widget/myimage.dart';
import 'package:yourappname/widget/mynetworkimg.dart';
import 'package:yourappname/widget/mytext.dart';
import 'package:yourappname/model/podcastsectionmodel.dart' as podcastsection;

class Podcast extends StatefulWidget {
  const Podcast({super.key});

  @override
  State<Podcast> createState() => _PodcastState();
}

class _PodcastState extends State<Podcast> {
  CarouselSliderController bannerController = CarouselSliderController();
  late PodcatsProvider podcatsProvider;
  late ScrollController _scrollController;

  @override
  void initState() {
    podcatsProvider = Provider.of<PodcatsProvider>(context, listen: false);
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    super.initState();
    _fetchData(0);
  }

  _scrollListener() async {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange &&
        (podcatsProvider.sectioncurrentPage ?? 0) <
            (podcatsProvider.sectiontotalPage ?? 0)) {
      await podcatsProvider.setLoadMore(true);
      _fetchData(podcatsProvider.sectioncurrentPage ?? 0);
    }
  }

  Future<void> _fetchData(int? nextPage) async {
    printLog("isMorePage  ======> ${podcatsProvider.sectionisMorePage}");
    printLog("currentPage ======> ${podcatsProvider.sectioncurrentPage}");
    printLog("totalPage   ======> ${podcatsProvider.sectiontotalPage}");
    printLog("nextpage   ======> $nextPage");
    printLog("Call MyCourse");
    printLog("Pageno:== ${(nextPage ?? 0) + 1}");
    await podcatsProvider.getSeactionList((nextPage ?? 0) + 1);
    await podcatsProvider.setLoadMore(false);
  }

  @override
  void dispose() {
    podcatsProvider.clearProvider();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              MyAppbar(
                title: "podcast",
                icon: "back.png",
                isSimpleappbar: 1,
                isMultiLang: true,
                onBack: () {
                  Navigator.pop(context);
                },
              ),
              Expanded(
                child: RefreshIndicator(
                  backgroundColor: white,
                  color: colorAccent,
                  displacement: 70,
                  edgeOffset: 1.0,
                  triggerMode: RefreshIndicatorTriggerMode.anywhere,
                  strokeWidth: 3,
                  onRefresh: () async {
                    podcatsProvider.clearProvider();
                    _fetchData(0);
                  },
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(0, 15, 0, 80),
                    child: Column(
                      children: [
                        buildPage(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          _buildMusicPanel(context),
        ],
      ),
    );
  }

  Widget buildPage() {
    return Consumer<PodcatsProvider>(
        builder: (context, podcastprovider, child) {
      if (podcastprovider.loading && !podcastprovider.loadmore) {
        return shimmer();
      } else {
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              setSectioByType(),
              if (podcastprovider.loadmore)
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
    if (podcatsProvider.podcastSectionModel.status == 200 &&
        podcatsProvider.sectionList != null) {
      if ((podcatsProvider.sectionList?.length ?? 0) > 0) {
        return MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: ListView.builder(
            itemCount: podcatsProvider.sectionList?.length ?? 0,
            shrinkWrap: true,
            reverse: false,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (BuildContext context, int index) {
              if (podcatsProvider.sectionList?[index].data != null &&
                  (podcatsProvider.sectionList?[index].data?.length ?? 0) > 0) {
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
                                MyText(
                                    color:
                                        Theme.of(context).colorScheme.surface,
                                    text: podcatsProvider
                                            .sectionList?[index].title
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
                                    text: podcatsProvider
                                            .sectionList?[index].subTitle
                                            .toString() ??
                                        "",
                                    textalign: TextAlign.center,
                                    fontsize: Dimens.textSmall,
                                    maxline: 1,
                                    fontwaight: FontWeight.w400,
                                    overflow: TextOverflow.ellipsis,
                                    fontstyle: FontStyle.normal),
                              ],
                            ),
                          ),
                          podcatsProvider.sectionList?[index].viewAll == 1
                              ? InkWell(
                                  onTap: () {
                                    AdHelper.showFullscreenAd(
                                        context, Constant.interstialAdType, () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return PodcastViewAll(
                                              sectionId: podcatsProvider
                                                      .sectionList?[index].id
                                                      .toString() ??
                                                  "",
                                              appbarTitle: podcatsProvider
                                                      .sectionList?[index].title
                                                      .toString() ??
                                                  "",
                                              isTitleMultiLang: false,
                                              screenLayout: podcatsProvider
                                                      .sectionList?[index]
                                                      .screenLayout
                                                      .toString() ??
                                                  "",
                                              sectionType: 2,
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
                          screenLayout: podcatsProvider
                                  .sectionList?[index].screenLayout
                                  .toString() ??
                              "",
                          sectionList: podcatsProvider.sectionList ?? []),
                      child: setSectionData(
                          index: index,
                          sectionList: podcatsProvider.sectionList ?? []),
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
      String? screenLayout,
      List<podcastsection.Result>? sectionList}) {
    if (screenLayout == "sqaure") {
      return Dimens.squarePodcastHeight;
    } else if (screenLayout == "landscape") {
      return Dimens.landscapPodcastHeight;
    } else if (screenLayout == "portrait") {
      return Dimens.portraitPodcastHeight;
    } else {
      return 0.0;
    }
  }

  Widget setSectionData(
      {required int index, required List<podcastsection.Result>? sectionList}) {
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
  }

/* ================ Podcast Layout's ================ */

  Widget squarePodcast(
      int sectionindex, List<podcastsection.Result>? sectionList) {
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

  Widget landscapPodcast(
      int sectionindex, List<podcastsection.Result>? sectionList) {
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

  Widget portraitPodcast(
      int sectionindex, List<podcastsection.Result>? sectionList) {
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

  Widget shimmer() {
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
}
