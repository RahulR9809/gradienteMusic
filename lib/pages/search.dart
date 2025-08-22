import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:yourappname/pages/home.dart';
import 'package:yourappname/music/musicdetails.dart';
import 'package:yourappname/pages/nodata.dart';
import 'package:yourappname/provider/musicdetailprovider.dart';
import 'package:yourappname/provider/searchprovider.dart';
import 'package:yourappname/utils/color.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/customwidget.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/widget/myimage.dart';
import 'package:yourappname/widget/mynetworkimg.dart';
import 'package:yourappname/widget/mytext.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  late SearchProvider searchProvider;
  final searchController = TextEditingController();

  @override
  void initState() {
    searchProvider = Provider.of<SearchProvider>(context, listen: false);
    super.initState();
  }

  Future<void> _fetchData(type, int? nextPage) async {
    await searchProvider.getSearch(searchController.text.toString(), type,
        ((nextPage ?? 0) + 1).toString());
  }

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
    searchProvider.clearProvider();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          body: Consumer<SearchProvider>(
              builder: (context, searchprovider, child) {
            return Column(
              children: [
                Container(
                  constraints: const BoxConstraints(minHeight: 0),
                  decoration: const BoxDecoration(
                    color: colorPrimary,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(25),
                      bottomRight: Radius.circular(25),
                    ),
                  ),
                  child: Column(
                    children: [
                      AppBar(
                        backgroundColor: transparent,
                        elevation: 0,
                        automaticallyImplyLeading: false,
                        titleSpacing: 10,
                        systemOverlayStyle: const SystemUiOverlayStyle(
                          statusBarColor: colorPrimary,
                          statusBarBrightness: Brightness.light,
                        ),
                        leading: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: MyImage(
                              width: 15, height: 15, imagePath: "back.png"),
                        ),
                        title: MyText(
                            color: white,
                            text: "search",
                            textalign: TextAlign.center,
                            fontsize: Dimens.textlargeExtraBig,
                            inter: 1,
                            maxline: 2,
                            multilanguage: true,
                            fontwaight: FontWeight.w500,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal),
                        centerTitle: true,
                      ),
                      const SizedBox(height: 5),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
                        alignment: Alignment.center,
                        child: TextFormField(
                          textAlign: TextAlign.start,
                          controller: searchController,
                          keyboardType: TextInputType.text,
                          cursorColor: black,
                          style: Utils.googleFontStyle(
                              1, 18, FontStyle.normal, black, FontWeight.w400),
                          onChanged: (value) async {
                            if (value.isNotEmpty) {
                              if (searchProvider.layoutType ==
                                  Constant.radioType) {
                                _fetchData("1", 0);
                              } else {
                                _fetchData("2", 0);
                              }
                            } else {
                              searchProvider.clearProvider();
                            }
                          },
                          decoration: InputDecoration(
                            prefixIcon: Container(
                              width: 30,
                              height: 30,
                              alignment: Alignment.center,
                              child: MyImage(
                                width: 20,
                                height: 20,
                                imagePath: "ic_search.png",
                                color: lightgray,
                              ),
                            ),
                            hintText: Locales.string(context, "search"),
                            hintStyle: Utils.googleFontStyle(1, 18,
                                FontStyle.normal, lightgray, FontWeight.w400),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(32),
                              borderSide: const BorderSide(
                                width: 0,
                                style: BorderStyle.none,
                              ),
                            ),
                            filled: true,
                            contentPadding: const EdgeInsets.all(10),
                            fillColor: white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                tabButton(),
                Expanded(child: searchList()),
              ],
            );
          }),
        ),
        buildMusicPanel(context),
      ],
    );
  }

  Widget tabButton() {
    return Consumer<SearchProvider>(builder: (context, searchprovider, child) {
      return Container(
        width: MediaQuery.of(context).size.width,
        height: 60,
        alignment: Alignment.centerRight,
        margin: const EdgeInsets.fromLTRB(15, 15, 15, 5),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          color: colorPrimary.withValues(alpha: 0.18),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: InkWell(
                borderRadius: BorderRadius.circular(50),
                focusColor: transparent,
                highlightColor: transparent,
                hoverColor: transparent,
                splashColor: transparent,
                onTap: () async {
                  await searchProvider.selectLayout(Constant.radioType);
                  await searchProvider.clearSearch();
                  _fetchData("1", 0);
                },
                child: Container(
                  alignment: Alignment.center,
                  height: MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: searchProvider.layoutType == Constant.radioType
                        ? colorPrimary
                        : transparent,
                  ),
                  child: MyText(
                      color: searchProvider.layoutType == Constant.radioType
                          ? white
                          : Theme.of(context).colorScheme.surface,
                      text: "radio",
                      multilanguage: true,
                      fontsize: Dimens.textSmall,
                      fontwaight: FontWeight.w600,
                      maxline: 3,
                      overflow: TextOverflow.ellipsis,
                      textalign: TextAlign.left,
                      fontstyle: FontStyle.normal),
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              flex: 1,
              child: InkWell(
                borderRadius: BorderRadius.circular(50),
                focusColor: transparent,
                highlightColor: transparent,
                hoverColor: transparent,
                splashColor: transparent,
                onTap: () async {
                  await searchprovider.selectLayout(Constant.podcastType);
                  await searchprovider.clearSearch();
                  _fetchData("2", 0);
                },
                child: Container(
                  alignment: Alignment.center,
                  height: MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: searchprovider.layoutType == Constant.podcastType
                        ? colorPrimary
                        : transparent,
                  ),
                  child: MyText(
                      color: searchprovider.layoutType == Constant.podcastType
                          ? white
                          : Theme.of(context).colorScheme.surface,
                      text: "podcast",
                      multilanguage: true,
                      fontsize: Dimens.textSmall,
                      fontwaight: FontWeight.w600,
                      maxline: 3,
                      overflow: TextOverflow.ellipsis,
                      textalign: TextAlign.left,
                      fontstyle: FontStyle.normal),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget searchList() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(15, 15, 15, playerMinHeight),
      child: searchProvider.layoutType == Constant.radioType
          ? _buildRadio()
          : _buildPodcast(),
    );
  }

  Widget _buildRadio() {
    if (searchProvider.loading) {
      return searchShimmer();
    }
    return Consumer<SearchProvider>(
      builder: (context, searchProvider, child) {
        if (searchProvider.resultDataList == null ||
            (searchProvider.resultDataList?.length ?? 0) == 0) {
          return const NoData(text: "", subTitle: "");
        }
        return AlignedGridView.count(
          shrinkWrap: true,
          crossAxisCount: 1,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          itemCount: (searchProvider.resultDataList?.length ?? 0),
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            return InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                Utils.playAudio(
                  context,
                  "radio",
                  searchProvider.resultDataList?[index].isPremium ?? 0,
                  searchProvider.resultDataList?[index].isBuy ?? 0,
                  searchProvider.resultDataList?[index].image.toString() ?? "",
                  searchProvider.resultDataList?[index].name.toString() ?? "",
                  'search',
                  searchProvider.resultDataList?[index].songUrl.toString() ??
                      "",
                  searchController.text.toString(),
                  searchProvider.resultDataList?[index].artistName.toString() ??
                      "",
                  searchProvider.resultDataList?[index].id.toString() ?? "",
                  "",
                  index,
                  searchProvider.resultDataList?.toList() ?? [],
                );
              },
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Theme.of(context).secondaryHeaderColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: MyNetworkImage(
                            imgWidth: 65,
                            imgHeight: 65,
                            imageUrl: searchProvider
                                    .resultDataList?[index].image
                                    .toString() ??
                                "",
                            fit: BoxFit.cover,
                          ),
                        ),
                        searchProvider.resultDataList?[index].isPremium == 1 &&
                                searchProvider.resultDataList?[index].isBuy == 0
                            ? Positioned.fill(
                                top: 5,
                                left: 5,
                                right: 5,
                                child: Align(
                                  alignment: Alignment.topLeft,
                                  child: Container(
                                      width: 20,
                                      height: 20,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(50),
                                        color: colorPrimary,
                                      ),
                                      child: MyImage(
                                          width: 10,
                                          height: 10,
                                          color: white,
                                          imagePath: "ic_primium.png")),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ],
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MyText(
                            color: Theme.of(context).colorScheme.surface,
                            text: searchProvider.resultDataList?[index].name
                                    .toString() ??
                                "",
                            textalign: TextAlign.start,
                            fontsize: Dimens.textTitle,
                            inter: 1,
                            maxline: 1,
                            fontwaight: FontWeight.w600,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal,
                          ),
                          MyText(
                            color: gray,
                            text: searchProvider
                                    .resultDataList?[index].languageName
                                    .toString() ??
                                "",
                            textalign: TextAlign.start,
                            fontsize: Dimens.textMedium,
                            inter: 1,
                            maxline: 2,
                            fontwaight: FontWeight.w400,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal,
                          ),
                        ],
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
  }

  Widget _buildPodcast() {
    if (searchProvider.loading) {
      return searchShimmer();
    }
    return Consumer<SearchProvider>(
      builder: (context, searchProvider, child) {
        if (searchProvider.resultDataList == null ||
            (searchProvider.resultDataList?.length ?? 0) == 0) {
          return const NoData(text: "", subTitle: "");
        }
        return AlignedGridView.count(
          shrinkWrap: true,
          crossAxisCount: 1,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          itemCount: (searchProvider.resultDataList?.length ?? 0),
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            return InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () async {
                final musicdetailProvider =
                    Provider.of<MusicDetailProvider>(context, listen: false);
                await musicdetailProvider.getEpisodebyPodcastList(
                    searchProvider.resultDataList?[index].id.toString() ?? "",
                    0);

                if (!musicdetailProvider.loading) {
                  if (musicdetailProvider.getEpisodeByPodcstModel.status ==
                          200 &&
                      ((musicdetailProvider
                                  .getEpisodeByPodcstModel.result?.length ??
                              0) >
                          0)) {
                    if (!context.mounted) return;
                    Utils.playAudio(
                        context,
                        "podcast",
                        searchProvider.resultDataList?[index].isPremium ?? 0,
                        searchProvider.resultDataList?[index].isBuy ?? 0,
                        searchProvider.resultDataList?[index].landscapeImg
                                .toString() ??
                            "",
                        searchProvider.resultDataList?[index].title
                                .toString() ??
                            "",
                        '',
                        musicdetailProvider.episodeList?[0].episodeAudio
                                .toString() ??
                            "",
                        "",
                        "",
                        musicdetailProvider.episodeList?[0].id.toString() ?? "",
                        searchProvider.resultDataList?[index].id.toString() ??
                            "",
                        0,
                        musicdetailProvider.episodeList?.toList() ?? []);
                  }
                }
              },
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Theme.of(context).secondaryHeaderColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: MyNetworkImage(
                            imgWidth: 65,
                            imgHeight: 65,
                            imageUrl: searchProvider
                                    .resultDataList?[index].portraitImg
                                    .toString() ??
                                "",
                            fit: BoxFit.cover,
                          ),
                        ),
                        searchProvider.resultDataList?[index].isPremium == 1 &&
                                searchProvider.resultDataList?[index].isBuy == 0
                            ? Positioned.fill(
                                top: 5,
                                left: 5,
                                right: 5,
                                child: Align(
                                  alignment: Alignment.topLeft,
                                  child: Container(
                                      width: 20,
                                      height: 20,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(50),
                                        color: colorPrimary,
                                      ),
                                      child: MyImage(
                                          width: 10,
                                          height: 10,
                                          color: white,
                                          imagePath: "ic_primium.png")),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ],
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MyText(
                            color: Theme.of(context).colorScheme.surface,
                            text: searchProvider.resultDataList?[index].title
                                    .toString() ??
                                "",
                            textalign: TextAlign.start,
                            fontsize: Dimens.textTitle,
                            inter: 1,
                            maxline: 1,
                            fontwaight: FontWeight.w600,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal,
                          ),
                          MyText(
                            color: gray,
                            text: searchProvider
                                    .resultDataList?[index].languageName
                                    .toString() ??
                                "",
                            textalign: TextAlign.start,
                            fontsize: Dimens.textMedium,
                            inter: 1,
                            maxline: 2,
                            fontwaight: FontWeight.w400,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal,
                          ),
                        ],
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
  }

  Widget searchShimmer() {
    return SingleChildScrollView(
      child: AlignedGridView.count(
        shrinkWrap: true,
        crossAxisCount: 1,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        itemCount: 10,
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext ctx, index) {
          return Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            decoration: BoxDecoration(
              color: Theme.of(context).secondaryHeaderColor,
              borderRadius: BorderRadius.circular(10),
            ),
            width: MediaQuery.of(context).size.width,
            child: const Row(
              children: [
                CustomWidget.circular(
                  width: 65,
                  height: 65,
                ),
                SizedBox(width: 15),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomWidget.roundrectborder(
                        width: 150,
                        height: 15,
                      ),
                      CustomWidget.roundrectborder(width: 120, height: 15),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

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
