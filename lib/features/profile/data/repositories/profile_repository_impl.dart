import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  const ProfileRepositoryImpl({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
  })  : _firestore = firestore,
        _storage = storage;

  @override
  Future<UserEntity> getProfile(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (!doc.exists) throw Exception('Profile not found');
    return UserModel.fromFirestore(doc);
  }

  @override
  Future<void> updateProfile(UserEntity user) async {
    final model = UserModel.fromEntity(user);
    await _firestore
        .collection('users')
        .doc(user.id)
        .update(model.toFirestore());
  }

  @override
  Future<String> uploadProfileImage(String userId, File image) async {
    final ref = _storage
        .ref()
        .child('profile_images')
        .child('$userId.jpg');
    final task = await ref.putFile(image);
    return task.ref.getDownloadURL();
  }
}
