import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserRepository {
  static FirebaseFirestore get _db => FirebaseFirestore.instance;

  static DocumentReference<Map<String, dynamic>>? _userRef() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return _db.collection('users').doc(uid);
  }

  static Future<void> syncOnAuth() async {
    final user = FirebaseAuth.instance.currentUser;
    final ref = _userRef();
    if (user == null || ref == null) return;
    try {
      final snap = await ref.get();
      if (!snap.exists) {
        await _push(ref, user, create: true);
      } else {
        await _pull(snap.data()!);
        await _push(ref, user, create: false);
      }
    } catch (_) {}
  }

  static Future<void> push() async {
    final user = FirebaseAuth.instance.currentUser;
    final ref = _userRef();
    if (user == null || ref == null) return;
    try {
      await _push(ref, user, create: false);
    } catch (_) {}
  }

  static Future<void> _pull(Map<String, dynamic> data) async {
    final p = await SharedPreferences.getInstance();
    if (data['plan'] is String) await p.setString('sub_plan', data['plan'] as String);
    if (data['coins'] is int) await p.setInt('sub_coins', data['coins'] as int);
    if (data['videoUsed'] is int) await p.setInt('sub_video_used', data['videoUsed'] as int);
    if (data['audioUsed'] is int) await p.setInt('sub_audio_used', data['audioUsed'] as int);
    if (data['extraVideo'] is int) await p.setInt('sub_extra_video', data['extraVideo'] as int);
    if (data['extraAudio'] is int) await p.setInt('sub_extra_audio', data['extraAudio'] as int);
    if (data['quotaDate'] is String) await p.setString('sub_quota_date', data['quotaDate'] as String);
    if (data['lastDaily'] is String) await p.setString('sub_last_daily', data['lastDaily'] as String);
    if (data['inviteCount'] is int) await p.setInt('sub_invite_count', data['inviteCount'] as int);
    if (data['badge'] is bool) await p.setBool('sub_badge_unlocked', data['badge'] as bool);
    if (data['planActive'] is bool) await p.setBool('sub_plan_active', data['planActive'] as bool);
    if (data['streak'] is int) await p.setInt('sub_streak', data['streak'] as int);
    if (data['welcomeGiven'] is List) {
      await p.setStringList('sub_welcome_given', List<String>.from(data['welcomeGiven'] as List));
    }
  }

  static Future<void> _push(DocumentReference<Map<String, dynamic>> ref, User user, {required bool create}) async {
    final p = await SharedPreferences.getInstance();
    final payload = <String, dynamic>{
      'email': user.email,
      'plan': p.getString('sub_plan') ?? 'free',
      'coins': p.getInt('sub_coins') ?? 0,
      'videoUsed': p.getInt('sub_video_used') ?? 0,
      'audioUsed': p.getInt('sub_audio_used') ?? 0,
      'extraVideo': p.getInt('sub_extra_video') ?? 0,
      'extraAudio': p.getInt('sub_extra_audio') ?? 0,
      'quotaDate': p.getString('sub_quota_date'),
      'lastDaily': p.getString('sub_last_daily'),
      'inviteCount': p.getInt('sub_invite_count') ?? 0,
      'badge': p.getBool('sub_badge_unlocked') ?? false,
      'planActive': p.getBool('sub_plan_active') ?? true,
      'streak': p.getInt('sub_streak') ?? 0,
      'welcomeGiven': p.getStringList('sub_welcome_given') ?? ['free'],
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (create) {
      payload['createdAt'] = FieldValue.serverTimestamp();
      await ref.set(payload);
    } else {
      await ref.set(payload, SetOptions(merge: true));
    }
  }
}
