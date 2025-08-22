import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vimeo_video_player/vimeo_video_player.dart';
import 'package:yourappname/utils/color.dart';
import 'package:yourappname/utils/utils.dart';

class PlayerVimeo extends StatefulWidget {
  final String? videoId, videoUrl, vUploadType, videoThumb;
  const PlayerVimeo(
      this.videoId, this.videoUrl, this.vUploadType, this.videoThumb,
      {super.key});

  @override
  State<PlayerVimeo> createState() => PlayerVimeoState();
}

class PlayerVimeoState extends State<PlayerVimeo> {
  String? vUrl;
  int? playerCPosition, videoDuration;

  @override
  void initState() {
    super.initState();
    vUrl = widget.videoUrl;
    if (!(vUrl ?? "").contains("https://vimeo.com/")) {
      vUrl = "https://vimeo.com/$vUrl";
    }
    debugPrint("vUrl===> $vUrl");
  }

  @override
  void dispose() {
    if (!(kIsWeb)) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: onBackPressed,
      child: Scaffold(
        backgroundColor: black,
        body: Stack(
          children: [
            VimeoVideoPlayer(
              url: vUrl ?? "",
              autoPlay: true,
              systemUiOverlay: const [],
              deviceOrientation: const [
                DeviceOrientation.landscapeLeft,
                DeviceOrientation.landscapeRight,
                DeviceOrientation.portraitUp,
                DeviceOrientation.portraitDown,
              ],
              startAt: Duration.zero,
              onProgress: (timePoint) {
                playerCPosition = timePoint.inMilliseconds;
                debugPrint("playerCPosition :===> $playerCPosition");
              },
              onFinished: () async {
                /* Remove From Continue */
              },
            ),
            if (!kIsWeb)
              Positioned(
                top: 15,
                left: 15,
                child: SafeArea(
                  child: InkWell(
                    onTap: () {
                      onBackPressed(false);
                    },
                    focusColor: gray.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                    child: Utils.buildBackBtnDesign(context),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> onBackPressed(didPop) async {
    if (didPop) return;
    if (!(kIsWeb)) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    debugPrint("onBackPressed playerCPosition :===> $playerCPosition");
    debugPrint("onBackPressed videoDuration :===> $videoDuration");
    if ((playerCPosition ?? 0) > 0 &&
        (playerCPosition == videoDuration ||
            (playerCPosition ?? 0) > (videoDuration ?? 0))) {
      // await playerProvider.removeContentHistory("1", "${widget.videoId}", "0");
      if (!mounted) return;
      if (Navigator.canPop(context)) {
        Navigator.pop(context, true);
      }
    } else if ((playerCPosition ?? 0) > 0) {
      // await playerProvider.addContentHistory(
      // "1", widget.videoId, "$playerCPosition", "0");
      if (!mounted) return;
      if (Navigator.canPop(context)) {
        Navigator.pop(context, true);
      }
    } else {
      if (!mounted) return;
      if (Navigator.canPop(context)) {
        Navigator.pop(context, false);
      }
    }
  }
}
