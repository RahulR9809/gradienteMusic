// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';
// import 'package:yourappname/pages/home.dart';
// import 'package:yourappname/pages/intro.dart';
// import 'package:yourappname/provider/generalprovider.dart';
// import 'package:yourappname/utils/adhelper.dart';
// import 'package:yourappname/utils/constant.dart';
// import 'package:yourappname/utils/sharedpref.dart';
// import 'package:yourappname/utils/utils.dart';
// import 'package:yourappname/widget/myimage.dart';

// class Splash extends StatefulWidget {
//   const Splash({super.key});

//   @override
//   State<Splash> createState() => SplashState();
// }

// class SplashState extends State<Splash> {
//   SharedPref sharedpre = SharedPref();
//   late GeneralProvider generalProvider;

//   @override
//   void initState() {
//     generalProvider = Provider.of<GeneralProvider>(context, listen: false);
//     getApi();
//     SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
//     Utils.getCurrencySymbol();
//     super.initState();
//   }

//   @override
//   void dispose() {
//     SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
//         overlays: SystemUiOverlay.values);

//     super.dispose();
//   }

//   getApi() async {
//     await generalProvider.getGeneralsetting(context);
//     Future.delayed(Duration.zero).then((value) {
//       if (!mounted) return;
//       setState(() {
//         isFirstCheck();
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
//     return Scaffold(
//       body: SizedBox(
//         width: MediaQuery.of(context).size.width,
//         height: MediaQuery.of(context).size.height,
//         child: MyImage(
//           width: MediaQuery.of(context).size.width,
//           height: MediaQuery.of(context).size.height,
//           imagePath: "splash.png",
//           fit: BoxFit.cover,
//         ),
//       ),
//     );
//   }

//   Future<void> isFirstCheck() async {
//     /* Get Ads Init */
//     Utils.getCurrencySymbol();
//     AdHelper.getAds(context);
//     await generalProvider.getIntroPages();

//     String? seen = await sharedpre.read("seen") ?? "";
//     printLog("seen :=================> $seen");
//     Constant.userID = await sharedpre.read('userid');
//     printLog("userID =======> ${Constant.userID}");

//     if (seen == "1") {
//       if (!mounted) return;
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (context) {
//             return const Home();
//           },
//         ),
//       );
//     } else {
//       if (!generalProvider.loading &&
//           generalProvider.introScreenModel.status == 200 &&
//           (generalProvider.introScreenModel.result != null ||
//               ((generalProvider.introScreenModel.result?.length ?? 0) > 0))) {
//         if (!mounted) return;
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (context) {
//               return Intro(
//                 introList: generalProvider.introScreenModel.result ?? [],
//               );
//             },
//           ),
//         );
//       } else {
//         if (!mounted) return;
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (context) {
//               return const Home();
//             },
//           ),
//         );
//       }
//     }
//   }
// }





import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:yourappname/pages/home.dart';
import 'package:yourappname/pages/intro.dart';
import 'package:yourappname/provider/generalprovider.dart';
import 'package:yourappname/utils/adhelper.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/sharedpref.dart';
import 'package:yourappname/utils/utils.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => SplashState();
}

class SplashState extends State<Splash> {
  SharedPref sharedpre = SharedPref();
  late GeneralProvider generalProvider;
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _showVideo = false;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    generalProvider = Provider.of<GeneralProvider>(context, listen: false);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    Utils.getCurrencySymbol();
    
    // Start both processes simultaneously
    getApi();
    _initializeVideoWithFallback();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
  }

  Future<void> _initializeVideoWithFallback() async {
    // List of potential video paths to try
    final List<String> videoPaths = [
      'assets/videos/splash_video.mp4',
    ];

    bool videoLoaded = false;

    // Try each path until one works
    for (String path in videoPaths) {
      try {
        printLog("Trying to load video from: $path");
        _videoController = VideoPlayerController.asset(path);
        
        await _videoController!.initialize();
        
        if (_videoController!.value.isInitialized) {
          printLog("Video loaded successfully from: $path");
          
          // Configure video
          await _videoController!.setLooping(false);
          await _videoController!.setVolume(1.0);
          
          setState(() {
            _isVideoInitialized = true;
            _showVideo = true;
          });
          
          // Play video and set up completion listener
          _playVideoWithTimer();
          videoLoaded = true;
          break;
        }
      } catch (e) {
        printLog("Failed to load video from $path: $e");
        _videoController?.dispose();
        _videoController = null;
      }
    }

    // If no video loaded, fall back to black screen with timer
    if (!videoLoaded) {
      printLog("Video failed to load, using black screen with timer");
      setState(() {
        _isVideoInitialized = false;
        _showVideo = false;
      });
      _startStaticSplashTimer();
    }
  }

  void _playVideoWithTimer() {
    if (_videoController != null && _isVideoInitialized && !_hasNavigated) {
      _videoController!.play();
      
      // Add listener for video completion
      _videoController!.addListener(_videoListener);
      
      // Ensure navigation after 3 seconds regardless
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && !_hasNavigated) {
          _navigateToNextScreen();
        }
      });
    }
  }

  void _videoListener() {
    if (_videoController != null && 
        _videoController!.value.position >= _videoController!.value.duration &&
        !_hasNavigated) {
      _navigateToNextScreen();
    }
  }

  void _startStaticSplashTimer() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && !_hasNavigated) {
        _navigateToNextScreen();
      }
    });
  }

  void _navigateToNextScreen() {
    if (_hasNavigated) return;
    
    _hasNavigated = true;
    _videoController?.removeListener(_videoListener);
    _videoController?.pause();
    
    isFirstCheck();
  }

  getApi() async {
    try {
      await generalProvider.getGeneralsetting(context);
      Future.delayed(Duration.zero).then((value) {
        if (!mounted) return;
        setState(() {
          // API loaded
        });
      });
    } catch (e) {
      printLog("API Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Video player (full screen)
            if (_showVideo && _isVideoInitialized && _videoController != null)
              _buildVideoPlayer(),
            
            // Show black screen if video is not ready or failed to load
            if (!_showVideo || !_isVideoInitialized)
              Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.black,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    if (_videoController == null || !_videoController!.value.isInitialized) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: _videoController!.value.size.width,
          height: _videoController!.value.size.height,
          child: VideoPlayer(_videoController!),
        ),
      ),
    );
  }

  Future<void> isFirstCheck() async {
    try {
      /* Get Ads Init */
      Utils.getCurrencySymbol();
      AdHelper.getAds(context);
      await generalProvider.getIntroPages();

      String? seen = await sharedpre.read("seen") ?? "";
      printLog("seen :=================> $seen");
      Constant.userID = await sharedpre.read('userid');
      printLog("userID =======> ${Constant.userID}");

      if (!mounted) return;

      if (seen == "1") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const Home(),
          ),
        );
      } else {
        if (!generalProvider.loading &&
            generalProvider.introScreenModel.status == 200 &&
            (generalProvider.introScreenModel.result != null ||
                ((generalProvider.introScreenModel.result?.length ?? 0) > 0))) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Intro(
                introList: generalProvider.introScreenModel.result ?? [],
              ),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const Home(),
            ),
          );
        }
      }
    } catch (e) {
      printLog("Navigation Error: $e");
      // Fallback to home in case of error
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const Home(),
          ),
        );
      }
    }
  }
}