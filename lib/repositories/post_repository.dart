import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post.dart';

class PostRepository {
  final FirebaseFirestore _firestore;
  static const int postsPerPage = 20;

  PostRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Stream posts ordered by createdAt descending with pagination
  Stream<List<Post>> streamPosts({DocumentSnapshot? startAfter}) {
    Query query = _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .limit(postsPerPage);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Post.fromFirestore(doc)).toList();
    });
  }

  /// Add a new post with idempotency using a client-generated ID
  Future<String> addPost({
    required String uid,
    required String text,
    String? customId,
  }) async {
    final docRef = customId != null
        ? _firestore.collection('posts').doc(customId)
        : _firestore.collection('posts').doc();

    final post = Post(
      id: docRef.id,
      uid: uid,
      text: text,
      createdAt: DateTime.now(),
    );

    // Use set with merge to prevent overwriting if doc already exists
    await docRef.set(post.toFirestore(), SetOptions(merge: true));
    return docRef.id;
  }

  /// Get a specific post by ID (useful for retry logic)
  Future<Post?> getPost(String id) async {
    final doc = await _firestore.collection('posts').doc(id).get();
    if (doc.exists) {
      return Post.fromFirestore(doc);
    }
    return null;
  }

  /// Get the last document snapshot for pagination
  Future<DocumentSnapshot?> getLastDocument(int limit) async {
    final snapshot = await _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return snapshot.docs.last;
  }
}
