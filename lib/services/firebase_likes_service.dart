import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseLikesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  
  Future<void> likePost(int postId, String userId) async {
    final postRef = _firestore.collection('posts').doc(postId.toString());
    final likeRef = postRef.collection('likes').doc(userId);

    
    final likeDoc = await likeRef.get();
    final alreadyLiked = likeDoc.exists && (likeDoc.data()?['liked'] == true);

    if (alreadyLiked) {
      
      await likeRef.delete();
      await postRef.update({
        'likesCount': FieldValue.increment(-1),
      });
    } else {
      
      await likeRef.set({
        'liked': true,
        'disliked': false,
        'timestamp': FieldValue.serverTimestamp(),
      });
      await postRef.update({
        'likesCount': FieldValue.increment(1),
      });
    }
  }

  
  Future<void> dislikePost(int postId, String userId) async {
    final postRef = _firestore.collection('posts').doc(postId.toString());
    final likeRef = postRef.collection('likes').doc(userId);

    final likeDoc = await likeRef.get();
    final alreadyDisliked = likeDoc.exists && (likeDoc.data()?['disliked'] == true);

    if (alreadyDisliked) {
      await likeRef.delete();
      await postRef.update({
        'dislikesCount': FieldValue.increment(-1),
      });
    } else {
      await likeRef.set({
        'liked': false,
        'disliked': true,
        'timestamp': FieldValue.serverTimestamp(),
      });
      await postRef.update({
        'dislikesCount': FieldValue.increment(1),
      });
    }
  }

  
  Stream<int> getLikesCount(int postId) {
    return _firestore
        .collection('posts')
        .doc(postId.toString())
        .snapshots()
        .map((doc) {
      if (!doc.exists) {
        
        _initializePost(postId);
        return 0;
      }
      return doc.data()?['likesCount'] ?? 0;
    });
  }

  
  Stream<int> getDislikesCount(int postId) {
    return _firestore
        .collection('posts')
        .doc(postId.toString())
        .snapshots()
        .map((doc) {
      if (!doc.exists) {
        _initializePost(postId);
        return 0;
      }
      return doc.data()?['dislikesCount'] ?? 0;
    });
  }

  
  Future<bool> hasUserLiked(int postId, String userId) async {
    final doc = await _firestore
        .collection('posts')
        .doc(postId.toString())
        .collection('likes')
        .doc(userId)
        .get();
    return doc.exists && (doc.data()?['liked'] == true);
  }

  
  Future<bool> hasUserDisliked(int postId, String userId) async {
    final doc = await _firestore
        .collection('posts')
        .doc(postId.toString())
        .collection('likes')
        .doc(userId)
        .get();
    return doc.exists && (doc.data()?['disliked'] == true);
  }

  // Inicializar un post en Firebase (si no existe)
  Future<void> _initializePost(int postId) async {
    final postRef = _firestore.collection('posts').doc(postId.toString());
    final doc = await postRef.get();
    
    if (!doc.exists) {
      await postRef.set({
        'likesCount': 0,
        'dislikesCount': 0,
        'topicoId': postId,
      });
    }
  }

  
  Future<void> initializePost(int postId) async {
    await _initializePost(postId);
  }
}

