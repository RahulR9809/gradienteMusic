import 'package:yourappname/provider/subhistoryprovider.dart';
import 'package:yourappname/utils/color.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/widget/mytext.dart';
import 'package:yourappname/pages/nodata.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

class SubscriptionHistory extends StatefulWidget {
  const SubscriptionHistory({super.key});

  @override
  State<SubscriptionHistory> createState() => _SubscriptionHistoryState();
}

class _SubscriptionHistoryState extends State<SubscriptionHistory> {
  late SubHistoryProvider subHistoryProvider;

  @override
  void initState() {
    subHistoryProvider =
        Provider.of<SubHistoryProvider>(context, listen: false);
    _getData();
    super.initState();
  }

  _getData() async {
    await subHistoryProvider.getTransactionList();
  }

  @override
  void dispose() {
    subHistoryProvider.clearProvider();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBgColor,
      appBar: Utils.myAppBarWithBack(context, "transactions", true),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 12, bottom: 12),
                child: Consumer<SubHistoryProvider>(
                  builder: (context, subHistoryProvider, child) {
                    if (subHistoryProvider.loading) {
                      return Utils.pageLoader();
                    } else {
                      if (subHistoryProvider.historyModel.status == 200 &&
                          subHistoryProvider.historyModel.result != null) {
                        if ((subHistoryProvider.historyModel.result?.length ??
                                0) >
                            0) {
                          return AlignedGridView.count(
                            shrinkWrap: true,
                            crossAxisCount: 1,
                            crossAxisSpacing: 0,
                            mainAxisSpacing: 12,
                            padding: const EdgeInsets.only(left: 15, right: 15),
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: subHistoryProvider
                                    .historyModel.result?.length ??
                                0,
                            itemBuilder: (BuildContext context, int position) {
                              return _buildHistoryItem(position);
                            },
                          );
                        } else {
                          return const NoData(text: "", subTitle: "");
                        }
                      } else {
                        return const NoData(text: "", subTitle: "");
                      }
                    }
                  },
                ),
              ),
            ),
            /* AdMob Banner */
            Container(
              child: Utils.showBannerAd(context),
            ),
          ],
        ),
      ),
    );
  }

  bool _checkExpiry(int position) {
    printLog("position ======> $position");
    printLog(
        "expDate =======> ${subHistoryProvider.historyModel.result?[position].expiryDate}");
    if ((subHistoryProvider.historyModel.result?[position].expiryDate ?? "") !=
        "") {
      return DateTime.now().isBefore(DateTime.parse(
          subHistoryProvider.historyModel.result?[position].expiryDate ?? ""));
    } else {
      return false;
    }
  }

  Widget _buildHistoryItem(position) {
    return Container(
      width: MediaQuery.of(context).size.width,
      constraints: const BoxConstraints(minHeight: 70),
      decoration: Utils.setBackground(
          _checkExpiry(position) ? colorPrimary : appBgColor, 5),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  /* Title */
                  MyText(
                    color: _checkExpiry(position) ? black : white,
                    text: subHistoryProvider
                            .historyModel.result?[position].packageName ??
                        "",
                    textalign: TextAlign.start,
                    maxline: 2,
                    overflow: TextOverflow.ellipsis,
                    fontsize: Dimens.textBig,
                    fontwaight: FontWeight.w700,
                    fontstyle: FontStyle.normal,
                  ),

                  /* Price */
                  Container(
                    constraints: const BoxConstraints(minHeight: 0),
                    margin: const EdgeInsets.only(top: 5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyText(
                          color: _checkExpiry(position) ? black : appBgColor,
                          text: "price",
                          textalign: TextAlign.center,
                          fontsize: Dimens.textMedium,
                          fontwaight: FontWeight.w500,
                          maxline: 1,
                          multilanguage: true,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal,
                        ),
                        const SizedBox(width: 5),
                        MyText(
                          color: _checkExpiry(position) ? black : appBgColor,
                          text: ":",
                          textalign: TextAlign.center,
                          fontsize: Dimens.textMedium,
                          fontwaight: FontWeight.w500,
                          maxline: 1,
                          multilanguage: false,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: MyText(
                            color: _checkExpiry(position) ? black : white,
                            text:
                                "${subHistoryProvider.historyModel.result?[position].currencyCode.toString()}${subHistoryProvider.historyModel.result?[position].amount.toString()}",
                            textalign: TextAlign.start,
                            fontsize: Dimens.textMedium,
                            fontwaight: FontWeight.w700,
                            multilanguage: false,
                            maxline: 1,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal,
                          ),
                        ),
                      ],
                    ),
                  ),

                  /* Expire On */
                  Container(
                    constraints: const BoxConstraints(minHeight: 0),
                    margin: const EdgeInsets.only(top: 5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyText(
                          color: _checkExpiry(position) ? black : appBgColor,
                          text: _checkExpiry(position)
                              ? "expired_on"
                              : "expire_on",
                          textalign: TextAlign.center,
                          fontsize: Dimens.textMedium,
                          fontwaight: FontWeight.w500,
                          maxline: 1,
                          multilanguage: true,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal,
                        ),
                        const SizedBox(width: 5),
                        MyText(
                          color: _checkExpiry(position) ? black : appBgColor,
                          text: ":",
                          textalign: TextAlign.center,
                          fontsize: Dimens.textMedium,
                          fontwaight: FontWeight.w500,
                          maxline: 1,
                          multilanguage: false,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: MyText(
                            color: _checkExpiry(position) ? black : white,
                            text: (subHistoryProvider.historyModel
                                            .result?[position].expiryDate !=
                                        null ||
                                    (subHistoryProvider.historyModel
                                                .result?[position].expiryDate ??
                                            "") !=
                                        "")
                                ? (subHistoryProvider.historyModel
                                        .result?[position].expiryDate
                                        .toString() ??
                                    "")
                                : "-",
                            textalign: TextAlign.start,
                            fontsize: Dimens.textMedium,
                            fontwaight: FontWeight.w700,
                            multilanguage: false,
                            maxline: 5,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (subHistoryProvider.historyModel.result?[position].expiryDate !=
                  null ||
              (subHistoryProvider.historyModel.result?[position].expiryDate ??
                      "") !=
                  "")
            Container(
              height: 32,
              constraints: const BoxConstraints(minWidth: 0),
              decoration: Utils.setBGWithBorder(
                  _checkExpiry(position) ? colorAccent : colorPrimary,
                  white,
                  15,
                  0.5),
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
              alignment: Alignment.center,
              child: MyText(
                color: _checkExpiry(position) ? white : black,
                text: _checkExpiry(position) ? "current" : "expired",
                multilanguage: true,
                textalign: TextAlign.center,
                maxline: 1,
                overflow: TextOverflow.ellipsis,
                fontsize: Dimens.textMedium,
                fontwaight: FontWeight.w700,
                fontstyle: FontStyle.normal,
              ),
            ),
        ],
      ),
    );
  }
}
