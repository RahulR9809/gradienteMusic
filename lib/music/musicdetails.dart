import 'dart:io';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:miniplayer/miniplayer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:yourappname/pages/home.dart';
import 'package:yourappname/pages/login.dart';
import 'package:yourappname/provider/musicdetailprovider.dart';
import 'package:yourappname/subscription/subscription.dart';
import 'package:yourappname/utils/adhelper.dart';
import 'package:yourappname/utils/color.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/music/musicmanager.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/widget/music_like_widget.dart';
import 'package:yourappname/widget/musicutils.dart';
import 'package:yourappname/widget/myimage.dart';
import 'package:yourappname/widget/mynetworkimg.dart';
import 'package:yourappname/widget/mytext.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:rxdart/rxdart.dart';
import 'package:text_scroll/text_scroll.dart';





import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:yourappname/music/musicdetails.dart';
import 'package:yourappname/utils/constant.dart';







AudioPlayer audioPlayer = AudioPlayer();
late MusicManager musicManager;

Stream<PositionData> get positionDataStream {
  return Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
          audioPlayer.positionStream,
          audioPlayer.bufferedPositionStream,
          audioPlayer.durationStream,
          (position, bufferedPosition, duration) => PositionData(
              position, bufferedPosition, duration ?? Duration.zero))
      .asBroadcastStream();
}

final ValueNotifier<double> playerExpandProgress =
    ValueNotifier(playerMinHeight);

final MiniplayerController miniPlayerController = MiniplayerController();

class MusicDetails extends StatefulWidget {
  final bool ishomepage;
  const MusicDetails({super.key, required this.ishomepage});

  @override
  State<MusicDetails> createState() => _MusicDetailsState();
}

class _MusicDetailsState extends State<MusicDetails>
    with WidgetsBindingObserver {
  late MusicDetailProvider musicDetailProvider;
  final ScrollController _scrollController = ScrollController();
  final commentController = TextEditingController();

  @override
  void initState() {
    musicDetailProvider =
        Provider.of<MusicDetailProvider>(context, listen: false);
    super.initState();
    ambiguate(WidgetsBinding.instance)?.addObserver(this);
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: black));
  }

  @override
  void dispose() {
    ambiguate(WidgetsBinding.instance)?.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      printLog(
          "didChangeAppLifecycleState state ====================> $state.");
    }
  }

  _checkPremiumPlayPause() async {
    if ((audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                ?.extras?['is_premium'] ==
            1 &&
        (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                ?.extras?['is_buy'] ==
            0) {
      AdHelper.showFullscreenAd(context, Constant.interstialAdType, () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return const Subscription(openFrom: '');
            },
          ),
        );
      });
    } else {
      if (audioPlayer.playing) {
        audioPlayer.pause();
      } else {
        audioPlayer.play();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Miniplayer(
      valueNotifier: playerExpandProgress,
      minHeight: playerMinHeight,
      duration: const Duration(seconds: 1),
      maxHeight: MediaQuery.of(context).size.height,
      controller: miniPlayerController,
      elevation: 4,
      // backgroundColor: colorPrimary,
      onDismissed: () async {
        printLog("onDismissed");
        currentlyPlaying.value = null;
        await audioPlayer.pause();
        await audioPlayer.stop();
        if (mounted) {
          setState(() {});
        }
        await audioPlayer.dispose();
        audioPlayer = AudioPlayer();
        musicManager.clearMusicPlayer();
        musicDetailProvider.clearProvider();
      },
      curve: Curves.easeInOutCubicEmphasized,
      builder: (height, percentage) {
        final bool miniplayer = percentage < miniplayerPercentageDeclaration;

        if (!miniplayer) {
          return Scaffold(
            body: StreamBuilder<SequenceState?>(
                stream: audioPlayer.sequenceStateStream,
                builder: (context, snapshot) {
                  return NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      if (_scrollController.offset >=
                              _scrollController.position.maxScrollExtent &&
                          !_scrollController.position.outOfRange &&
                          (musicDetailProvider.currentPage ?? 0) <
                              (musicDetailProvider.totalPage ?? 0)) {
                        musicDetailProvider.setLoadMore(true);
                        _fetchEpisodeByPodcast(
                            ((audioPlayer.sequenceState?.currentSource?.tag
                                        as MediaItem?)
                                    ?.artist)
                                .toString(),
                            musicDetailProvider.currentPage ?? 0);
                      }
                      return true;
                    },
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      child: Column(
                        children: [
                          buildPodcastAppBar(),
                          buildPodcastMusicPage(),
                        ],
                      ),
                    ),
                  );
                }),
          );
        }

        //Miniplayer in BuildMethod
        final percentageMiniplayer = percentageFromValueInRange(
            min: playerMinHeight,
            max: MediaQuery.of(context).size.height,
            value: height);

        final elementOpacity = 1 - 1 * percentageMiniplayer;
        final progressIndicatorHeight = 2 - 2 * percentageMiniplayer;
        // MiniPlayer End

        // Scaffold
        return Scaffold(
          body:
              buildMusicPanel(height, elementOpacity, progressIndicatorHeight),
        );
      },
    );
  }

  // MiniPlayer AppBar
  Widget buildPodcastAppBar() {
    return Stack(
      children: [
        Column(
          children: [
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.38,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25)),
              ),
              child: Column(
                children: [
                  AppBar(
                    // backgroundColor: transparent,
                    elevation: 0,
                    titleSpacing: 0,
                    automaticallyImplyLeading: false,
                    leading: RotatedBox(
                        quarterTurns: 3,
                        child: MyImage(
                            width: 15, height: 15, imagePath: "back.png")),
                    title: MyText(
                      color: gray,
                      text: "Now Playing",
                      textalign: TextAlign.center,
                      fontsize: Dimens.textlargeBig,
                      inter: 1,
                      maxline: 2,
                      fontwaight: FontWeight.w500,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal,
                    ),
                    centerTitle: true,
                  ),
                ],
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.07,
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
            )
          ],
        ),
        Positioned.fill(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: StreamBuilder<SequenceState?>(
              stream: audioPlayer.sequenceStateStream,
              builder: (context, snapshot) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(0),
                  child: MyNetworkImage(
                    imgWidth: MediaQuery.of(context).size.width,
                    imgHeight: MediaQuery.of(context).size.height * 0.32,
                    imageUrl: ((audioPlayer.sequenceState?.currentSource?.tag
                                as MediaItem?)
                            ?.artUri)
                        .toString(),
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  // FullPage MiniPlayer Screen Open Using This Method
  Widget buildPodcastMusicPage() {
    return StreamBuilder<SequenceState?>(
      stream: audioPlayer.sequenceStateStream,
      builder: (context, snapshot) {
        if ((audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                    ?.extras?['is_premium'] ==
                1 &&
            (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                    ?.extras?['is_buy'] ==
                0) {
          audioPlayer.pause();
        } else {
          audioPlayer.play();
        }
        return Container(
          alignment: Alignment.center,
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                StreamBuilder<SequenceState?>(
                  stream: audioPlayer.sequenceStateStream,
                  builder: (context, snapshot) {

                    return Padding(
                      padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: TextScroll(
                          intervalSpaces: 10,
                          mode: TextScrollMode.endless,
                          ((audioPlayer.sequenceState?.currentSource?.tag
                                      as MediaItem?)
                                  ?.title)
                              .toString(),
                          selectable: true,
                          delayBefore: const Duration(milliseconds: 500),
                          fadedBorder: true,
                          style: Utils.googleFontStyle(
                              1, 18, FontStyle.normal, black, FontWeight.w600),
                          fadeBorderVisibility: FadeBorderVisibility.auto,
                          fadeBorderSide: FadeBorderSide.both,
                          velocity:
                              const Velocity(pixelsPerSecond: Offset(50, 0)),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 15),
                StreamBuilder<SequenceState?>(
                    stream: audioPlayer.sequenceStateStream,
                    builder: (context, snapshot) {
                                          // final currentAudioId = (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)?.extras?['audioId'] ?? '';

                      return 


  //=========changed here=====================>>>>>
                             //=========changed here=====================>>>>>
                              //=========changed here=====================>>>>>
                               //=========changed here=====================>>>>>
                                //=========changed here=====================>>>>>
                                 //=========changed here=====================>>>>>
                                  //=========changed here=====================>>>>>
                                   //=========changed here=====================>>>>>
                                    //=========changed here=====================>>>>>
                                           //=========changed here=====================>>>>>



                      
                      // ((audioPlayer.sequenceState?.currentSource?.tag
                      //                     as MediaItem?)
                      //                 ?.displaySubtitle)
                      //             .toString() ==
                      //         "podcast"
                      //     ?


                           SizedBox(
                              width: MediaQuery.of(context).size.width,
                              // color: colorAccent,
                              child: SingleChildScrollView(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 0, 20, 0),
                                physics: const BouncingScrollPhysics(),
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // InkWell(
                                    //   onTap: () {
                                    //     musicDetailProvider.getCommentList(
                                    //         "2",
                                    //         ((audioPlayer
                                    //                     .sequenceState
                                    //                     ?.currentSource
                                    //                     ?.tag as MediaItem?)
                                    //                 ?.artist)
                                    //             .toString(),
                                    //         ((audioPlayer
                                    //                     .sequenceState
                                    //                     ?.currentSource
                                    //                     ?.tag as MediaItem?)
                                    //                 ?.id)
                                    //             .toString(),
                                    //         "1");
                                    //     commentBottomSheet(
                                    //       index: 0,
                                    //       podcastId: ((audioPlayer
                                    //                   .sequenceState
                                    //                   ?.currentSource
                                    //                   ?.tag as MediaItem?)
                                    //               ?.artist)
                                    //           .toString(),
                                    //       episodeId: ((audioPlayer
                                    //                   .sequenceState
                                    //                   ?.currentSource
                                    //                   ?.tag as MediaItem?)
                                    //               ?.id)
                                    //           .toString(),
                                    //     );
                                    //   },
                                    //   child: Container(
                                    //     padding: const EdgeInsets.fromLTRB(
                                    //         15, 8, 15, 8),
                                    //     decoration: BoxDecoration(
                                    //       borderRadius:
                                    //           BorderRadius.circular(20),
                                    //       color: colorPrimary.withValues(
                                    //           alpha: 0.25),
                                    //     ),
                                    //     child: Row(
                                    //       children: [
                                    //         MyImage(
                                    //           width: 18,
                                    //           height: 18,
                                    //           imagePath: "ic_comment.png",
                                    //           color: Theme.of(context)
                                    //               .colorScheme
                                    //               .surface,
                                           
                                    //         ),
                                    //         const SizedBox(width: 8),
                                    //         MyText(
                                    //             color: Theme.of(context)
                                    //                 .colorScheme
                                    //                 .surface,
                                    //             text: Utils.kmbGenerator(
                                    //                 int.parse(((audioPlayer
                                    //                             .sequenceState
                                    //                             ?.currentSource
                                    //                             ?.tag as MediaItem?)
                                    //                         ?.extras?['total_comment'])
                                    //                     .toString())),
                                    //             multilanguage: false,
                                    //             textalign: TextAlign.center,
                                    //             fontsize: Dimens.textTitle,
                                    //             maxline: 1,
                                    //             fontwaight: FontWeight.w500,
                                    //             overflow: TextOverflow.ellipsis,
                                    //             fontstyle: FontStyle.normal),
                                    //       ],
                                    //     ),
                                    //   ),
                                    // ),
                                    MusicLikeWidget(),
                                    const SizedBox(width: 10),
                                    
                                    InkWell(
                                      // onTap: () {
                                      //   Utils.shareApp(Platform.isIOS
                                      //       ? "Hey! I'm Listening ${(audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)?.title}. Check it out now on ${Constant.appName}! \nhttps://apps.apple.com/us/app/${Constant.appName.toLowerCase()}/${Constant.appPackageName} \n"
                                      //       : "Hey! I'm Listening ${(audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)?.title}. Check it out now on ${Constant.appName}! \nhttps://play.google.com/store/apps/details?id=${Constant.appPackageName} \n");
                                      // },

// onTap: () async {
//   final String message = Platform.isIOS
//       ? "Hey! I'm Listening ${(audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)?.title}. Check it out now on ${Constant.appName}! \nhttps://apps.apple.com/us/app/${Constant.appName.toLowerCase()}/${Constant.appPackageName} \n"
//       : "Hey! I'm Listening ${(audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)?.title}. Check it out now on ${Constant.appName}! \nhttps://play.google.com/store/apps/details?id=${Constant.appPackageName} \n";

//   try {
//     // Load asset image as bytes
//     final byteData = await rootBundle.load('assets/appicon/appicon.png');

//     // Get temporary directory
//     final tempDir = await getTemporaryDirectory();
//     final file = File('${tempDir.path}/appicon.png');

//     // Write the bytes to a file
//     await file.writeAsBytes(byteData.buffer.asUint8List());

//     // Share with image and text
//     await Share.shareXFiles(
//       [XFile(file.path)],
//       text: message,
//     );
//   } catch (e) {
//     // Fallback to sharing only text if any error occurs
//     await Share.share(message);
//   }
// },

 onTap: () async {
    // Call the enhanced share function
    await _shareWithSongBanner();
  },

                                      child: Container(
                                        padding: const EdgeInsets.fromLTRB(
                                            15, 8, 15, 8),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          color: colorPrimary.withValues(
                                              alpha: 0.25),
                                        ),
                                        child: Row(
                                          children: [
                                            
                                            MyImage(
                                              width: 18,
                                              height: 18,
                                              imagePath: "ic_sharemusic.png",
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .surface,
                                            ),
                                            const SizedBox(width: 8),
                                            MyText(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .surface,
                                                text: "share",
                                                multilanguage: true,
                                                textalign: TextAlign.center,
                                                fontsize: Dimens.textTitle,
                                                maxline: 6,
                                                fontwaight: FontWeight.w600,
                                                overflow: TextOverflow.ellipsis,
                                                fontstyle: FontStyle.normal),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                            //=========changed here=====================>>>>>
                             //=========changed here=====================>>>>>
                              //=========changed here=====================>>>>>
                               //=========changed here=====================>>>>>
                                //=========changed here=====================>>>>>
                                 //=========changed here=====================>>>>>
                                  //=========changed here=====================>>>>>
                                   //=========changed here=====================>>>>>
                                    //=========changed here=====================>>>>>
                                           //=========changed here=====================>>>>>
                                  
                          // : const SizedBox.shrink();
                    }),
                Container(
                  margin: const EdgeInsets.fromLTRB(15, 20, 15, 15),
                  child: StreamBuilder<PositionData>(
                    stream: positionDataStream,
                    builder: (context, snapshot) {
                      final positionData = snapshot.data;
                      return ProgressBar(
                        progress: positionData?.position ?? Duration.zero,
                        buffered:
                            positionData?.bufferedPosition ?? Duration.zero,
                        total: positionData?.duration ?? Duration.zero,
                        progressBarColor: colorPrimary,
                        baseBarColor: lightgray,
                        bufferedBarColor: gray,
                        thumbColor: colorPrimary,
                        barHeight: 4.0,
                        thumbRadius: 6.0,
                        timeLabelPadding: 5.0,
                        timeLabelType: TimeLabelType.totalTime,
                        timeLabelTextStyle: GoogleFonts.inter(
                          fontSize: 12,
                          fontStyle: FontStyle.normal,
                          color: gray,
                          fontWeight: FontWeight.w700,
                        ),
                        onSeek: (duration) {
                          audioPlayer.seek(duration);
                        },
                      );
                    },
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Privious Audio Play
                    StreamBuilder<SequenceState?>(
                      stream: audioPlayer.sequenceStateStream,
                      builder: (context, snapshot) => InkWell(
                        onTap: audioPlayer.hasPrevious
                            ? audioPlayer.seekToPrevious
                            : null,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: MyImage(
                            width: 25,
                            height: 25,
                            imagePath: "ic_previous.png",
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    // 10 Second Privious
                    StreamBuilder<PositionData>(
                      stream: positionDataStream,
                      builder: (context, snapshot) {
                        final positionData = snapshot.data;
                        return InkWell(
                          onTap: () {
                            if ((audioPlayer.sequenceState?.currentSource?.tag
                                            as MediaItem?)
                                        ?.extras?['is_premium'] ==
                                    1 &&
                                (audioPlayer.sequenceState?.currentSource?.tag
                                            as MediaItem?)
                                        ?.extras?['is_buy'] ==
                                    0) {
                              AdHelper.showFullscreenAd(
                                  context, Constant.interstialAdType, () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return const Subscription(openFrom: '');
                                    },
                                  ),
                                );
                              });
                            } else {
                              tenSecNextOrPrevious(
                                  positionData?.position.inSeconds.toString() ??
                                      "",
                                  false);
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: MyImage(
                                width: 30,
                                height: 30,
                                color: Theme.of(context).colorScheme.surface,
                                imagePath: "ic_backward.png"),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 15),
                    // Pause and Play Control
                    StreamBuilder<PlayerState>(
                      stream: audioPlayer.playerStateStream,
                      builder: (context, snapshot) {
                        final playerState = snapshot.data;
                        final processingState = playerState?.processingState;
                        final playing = playerState?.playing;
                        if (processingState == ProcessingState.loading ||
                            processingState == ProcessingState.buffering) {
                          return Container(
                            margin: const EdgeInsets.all(8.0),
                            width: 50.0,
                            height: 50.0,
                            child: const CircularProgressIndicator(
                              color: colorAccent,
                            ),
                          );
                        } else if (playing != true) {
                          return Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  colorPrimary,
                                  colorPrimary,
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.play_arrow_rounded,
                                color: white,
                              ),
                              color: white,
                              iconSize: 50.0,
                              onPressed: () {
                                _checkPremiumPlayPause();
                              },
                            ),
                          );
                        } else if (processingState !=
                            ProcessingState.completed) {
                          return Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  colorPrimary,
                                  colorPrimary,
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.pause_rounded,
                                color: white,
                              ),
                              iconSize: 50.0,
                              color: white,
                              onPressed: () {
                                _checkPremiumPlayPause();
                              },
                            ),
                          );
                        } else {
                          return IconButton(
                            icon: const Icon(
                              Icons.replay_rounded,
                              color: white,
                            ),
                            iconSize: 60.0,
                            onPressed: () => audioPlayer.seek(Duration.zero,
                                index: audioPlayer.effectiveIndices!.first),
                          );
                        }
                      },
                    ),
                    const SizedBox(width: 15),
                    // 10 Second Next
                    StreamBuilder<PositionData>(
                      stream: positionDataStream,
                      builder: (context, snapshot) {
                        final positionData = snapshot.data;
                        return InkWell(
                          onTap: () {
                            if ((audioPlayer.sequenceState?.currentSource?.tag
                                            as MediaItem?)
                                        ?.extras?['is_premium'] ==
                                    1 &&
                                (audioPlayer.sequenceState?.currentSource?.tag
                                            as MediaItem?)
                                        ?.extras?['is_buy'] ==
                                    0) {
                              AdHelper.showFullscreenAd(
                                  context, Constant.interstialAdType, () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return const Subscription(openFrom: '');
                                    },
                                  ),
                                );
                              });
                            } else {
                              tenSecNextOrPrevious(
                                  positionData?.position.inSeconds.toString() ??
                                      "",
                                  true);
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: MyImage(
                              width: 30,
                              height: 30,
                              color: Theme.of(context).colorScheme.surface,
                              imagePath: "ic_forward.png",
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 15),
                    // Next Audio Play
                    StreamBuilder<SequenceState?>(
                      stream: audioPlayer.sequenceStateStream,
                      builder: (context, snapshot) => InkWell(
                        onTap:
                            audioPlayer.hasNext ? audioPlayer.seekToNext : null,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: MyImage(
                              width: 25, height: 25, imagePath: "ic_next.png"),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Volumn Costome Set
                      IconButton(
                        iconSize: 30.0,
                        icon: const Icon(Icons.volume_up),
                        // color: Theme.of(context).colorScheme.surface,
                        color: Theme.of(context).colorScheme.surface,
                        onPressed: () {
                          showSliderDialog(
                            context: context,
                            title: "Adjust volume",
                            divisions: 10,
                            min: 0.0,
                            max: 2.0,
                            value: audioPlayer.volume,
                            stream: audioPlayer.volumeStream,
                            onChanged: audioPlayer.setVolume,
                          );
                        },
                      ),
                      // Audio Speed Costomized
                      StreamBuilder<double>(
                        stream: audioPlayer.speedStream,
                        builder: (context, snapshot) => IconButton(
                          icon: Text(
                            overflow: TextOverflow.ellipsis,
                            "${snapshot.data?.toStringAsFixed(1)}x",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.surface,
                                fontSize: 14),
                          ),
                          onPressed: () {
                            showSliderDialog(
                              context: context,
                              title: "Adjust speed",
                              divisions: 10,
                              min: 0.5,
                              max: 2.0,
                              value: audioPlayer.speed,
                              stream: audioPlayer.speedStream,
                              onChanged: audioPlayer.setSpeed,
                            );
                          },
                        ),
                      ),
                      // Loop Node Button
                      StreamBuilder<LoopMode>(
                        stream: audioPlayer.loopModeStream,
                        builder: (context, snapshot) {
                          final loopMode = snapshot.data ?? LoopMode.off;
                          final icons = [
                            Icon(Icons.repeat,
                                color: Theme.of(context).colorScheme.surface,
                                size: 30.0),
                            const Icon(Icons.repeat,
                                color: colorPrimary, size: 30.0),
                            const Icon(Icons.repeat_one,
                                color: colorPrimary, size: 30.0),
                          ];
                          const cycleModes = [
                            LoopMode.off,
                            LoopMode.all,
                            LoopMode.one,
                          ];
                          final index = cycleModes.indexOf(loopMode);
                          return IconButton(
                            icon: icons[index],
                            onPressed: () {
                              audioPlayer.setLoopMode(cycleModes[
                                  (cycleModes.indexOf(loopMode) + 1) %
                                      cycleModes.length]);
                            },
                          );
                        },
                      ),
                      // Suffle Button
                      StreamBuilder<bool>(
                        stream: audioPlayer.shuffleModeEnabledStream,
                        builder: (context, snapshot) {
                          final shuffleModeEnabled = snapshot.data ?? false;
                          return IconButton(
                            iconSize: 30.0,
                            icon: shuffleModeEnabled
                                ? const Icon(Icons.shuffle, color: colorPrimary)
                                : Icon(Icons.shuffle,
                                    color:
                                        Theme.of(context).colorScheme.surface),
                            onPressed: () async {
                              final enable = !shuffleModeEnabled;
                              if (enable) {
                                await audioPlayer.shuffle();
                              }
                              await audioPlayer.setShuffleModeEnabled(enable);
                            },
                          );
                        },
                      ),
                      // Favorite



                        //=========check here this is the Like section =====================>>>>>
                             //=========check here this is the Like section =====================>>>>>
                              //=========check here this is the Like section =====================>>>>>
                               //=========check here this is the Like section =====================>>>>>
                                //=========check here this is the Like section =====================>>>>>
                                 //=========check here this is the Like section =====================>>>>>
                                  //=========check here this is the Like section =====================>>>>>
                                   //=========check here this is the Like section =====================>>>>>
                                    //=========check here this is the Like section =====================>>>>>
                                           //=========check here this is the Like section =====================>>>>>

                      // _buildLikeUnlike(),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                /* Episode List */
                if ((musicDetailProvider.episodeList?.length ?? 0) > 0 &&
                    ((audioPlayer.sequenceState?.currentSource?.tag
                                    as MediaItem?)
                                ?.displaySubtitle)
                            .toString() ==
                        "podcast")
                  Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(18),
                        topRight: Radius.circular(18),
                      ),
                      color: colorPrimary.withValues(alpha: 0.25),
                    ),
                    child: Consumer<MusicDetailProvider>(
                      builder: (context, seactionprovider, child) {
                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: InkWell(
                                    onTap: () async {
                                      await seactionprovider
                                          .changeMusicTab("episode");
                                    },
                                    child: SizedBox(
                                      height: 50,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          MyText(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .surface,
                                              text: "episode",
                                              multilanguage: true,
                                              textalign: TextAlign.center,
                                              fontsize: Dimens.textTitle,
                                              maxline: 1,
                                              fontwaight: FontWeight.w600,
                                              overflow: TextOverflow.ellipsis,
                                              fontstyle: FontStyle.normal),
                                          const SizedBox(height: 14),
                                          Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            height: 1.5,
                                            color: seactionprovider.istype ==
                                                    "episode"
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .surface
                                                : transparent,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: InkWell(
                                    onTap: () async {
                                      await seactionprovider
                                          .changeMusicTab("details");
                                    },
                                    child: SizedBox(
                                      height: 50,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          MyText(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .surface,
                                              text: "detail",
                                              multilanguage: true,
                                              textalign: TextAlign.center,
                                              fontsize: Dimens.textTitle,
                                              maxline: 1,
                                              fontwaight: FontWeight.w600,
                                              overflow: TextOverflow.ellipsis,
                                              fontstyle: FontStyle.normal),
                                          const SizedBox(height: 14),
                                          Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            height: 1.5,
                                            color: seactionprovider.istype ==
                                                    "details"
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .surface
                                                : transparent,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            seactionprovider.istype == "episode"
                                ? podcastEpisodeList()
                                : podcastEpisodeDetail(),
                          ],
                        );
                      },
                    ),
                  )
                else
                  const SizedBox.shrink(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget podcastEpisodeList() {
    return Consumer<MusicDetailProvider>(
        builder: (context, musicdetailprovider, child) {
      if (musicdetailprovider.loading && !musicdetailprovider.loadMore) {
        return Utils.pageLoader();
      } else {
        if (musicdetailprovider.getEpisodeByPodcstModel.status == 200 &&
            musicdetailprovider.episodeList != null) {
          if ((musicdetailprovider.episodeList?.length ?? 0) > 0) {
            return StreamBuilder<SequenceState?>(
              stream: audioPlayer.sequenceStateStream,
              builder: (context, snapshot) {
                return Column(
                  children: [
                    MediaQuery.removePadding(
                      removeTop: true,
                      context: context,
                      child: ResponsiveGridList(
                        minItemWidth: 120,
                        minItemsPerRow: 1,
                        maxItemsPerRow: 1,
                        horizontalGridSpacing: 10,
                        verticalGridSpacing: 10,
                        listViewBuilderOptions: ListViewBuilderOptions(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                        ),
                        children: List.generate(
                          musicdetailprovider.episodeList?.length ?? 0,
                          (index) {
                            return InkWell(
                              onTap: () {
                                Utils.playAudio(
                                    context,
                                    "podcast",
                                    0,
                                    0,
                                    musicdetailprovider
                                            .episodeList?[0].landscapeImg
                                            .toString() ??
                                        "",
                                    musicdetailprovider.episodeList?[0].name
                                            .toString() ??
                                        "",
                                    '',
                                    musicdetailprovider
                                            .episodeList?[0].episodeAudio
                                            .toString() ??
                                        "",
                                    "",
                                    musicdetailprovider
                                            .episodeList?[0].description
                                            .toString() ??
                                        "",
                                    musicdetailprovider
                                            .episodeList?[0].id
                                            .toString() ??
                                        "",
                                    (audioPlayer.sequenceState?.currentSource
                                            ?.tag as MediaItem?)!
                                        .artist
                                        .toString(),
                                    index,
                                    musicdetailprovider.episodeList?.toList() ??
                                        []);
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.fromLTRB(15, 5, 15, 5),
                                decoration: BoxDecoration(
                                  // borderRadius: BorderRadius.circular(5),
                                  color: ((audioPlayer
                                                      .sequenceState
                                                      ?.currentSource
                                                      ?.tag as MediaItem?)
                                                  ?.id)
                                              .toString() ==
                                          musicdetailprovider
                                              .episodeList?[index].id
                                              .toString()
                                      ? colorPrimary.withValues(alpha: 0.25)
                                      : transparent,
                                ),
                                child: Row(
                                  children: [
                                    Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          child: MyNetworkImage(
                                              imgWidth: 60,
                                              imgHeight: 48,
                                              imageUrl: musicdetailprovider
                                                      .episodeList?[index]
                                                      .portraitImg
                                                      .toString() ??
                                                  "",
                                              fit: BoxFit.cover),
                                        ),
                                        Positioned.fill(
                                          left: 5,
                                          right: 5,
                                          child: Align(
                                            alignment: Alignment.bottomRight,
                                            child: ((audioPlayer
                                                                    .sequenceState
                                                                    ?.currentSource
                                                                    ?.tag
                                                                as MediaItem?)
                                                            ?.id)
                                                        .toString() ==
                                                    musicdetailprovider
                                                        .episodeList?[index].id
                                                        .toString()
                                                ? MyImage(
                                                    width: 25,
                                                    height: 25,
                                                    imagePath: "music.gif")
                                                : const SizedBox.shrink(),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 15),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          MyText(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .surface,
                                            text: musicdetailprovider
                                                    .episodeList?[index].name
                                                    .toString() ??
                                                "",
                                            multilanguage: false,
                                            textalign: TextAlign.left,
                                            fontsize: Dimens.textSmall,
                                            inter: 1,
                                            maxline: 2,
                                            fontwaight: FontWeight.w600,
                                            overflow: TextOverflow.ellipsis,
                                            fontstyle: FontStyle.normal,
                                          ),
                                          const SizedBox(height: 2),
                                          MyText(
                                            color: colorPrimary,
                                            text: Utils.dateformat(
                                                DateTime.parse(
                                                    musicdetailprovider
                                                            .episodeList?[index]
                                                            .createdAt
                                                            .toString() ??
                                                        "")),
                                            multilanguage: false,
                                            textalign: TextAlign.left,
                                            fontsize: Dimens.textSmall,
                                            inter: 1,
                                            maxline: 6,
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
                        ),
                      ),
                    ),
                    if (musicdetailprovider.loadMore)
                      SizedBox(
                        height: 50,
                        child: Utils.pageLoader(),
                      )
                    else
                      const SizedBox.shrink(),
                  ],
                );
              },
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

  Widget podcastEpisodeDetail() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 15, 10, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyText(
            color: Theme.of(context).colorScheme.surface,
            text: ((audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                    ?.extras?['name'])
                .toString(),
            multilanguage: false,
            textalign: TextAlign.left,
            fontsize: Dimens.textTitle,
            inter: 1,
            maxline: 2,
            fontwaight: FontWeight.w600,
            overflow: TextOverflow.ellipsis,
            fontstyle: FontStyle.normal,
          ),
          const SizedBox(height: 10),
          MyText(
            color: Theme.of(context).colorScheme.surface,
            text: ((audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                    ?.extras?['description'])
                .toString(),
            multilanguage: false,
            textalign: TextAlign.left,
            fontsize: Dimens.textMedium,
            inter: 1,
            maxline: 100,
            fontwaight: FontWeight.w400,
            overflow: TextOverflow.ellipsis,
            fontstyle: FontStyle.normal,
          ),
        ],
      ),
    );
  }

  // Small MiniPlayer Panal Open Using This Method
  Widget buildMusicPanel(
      dynamicPanelHeight, elementOpacity, progressIndicatorHeight) {
    return StreamBuilder<SequenceState?>(
      stream: audioPlayer.sequenceStateStream,
      builder: (context, snapshot) {
        if ((audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                    ?.extras?['is_premium'] ==
                1 &&
            (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                    ?.extras?['is_buy'] ==
                0) {
          audioPlayer.pause();
        } else {
          audioPlayer.play();
        }
        return Container(
          color: Theme.of(context).secondaryHeaderColor,
          child: Column(
            children: [
              Opacity(
                opacity: elementOpacity,
                child: StreamBuilder<PositionData>(
                  stream: positionDataStream,
                  builder: (context, snapshot) {
                    final positionData = snapshot.data;
                    return ProgressBar(
                      progress: positionData?.position ?? Duration.zero,
                      buffered: positionData?.bufferedPosition ?? Duration.zero,
                      total: positionData?.duration ?? Duration.zero,
                      progressBarColor: colorPrimary,
                      baseBarColor: colorAccent,
                      bufferedBarColor: white.withValues(alpha: 0.24),
                      barCapShape: BarCapShape.square,
                      barHeight: progressIndicatorHeight,
                      thumbRadius: 0.0,
                      timeLabelLocation: TimeLabelLocation.none,
                    );
                  },
                ),
              ),
              const SizedBox(height: 15),
              Expanded(
                child: Opacity(
                  opacity: elementOpacity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /* Music Image */
                      StreamBuilder<SequenceState?>(
                        stream: audioPlayer.sequenceStateStream,
                        builder: (context, snapshot) {
                          return Container(
                            width: 90,
                            height: 60,
                            alignment: Alignment.center,
                            padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: MyNetworkImage(
                                imgWidth: MediaQuery.of(context).size.width,
                                imgHeight: MediaQuery.of(context).size.height,
                                imageUrl: ((audioPlayer.sequenceState
                                            ?.currentSource?.tag as MediaItem?)
                                        ?.artUri)
                                    .toString(),
                                fit: BoxFit.fill,
                              ),
                            ),
                          );
                        },
                      ),
                      Expanded(
                        child: StreamBuilder<SequenceState?>(
                          stream: audioPlayer.sequenceStateStream,
                          builder: (context, snapshot) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextScroll(
                                  intervalSpaces: 10,
                                  mode: TextScrollMode.endless,
                                  ((audioPlayer.sequenceState?.currentSource
                                              ?.tag as MediaItem?)
                                          ?.title)
                                      .toString(),
                                  selectable: true,
                                  delayBefore:
                                      const Duration(milliseconds: 500),
                                  fadedBorder: true,
                                  style: Utils.googleFontStyle(
                                      1,
                                      16,
                                      FontStyle.normal,
                                      Theme.of(context).colorScheme.surface,
                                      FontWeight.w500),
                                  fadeBorderVisibility:
                                      FadeBorderVisibility.auto,
                                  fadeBorderSide: FadeBorderSide.both,
                                  velocity: const Velocity(
                                      pixelsPerSecond: Offset(50, 0)),
                                ),
                                const SizedBox(height: 5),
                                MyText(
                                  color: Theme.of(context).colorScheme.surface,
                                  text: ((audioPlayer
                                              .sequenceState
                                              ?.currentSource
                                              ?.tag as MediaItem?)
                                          ?.displayDescription)
                                      .toString(),
                                  textalign: TextAlign.left,
                                  fontsize: Dimens.textSmall,
                                  inter: 1,
                                  maxline: 1,
                                  fontwaight: FontWeight.w400,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal,
                                ),
                              ],
                            );
                          },
                        ),
                      ),

























                      // _buildLikeUnlike(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          StreamBuilder<SequenceState?>(
                            stream: audioPlayer.sequenceStateStream,
                            builder: (context, snapshot) {
                              if (dynamicPanelHeight <= playerMinHeight) {
                                if (audioPlayer.hasPrevious) {
                                  return IconButton(
                                    iconSize: 25.0,
                                    icon: Icon(
                                      Icons.skip_previous_rounded,
                                      color:
                                          Theme.of(context).colorScheme.surface,
                                    ),
                                    onPressed: audioPlayer.hasPrevious
                                        ? audioPlayer.seekToPrevious
                                        : null,
                                  );
                                } else {
                                  return const SizedBox.shrink();
                                }
                              } else {
                                return const SizedBox.shrink();
                              }
                            },
                          ),

                          /* Play/Pause */
                          StreamBuilder<PlayerState>(
                            stream: audioPlayer.playerStateStream,
                            builder: (context, snapshot) {
                              if (dynamicPanelHeight <= playerMinHeight) {
                                final playerState = snapshot.data;
                                final processingState =
                                    playerState?.processingState;
                                final playing = playerState?.playing;
                                if (processingState ==
                                        ProcessingState.loading ||
                                    processingState ==
                                        ProcessingState.buffering) {
                                  return Container(
                                    margin: const EdgeInsets.all(8.0),
                                    width: 35.0,
                                    height: 35.0,
                                    child: Utils.pageLoader(),
                                  );
                                } else if (playing != true) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: colorAccent,
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.play_arrow_rounded,
                                        color: white,
                                      ),
                                      color: white,
                                      iconSize: 20.0,
                                      onPressed: () {
                                        _checkPremiumPlayPause();
                                      },
                                    ),
                                  );
                                } else if (processingState !=
                                    ProcessingState.completed) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: colorAccent,
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.pause_rounded,
                                        color: white,
                                      ),
                                      iconSize: 20.0,
                                      color: white,
                                      onPressed: () {
                                        _checkPremiumPlayPause();
                                      },
                                    ),
                                  );
                                } else {
                                  return IconButton(
                                    icon: const Icon(
                                      Icons.replay_rounded,
                                      color: white,
                                    ),
                                    iconSize: 25.0,
                                    onPressed: () => audioPlayer.seek(
                                        Duration.zero,
                                        index: audioPlayer
                                            .effectiveIndices!.first),
                                  );
                                }
                              } else {
                                return const SizedBox.shrink();
                              }
                            },
                          ),

                          /* Next */
                          StreamBuilder<SequenceState?>(
                            stream: audioPlayer.sequenceStateStream,
                            builder: (context, snapshot) {
                              if (dynamicPanelHeight <= playerMinHeight) {
                                if (audioPlayer.hasNext) {
                                  return IconButton(
                                    iconSize: 25.0,
                                    icon: Icon(
                                      Icons.skip_next_rounded,
                                      color:
                                          Theme.of(context).colorScheme.surface,
                                    ),
                                    onPressed: audioPlayer.hasNext
                                        ? audioPlayer.seekToNext
                                        : null,
                                  );
                                } else {
                                  return const SizedBox.shrink();
                                }
                              } else {
                                return const SizedBox.shrink();
                              }
                            },
                          ),
                          const SizedBox(width: 15),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 10 Second Next And Previous Functionality
  // bool isnext = true > next Audio Seek
  // bool isnext = false > previous Audio Seek
  tenSecNextOrPrevious(String audioposition, bool isnext) {
    dynamic firstHalf = Duration(seconds: int.parse(audioposition));
    const secondHalf = Duration(seconds: 10);
    Duration movePosition;
    if (isnext == true) {
      movePosition = firstHalf + secondHalf;
    } else {
      movePosition = firstHalf - secondHalf;
    }

    musicManager.seek(movePosition);
  }

  Future<void> _fetchEpisodeByPodcast(podcastId, int? nextPage) async {
    printLog("Pageno:== ${(nextPage ?? 0) + 1}");
    await musicDetailProvider.getEpisodebyPodcastList(
        podcastId, (nextPage ?? 0) + 1);
    await musicDetailProvider.setLoadMore(false);
  }
  /* ================================================ Like / UnLike END */

  commentBottomSheet(
      {required int index, required podcastId, required episodeId}) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).bottomSheetTheme.backgroundColor,
      isScrollControlled: true,
      useSafeArea: true,
      isDismissible: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(5)),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (BuildContext context) {
        return Wrap(
          children: [
            buildComment(index, podcastId, episodeId),
          ],
        );
      },
    ).whenComplete(() {
      commentController.clear();
      musicDetailProvider.clearComment();
    });
  }

/* Build Comment List */
  Widget buildComment(index, dynamic podcastId, episodeId) {
    return AnimatedPadding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      duration: const Duration(milliseconds: 100),
      curve: Curves.decelerate,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.5,
        constraints: BoxConstraints(
          minHeight: 0,
          maxHeight: MediaQuery.of(context).size.height,
        ),
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 50,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(left: 20),
                      child: MyText(
                        color: Theme.of(context).colorScheme.surface,
                        multilanguage: true,
                        text: "comment",
                        fontsize: Dimens.textMedium,
                        fontstyle: FontStyle.normal,
                        fontwaight: FontWeight.w600,
                        maxline: 1,
                        overflow: TextOverflow.ellipsis,
                        textalign: TextAlign.start,
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(right: 12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(5),
                      onTap: () {
                        Navigator.pop(context);
                        commentController.clear();
                        musicDetailProvider.clearComment();
                      },
                      child: Container(
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            Icons.close,
                            size: 20,
                            color: Theme.of(context).colorScheme.surface,
                          )),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Column(
                  children: [
                    Consumer<MusicDetailProvider>(
                        builder: (context, commentprovider, child) {
                      if (musicDetailProvider.commentloading &&
                          !musicDetailProvider.commentloadMore) {
                        return Utils.pageLoader();
                      } else {
                        if (musicDetailProvider.commentListModel.status ==
                                200 &&
                            musicDetailProvider.commentList != null) {
                          if ((musicDetailProvider.commentList?.length ?? 0) >
                              0) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Align(
                                  alignment: Alignment.topCenter,
                                  child: ListView.builder(
                                      scrollDirection: Axis.vertical,
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount:
                                          commentprovider.commentList?.length ??
                                              0,
                                      itemBuilder: (BuildContext ctx, index) {
                                        return Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 10, 0, 10),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(1),
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50),
                                                    border: Border.all(
                                                        width: 1,
                                                        color: white)),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(50),
                                                  child: MyNetworkImage(
                                                      imageUrl: commentprovider
                                                              .commentList?[
                                                                  index]
                                                              .image
                                                              .toString() ??
                                                          "",
                                                      fit: BoxFit.fill,
                                                      imgWidth: 30,
                                                      imgHeight: 30),
                                                ),
                                              ),
                                              const SizedBox(width: 15),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  MyText(
                                                      color: colorPrimary,
                                                      text: commentprovider
                                                                  .commentList?[
                                                                      index]
                                                                  .fullName
                                                                  .toString() ==
                                                              ""
                                                          ? "${commentprovider.commentList?[index].userName.toString()}"
                                                          : commentprovider
                                                                  .commentList?[
                                                                      index]
                                                                  .fullName
                                                                  .toString() ??
                                                              "",
                                                      fontsize:
                                                          Dimens.textMedium,
                                                      fontwaight:
                                                          FontWeight.w500,
                                                      multilanguage: false,
                                                      maxline: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      textalign:
                                                          TextAlign.center,
                                                      fontstyle:
                                                          FontStyle.normal),
                                                  const SizedBox(height: 8),
                                                  SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.70,
                                                    child: MyText(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .surface,
                                                        text: commentprovider
                                                                .commentList?[
                                                                    index]
                                                                .comment
                                                                .toString() ??
                                                            "",
                                                        fontsize:
                                                            Dimens.textSmall,
                                                        fontwaight:
                                                            FontWeight.w400,
                                                        multilanguage: false,
                                                        maxline: 3,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        textalign:
                                                            TextAlign.left,
                                                        fontstyle:
                                                            FontStyle.normal),
                                                  ),
                                                  const SizedBox(height: 7),
                                                ],
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                ),
                                if (musicDetailProvider.commentloading)
                                  const CircularProgressIndicator(
                                    color: colorAccent,
                                  )
                                else
                                  const SizedBox.shrink(),
                              ],
                            );
                          } else {
                            return Align(
                              alignment: Alignment.center,
                              child: MyImage(
                                width: 130,
                                height:
                                    MediaQuery.of(context).size.height * 0.40,
                                fit: BoxFit.contain,
                                imagePath: "nodata.png",
                              ),
                            );
                          }
                        } else {
                          return Align(
                            alignment: Alignment.center,
                            child: MyImage(
                              width: 130,
                              height: MediaQuery.of(context).size.height * 0.35,
                              fit: BoxFit.contain,
                              imagePath: "nodata.png",
                            ),
                          );
                        }
                      }
                    }),
                  ],
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 50,
              constraints: BoxConstraints(
                minHeight: 0,
                maxHeight: MediaQuery.of(context).size.height,
              ),
              alignment: Alignment.center,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: commentController,
                        maxLines: 1,
                        scrollPhysics: const AlwaysScrollableScrollPhysics(),
                        textAlign: TextAlign.start,
                        cursorColor: Theme.of(context).colorScheme.surface,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: transparent,
                          border: InputBorder.none,
                          hintText: "Add Comments",
                          hintStyle: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.normal,
                            color: Theme.of(context).colorScheme.surface,
                          ),
                          contentPadding:
                              const EdgeInsets.only(left: 10, right: 10),
                        ),
                        obscureText: false,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.normal,
                          color: Theme.of(context).colorScheme.surface,
                        ),
                      ),
                    ),
                    const SizedBox(width: 3),
                    InkWell(
                      borderRadius: BorderRadius.circular(5),
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
                        } else if (commentController.text.isEmpty) {
                          Utils.showToast("Please Enter Your Comment");
                        } else {
                          await musicDetailProvider.getaddcomment(podcastId,
                              commentController.text, "2", episodeId);

                          if (musicDetailProvider.successModel.status == 200) {
                            commentController.clear();

                            setState(() {
                              (audioPlayer.sequenceState?.currentSource?.tag
                                      as MediaItem?)
                                  ?.extras?['total_comment'] = (audioPlayer
                                          .sequenceState
                                          ?.currentSource
                                          ?.tag as MediaItem?)
                                      ?.extras?['total_comment'] +
                                  1;
                            });
                          } else {
                            Utils.showToast(
                                musicDetailProvider.successModel.message ?? "");
                          }
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: SizedBox(
                          width: 30,
                          height: 30,
                          child: Consumer<MusicDetailProvider>(
                            builder: (context, commentprovider, child) {
                              if (commentprovider.addcommentloading) {
                                return const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: colorAccent,
                                    strokeWidth: 1,
                                  ),
                                );
                              } else {
                                return Icon(
                                  Icons.send,
                                  size: 20,
                                  color: Theme.of(context).colorScheme.surface,
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


































// Future<void> _shareWithSongBanner() async {
//   try {
//     final String message = Platform.isIOS
//         ? "Hey! I'm Listening ${(audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)?.title}. Check it out now on ${Constant.appName}! \nhttps://apps.apple.com/us/app/${Constant.appName.toLowerCase()}/${Constant.appPackageName} \n"
//         : "Hey! I'm Listening ${(audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)?.title}. Check it out now on ${Constant.appName}! \nhttps://play.google.com/store/apps/details?id=${Constant.appPackageName} \n";

//     // Get the song image URL
//     final String? songImageUrl = ((audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)?.artUri).toString();
    
//     if (songImageUrl == null || songImageUrl == 'null') {
//       // Fallback to original sharing method if no song image
//       await _shareWithAppIconOnly(message);
//       return;
//     }

//     // Create composite image with song banner and app icon
//     final File compositeImageFile = await _createCompositeShareImage(songImageUrl);
    
//     // Share with composite image
//     await Share.shareXFiles(
//       [XFile(compositeImageFile.path)],
//       text: message,
//     );
//   } catch (e) {
//     // Fallback to text-only sharing
//     await Share.share(Platform.isIOS
//         ? "Hey! I'm Listening ${(audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)?.title}. Check it out now on ${Constant.appName}! \nhttps://apps.apple.com/us/app/${Constant.appName.toLowerCase()}/${Constant.appPackageName} \n"
//         : "Hey! I'm Listening ${(audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)?.title}. Check it out now on ${Constant.appName}! \nhttps://play.google.com/store/apps/details?id=${Constant.appPackageName} \n");
//   }
// }

// // Fallback method for app icon only
// Future<void> _shareWithAppIconOnly(String message) async {
//   try {
//     final byteData = await rootBundle.load('assets/appicon/appicon.png');
//     final tempDir = await getTemporaryDirectory();
//     final file = File('${tempDir.path}/appicon.png');
//     await file.writeAsBytes(byteData.buffer.asUint8List());
    
//     await Share.shareXFiles(
//       [XFile(file.path)],
//       text: message,
//     );
//   } catch (e) {
//     await Share.share(message);
//   }
// }

// // Create composite image with song banner and app icon overlay
// Future<File> _createCompositeShareImage(String songImageUrl) async {
//   final tempDir = await getTemporaryDirectory();
//   final outputFile = File('${tempDir.path}/share_image_${DateTime.now().millisecondsSinceEpoch}.png');

//   try {
//     // Download song image
//     final http.Response songImageResponse = await http.get(Uri.parse(songImageUrl));
//     final Uint8List songImageBytes = songImageResponse.bodyBytes;
//     final ui.Codec songCodec = await ui.instantiateImageCodec(songImageBytes);
//     final ui.FrameInfo songFrameInfo = await songCodec.getNextFrame();
//     final ui.Image songImage = songFrameInfo.image;

//     // Load app icon
//     final ByteData appIconData = await rootBundle.load('assets/appicon/appicon.png');
//     final Uint8List appIconBytes = appIconData.buffer.asUint8List();
//     final ui.Codec appIconCodec = await ui.instantiateImageCodec(appIconBytes);
//     final ui.FrameInfo appIconFrameInfo = await appIconCodec.getNextFrame();
//     final ui.Image appIcon = appIconFrameInfo.image;

//     // Create canvas and draw composite image
//     final ui.PictureRecorder recorder = ui.PictureRecorder();
//     final Canvas canvas = Canvas(recorder);
//     final Size canvasSize = Size(songImage.width.toDouble(), songImage.height.toDouble());

//     // Draw song image as background
//     canvas.drawImage(songImage, Offset.zero, Paint());

//     // Add semi-transparent overlay for better contrast
//     final Paint overlayPaint = Paint()
//       ..color = Colors.black.withOpacity(0.3);
//     canvas.drawRect(Rect.fromLTWH(0, 0, canvasSize.width, canvasSize.height), overlayPaint);

//     // Calculate app icon position (bottom-right corner with padding)
//     final double iconSize = canvasSize.width * 0.2; // 20% of image width
//     final double padding = canvasSize.width * 0.05; // 5% padding
//     final Rect iconRect = Rect.fromLTWH(
//       canvasSize.width - iconSize - padding,
//       canvasSize.height - iconSize - padding,
//       iconSize,
//       iconSize,
//     );

//     // Draw app icon with circular background
//     final Paint circlePaint = Paint()
//       ..color = Colors.white
//       ..style = PaintingStyle.fill;
    
//     final Offset iconCenter = iconRect.center;
//     final double circleRadius = iconSize / 2 + 8; // Slightly larger than icon
    
//     canvas.drawCircle(iconCenter, circleRadius, circlePaint);
    
//     // Draw app icon
//     canvas.drawImageRect(
//       appIcon,
//       Rect.fromLTWH(0, 0, appIcon.width.toDouble(), appIcon.height.toDouble()),
//       iconRect,
//       Paint(),
//     );

//     // Add song title text (optional)
//     final String? songTitle = (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)?.title;
//     if (songTitle != null && songTitle != 'null') {
//       final ui.ParagraphBuilder paragraphBuilder = ui.ParagraphBuilder(
//         ui.ParagraphStyle(
//           textAlign: TextAlign.center,
//           fontSize: canvasSize.width * 0.04,
//           fontWeight: FontWeight.bold,
//         ),
//       );
      
//       paragraphBuilder.pushStyle(ui.TextStyle(color: Colors.white));
//       paragraphBuilder.addText(songTitle);
      
//       final ui.Paragraph paragraph = paragraphBuilder.build();
//       paragraph.layout(ui.ParagraphConstraints(width: canvasSize.width - 40));
      
//       canvas.drawParagraph(
//         paragraph,
//         Offset(20, canvasSize.height - iconSize - padding - paragraph.height - 20),
//       );
//     }

//     // Convert to image and save
//     final ui.Picture picture = recorder.endRecording();
//     final ui.Image finalImage = await picture.toImage(
//       canvasSize.width.toInt(),
//       canvasSize.height.toInt(),
//     );
    
//     final ByteData? pngBytes = await finalImage.toByteData(format: ui.ImageByteFormat.png);
//     if (pngBytes != null) {
//       await outputFile.writeAsBytes(pngBytes.buffer.asUint8List());
//     }

//     return outputFile;
//   } catch (e) {
//     // If composite creation fails, create a simple fallback
//     return await _createSimpleFallbackImage();
//   }
// }

// // Simple fallback image creation
// Future<File> _createSimpleFallbackImage() async {
//   final tempDir = await getTemporaryDirectory();
//   final outputFile = File('${tempDir.path}/fallback_share_image.png');
  
//   // Load and save app icon as fallback
//   final ByteData appIconData = await rootBundle.load('assets/appicon/appicon.png');
//   await outputFile.writeAsBytes(appIconData.buffer.asUint8List());
  
//   return outputFile;
// }

















Future<void> _shareWithSongBanner() async {
  try {
    final String message = Platform.isIOS
        ? "Hey! I'm Listening ${(audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)?.title}. Check it out now on ${Constant.appName}! \nhttps://apps.apple.com/us/app/${Constant.appName.toLowerCase()}/${Constant.appPackageName} \n"
        : "Hey! I'm Listening ${(audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)?.title}. Check it out now on ${Constant.appName}! \nhttps://play.google.com/store/apps/details?id=${Constant.appPackageName} \n";

    // Get the song image URL
    final String? songImageUrl = ((audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)?.artUri).toString();
    
    if (songImageUrl == null || songImageUrl == 'null') {
      // Fallback to original sharing method if no song image
      await _shareWithAppIconOnly(message);
      return;
    }

    // Create composite image with song banner and app icon
    final File compositeImageFile = await _createCompositeShareImage(songImageUrl);
    
    // Share with composite image
    await Share.shareXFiles(
      [XFile(compositeImageFile.path)],
      text: message,
    );
  } catch (e) {
    // Fallback to text-only sharing
    await Share.share(Platform.isIOS
        ? "Hey! I'm Listening ${(audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)?.title}. Check it out now on ${Constant.appName}! \nhttps://apps.apple.com/us/app/${Constant.appName.toLowerCase()}/${Constant.appPackageName} \n"
        : "Hey! I'm Listening ${(audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)?.title}. Check it out now on ${Constant.appName}! \nhttps://play.google.com/store/apps/details?id=${Constant.appPackageName} \n");
  }
}

// Fallback method for app icon only
Future<void> _shareWithAppIconOnly(String message) async {
  try {
    final byteData = await rootBundle.load('assets/appicon/appicon.png');
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/appicon.png');
    await file.writeAsBytes(byteData.buffer.asUint8List());
    
    await Share.shareXFiles(
      [XFile(file.path)],
      text: message,
    );
  } catch (e) {
    await Share.share(message);
  }
}

// Create composite image with song banner and app icon overlay
Future<File> _createCompositeShareImage(String songImageUrl) async {
  final tempDir = await getTemporaryDirectory();
  final outputFile = File('${tempDir.path}/share_image_${DateTime.now().millisecondsSinceEpoch}.png');

  try {
    // Download song image
    final http.Response songImageResponse = await http.get(Uri.parse(songImageUrl));
    final Uint8List songImageBytes = songImageResponse.bodyBytes;
    final ui.Codec songCodec = await ui.instantiateImageCodec(songImageBytes);
    final ui.FrameInfo songFrameInfo = await songCodec.getNextFrame();
    final ui.Image songImage = songFrameInfo.image;

    // Load app icon
    final ByteData appIconData = await rootBundle.load('assets/appicon/appicon.png');
    final Uint8List appIconBytes = appIconData.buffer.asUint8List();
    final ui.Codec appIconCodec = await ui.instantiateImageCodec(appIconBytes);
    final ui.FrameInfo appIconFrameInfo = await appIconCodec.getNextFrame();
    final ui.Image appIcon = appIconFrameInfo.image;

    // Create canvas and draw composite image - FIXED LARGE SIZE
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);
    final Size canvasSize = Size(1200.0, 1200.0); // Fixed large size

    // Draw song image as background (scaled to fill entire canvas)
    canvas.drawImageRect(
      songImage, 
      Rect.fromLTWH(0, 0, songImage.width.toDouble(), songImage.height.toDouble()),
      Rect.fromLTWH(0, 0, canvasSize.width, canvasSize.height),
      Paint()
    );

    // Add semi-transparent overlay for better contrast
    final Paint overlayPaint = Paint()
      ..color = Colors.black.withOpacity(0.3);
    canvas.drawRect(Rect.fromLTWH(0, 0, canvasSize.width, canvasSize.height), overlayPaint);

    // Calculate app icon position (bottom-right corner with padding)
    final double iconSize = canvasSize.width * 0.2; // 20% of image width
    final double padding = canvasSize.width * 0.05; // 5% padding
    final Rect iconRect = Rect.fromLTWH(
      canvasSize.width - iconSize - padding,
      canvasSize.height - iconSize - padding,
      iconSize,
      iconSize,
    );

    // Draw app icon with circular background
    final Paint circlePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    final Offset iconCenter = iconRect.center;
    final double circleRadius = iconSize / 2 + 8; // Slightly larger than icon
    
    canvas.drawCircle(iconCenter, circleRadius, circlePaint);
    
    // Draw app icon
    canvas.drawImageRect(
      appIcon,
      Rect.fromLTWH(0, 0, appIcon.width.toDouble(), appIcon.height.toDouble()),
      iconRect,
      Paint(),
    );

    // Add song title text (optional)
    final String? songTitle = (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)?.title;
    if (songTitle != null && songTitle != 'null') {
      final ui.ParagraphBuilder paragraphBuilder = ui.ParagraphBuilder(
        ui.ParagraphStyle(
          textAlign: TextAlign.center,
          fontSize: canvasSize.width * 0.04,
          fontWeight: FontWeight.bold,
        ),
      );
      
      paragraphBuilder.pushStyle(ui.TextStyle(color: Colors.white));
      paragraphBuilder.addText(songTitle);
      
      final ui.Paragraph paragraph = paragraphBuilder.build();
      paragraph.layout(ui.ParagraphConstraints(width: canvasSize.width - 40));
      
      canvas.drawParagraph(
        paragraph,
        Offset(20, canvasSize.height - iconSize - padding - paragraph.height - 20),
      );
    }

    // Convert to image and save
    final ui.Picture picture = recorder.endRecording();
    final ui.Image finalImage = await picture.toImage(
      canvasSize.width.toInt(),
      canvasSize.height.toInt(),
    );
    
    final ByteData? pngBytes = await finalImage.toByteData(format: ui.ImageByteFormat.png);
    if (pngBytes != null) {
      await outputFile.writeAsBytes(pngBytes.buffer.asUint8List());
    }

    return outputFile;
  } catch (e) {
    // If composite creation fails, create a simple fallback
    return await _createSimpleFallbackImage();
  }
}

// Simple fallback image creation
Future<File> _createSimpleFallbackImage() async {
  final tempDir = await getTemporaryDirectory();
  final outputFile = File('${tempDir.path}/fallback_share_image.png');
  
  // Load and save app icon as fallback
  final ByteData appIconData = await rootBundle.load('assets/appicon/appicon.png');
  await outputFile.writeAsBytes(appIconData.buffer.asUint8List());
  
  return outputFile;
}



















// Future<void> _shareWithSongBanner() async {
//   try {
//     final String message = Platform.isIOS
//         ? "Hey! I'm Listening ${(audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)?.title}. Check it out now on ${Constant.appName}! \nhttps://apps.apple.com/us/app/${Constant.appName.toLowerCase()}/${Constant.appPackageName} \n"
//         : "Hey! I'm Listening ${(audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)?.title}. Check it out now on ${Constant.appName}! \nhttps://play.google.com/store/apps/details?id=${Constant.appPackageName} \n";

//     // Get song details
//     final MediaItem? mediaItem = audioPlayer.sequenceState?.currentSource?.tag as MediaItem?;
//     final String? songImageUrl = mediaItem?.artUri?.toString();
//     final String? songTitle = mediaItem?.title;
//     final String? artistName = mediaItem?.artist;
    
//     // Create the Spotify-style share card
//     final File shareImageFile = await _createSpotifyStyleShareCard(
//       songImageUrl: songImageUrl,
//       songTitle: songTitle ?? 'Unknown Song',
//       artistName: artistName ?? 'Unknown Artist',
//     );
    
//     // Share with the created image
//     await Share.shareXFiles(
//       [XFile(shareImageFile.path)],
//       text: message,
//     );
//   } catch (e) {
//     // Fallback to text-only sharing
//     final String fallbackMessage = Platform.isIOS
//         ? "Hey! I'm Listening ${(audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)?.title}. Check it out now on ${Constant.appName}! \nhttps://apps.apple.com/us/app/${Constant.appName.toLowerCase()}/${Constant.appPackageName} \n"
//         : "Hey! I'm Listening ${(audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)?.title}. Check it out now on ${Constant.appName}! \nhttps://play.google.com/store/apps/details?id=${Constant.appPackageName} \n";
    
//     await Share.share(fallbackMessage);
//   }
// }

// // Create Spotify-style share card
// Future<File> _createSpotifyStyleShareCard({
//   String? songImageUrl,
//   required String songTitle,
//   required String artistName,
// }) async {
//   final tempDir = await getTemporaryDirectory();
//   final outputFile = File('${tempDir.path}/music_share_card_${DateTime.now().millisecondsSinceEpoch}.png');

//   try {
//     // Card dimensions (similar to mobile sharing cards)
//     const double cardWidth = 400;
//     const double cardHeight = 500;
//     const double cornerRadius = 20;
//     const double albumArtSize = 280;
//     const double padding = 20;

//     // Create canvas
//     final ui.PictureRecorder recorder = ui.PictureRecorder();
//     final Canvas canvas = Canvas(recorder);

//     // Draw background with gradient
//     final Paint bgPaint = Paint()
//       ..shader = const LinearGradient(
//         begin: Alignment.topCenter,
//         end: Alignment.bottomCenter,
//         colors: [
//           Color(0xFF1a1a1a),
//           Color(0xFF2d2d2d),
//         ],
//       ).createShader(const Rect.fromLTWH(0, 0, cardWidth, cardHeight));
    
//     final RRect bgRRect = RRect.fromRectAndRadius(
//       const Rect.fromLTWH(0, 0, cardWidth, cardHeight),
//       const Radius.circular(cornerRadius),
//     );
//     canvas.drawRRect(bgRRect, bgPaint);

//     // Load and draw album art
//     ui.Image? albumImage;
//     try {
//       if (songImageUrl != null && songImageUrl != 'null' && songImageUrl.isNotEmpty) {
//         final http.Response response = await http.get(Uri.parse(songImageUrl));
//         final Uint8List imageBytes = response.bodyBytes;
//         final ui.Codec codec = await ui.instantiateImageCodec(imageBytes);
//         final ui.FrameInfo frameInfo = await codec.getNextFrame();
//         albumImage = frameInfo.image;
//       }
//     } catch (e) {
//       // Will use default placeholder if image fails to load
//     }

//     // Album art position (centered at top)
//     const double albumX = (cardWidth - albumArtSize) / 2;
//     const double albumY = padding;
    
//     if (albumImage != null) {
//       // Draw album art with rounded corners
//       final Path albumPath = Path()
//         ..addRRect(RRect.fromRectAndRadius(
//           const Rect.fromLTWH(albumX, albumY, albumArtSize, albumArtSize),
//           const Radius.circular(12),
//         ));
//       canvas.clipPath(albumPath);
      
//       canvas.drawImageRect(
//         albumImage,
//         Rect.fromLTWH(0, 0, albumImage.width.toDouble(), albumImage.height.toDouble()),
//         const Rect.fromLTWH(albumX, albumY, albumArtSize, albumArtSize),
//         Paint(),
//       );
      
//       // Reset clipping
//       canvas.restore();
//       canvas.save();
//     } else {
//       // Draw placeholder album art
//       final Paint placeholderPaint = Paint()
//         ..color = const Color(0xFF404040);
      
//       final RRect placeholderRRect = RRect.fromRectAndRadius(
//         const Rect.fromLTWH(albumX, albumY, albumArtSize, albumArtSize),
//         const Radius.circular(12),
//       );
//       canvas.drawRRect(placeholderRRect, placeholderPaint);
      
//       // Music note icon placeholder
//       final Paint iconPaint = Paint()
//         ..color = const Color(0xFF666666);
      
//       const double iconSize = 60;
//       const double iconX = albumX + (albumArtSize - iconSize) / 2;
//       const double iconY = albumY + (albumArtSize - iconSize) / 2;
      
//       // Simple music note shape
//       canvas.drawCircle(Offset(iconX + 15, iconY + 45), 8, iconPaint);
//       canvas.drawRect(Rect.fromLTWH(iconX + 23, iconY + 10, 3, 35), iconPaint);
//       canvas.drawRect(Rect.fromLTWH(iconX + 26, iconY + 10, 15, 3), iconPaint);
//     }

//     // Song title
//     final ui.ParagraphBuilder titleBuilder = ui.ParagraphBuilder(
//       ui.ParagraphStyle(
//         textAlign: TextAlign.center,
//         fontSize: 24,
//         fontWeight: FontWeight.bold,
//         height: 1.2,
//       ),
//     );
//     titleBuilder.pushStyle(ui.TextStyle(color: Colors.white));
//     titleBuilder.addText(songTitle);
    
//     final ui.Paragraph titleParagraph = titleBuilder.build();
//     titleParagraph.layout(ui.ParagraphConstraints(width: cardWidth - 40));
    
//     const double titleY = albumY + albumArtSize + 25;
//     canvas.drawParagraph(
//       titleParagraph,
//       Offset((cardWidth - titleParagraph.width) / 2, titleY),
//     );

//     // Artist name
//     final ui.ParagraphBuilder artistBuilder = ui.ParagraphBuilder(
//       ui.ParagraphStyle(
//         textAlign: TextAlign.center,
//         fontSize: 18,
//         height: 1.2,
//       ),
//     );
//     artistBuilder.pushStyle(ui.TextStyle(color: const Color(0xFFB3B3B3)));
//     artistBuilder.addText(artistName);
    
//     final ui.Paragraph artistParagraph = artistBuilder.build();
//     artistParagraph.layout(ui.ParagraphConstraints(width: cardWidth - 40));
    
//     final double artistY = titleY + titleParagraph.height + 8;
//     canvas.drawParagraph(
//       artistParagraph,
//       Offset((cardWidth - artistParagraph.width) / 2, artistY),
//     );

//     // App branding section at bottom
//     final double brandingY = cardHeight - 80;
    
//     // App icon
//     ui.Image? appIcon;
//     try {
//       final ByteData appIconData = await rootBundle.load('assets/appicon/appicon.png');
//       final Uint8List appIconBytes = appIconData.buffer.asUint8List();
//       final ui.Codec appIconCodec = await ui.instantiateImageCodec(appIconBytes);
//       final ui.FrameInfo appIconFrameInfo = await appIconCodec.getNextFrame();
//       appIcon = appIconFrameInfo.image;
//     } catch (e) {
//       // Continue without app icon if loading fails
//     }

//     if (appIcon != null) {
//       const double iconSize = 32;
//       const double iconX = padding;
      
//       canvas.drawImageRect(
//         appIcon,
//         Rect.fromLTWH(0, 0, appIcon.width.toDouble(), appIcon.height.toDouble()),
//         Rect.fromLTWH(iconX, brandingY, iconSize, iconSize),
//         Paint(),
//       );
//     }

//     // App name
//     final ui.ParagraphBuilder appNameBuilder = ui.ParagraphBuilder(
//       ui.ParagraphStyle(
//         textAlign: TextAlign.left,
//         fontSize: 16,
//         fontWeight: FontWeight.w600,
//       ),
//     );
//     appNameBuilder.pushStyle(ui.TextStyle(color: Colors.white));
//     appNameBuilder.addText(Constant.appName);
    
//     final ui.Paragraph appNameParagraph = appNameBuilder.build();
//     appNameParagraph.layout(ui.ParagraphConstraints(width: cardWidth - 100));
    
//     const double appNameX = padding + 40; // After icon + spacing
//     canvas.drawParagraph(
//       appNameParagraph,
//       Offset(appNameX, brandingY + 8),
//     );

//     // Convert to image and save
//     final ui.Picture picture = recorder.endRecording();
//     final ui.Image finalImage = await picture.toImage(
//       cardWidth.toInt(),
//       cardHeight.toInt(),
//     );
    
//     final ByteData? pngBytes = await finalImage.toByteData(format: ui.ImageByteFormat.png);
//     if (pngBytes != null) {
//       await outputFile.writeAsBytes(pngBytes.buffer.asUint8List());
//     }

//     return outputFile;
//   } catch (e) {
//     // Create a simple text-based fallback card
//     return await _createTextFallbackCard(songTitle, artistName);
//   }
// }

// // Simple fallback card with just text
// Future<File> _createTextFallbackCard(String songTitle, String artistName) async {
//   final tempDir = await getTemporaryDirectory();
//   final outputFile = File('${tempDir.path}/text_fallback_card.png');
  
//   const double cardWidth = 400;
//   const double cardHeight = 300;
  
//   final ui.PictureRecorder recorder = ui.PictureRecorder();
//   final Canvas canvas = Canvas(recorder);
  
//   // Background
//   final Paint bgPaint = Paint()..color = const Color(0xFF1a1a1a);
//   canvas.drawRect(const Rect.fromLTWH(0, 0, cardWidth, cardHeight), bgPaint);
  
//   // Title
//   final ui.ParagraphBuilder titleBuilder = ui.ParagraphBuilder(
//     ui.ParagraphStyle(
//       textAlign: TextAlign.center,
//       fontSize: 24,
//       fontWeight: FontWeight.bold,
//     ),
//   );
//   titleBuilder.pushStyle(ui.TextStyle(color: Colors.white));
//   titleBuilder.addText(songTitle);
  
//   final ui.Paragraph titleParagraph = titleBuilder.build();
//   titleParagraph.layout(ui.ParagraphConstraints(width: cardWidth - 40));
//   canvas.drawParagraph(titleParagraph, Offset(20, cardHeight / 2 - 40));
  
//   // Artist
//   final ui.ParagraphBuilder artistBuilder = ui.ParagraphBuilder(
//     ui.ParagraphStyle(
//       textAlign: TextAlign.center,
//       fontSize: 18,
//     ),
//   );
//   artistBuilder.pushStyle(ui.TextStyle(color: const Color(0xFFB3B3B3)));
//   artistBuilder.addText(artistName);
  
//   final ui.Paragraph artistParagraph = artistBuilder.build();
//   artistParagraph.layout(ui.ParagraphConstraints(width: cardWidth - 40));
//   canvas.drawParagraph(artistParagraph, Offset(20, cardHeight / 2 + 10));
  
//   // App name
//   final ui.ParagraphBuilder appBuilder = ui.ParagraphBuilder(
//     ui.ParagraphStyle(
//       textAlign: TextAlign.center,
//       fontSize: 14,
//     ),
//   );
//   appBuilder.pushStyle(ui.TextStyle(color: const Color(0xFF888888)));
//   appBuilder.addText('Shared from ${Constant.appName}');
  
//   final ui.Paragraph appParagraph = appBuilder.build();
//   appParagraph.layout(ui.ParagraphConstraints(width: cardWidth - 40));
//   canvas.drawParagraph(appParagraph, Offset(20, cardHeight - 60));
  
//   final ui.Picture picture = recorder.endRecording();
//   final ui.Image finalImage = await picture.toImage(cardWidth.toInt(), cardHeight.toInt());
  
//   final ByteData? pngBytes = await finalImage.toByteData(format: ui.ImageByteFormat.png);
//   if (pngBytes != null) {
//     await outputFile.writeAsBytes(pngBytes.buffer.asUint8List());
//   }
  
//   return outputFile;
// }