import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:yourappname/pages/home.dart';
import 'package:yourappname/music/musicdetails.dart';
import 'package:yourappname/pages/nodata.dart';
import 'package:yourappname/provider/musicdetailprovider.dart';
import 'package:yourappname/provider/podcastviewallprovider.dart';
import 'package:yourappname/utils/color.dart';
import 'package:yourappname/utils/customwidget.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/widget/myappbar.dart';
import 'package:yourappname/widget/myimage.dart';
import 'package:yourappname/widget/mynetworkimg.dart';
import 'package:yourappname/widget/mytext.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

class PodcastViewAll extends StatefulWidget {
  final String screenLayout, appbarTitle, sectionId;
  final int sectionType;
  final bool isTitleMultiLang;
  const PodcastViewAll({
    required this.sectionId,
    required this.sectionType,
    required this.screenLayout,
    required this.appbarTitle,
    required this.isTitleMultiLang,
    super.key,
  });
  @override
  State<PodcastViewAll> createState() => PodcastViewAllState();
}

class PodcastViewAllState extends State<PodcastViewAll> {
  late PodcatViewAllProvider podcatViewAllProvider;
  late ScrollController _scrollController;

  @override
  void initState() {
    podcatViewAllProvider =
        Provider.of<PodcatViewAllProvider>(context, listen: false);
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    super.initState();
    _fetchSectionDetail(0);
  }

  _scrollListener() async {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange &&
        (podcatViewAllProvider.currentPage ?? 0) <
            (podcatViewAllProvider.totalPage ?? 0)) {
      podcatViewAllProvider.setLoadMore(true);
      _fetchSectionDetail(podcatViewAllProvider.currentPage ?? 0);
    }
  }

  Future<void> _fetchSectionDetail(int? nextPage) async {
    printLog("isMorePage  ======> ${podcatViewAllProvider.morePage}");
    printLog("currentPage ======> ${podcatViewAllProvider.currentPage}");
    printLog("totalPage   ======> ${podcatViewAllProvider.totalPage}");
    printLog("nextpage   ======> $nextPage");
    printLog("Call MyCourse");
    printLog("Pageno:== ${(nextPage ?? 0) + 1}");
    await podcatViewAllProvider.getPodcastSectionDetail(
        widget.sectionId, (nextPage ?? 0) + 1);

    await podcatViewAllProvider.setLoadMore(false);
  }

  @override
  void dispose() {
    podcatViewAllProvider.clearProvider();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          body: Column(
            children: [
              MyAppbar(
                title: widget.appbarTitle,
                isSimpleappbar: 1,
                isMultiLang: widget.isTitleMultiLang,
                icon: "back.png",
                onBack: () {
                  Navigator.pop(context);
                },
              ),
              Expanded(
                child: Consumer<PodcatViewAllProvider>(
                    builder: (context, podcatViewAllProvider, child) {
                  if (podcatViewAllProvider.loading &&
                      !podcatViewAllProvider.loadMore) {
                    return buildShimmer();
                  } else {
                    if (podcatViewAllProvider.podcastList != null ||
                        (podcatViewAllProvider.podcastList?.length ?? 0) > 0) {
                      return SingleChildScrollView(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(
                            15, 15, 15, playerMinHeight),
                        child: Column(
                          children: [
                            returnByType(
                              screenLayout: widget.screenLayout,
                              type: widget.sectionType,
                            ),
                            /* Loader */
                            (podcatViewAllProvider.loadMore)
                                ? Container(
                                    height: 50,
                                    margin:
                                        const EdgeInsets.fromLTRB(5, 5, 5, 10),
                                    child: Utils.pageLoader(),
                                  )
                                : const SizedBox.shrink(),
                          ],
                        ),
                      );
                    } else {
                      return const NoData(text: "", subTitle: "");
                    }
                  }
                }),
              ),
              Utils.showBannerAd(context),
            ],
          ),
        ),
        buildMusicPanel(context),
      ],
    );
  }

  /* Type 1 == Radio */
  /* Type 2 == Podcast */
  Widget returnByType({String? screenLayout, int? type}) {
    if (type == 2 &&
        (screenLayout == "sqaure" ||
            screenLayout == "landscape" ||
            screenLayout == "portrait")) {
      return _buildPodcast();
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget buildShimmer() {
    if (widget.sectionType == 2) {
      return podcastShimmer();
    } else {
      return const NoData(text: "", subTitle: "");
    }
  }

  /* ============== Podcast ============== */
  Widget _buildPodcast() {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: ResponsiveGridList(
        minItemWidth: 120,
        minItemsPerRow: 2,
        maxItemsPerRow: 2,
        horizontalGridSpacing: 10,
        verticalGridSpacing: 10,
        listViewBuilderOptions: ListViewBuilderOptions(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
        ),
        children: List.generate(
          podcatViewAllProvider.podcastList?.length ?? 0,
          (position) {
            return InkWell(
              borderRadius: BorderRadius.circular(5),
              onTap: () async {
                final musicdetailProvider =
                    Provider.of<MusicDetailProvider>(context, listen: false);
                await musicdetailProvider.getEpisodebyPodcastList(
                    podcatViewAllProvider.podcastList?[position].id
                            .toString() ??
                        "",
                    0);

                if (!musicdetailProvider.loading) {
                  if (musicdetailProvider.getEpisodeByPodcstModel.status ==
                          200 &&
                      ((musicdetailProvider
                                  .getEpisodeByPodcstModel.result?.length ??
                              0) >
                          0)) {
                    if (!mounted) return;
                    Utils.playAudio(
                        context,
                        "podcast",
                        podcatViewAllProvider
                                .podcastList?[position].isPremium ??
                            0,
                        podcatViewAllProvider.podcastList?[position].isBuy ?? 0,
                        podcatViewAllProvider
                                .podcastList?[position].landscapeImg
                                .toString() ??
                            "",
                        podcatViewAllProvider.podcastList?[position].title
                                .toString() ??
                            "",
                        '',
                        musicdetailProvider
                                .episodeList?[0].episodeAudio
                                .toString() ??
                            "",
                        "",
                        "",
                        musicdetailProvider.episodeList?[0].id.toString() ?? "",
                        podcatViewAllProvider.podcastList?[position].id
                                .toString() ??
                            "",
                        0,
                        musicdetailProvider.episodeList?.toList() ?? []);
                  }
                }
              },
              child: Container(
                width: 185,
                alignment: Alignment.centerLeft,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                  imageUrl: podcatViewAllProvider
                                          .podcastList?[position].landscapeImg
                                          .toString() ??
                                      ""),
                            ),
                          ),
                        ),
                        podcatViewAllProvider
                                        .podcastList?[position].isPremium ==
                                    1 &&
                                podcatViewAllProvider
                                        .podcastList?[position].isBuy ==
                                    0
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
                    MyText(
                        color: Theme.of(context).colorScheme.surface,
                        multilanguage: false,
                        text: podcatViewAllProvider.podcastList?[position].title
                                .toString() ??
                            "",
                        textalign: TextAlign.left,
                        fontsize: Dimens.textSmall,
                        maxline: 2,
                        fontwaight: FontWeight.w600,
                        overflow: TextOverflow.ellipsis,
                        fontstyle: FontStyle.normal),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget podcastShimmer() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: AlignedGridView.count(
        shrinkWrap: true,
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        itemCount: 10,
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext ctx, index) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomWidget.roundrectborder(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.17,
                shapeBorder: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              const SizedBox(height: 2),
              CustomWidget.roundrectborder(
                width: MediaQuery.of(context).size.width,
                height: 15,
                shapeBorder: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 2),
              CustomWidget.roundrectborder(
                width: MediaQuery.of(context).size.width,
                height: 12,
                shapeBorder: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
/* ============== Podcast ============== */

  Widget buildMusicPanel(context) {
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
