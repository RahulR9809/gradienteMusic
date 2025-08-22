import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:yourappname/pages/home.dart';
import 'package:yourappname/music/musicdetails.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/widget/musicutils.dart';

class MusicManager {
  late ConcatenatingAudioSource playlist;
  BuildContext context;

  dynamic audioList;

  MusicManager(this.context);

  // Data change Using This Playlist (Api Data Set in This ArrayList And After Set data From This ArrayList)
  void setInitialPlaylist(int cPosition, String songFrom, String searchText,
      dynamic dataList, String playType) async {
    currentlyPlaying.value = audioPlayer;
    playlist = ConcatenatingAudioSource(children: []);
    printLog("dataList :=====================> ${dataList.length}");
    audioList = dataList.toList();
    for (int i = 0; i < (audioList?.length ?? 0); i++) {
      playlist.add(
        buildAudioSource(
          audioUrl: audioList?[i].songUrl.toString() ?? "",
          extraDetails: audioList?[i].toMap(),
          songFrom: songFrom,
          album: searchText,
          playType: playType,
          podcastId: "",
          audioId: audioList?[i].id.toString() ?? "",
          title: audioList?[i].name.toString() ?? "",
          description: audioList?[i].artistName.toString() ?? "",
          audioThumb: audioList?[i].image.toString() ?? "",
        ),
      );
    }

    try {
      printLog("playing     :==============> ${audioPlayer.playing}");
      printLog(
          "audioSource :==============> ${audioPlayer.audioSource?.sequence.length}");
      printLog("playlist    :==============> ${playlist.length}");
      // Preloading audio is not currently supported on Linux.
      await audioPlayer.setAudioSource(playlist, initialIndex: cPosition);

      audioPlayer.playerStateStream.listen(
        (event) {
          printLog("processingState =======> ${event.processingState}");
          if (event.processingState == ProcessingState.ready) {
            printLog(
                "is_premium =========> ${(audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)?.extras?['is_premium']}");
            printLog(
                "is_buy =============> ${(audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)?.extras?['is_buy']}");
            if ((audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                        ?.extras?['is_premium'] ==
                    1 &&
                (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                        ?.extras?['is_buy'] ==
                    0) {
              pause();
            }
          }
        },
        onDone: () {},
        onError: (Object e, StackTrace stackTrace) {
          if (e is PlayerException) {
            printLog('Error code: ${e.code}');
            printLog('Error message: ${e.message}');
          } else {
            printLog('An error occurred: $e');
          }
          Utils.showToast("Some error occured.");
        },
      );
    } catch (e) {
      // Catch load errors: 404, invalid url...
      Utils.showToast("Some error occured.");
      printLog("Error loading audio source: $e");
    }
  }

  void setInitialPodcast(int cPosition, String songFrom, String searchText,
      dynamic dataList, String podcastId, String playType) async {
    currentlyPlaying.value = audioPlayer;
    playlist = ConcatenatingAudioSource(children: []);
    printLog("dataList :=====================> ${dataList.length}");
    audioList = dataList.toList();
    for (int i = 0; i < (audioList?.length ?? 0); i++) {
      playlist.add(
        buildAudioSource(
          audioUrl: audioList?[i].episodeAudio.toString() ?? "",
          extraDetails: audioList?[i].toMap(),
          songFrom: songFrom,
          podcastId: podcastId,
          playType: playType,
          album: searchText,
          audioId: audioList?[i].id.toString() ?? "",
          title: audioList?[i].name.toString() ?? "",
          description: audioList?[i].description.toString() ?? "",
          audioThumb: audioList?[i].landscapeImg.toString() ?? "",
        ),
      );
    }

    try {
      printLog("playing     :==============> ${audioPlayer.playing}");
      printLog(
          "audioSource :==============> ${audioPlayer.audioSource?.sequence.length}");
      printLog("playlist    :==============> ${playlist.length}");
      // Preloading audio is not currently supported on Linux.
      await audioPlayer.setAudioSource(playlist, initialIndex: cPosition);

      audioPlayer.playerStateStream.listen(
        (event) {
          printLog("processingState =======> ${event.processingState}");
          if (event.processingState == ProcessingState.ready) {
            printLog(
                "is_premium =========> ${(audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)?.extras?['is_premium']}");
            printLog(
                "is_buy =============> ${(audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)?.extras?['is_buy']}");
            if ((audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                        ?.extras?['is_premium'] ==
                    1 &&
                (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                        ?.extras?['is_buy'] ==
                    0) {
              pause();
            }
          }
        },
        onDone: () {},
        onError: (Object e, StackTrace stackTrace) {
          if (e is PlayerException) {
            printLog('Error code: ${e.code}');
            printLog('Error message: ${e.message}');
          } else {
            printLog('An error occurred: $e');
          }
          Utils.showToast("Some error occured.");
        },
      );
    } catch (e) {
      // Catch load errors: 404, invalid url...
      Utils.showToast("Some error occured.");
      printLog("Error loading audio source: $e");
    }
  }

  void playSingleSong(String songId, String name, String songUrl,
      String songThumb, String playType) async {
    currentlyPlaying.value = audioPlayer;
    ConcatenatingAudioSource singlePlaylist =
        ConcatenatingAudioSource(children: []);
    singlePlaylist.add(buildAudioSource(
      playType: playType,
      audioUrl: songUrl.toString(),
      audioId: songId.toString(),
      podcastId: "",
      title: name.toString(),
      songFrom: 'notification',
      album: '',
      description: name.toString(),
      extraDetails: {},
      audioThumb: songThumb.toString(),
    ));
    try {
      printLog("playing        :=====================> ${audioPlayer.playing}");
      printLog("songUrl        :=====================> $songUrl");
      printLog(
          "singlePlaylist :=====================> ${singlePlaylist.length}");
      // Preloading audio is not currently supported on Linux.
      await audioPlayer.setAudioSource(singlePlaylist);
      audioPlayer.playbackEventStream.listen(
          (event) {
            printLog("currentIndex ========> ${event.currentIndex}");
          },
          onDone: () {},
          onError: (Object e, StackTrace stackTrace) {
            if (e is PlayerException) {
              printLog('Error code: ${e.code}');
              printLog('Error message: ${e.message}');
            } else {
              printLog('An error occurred: $e');
            }
            Utils.showToast("Some error occured.");
          });
    } catch (e) {
      // Catch load errors: 404, invalid url...
      printLog("Error loading audio source: $e");
    }
  }

  // Play Audio Using This Method
  void play() async {
    if (audioPlayer.playing) return;
    audioPlayer.play();
  }

  // Pause Audio Using This Method
  void pause() {
    if (!audioPlayer.playing) return;
    audioPlayer.pause();
  }

  // Forward and Backward Method
  void seek(Duration position) {
    audioPlayer.seek(position);
  }

  //  Audio Player Dispose Using This Method
  void dispose() {
    audioPlayer.dispose();
  }

  clearMusicPlayer() async {
    audioList = [];
    playlist = ConcatenatingAudioSource(children: []);
    for (var i = 0; i < playlist.length; i++) {
      playlist.removeAt(i);
    }
    playlist.clear();
  }
}
