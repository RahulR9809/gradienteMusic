// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:yourappname/provider/likeprovider.dart';
// import 'package:yourappname/utils/sharedpref.dart';

// class MusicLikeWidget extends StatefulWidget {
//   // final String songId;
//   const MusicLikeWidget({super.key, });

//   @override
//   State<MusicLikeWidget> createState() => _MusicLikeWidgetState();
// }

// class _MusicLikeWidgetState extends State<MusicLikeWidget>
//     with TickerProviderStateMixin {
//   late AnimationController _animationController;
//   late Animation<double> _scaleAnimation;
//   late Animation<double> _fadeAnimation;
//   bool _isInitialized = false;

//   @override
//   void initState() {
//     super.initState();
//     _setupAnimations();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _initializeSong();
//     });
//   }

//   void _setupAnimations() {
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 600),
//       vsync: this,
//     );

//     _scaleAnimation = Tween<double>(
//       begin: 1.0,
//       end: 1.3,
//     ).animate(CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.elasticOut,
//     ));

//     _fadeAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _animationController,
//       curve: const Interval(0.0, 0.5),
//     ));
//   }

//   // Future<void> _initializeSong() async {
//   //   if (!_isInitialized && mounted) {
//   //     final likeProvider = context.read<LikeProvider>();
//   //     await likeProvider.setSong(widget.songId);
//   //     if (mounted) {
//   //       setState(() {
//   //         _isInitialized = true;
//   //       });
//   //     }
//   //   }
//   // }

//   Future<void> _initializeSong() async {
//   if (!_isInitialized && mounted) {
//     final SharedPref sharedPref = SharedPref();
//     String audioIdFromPref = await sharedPref.read("current_audio_id") ?? '';

//     if (audioIdFromPref.isEmpty) {
//       print("No audio ID found in SharedPreferences");
//       return;
//     }

//     final likeProvider = context.read<LikeProvider>();
//     await likeProvider.setSong(audioIdFromPref);

//     if (mounted) {
//       setState(() {
//         _isInitialized = true;
//       });
//     }
//   }
// }


//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   Future<void> _handleLikeTap() async {
//     if (!_isInitialized) return; // Don't allow taps until initialized
    
//     final likeProvider = context.read<LikeProvider>();
    
//     try {
//       // Start animation
//       likeProvider.setLikeAnimation(true);
//       _animationController.forward().then((_) {
//         if (mounted) {
//           _animationController.reverse();
//         }
//       });
      
//       // Toggle like
//       await likeProvider.toggleLike();
      
//       // Add haptic feedback
//       // HapticFeedback.lightImpact(); // Uncomment if you want haptic feedback
      
//     } catch (e) {
//       // Show error snackbar
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Failed to update like: ${e.toString()}'),
//             backgroundColor: Colors.red,
//             duration: const Duration(seconds: 2),
//           ),
//         );
//       }
//     } finally {
//       if (mounted) {
//         likeProvider.setLikeAnimation(false);
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<LikeProvider>(
//       builder: (context, likeProvider, child) {
//         // Show loading indicator while initializing
//         if (!_isInitialized) {
//           return Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 width: 32,
//                 height: 32,
//                 padding: const EdgeInsets.all(6),
//                 child: const CircularProgressIndicator(
//                   strokeWidth: 2,
//                   valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
//                 ),
//               ),
//               const SizedBox(height: 4),
//               const Text(
//                 '-- likes',
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: Colors.white,
//                   fontWeight: FontWeight.normal,
//                 ),
//               ),
//             ],
//           );
//         }
        
//         return Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             GestureDetector(
//               onTap: _handleLikeTap,
//               child: AnimatedBuilder(
//                 animation: _animationController,
//                 builder: (context, child) {
//                   return Transform.scale(
//                     scale: _scaleAnimation.value,
//                     child: Stack(
//                       alignment: Alignment.center,
//                       children: [
//                         // Main heart icon
//                         Icon(
//                           likeProvider.isLiked
//                               ? Icons.favorite
//                               : Icons.favorite_outline,
//                           color: likeProvider.isLiked
//                               ? Colors.red
//                               : Colors.grey[400],
//                           size: 32,
//                         ),
                        
//                         // Animated heart particles (when liked)
//                         if (likeProvider.isLiked && likeProvider.isLikeAnimating)
//                           ...List.generate(6, (index) {
//                             return Positioned(
//                               left: 16 + (index * 8.0),
//                               top: 16 - (index * 4.0),
//                               child: FadeTransition(
//                                 opacity: _fadeAnimation,
//                                 child: Icon(
//                                   Icons.favorite,
//                                   color: Colors.red.withOpacity(0.6),
//                                   size: 12 - (index * 1.5),
//                                 ),
//                               ),
//                             );
//                           }),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//             ),
            
//             const SizedBox(height: 4),
            
//             // Like count with animation
//             AnimatedSwitcher(
//               duration: const Duration(milliseconds: 300),
//               child: Text(
//                 '${likeProvider.totalLikes} like${likeProvider.totalLikes != 1 ? 's' : ''}',
//                 key: ValueKey(likeProvider.totalLikes),
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: Colors.white,
//                   fontWeight: likeProvider.isLiked 
//                       ? FontWeight.w600 
//                       : FontWeight.normal,
//                 ),
//               ),
//             ),
            
//             // Loading indicator
//             if (likeProvider.isLikeAnimating)
//               Container(
//                 margin: const EdgeInsets.only(top: 4),
//                 child: SizedBox(
//                   width: 16,
//                   height: 16,
//                   child: CircularProgressIndicator(
//                     strokeWidth: 2,
//                     valueColor: AlwaysStoppedAnimation<Color>(
//                       likeProvider.isLiked ? Colors.red : Colors.grey,
//                     ),
//                   ),
//                 ),
//               ),
//           ],
//         );
//       },
//     );
//   }
// }


















import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yourappname/provider/likeprovider.dart';
import 'package:yourappname/utils/sharedpref.dart';

class MusicLikeWidget extends StatefulWidget {
  // final String songId;
  const MusicLikeWidget({super.key, });

  @override
  State<MusicLikeWidget> createState() => _MusicLikeWidgetState();
}

class _MusicLikeWidgetState extends State<MusicLikeWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeSong();
    });
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.5),
    ));
  }

  Future<void> _initializeSong() async {
    if (!_isInitialized && mounted) {
      final SharedPref sharedPref = SharedPref();
      String audioIdFromPref = await sharedPref.read("current_audio_id") ?? '';

      if (audioIdFromPref.isEmpty) {
        print("No audio ID found in SharedPreferences");
        return;
      }

      final likeProvider = context.read<LikeProvider>();
      await likeProvider.setSong(audioIdFromPref);

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleLikeTap() async {
    if (!_isInitialized) return;

    final likeProvider = context.read<LikeProvider>();

    try {
      likeProvider.setLikeAnimation(true);
      _animationController.forward().then((_) {
        if (mounted) {
          _animationController.reverse();
        }
      });

      await likeProvider.toggleLike();

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update like: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        likeProvider.setLikeAnimation(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Consumer<LikeProvider>(
      builder: (context, likeProvider, child) {
        if (!_isInitialized) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 32,
                padding: const EdgeInsets.all(6),
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '-- likes',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: _handleLikeTap,
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          likeProvider.isLiked
                              ? Icons.favorite
                              : Icons.favorite_outline,
                          color: likeProvider.isLiked
                              ? Colors.red
                              : (isDarkMode ? Colors.white : Colors.black),
                          size: 32,
                        ),

                        if (likeProvider.isLiked && likeProvider.isLikeAnimating)
                          ...List.generate(6, (index) {
                            return Positioned(
                              left: 16 + (index * 8.0),
                              top: 16 - (index * 4.0),
                              child: FadeTransition(
                                opacity: _fadeAnimation,
                                child: Icon(
                                  Icons.favorite,
                                  color: Colors.red.withOpacity(0.6),
                                  size: 12 - (index * 1.5),
                                ),
                              ),
                            );
                          }),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 4),

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                '${likeProvider.totalLikes} like${likeProvider.totalLikes != 1 ? 's' : ''}',
                key: ValueKey(likeProvider.totalLikes),
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontWeight: likeProvider.isLiked
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
            ),

            if (likeProvider.isLikeAnimating)
              Container(
                margin: const EdgeInsets.only(top: 4),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      likeProvider.isLiked
                          ? Colors.red
                          : (isDarkMode ? Colors.white : Colors.black),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}








// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:yourappname/provider/likeprovider.dart';
// import 'package:yourappname/utils/sharedpref.dart';

// class MusicLikeWidget extends StatefulWidget {
//   const MusicLikeWidget({super.key});

//   @override
//   State<MusicLikeWidget> createState() => _MusicLikeWidgetState();
// }

// class _MusicLikeWidgetState extends State<MusicLikeWidget>
//     with TickerProviderStateMixin {
//   late AnimationController _mainHeartController;
//   late Animation<double> _mainHeartScale;

//   late AnimationController _explosionController;
//   late Animation<double> _explosionAnimation;

//   bool _isInitialized = false;
//   bool _showExplosion = false; // Flag to trigger animation

//   final int _numHearts = 8;
//   final Random _random = Random();

//   @override
//   void initState() {
//     super.initState();
//     _setupAnimations();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _initializeSong();
//     });
//   }

//   void _setupAnimations() {
//     _mainHeartController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 350),
//     );
//     _mainHeartScale = Tween<double>(begin: 1.0, end: 1.5).animate(
//       CurvedAnimation(parent: _mainHeartController, curve: Curves.elasticOut),
//     );

//     _explosionController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 700),
//     );
//     _explosionAnimation = CurvedAnimation(
//       parent: _explosionController,
//       curve: Curves.easeOutQuad,
//     );

//     // Hide explosion after animation completes
//     _explosionController.addStatusListener((status) {
//       if (status == AnimationStatus.completed) {
//         setState(() {
//           _showExplosion = false;
//         });
//       }
//     });
//   }

//   Future<void> _initializeSong() async {
//     if (!_isInitialized && mounted) {
//       final SharedPref sharedPref = SharedPref();
//       String audioIdFromPref = await sharedPref.read("current_audio_id") ?? '';

//       if (audioIdFromPref.isEmpty) {
//         print("No audio ID found in SharedPreferences");
//         return;
//       }

//       final likeProvider = context.read<LikeProvider>();
//       await likeProvider.setSong(audioIdFromPref);

//       if (mounted) {
//         setState(() {
//           _isInitialized = true;
//         });
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _mainHeartController.dispose();
//     _explosionController.dispose();
//     super.dispose();
//   }

//   Future<void> _handleLikeTap() async {
//     if (!_isInitialized) return;

//     final likeProvider = context.read<LikeProvider>();

//     try {
//       likeProvider.setLikeAnimation(true);

//       // Trigger main heart pop
//       _mainHeartController.forward().then((_) => _mainHeartController.reverse());

//       // Show explosion
//       setState(() {
//         _showExplosion = true;
//       });
//       _explosionController.forward(from: 0.0);

//       // Toggle like
//       await likeProvider.toggleLike();
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Failed to update like: $e'),
//             backgroundColor: Colors.red,
//             duration: const Duration(seconds: 2),
//           ),
//         );
//       }
//     } finally {
//       if (mounted) likeProvider.setLikeAnimation(false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<LikeProvider>(
//       builder: (context, likeProvider, child) {
//         if (!_isInitialized) {
//           return Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 width: 32,
//                 height: 32,
//                 padding: const EdgeInsets.all(6),
//                 child: const CircularProgressIndicator(
//                   strokeWidth: 2,
//                   valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
//                 ),
//               ),
//               const SizedBox(height: 4),
//               const Text('-- likes',
//                   style: TextStyle(fontSize: 14, color: Colors.white)),
//             ],
//           );
//         }

//         return Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             GestureDetector(
//               onTap: _handleLikeTap,
//               child: SizedBox(
//                 width: 60,
//                 height: 60,
//                 child: Stack(
//                   alignment: Alignment.center,
//                   children: [
//                     // Explosion hearts only show when tapping
//                     if (_showExplosion)
//                       AnimatedBuilder(
//                         animation: _explosionAnimation,
//                         builder: (context, _) {
//                           return Stack(
//                             children: List.generate(_numHearts, (index) {
//                               final angle = (_random.nextDouble() * 2 * pi);
//                               final distance = _explosionAnimation.value * (30 + _random.nextDouble() * 20);
//                               final size = 8.0 + _random.nextDouble() * 8;
//                               final rotation = _random.nextDouble() * pi * _explosionAnimation.value;
//                               return Positioned(
//                                 left: 30 + cos(angle) * distance,
//                                 top: 30 + sin(angle) * distance,
//                                 child: Opacity(
//                                   opacity: 1 - _explosionAnimation.value,
//                                   child: Transform.rotate(
//                                     angle: rotation,
//                                     child: Transform.scale(
//                                       scale: 0.7 + 0.3 * _explosionAnimation.value,
//                                       child: Icon(
//                                         Icons.favorite,
//                                         color: Colors.redAccent.withOpacity(0.8),
//                                         size: size,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               );
//                             }),
//                           );
//                         },
//                       ),

//                     // Main heart icon
//                     ScaleTransition(
//                       scale: _mainHeartScale,
//                       child: Icon(
//                         likeProvider.isLiked
//                             ? Icons.favorite
//                             : Icons.favorite_outline,
//                         color: likeProvider.isLiked
//                             ? Colors.red
//                             : Colors.grey[400],
//                         size: 32,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 4),
//             AnimatedSwitcher(
//               duration: const Duration(milliseconds: 300),
//               child: Text(
//                 '${likeProvider.totalLikes} like${likeProvider.totalLikes != 1 ? 's' : ''}',
//                 key: ValueKey(likeProvider.totalLikes),
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: Colors.white,
//                   fontWeight: likeProvider.isLiked
//                       ? FontWeight.w600
//                       : FontWeight.normal,
//                 ),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
