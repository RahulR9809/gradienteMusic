import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:yourappname/model/audiomodel.dart';
import 'package:yourappname/pages/home.dart';
import 'package:yourappname/music/musicdetails.dart';
import 'package:yourappname/pages/nodata.dart';
import 'package:yourappname/provider/radiobyidprovider.dart';
import 'package:yourappname/utils/color.dart';
import 'package:yourappname/utils/customwidget.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/widget/myappbar.dart';
import 'package:yourappname/widget/myimage.dart';
import 'package:yourappname/widget/mynetworkimg.dart';
import 'package:yourappname/widget/mytext.dart';

class RadioById extends StatefulWidget {
  final String title, viewType, itemId, languagegId;
  const RadioById({
    super.key,
    required this.title,
    required this.viewType,
    required this.itemId,
    required this.languagegId,
  });

  @override
  State<RadioById> createState() => _RadioByIdState();
}

class _RadioByIdState extends State<RadioById> {
  late RadioByIdProvider radioByIdProvider;
  late ScrollController _scrollController;

  @override
  void initState() {
    radioByIdProvider = Provider.of<RadioByIdProvider>(context, listen: false);
    super.initState();
    _fetchData(0);
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  Future<void> _fetchData(int? nextPage) async {
    printLog("morePage  =======> ${radioByIdProvider.morePage}");
    printLog("currentPage =====> ${radioByIdProvider.currentPage}");
    printLog("totalPage   =====> ${radioByIdProvider.totalPage}");

    if (widget.viewType == "artist") {
      await radioByIdProvider.getRadiobyArtist(
          widget.itemId, (nextPage ?? 0).toString());
    } else if (widget.viewType == "category") {
      await radioByIdProvider.getRadiobyCategory(
          widget.itemId, widget.languagegId, (nextPage ?? 0).toString());
    } else if (widget.viewType == "language") {
      await radioByIdProvider.getRadiobyLanguage(
          widget.itemId, (nextPage ?? 0).toString());
    } else if (widget.viewType == "city") {
      await radioByIdProvider.getRadiobyCity(
          widget.itemId, widget.languagegId, (nextPage ?? 0).toString());
    }
    printLog(
        "resultSongList ====> ${radioByIdProvider.resultSongList?.length}");
    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
    });
  }

  _scrollListener() async {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange &&
        (radioByIdProvider.currentPage ?? 0) <
            (radioByIdProvider.totalPage ?? 0)) {
      radioByIdProvider.setLoadMore(true);
      _fetchData(radioByIdProvider.currentPage ?? 0);
    }
  }

  playAudio({
    required List<Result>? resultSongList,
    required int position,
  }) async {
    String playType = "";
    if (widget.viewType == "artist") {
      playType = "radiobyartist";
    } else if (widget.viewType == "category") {
      playType = "radiobycategory";
    } else if (widget.viewType == "city") {
      playType = "radiobycity";
    } else if (widget.viewType == "language") {
      playType = "radiobylanguage";
    }
    printLog("playType ==========> $playType");
    Utils.playAudio(
      context,
      "radio",
      resultSongList?[position].isPremium ?? 0,
      resultSongList?[position].isBuy ?? 0,
      resultSongList?[position].image.toString() ?? "",
      resultSongList?[position].name.toString() ?? "",
      playType,
      resultSongList?[position].songUrl.toString() ?? "",
      resultSongList?[position].languageName.toString() ?? "",
      resultSongList?[position].artistName.toString() ?? "",
      resultSongList?[position].id.toString() ?? "",
      "",
      position,
      resultSongList?.toList() ?? [],
    );
  }

  @override
  void dispose() {
    radioByIdProvider.clearProvider();
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
                isSimpleappbar: 1,
                title: widget.title.toString(),
                isMultiLang: false,
                icon: "back.png",
                onBack: () {
                  Navigator.pop(context);
                },
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding:
                      const EdgeInsets.fromLTRB(15, 15, 15, playerMinHeight),
                  child: Column(
                    children: [
                      _buildRadio(),

                      /* Loader */
                      Consumer<RadioByIdProvider>(
                        builder: (context, radioByIdProvider, child) {
                          if (radioByIdProvider.loadMore) {
                            return Container(
                              height: 50,
                              margin: const EdgeInsets.fromLTRB(5, 5, 5, 10),
                              child: Utils.pageLoader(),
                            );
                          } else {
                            return const SizedBox.shrink();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Utils.showBannerAd(context),
            ],
          ),
        ),
        buildMusicPanel(context),
      ],
    );
  }

  /* Radio START ****************** */
  Widget _buildRadio() {
    if (radioByIdProvider.loading) {
      return radioShimmer();
    }
    return Consumer<RadioByIdProvider>(
      builder: (context, allRadioProvider, child) {
        if (allRadioProvider.resultSongList == null ||
            (allRadioProvider.resultSongList?.length ?? 0) == 0) {
          return const NoData(text: "", subTitle: "");
        }
        return AlignedGridView.count(
          shrinkWrap: true,
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          itemCount: (allRadioProvider.resultSongList?.length ?? 0),
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (BuildContext context, int position) {
            return InkWell(
              borderRadius: BorderRadius.circular(5),
              onTap: () {
                playAudio(
                  position: position,
                  resultSongList: allRadioProvider.resultSongList,
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
                          imgHeight: MediaQuery.of(context).size.height * 0.17,
                          imageUrl: allRadioProvider
                                  .resultSongList?[position].image
                                  .toString() ??
                              "",
                          fit: BoxFit.cover,
                        ),
                      ),
                      allRadioProvider.resultSongList?[position].isPremium ==
                                  1 &&
                              allRadioProvider
                                      .resultSongList?[position].isBuy ==
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
                    text: allRadioProvider.resultSongList?[position].name
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
                    text: allRadioProvider
                            .resultSongList?[position].categoryName
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
        );
      },
    );
  }

  Widget radioShimmer() {
    return AlignedGridView.count(
      shrinkWrap: true,
      crossAxisCount: 3,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
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
    );
  }
  /* Radio END ****************** */

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
