import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:yourappname/music/musicdetails.dart';
import 'package:yourappname/pages/login.dart';
import 'package:yourappname/pages/nodata.dart';
import 'package:yourappname/provider/liveeventsprovider.dart';
import 'package:yourappname/subscription/allpayment.dart';
import 'package:yourappname/utils/color.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/customwidget.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/widget/myappbar.dart';
import 'package:yourappname/widget/mynetworkimg.dart';
import 'package:yourappname/widget/mytext.dart';

class LiveEvent extends StatefulWidget {
  const LiveEvent({super.key});

  @override
  State<LiveEvent> createState() => _LiveEventState();
}

class _LiveEventState extends State<LiveEvent> {
  late LiveEventProvider liveEventProvider;
  final ScrollController categoryController = ScrollController();
  late ScrollController _scrollController;

  @override
  void initState() {
    liveEventProvider = Provider.of<LiveEventProvider>(context, listen: false);
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _fetchData(0);
    super.initState();
  }

  _scrollListener() async {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange &&
        (liveEventProvider.currentPage ?? 0) <
            (liveEventProvider.totalPage ?? 0)) {
      await liveEventProvider.setLoadMore(true);
      _fetchData(liveEventProvider.currentPage ?? 0);
    }
  }

  Future<void> _fetchData(int? nextPage) async {
    printLog("isMorePage  ======> ${liveEventProvider.morePage}");
    printLog("currentPage ======> ${liveEventProvider.currentPage}");
    printLog("totalPage   ======> ${liveEventProvider.totalPage}");
    printLog("nextpage   ======> $nextPage");
    printLog("Call MyCourse");
    printLog("Pageno:== ${(nextPage ?? 0) + 1}");
    await liveEventProvider.getLiveEventList((nextPage ?? 0) + 1);
    await liveEventProvider.setLoadMore(false);
  }

  @override
  void dispose() {
    liveEventProvider.clearProvider();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: appBgColor,
      body: Column(
        children: [
          MyAppbar(
            title: "liveevents",
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
                liveEventProvider.clearProvider();
                _fetchData(0);
              },
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
                scrollDirection: Axis.vertical,
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    buildLiveEventList(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildLiveEventList() {
    return Consumer<LiveEventProvider>(
        builder: (context, liveeventprovider, child) {
      if (liveeventprovider.loading && !liveeventprovider.loadMore) {
        return buildLiveEventListShimmer();
      } else {
        if (liveeventprovider.liveEventModel.status == 200 &&
            liveeventprovider.liveEventList != null) {
          if ((liveeventprovider.liveEventList?.length ?? 0) > 0) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildLiveEventListItem(),
                if (liveeventprovider.loadMore)
                  SizedBox(
                    height: 50,
                    child: Utils.pageLoader(),
                  )
                else
                  const SizedBox.shrink(),
              ],
            );
          } else {
            return const NoData(text: "", subTitle: "");
          }
        } else {
          return const NoData(text: "", subTitle: "");
        }
      }
    });
  }

  Widget buildLiveEventListItem() {
    return AlignedGridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      mainAxisSpacing: 20,
      crossAxisSpacing: 15,
      itemCount: liveEventProvider.liveEventList?.length ?? 0,
      padding: const EdgeInsets.fromLTRB(15, 0, 15, 8),
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
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
              if (liveEventProvider.liveEventList?[index].isPaid == 1 &&
                  liveEventProvider.liveEventList?[index].isJoin == 0) {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return AllPayment(
                        payType: 'liveevent',
                        itemId: liveEventProvider.liveEventList?[index].id
                                .toString() ??
                            '',
                        price: liveEventProvider.liveEventList?[index].price
                                .toString() ??
                            '',
                        itemTitle: liveEventProvider.liveEventList?[index].title
                                .toString() ??
                            '',
                        typeId: '',
                        contentType: liveEventProvider
                                .liveEventList?[index].type
                                .toString() ??
                            '',
                        productPackage: '',
                        currency: '',
                      );
                    },
                  ),
                );
              } else {
                if (liveEventProvider.liveEventList?[index].type == 1) {
                  /* Audio */
                  musicManager.playSingleSong(
                    liveEventProvider.liveEventList?[index].id.toString() ?? "",
                    liveEventProvider.liveEventList?[index].title.toString() ??
                        "",
                    liveEventProvider.liveEventList?[index].link.toString() ??
                        "",
                    liveEventProvider.liveEventList?[index].landscapeImg
                            .toString() ??
                        "",
                    "",
                  );
                } else {
                  /* Video */
                  Utils.openPlayer(
                      context: context,
                      videoId: liveEventProvider.liveEventList?[index].id
                              .toString() ??
                          "",
                      videoUrl: liveEventProvider.liveEventList?[index].link
                              .toString() ??
                          "",
                      vUploadType: "external",
                      videoThumb: liveEventProvider
                              .liveEventList?[index].landscapeImg
                              .toString() ??
                          "",
                      stoptime: "",
                      iscontinueWatching: false);
                }
              }
            }
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: MyNetworkImage(
                    imgWidth: MediaQuery.of(context).size.width,
                    imgHeight: 250,
                    fit: BoxFit.cover,
                    imageUrl: liveEventProvider
                            .liveEventList?[index].portraitImg
                            .toString() ??
                        ""),
              ),
              const SizedBox(height: 10),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: colorPrimary.withValues(alpha: 0.09),
                    ),
                    child: Row(
                      children: [
                        MyText(
                          color: colorPrimary,
                          inter: 1,
                          text: Utils.dateformat(DateTime.parse(
                              liveEventProvider.liveEventList?[index].createdAt
                                      .toString() ??
                                  "")),
                          fontsize: Dimens.textSmall,
                          fontwaight: FontWeight.w600,
                          maxline: 1,
                          overflow: TextOverflow.ellipsis,
                          textalign: TextAlign.center,
                          fontstyle: FontStyle.normal,
                        ),
                        const SizedBox(width: 5),
                        MyText(
                          color: colorPrimary,
                          inter: 1,
                          text: "onwards",
                          fontsize: Dimens.textSmall,
                          multilanguage: true,
                          fontwaight: FontWeight.w600,
                          maxline: 1,
                          overflow: TextOverflow.ellipsis,
                          textalign: TextAlign.center,
                          fontstyle: FontStyle.normal,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 3),
                  MyText(
                    color: Theme.of(context).colorScheme.surface,
                    inter: 1,
                    text: liveEventProvider.liveEventList?[index].title
                            .toString() ??
                        "",
                    fontsize: Dimens.textSmall,
                    fontwaight: FontWeight.w600,
                    maxline: 1,
                    overflow: TextOverflow.ellipsis,
                    textalign: TextAlign.left,
                    fontstyle: FontStyle.normal,
                  ),
                  const SizedBox(height: 4),
                  if (liveEventProvider.liveEventList?[index].isPaid
                              .toString() ==
                          "1" &&
                      liveEventProvider.liveEventList?[index].isJoin
                              .toString() ==
                          "0")
                    MyText(
                      color: colorPrimary,
                      inter: 1,
                      text:
                          "${Constant.currencySymbol}${liveEventProvider.liveEventList?[index].price.toString() ?? ""}",
                      fontsize: Dimens.textTitle,
                      fontwaight: FontWeight.w600,
                      maxline: 2,
                      overflow: TextOverflow.ellipsis,
                      textalign: TextAlign.left,
                      fontstyle: FontStyle.normal,
                    )
                  else if (liveEventProvider.liveEventList?[index].isPaid
                              .toString() ==
                          "1" &&
                      liveEventProvider.liveEventList?[index].isJoin
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
            ],
          ),
        );
      },
    );
  }

  Widget buildLiveEventListShimmer() {
    return AlignedGridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      mainAxisSpacing: 20,
      crossAxisSpacing: 15,
      itemCount: 10,
      padding: const EdgeInsets.fromLTRB(15, 0, 15, 8),
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: CustomWidget.roundcorner(
                width: MediaQuery.of(context).size.width,
                height: 250,
              ),
            ),
            const SizedBox(height: 10),
            const Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomWidget.roundcorner(
                  width: 120,
                  height: 8,
                ),
                SizedBox(height: 3),
                CustomWidget.roundcorner(
                  width: 120,
                  height: 8,
                ),
                SizedBox(height: 3),
                CustomWidget.roundcorner(
                  width: 120,
                  height: 8,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
