import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:yourappname/pages/radiobyid.dart';
import 'package:yourappname/pages/home.dart';
import 'package:yourappname/music/musicdetails.dart';
import 'package:yourappname/pages/nodata.dart';
import 'package:yourappname/provider/musicdetailprovider.dart';
import 'package:yourappname/provider/viewallprovider.dart';
import 'package:yourappname/utils/color.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/customwidget.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/widget/myappbar.dart';
import 'package:yourappname/widget/myimage.dart';
import 'package:yourappname/widget/mynetworkimg.dart';
import 'package:yourappname/widget/mytext.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

class ViewAll extends StatefulWidget {
  final String screenLayout, appbarTitle, sectionId;
  final int sectionType;
  final bool isTitleMultiLang;
  const ViewAll({
    required this.sectionId,
    required this.sectionType,
    required this.screenLayout,
    required this.appbarTitle,
    required this.isTitleMultiLang,
    super.key,
  });
  @override
  State<ViewAll> createState() => _ViewAllState();
}

class _ViewAllState extends State<ViewAll> {
  late ViewAllProvider viewAllProvider;
  late ScrollController _scrollController;

  @override
  void initState() {
    viewAllProvider = Provider.of<ViewAllProvider>(context, listen: false);
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
        (viewAllProvider.currentPage ?? 0) < (viewAllProvider.totalPage ?? 0)) {
      viewAllProvider.setLoadMore(true);
      _fetchSectionDetail(viewAllProvider.currentPage ?? 0);
    }
  }

  Future<void> _fetchSectionDetail(int? nextPage) async {
    printLog("isMorePage  ======> ${viewAllProvider.isMorePage}");
    printLog("currentPage ======> ${viewAllProvider.currentPage}");
    printLog("totalPage   ======> ${viewAllProvider.totalPage}");
    printLog("nextpage   ======> $nextPage");
    printLog("Call MyCourse");
    printLog("Pageno:== ${(nextPage ?? 0) + 1}");
    await viewAllProvider.getSeactionDetail(
        widget.sectionId, (nextPage ?? 0) + 1);

    await viewAllProvider.setLoadMore(false);
  }

  @override
  void dispose() {
    viewAllProvider.clearProvider();
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
                child: Consumer<ViewAllProvider>(
                    builder: (context, viewAllProvider, child) {
                  if (viewAllProvider.loading && !viewAllProvider.loadmore) {
                    return buildShimmer();
                  } else {
                    if (viewAllProvider.sectionDetailList != null ||
                        (viewAllProvider.sectionDetailList?.length ?? 0) > 0) {
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
                            (viewAllProvider.loadmore)
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
    if (type == 1 &&
        (screenLayout == "sqaure" ||
            screenLayout == "landscape" ||
            screenLayout == "portrait")) {
      return _buildRadio();
    } else if (type == 2 &&
        (screenLayout == "sqaure" ||
            screenLayout == "landscape" ||
            screenLayout == "portrait")) {
      return _buildPodcast();
    } else {
      if (screenLayout == "category") {
        return _buildCategory();
      } else if (screenLayout == "language") {
        return _buildLanguage();
      } else if (screenLayout == "artist") {
        return _buildArtist();
      } else if (screenLayout == "city") {
        return _buildCity();
      } else if (screenLayout == "live_event") {
        return _buildLiveEvent();
      } else {
        return const NoData(text: "", subTitle: "");
      }
    }
  }

  Widget buildShimmer() {
    if (widget.sectionType == 1) {
      return radioShimmer();
    } else if (widget.sectionType == 2) {
      return podcastShimmer();
    } else {
      if (widget.screenLayout == "category") {
        return categoryShimmer();
      } else if (widget.screenLayout == "language") {
        return languageShimmer();
      } else if (widget.screenLayout == "artist") {
        return artistShimmer();
      } else if (widget.screenLayout == "city") {
        return cityShimmer();
      } else if (widget.screenLayout == "live_event") {
        return liveEventShimmer();
      } else {
        return const NoData(text: "", subTitle: "");
      }
    }
  }

  /* ============== Artist ============== */
  Widget _buildArtist() {
    return MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: ResponsiveGridList(
            minItemWidth: 120,
            minItemsPerRow: 3,
            maxItemsPerRow: 3,
            horizontalGridSpacing: 10,
            verticalGridSpacing: 10,
            listViewBuilderOptions: ListViewBuilderOptions(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
            ),
            children: List.generate(
                viewAllProvider.sectionDetailList?.length ?? 0, (index) {
              return InkWell(
                borderRadius: BorderRadius.circular(60),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return RadioById(
                          itemId: viewAllProvider.sectionDetailList?[index].id
                                  .toString() ??
                              "",
                          viewType: "artist",
                          title: viewAllProvider.sectionDetailList?[index].name
                                  .toString() ??
                              "",
                          languagegId: "",
                        );
                      },
                    ),
                  );
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(60),
                      child: MyNetworkImage(
                        imgWidth: MediaQuery.of(context).size.width,
                        imgHeight: 100,
                        imageUrl: viewAllProvider
                                .sectionDetailList?[index].image
                                .toString() ??
                            "",
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 5),
                    MyText(
                      color: Theme.of(context).colorScheme.surface,
                      inter: 1,
                      text: viewAllProvider.sectionDetailList?[index].name
                              .toString() ??
                          "",
                      fontsize: Dimens.textSmall,
                      fontwaight: FontWeight.w600,
                      maxline: 1,
                      overflow: TextOverflow.ellipsis,
                      textalign: TextAlign.center,
                      fontstyle: FontStyle.normal,
                    ),
                  ],
                ),
              );
            })));
  }

  Widget artistShimmer() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: AlignedGridView.count(
        shrinkWrap: true,
        crossAxisCount: 3,
        mainAxisSpacing: 15,
        crossAxisSpacing: 15,
        itemCount: 10,
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int position) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CustomWidget.circular(
                width: 90,
                height: 90,
              ),
              const SizedBox(height: 5),
              CustomWidget.roundrectborder(
                width: MediaQuery.of(context).size.width,
                height: 15,
              ),
            ],
          );
        },
      ),
    );
  }
  /* ============== Artist ============== */

  /* ============== City ============== */
  Widget _buildCity() {
    return MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: ResponsiveGridList(
            minItemWidth: 120,
            minItemsPerRow: 3,
            maxItemsPerRow: 3,
            horizontalGridSpacing: 10,
            verticalGridSpacing: 10,
            listViewBuilderOptions: ListViewBuilderOptions(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
            ),
            children: List.generate(
                viewAllProvider.sectionDetailList?.length ?? 0, (index) {
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return RadioById(
                          itemId: viewAllProvider.sectionDetailList?[index].id
                                  .toString() ??
                              "",
                          viewType: "city",
                          title: viewAllProvider.sectionDetailList?[index].name
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
                  height: 120,
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
                          imageUrl: viewAllProvider
                                  .sectionDetailList?[index].image
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
                            text: viewAllProvider.sectionDetailList?[index].name
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
            })));
  }

  Widget cityShimmer() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: AlignedGridView.count(
        shrinkWrap: true,
        crossAxisCount: 3,
        mainAxisSpacing: 15,
        crossAxisSpacing: 15,
        itemCount: 10,
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int position) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CustomWidget.circular(
                width: 90,
                height: 90,
              ),
              const SizedBox(height: 5),
              CustomWidget.roundrectborder(
                width: MediaQuery.of(context).size.width,
                height: 15,
              ),
            ],
          );
        },
      ),
    );
  }
  /* ============== City ============== */

  /* ============== Language ============== */
  Widget _buildLanguage() {
    return MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: ResponsiveGridList(
            minItemWidth: 120,
            minItemsPerRow: 3,
            maxItemsPerRow: 3,
            horizontalGridSpacing: 10,
            verticalGridSpacing: 10,
            listViewBuilderOptions: ListViewBuilderOptions(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
            ),
            children: List.generate(
                viewAllProvider.sectionDetailList?.length ?? 0, (index) {
              return InkWell(
                borderRadius: BorderRadius.circular(50),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return RadioById(
                          itemId: viewAllProvider.sectionDetailList?[index].id
                                  .toString() ??
                              "",
                          viewType: "language",
                          title: viewAllProvider.sectionDetailList?[index].name
                                  .toString() ??
                              "",
                          languagegId: viewAllProvider.sectionDetailList?[index]
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
                            imageUrl: viewAllProvider
                                    .sectionDetailList?[index].image
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
                            text: (viewAllProvider
                                            .sectionDetailList?[index].name ==
                                        "" ||
                                    viewAllProvider
                                            .sectionDetailList?[index].name
                                            .toString() ==
                                        "false")
                                ? "-"
                                : viewAllProvider.sectionDetailList?[index].name
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
              );
            })));
  }

  Widget languageShimmer() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: AlignedGridView.count(
        shrinkWrap: true,
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        itemCount: 20,
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int position) {
          return CustomWidget.roundrectborder(
            width: MediaQuery.of(context).size.width,
            height: 60,
            shapeBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
          );
        },
      ),
    );
  }
  /* ============== Language ============== */

  /* ============== Category ============== */

  Widget _buildCategory() {
    return MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: ResponsiveGridList(
            minItemWidth: 120,
            minItemsPerRow: 3,
            maxItemsPerRow: 3,
            horizontalGridSpacing: 10,
            verticalGridSpacing: 10,
            listViewBuilderOptions: ListViewBuilderOptions(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
            ),
            children: List.generate(
                viewAllProvider.sectionDetailList?.length ?? 0, (index) {
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return RadioById(
                          itemId: viewAllProvider.sectionDetailList?[index].id
                                  .toString() ??
                              "",
                          viewType: "category",
                          title: viewAllProvider.sectionDetailList?[index].name
                                  .toString() ??
                              "",
                          languagegId: "",
                        );
                      },
                    ),
                  );
                },
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.15,
                  decoration: BoxDecoration(
                    color: Theme.of(context).secondaryHeaderColor,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MyNetworkImage(
                        imgWidth: 45,
                        imgHeight: 45,
                        imageUrl: viewAllProvider
                                .sectionDetailList?[index].image
                                .toString() ??
                            "",
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                        child: MyText(
                          color: Theme.of(context).colorScheme.surface,
                          text: viewAllProvider.sectionDetailList?[index].name
                                  .toString() ??
                              "",
                          textalign: TextAlign.center,
                          fontsize: Dimens.textSmall,
                          inter: 1,
                          maxline: 1,
                          fontwaight: FontWeight.w500,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            })));
  }

  Widget categoryShimmer() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: AlignedGridView.count(
        shrinkWrap: true,
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        itemCount: 10,
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int position) {
          return CustomWidget.roundcorner(
            height: MediaQuery.of(context).size.height * 0.15,
          );
        },
      ),
    );
  }
  /* ============== Category ============== */

  Widget _buildLiveEvent() {
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
                viewAllProvider.sectionDetailList?.length ?? 0, (position) {
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return RadioById(
                          itemId: viewAllProvider
                                  .sectionDetailList?[position].id
                                  .toString() ??
                              "",
                          viewType: "category",
                          title: viewAllProvider
                                  .sectionDetailList?[position].name
                                  .toString() ??
                              "",
                          languagegId: "",
                        );
                      },
                    ),
                  );
                },
                child: SizedBox(
                  width: 260,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: MyNetworkImage(
                                imgHeight: 200,
                                imageUrl: viewAllProvider
                                        .sectionDetailList?[position]
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
                                  text: viewAllProvider
                                          .sectionDetailList?[position].title
                                          .toString() ??
                                      "",
                                  textalign: TextAlign.left,
                                  fontsize: Dimens.textSmall,
                                  maxline: 2,
                                  fontwaight: FontWeight.w600,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal),
                              const SizedBox(height: 5),
                              if (viewAllProvider
                                          .sectionDetailList?[position].isPaid
                                          .toString() ==
                                      "1" &&
                                  viewAllProvider
                                          .sectionDetailList?[position].isJoin
                                          .toString() ==
                                      "0")
                                MyText(
                                  color: colorPrimary,
                                  inter: 1,
                                  text:
                                      "${Constant.currencySymbol}${viewAllProvider.sectionDetailList?[position].price.toString() ?? ""}",
                                  fontsize: Dimens.textTitle,
                                  fontwaight: FontWeight.w700,
                                  maxline: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textalign: TextAlign.left,
                                  fontstyle: FontStyle.normal,
                                )
                              else if (viewAllProvider
                                          .sectionDetailList?[position].isPaid
                                          .toString() ==
                                      "1" &&
                                  viewAllProvider
                                          .sectionDetailList?[position].isJoin
                                          .toString() ==
                                      "1")
                                Container(
                                  padding:
                                      const EdgeInsets.fromLTRB(5, 3, 5, 3),
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
            })));
  }

  Widget liveEventShimmer() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: AlignedGridView.count(
        shrinkWrap: true,
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        itemCount: 10,
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int position) {
          return const Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomWidget.roundcorner(
                height: 250,
              ),
              CustomWidget.roundcorner(
                height: 5,
              ),
              CustomWidget.roundcorner(
                height: 5,
              ),
            ],
          );
        },
      ),
    );
  }

  /* ============== Radio ============== */
  Widget _buildRadio() {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: ResponsiveGridList(
          minItemWidth: 120,
          minItemsPerRow: 3,
          maxItemsPerRow: 3,
          horizontalGridSpacing: 10,
          verticalGridSpacing: 10,
          listViewBuilderOptions: ListViewBuilderOptions(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
          ),
          children: List.generate(
            viewAllProvider.sectionDetailList?.length ?? 0,
            (position) {
              return InkWell(
                borderRadius: BorderRadius.circular(5),
                onTap: () {
                  Utils.playAudio(
                    context,
                    "radio",
                    viewAllProvider.sectionDetailList?[position].isPremium ?? 0,
                    viewAllProvider.sectionDetailList?[position].isBuy ?? 0,
                    viewAllProvider.sectionDetailList?[position].image
                            .toString() ??
                        "",
                    viewAllProvider.sectionDetailList?[position].name
                            .toString() ??
                        "",
                    'allradio',
                    viewAllProvider.sectionDetailList?[position].songUrl
                            .toString() ??
                        "",
                    viewAllProvider.sectionDetailList?[position].languageName
                            .toString() ??
                        "",
                    viewAllProvider.sectionDetailList?[position].artistName
                            .toString() ??
                        "",
                    viewAllProvider.sectionDetailList?[position].id
                            .toString() ??
                        "",
                    "",
                    position,
                    viewAllProvider.sectionDetailList?.toList() ?? [],
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: MyNetworkImage(
                            imgWidth: MediaQuery.of(context).size.width,
                            imgHeight:
                                MediaQuery.of(context).size.height * 0.17,
                            imageUrl: viewAllProvider
                                    .sectionDetailList?[position].image
                                    .toString() ??
                                "",
                            fit: BoxFit.cover,
                          ),
                        ),
                        viewAllProvider.sectionDetailList?[position]
                                        .isPremium ==
                                    1 &&
                                viewAllProvider
                                        .sectionDetailList?[position].isBuy ==
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
                      text: viewAllProvider.sectionDetailList?[position].name
                              .toString() ??
                          "",
                      textalign: TextAlign.start,
                      fontsize: Dimens.textMedium,
                      inter: 1,
                      maxline: 1,
                      fontwaight: FontWeight.w500,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal,
                    ),
                    const SizedBox(height: 2),
                    MyText(
                      color: gray,
                      text: viewAllProvider
                              .sectionDetailList?[position].categoryName
                              .toString() ??
                          "",
                      textalign: TextAlign.start,
                      fontsize: Dimens.textSmall,
                      inter: 1,
                      maxline: 1,
                      fontwaight: FontWeight.w400,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal,
                    ),
                  ],
                ),
              );
            },
          )),
    );
  }

  Widget radioShimmer() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: AlignedGridView.count(
        shrinkWrap: true,
        crossAxisCount: 3,
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
  /* ============== Radio ============== */

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
          viewAllProvider.sectionDetailList?.length ?? 0,
          (position) {
            return InkWell(
              borderRadius: BorderRadius.circular(5),
              onTap: () async {
                final musicdetailProvider =
                    Provider.of<MusicDetailProvider>(context, listen: false);
                await musicdetailProvider.getEpisodebyPodcastList(
                    viewAllProvider.sectionDetailList?[position].id
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
                        viewAllProvider
                                .sectionDetailList?[position].isPremium ??
                            0,
                        viewAllProvider.sectionDetailList?[position].isBuy ?? 0,
                        viewAllProvider
                                .sectionDetailList?[position].landscapeImg
                                .toString() ??
                            "",
                        viewAllProvider.sectionDetailList?[position].title
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
                        viewAllProvider.sectionDetailList?[position].id
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
                                  imageUrl: viewAllProvider
                                          .sectionDetailList?[position]
                                          .landscapeImg
                                          .toString() ??
                                      ""),
                            ),
                          ),
                        ),
                        viewAllProvider.sectionDetailList?[position]
                                        .isPremium ==
                                    1 &&
                                viewAllProvider
                                        .sectionDetailList?[position].isBuy ==
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
                        text: viewAllProvider.sectionDetailList?[position].title
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
