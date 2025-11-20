import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseLikesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Dar like a un post
  Future<void> likePost(int postId, String userId) async {
    final postRef = _firestore.collection('posts').doc(postId.toString());
    final likeRef = postRef.collection('likes').doc(userId);

    // Verificar si ya dio like
    final likeDoc = await likeRef.get();
    final alreadyLiked = likeDoc.exists && (likeDoc.data()?['liked'] == true);

    if (alreadyLiked) {
      // Quitar like
      await likeRef.delete();
      await postRef.update({
        'likesCount': FieldValue.increment(-1),
      });
    } else {
      // Dar like
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

  // Dar dislike a un post
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

  // Obtener contador de likes en tiempo real
  Stream<int> getLikesCount(int postId) {
    return _firestore
        .collection('posts')
        .doc(postId.toString())
        .snapshots()
        .map((doc) {
      if (!doc.exists) {
        // Si el documento no existe, inicializarlo con 0
        _initializePost(postId);
        return 0;
      }
      return doc.data()?['likesCount'] ?? 0;
    });
  }

  // Obtener contador de dislikes en tiempo real
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

  // Verificar si el usuario ya dio like
  Future<bool> hasUserLiked(int postId, String userId) async {
    final doc = await _firestore
        .collection('posts')
        .doc(postId.toString())
        .collection('likes')
        .doc(userId)
        .get();
    return doc.exists && (doc.data()?['liked'] == true);
  }

  // Verificar si el usuario dio dislike
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

  // Inicializar post cuando se crea (llamar desde tu app)
  Future<void> initializePost(int postId) async {
    await _initializePost(postId);
  }
}

