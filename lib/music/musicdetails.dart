import 'dart:io';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:miniplayer/miniplayer.dart';
import 'package:provider/provider.dart';
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
                                      onTap: () {
                                        Utils.shareApp(Platform.isIOS
                                            ? "Hey! I'm Listening ${(audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)?.title}. Check it out now on ${Constant.appName}! \nhttps://apps.apple.com/us/app/${Constant.appName.toLowerCase()}/${Constant.appPackageName} \n"
                                            : "Hey! I'm Listening ${(audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)?.title}. Check it out now on ${Constant.appName}! \nhttps://play.google.com/store/apps/details?id=${Constant.appPackageName} \n");
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
