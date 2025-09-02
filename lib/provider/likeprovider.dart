// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';

// class LikeProvider with ChangeNotifier {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
//   bool _isLikeAnimating = false;
//   int _totalLikes = 0;
//   bool _isLiked = false;
  
//   String? currentUserId;
//   String? currentSongId;
  
//   bool get isLikeAnimating => _isLikeAnimating;
//   int get totalLikes => _totalLikes;
//   bool get isLiked => _isLiked;
  
//   void setCurrentUser(String uid) {
//     currentUserId = uid;
//   }
  
//   Future<void> setSong(String songId) async {
//     if (currentSongId == songId) return; // Prevent unnecessary calls
    
//     currentSongId = songId;
//     await _loadLikes();
//   }
  
//   void setLikeAnimation(bool value) {
//     _isLikeAnimating = value;
//     notifyListeners();
//   }
  
//   /// Load likes from Firebase
//   Future<void> _loadLikes() async {
//     if (currentSongId == null) return;
    
//     try {
//       final doc = await _firestore.collection('songs').doc(currentSongId).get();
      
//       if (doc.exists) {
//         final data = doc.data();
//         _totalLikes = data?['likesCount'] ?? 0;
        
//         if (currentUserId != null && data?['likedBy'] != null) {
//           _isLiked = (data!['likedBy'] as List).contains(currentUserId);
//         } else {
//           _isLiked = false;
//         }
//       } else {
//         // Document doesn't exist, create it with initial values
//         await _createSongDocument();
//         _totalLikes = 0;
//         _isLiked = false;
//       }
      
//       notifyListeners();
//     } catch (e) {
//       print('Error loading likes: $e');
//     }
//   }
  
//   /// Create initial song document if it doesn't exist
//   Future<void> _createSongDocument() async {
//     if (currentSongId == null) return;
    
//     await _firestore.collection('songs').doc(currentSongId).set({
//       'likesCount': 0,
//       'likedBy': [],
//       'songId': currentSongId,
//       'createdAt': FieldValue.serverTimestamp(),
//     });
//   }
  
//   /// Toggle like with optimistic updates
//   Future<void> toggleLike() async {
//     if (currentSongId == null || currentUserId == null) return;
    
//     // Store original state for rollback if needed
//     final originalLiked = _isLiked;
//     final originalCount = _totalLikes;
    
//     // Optimistic update
//     _isLiked = !_isLiked;
//     _totalLikes = _isLiked ? _totalLikes + 1 : _totalLikes - 1;
//     notifyListeners();
    
//     try {
//       final docRef = _firestore.collection('songs').doc(currentSongId);
//       final doc = await docRef.get();
      
//       if (!doc.exists) {
//         await _createSongDocument();
//       }
      
//       // Use Firestore transaction to ensure data consistency
//       await _firestore.runTransaction((transaction) async {
//         final snapshot = await transaction.get(docRef);
//         List<dynamic> likedBy = snapshot.data()?['likedBy'] ?? [];
//         int currentCount = snapshot.data()?['likesCount'] ?? 0;
        
//         if (_isLiked && !likedBy.contains(currentUserId)) {
//           likedBy.add(currentUserId);
//           currentCount++;
//         } else if (!_isLiked && likedBy.contains(currentUserId)) {
//           likedBy.remove(currentUserId);
//           currentCount--;
//         }
        
//         transaction.update(docRef, {
//           'likedBy': likedBy,
//           'likesCount': currentCount,
//           'lastUpdated': FieldValue.serverTimestamp(),
//         });
        
//         // Update local state with server data
//         _totalLikes = currentCount;
//       });
      
//     } catch (e) {
//       print('Error toggling like: $e');
//       // Rollback on error
//       _isLiked = originalLiked;
//       _totalLikes = originalCount;
//       notifyListeners();
      
//       // Show error to user
//       throw Exception('Failed to update like status');
//     }
//   }
  
//   /// Get real-time updates for likes (optional)
//   Stream<DocumentSnapshot>? getLikesStream() {
//     if (currentSongId == null) return null;
//     return _firestore.collection('songs').doc(currentSongId).snapshots();
//   }
// }




import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LikeProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLikeAnimating = false;
  int _totalLikes = 0;
  bool _isLiked = false;

  String? currentUserId;
  String? currentSongId;

  bool get isLikeAnimating => _isLikeAnimating;
  int get totalLikes => _totalLikes;
  bool get isLiked => _isLiked;

  /// Set current logged-in user ID
  void setCurrentUser(String? uid) {
    currentUserId = uid;
    print('DEBUG: Current user ID set to: $uid');
  }

  /// Set current song ID and load its likes
  Future<void> setSong(String songId) async {
    if (songId.isEmpty) {
      print('DEBUG: Attempted to set empty songId!');
      return;
    }

    print('DEBUG: Changing songId from $currentSongId to $songId');
    currentSongId = songId;
    await _loadLikes();
  }

  /// Animate like button
  void setLikeAnimation(bool value) {
    _isLikeAnimating = value;
    notifyListeners();
  }

  /// Load likes from Firebase
  Future<void> _loadLikes() async {
    if (currentSongId == null || currentSongId!.isEmpty) {
      print('DEBUG: Cannot load likes - songId is null or empty');
      return;
    }

    try {
      print('DEBUG: Loading likes for song: $currentSongId');
      final doc = await _firestore.collection('songs').doc(currentSongId).get();

      if (doc.exists) {
        final data = doc.data();
        _totalLikes = data?['likesCount'] ?? 0;

        if (currentUserId != null && data?['likedBy'] != null) {
          final likedByList = List<String>.from(data!['likedBy'] ?? []);
          _isLiked = likedByList.contains(currentUserId);
        } else {
          _isLiked = false;
        }

        print('DEBUG: Loaded - likes: $_totalLikes, isLiked: $_isLiked');
      } else {
        print('DEBUG: Document does not exist, creating...');
        await _createSongDocument();
        _totalLikes = 0;
        _isLiked = false;
      }

      notifyListeners();
    } catch (e) {
      print('DEBUG: Error loading likes: $e');
      _totalLikes = 0;
      _isLiked = false;
      notifyListeners();
    }
  }

  /// Create initial song document if it doesn't exist
  Future<void> _createSongDocument() async {
    if (currentSongId == null || currentSongId!.isEmpty) return;

    try {
      await _firestore.collection('songs').doc(currentSongId).set({
        'likesCount': 0,
        'likedBy': [],
        'songId': currentSongId,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('DEBUG: Created new song document for: $currentSongId');
    } catch (e) {
      print('DEBUG: Error creating song document: $e');
      throw Exception('Failed to create song document');
    }
  }

  /// Toggle like with optimistic update
  Future<void> toggleLike() async {
    print('DEBUG: Attempting to toggle like');
    print('DEBUG: currentUserId = $currentUserId');
    print('DEBUG: currentSongId = $currentSongId');

    if (currentSongId == null || currentSongId!.isEmpty) {
      print('ERROR: Cannot toggle like - songId is null or empty');
      throw Exception('Song not selected');
    }

    if (currentUserId == null || currentUserId!.isEmpty) {
      print('ERROR: Cannot toggle like - userId is null or empty');
      throw Exception('User not logged in');
    }

    print('DEBUG: Toggling like for songId=$currentSongId by userId=$currentUserId');

    final originalLiked = _isLiked;
    final originalCount = _totalLikes;

    // Optimistic update
    _isLiked = !_isLiked;
    _totalLikes = _isLiked ? _totalLikes + 1 : _totalLikes - 1;
    notifyListeners();

    try {
      final docRef = _firestore.collection('songs').doc(currentSongId);

      final doc = await docRef.get();
      if (!doc.exists) {
        print('DEBUG: Document does not exist, creating it first');
        await _createSongDocument();
      }

      // Firestore transaction
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);

        if (!snapshot.exists) {
          transaction.set(docRef, {
            'likesCount': _isLiked ? 1 : 0,
            'likedBy': _isLiked ? [currentUserId] : [],
            'songId': currentSongId,
            'createdAt': FieldValue.serverTimestamp(),
            'lastUpdated': FieldValue.serverTimestamp(),
          });
          _totalLikes = _isLiked ? 1 : 0;
          return;
        }

        final data = snapshot.data() as Map<String, dynamic>;
        List<String> likedBy = List<String>.from(data['likedBy'] ?? []);
        int currentCount = data['likesCount'] ?? 0;

        if (_isLiked) {
          if (!likedBy.contains(currentUserId)) {
            likedBy.add(currentUserId!);
            currentCount++;
          }
        } else {
          if (likedBy.contains(currentUserId)) {
            likedBy.remove(currentUserId);
            currentCount--;
          }
        }

        currentCount = currentCount < 0 ? 0 : currentCount;

        transaction.update(docRef, {
          'likedBy': likedBy,
          'likesCount': currentCount,
          'lastUpdated': FieldValue.serverTimestamp(),
        });

        _totalLikes = currentCount;
      });

      print('DEBUG: Successfully updated like status');
    } catch (e) {
      print('DEBUG: Error toggling like: $e');

      _isLiked = originalLiked;
      _totalLikes = originalCount;
      notifyListeners();

      String errorMessage = 'Failed to update like status';
      if (e.toString().contains('permission-denied')) {
        errorMessage = 'Permission denied. Please check your login status.';
      } else if (e.toString().contains('network')) {
        errorMessage = 'Network error. Please check your connection.';
      }

      throw Exception(errorMessage);
    }
  }


  /// Safe toggle wrapper to prevent crashes
  Future<void> safeToggleLike() async {
    if (currentSongId == null || currentSongId!.isEmpty) {
      print('DEBUG: SafeToggle - Cannot toggle like, songId invalid');
      return;
    }
    try {
      await toggleLike();
    } catch (e) {
      print('DEBUG: SafeToggle - Error toggling like: $e');
    }
  }

  /// Get real-time updates for likes
  Stream<DocumentSnapshot>? getLikesStream() {
    if (currentSongId == null || currentSongId!.isEmpty) return null;
    return _firestore.collection('songs').doc(currentSongId).snapshots();
  }

  /// Refresh likes from server
  Future<void> refreshLikes() async {
    if (currentSongId != null && currentSongId!.isNotEmpty) {
      await _loadLikes();
    }
  }
}
