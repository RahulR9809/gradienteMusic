

// import 'package:flutter/material.dart';

// class LyricsExpandableContainer extends StatefulWidget {
//   final List<String> lyrics;
//   final TextStyle? textStyle;
//   final Color? backgroundColor;
//   final Color? containerColor;
//   final EdgeInsets? padding;
//   final double borderRadius;

//   const LyricsExpandableContainer({
//     Key? key,
//     required this.lyrics,
//     this.textStyle,
//     this.backgroundColor,
//     this.containerColor,
//     this.padding,
//     this.borderRadius = 15.0,
//   }) : super(key: key);

//   @override
//   State<LyricsExpandableContainer> createState() => _LyricsExpandableContainerState();
// }

// class _LyricsExpandableContainerState extends State<LyricsExpandableContainer>
//     with TickerProviderStateMixin {
  
//   late AnimationController _animationController;
//   late Animation<double> _heightAnimation;
  
//   bool _isExpanded = false;
//   final double _collapsedHeight = 120.0;
//   final double _expandedHeight = 400.0;
  
//   final ScrollController _scrollController = ScrollController();

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 300),
//       vsync: this,
//     );
    
//     _heightAnimation = Tween<double>(
//       begin: _collapsedHeight,
//       end: _expandedHeight,
//     ).animate(CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.easeInOut,
//     ));
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }

//   void _toggleExpansion() {
//     setState(() {
//       _isExpanded = !_isExpanded;
//     });
    
//     if (_isExpanded) {
//       _animationController.forward();
//     } else {
//       _animationController.reverse();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
//       decoration: BoxDecoration(
//         color: widget.containerColor ?? Theme.of(context).colorScheme.surface.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(widget.borderRadius),
//       ),
//       child: Column(
//         children: [
//           // Header with expand/collapse indicator
//           GestureDetector(
//             onTap: _toggleExpansion,
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'Lyrics',
//                     style: widget.textStyle?.copyWith(
//                       fontWeight: FontWeight.w600,
//                     ) ?? TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                       color: Theme.of(context).colorScheme.onSurface,
//                     ),
//                   ),
//                   AnimatedRotation(
//                     turns: _isExpanded ? 0.5 : 0.0,
//                     duration: const Duration(milliseconds: 300),
//                     child: Icon(
//                       Icons.keyboard_arrow_down,
//                       color: Theme.of(context).colorScheme.onSurface,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
          
//           // Expandable lyrics content
//           AnimatedBuilder(
//             animation: _heightAnimation,
//             builder: (context, child) {
//               return Container(
//                 height: _heightAnimation.value,
//                 child: GestureDetector(
//                   onPanUpdate: (details) {
//                     // Swipe up to expand
//                     if (details.delta.dy < -5 && !_isExpanded) {
//                       _toggleExpansion();
//                     }
//                     // Swipe down to collapse (only when at top of scroll)
//                     else if (details.delta.dy > 5 && _isExpanded && 
//                              _scrollController.offset <= 0) {
//                       _toggleExpansion();
//                     }
//                   },
//                   child: Container(
//                     padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
//                     child: _isExpanded
//                         ? _buildExpandedLyrics()
//                         : _buildCollapsedLyrics(),
//                   ),
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCollapsedLyrics() {
//     // Show only first few lines when collapsed
//     final previewLines = widget.lyrics.take(3).toList();
    
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         ...previewLines.map((line) => Padding(
//           padding: const EdgeInsets.symmetric(vertical: 2),
//           child: Text(
//             line,
//             style: widget.textStyle ?? TextStyle(
//               fontSize: 14,
//               color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
//             ),
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//           ),
//         )),
//         if (widget.lyrics.length > 3)
//           Padding(
//             padding: const EdgeInsets.only(top: 8),
//             child: Text(
//               '... ${widget.lyrics.length - 3} more lines',
//               style: TextStyle(
//                 fontSize: 12,
//                 color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
//                 fontStyle: FontStyle.italic,
//               ),
//             ),
//           ),
//       ],
//     );
//   }

//   Widget _buildExpandedLyrics() {
//     return Scrollbar(
//       controller: _scrollController,
//       child: ListView.builder(
//         controller: _scrollController,
//         physics: const BouncingScrollPhysics(),
//         itemCount: widget.lyrics.length,
//         itemBuilder: (context, index) {
//           final line = widget.lyrics[index];
//           return Padding(
//             padding: const EdgeInsets.symmetric(vertical: 3),
//             child: line.trim().isEmpty
//                 ? const SizedBox(height: 10) // Empty line spacing
//                 : Text(
//                     line,
//                     style: widget.textStyle ?? TextStyle(
//                       fontSize: 14,
//                       height: 1.4,
//                       color: Theme.of(context).colorScheme.onSurface.withOpacity(0.9),
//                     ),
//                   ),
//           );
//         },
//       ),
//     );
//   }
// }









import 'package:flutter/material.dart';

class LyricsExpandableContainer extends StatefulWidget {
  final List<String> lyrics;
  final TextStyle? textStyle;
  final Color? backgroundColor;
  final Color? containerColor;
  final EdgeInsets? padding;
  final double borderRadius;

  const LyricsExpandableContainer({
    Key? key,
    required this.lyrics,
    this.textStyle,
    this.backgroundColor,
    this.containerColor,
    this.padding,
    this.borderRadius = 20.0,
  }) : super(key: key);

  @override
  State<LyricsExpandableContainer> createState() => _LyricsExpandableContainerState();
}

class _LyricsExpandableContainerState extends State<LyricsExpandableContainer>
    with TickerProviderStateMixin {
  
  late AnimationController _animationController;
  late Animation<double> _heightAnimation;
  
  bool _isExpanded = false;
  final double _collapsedHeight = 120.0;
  final double _expandedHeight = 400.0;
  
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _heightAnimation = Tween<double>(
      begin: _collapsedHeight,
      end: _expandedHeight,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    
    if (_isExpanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: widget.containerColor != null
              ? [widget.containerColor!, widget.containerColor!.withOpacity(0.7)]
              : [Colors.purpleAccent, Colors.deepPurpleAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(widget.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with expand/collapse indicator
          GestureDetector(
            onTap: _toggleExpansion,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              decoration: BoxDecoration(
                color: widget.backgroundColor ?? Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(widget.borderRadius),
                  bottom: const Radius.circular(0),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Lyrics',
                    style: widget.textStyle?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white,
                    ) ??
                        const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                  ),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Expandable lyrics content
          AnimatedBuilder(
            animation: _heightAnimation,
            builder: (context, child) {
              return Container(
                height: _heightAnimation.value,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.05),
                      Colors.white.withOpacity(0.15)
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(widget.borderRadius),
                  ),
                ),
                child: GestureDetector(
                  onPanUpdate: (details) {
                    if (details.delta.dy < -5 && !_isExpanded) _toggleExpansion();
                    else if (details.delta.dy > 5 && _isExpanded && _scrollController.offset <= 0) _toggleExpansion();
                  },
                  child: Container(
                    padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    child: _isExpanded ? _buildExpandedLyrics() : _buildCollapsedLyrics(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsedLyrics() {
    final previewLines = widget.lyrics.take(3).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...previewLines.map((line) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Text(
            line,
            style: widget.textStyle ?? TextStyle(
              fontSize: 15,
              color: Colors.white.withOpacity(0.9),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        )),
        if (widget.lyrics.length > 3)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '... ${widget.lyrics.length - 3} more lines',
              style: TextStyle(
                fontSize: 13,
                color: Colors.white70,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildExpandedLyrics() {
    return Scrollbar(
      controller: _scrollController,
      radius: const Radius.circular(10),
      thickness: 4,
      thumbVisibility: true,
      child: ListView.builder(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        itemCount: widget.lyrics.length,
        itemBuilder: (context, index) {
          final line = widget.lyrics[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: line.trim().isEmpty
                ? const SizedBox(height: 10)
                : Text(
                    line,
                    style: widget.textStyle ?? TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: Colors.white.withOpacity(0.95),
                    ),
                  ),
          );
        },
      ),
    );
  }
}
