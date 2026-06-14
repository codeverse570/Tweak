import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/models/user_progression.dart';
import '../../domain/models/user_ratings.dart';

part 'user_repository.g.dart';

@Riverpod(keepAlive: true)
UserRepository userRepository(Ref ref) {
  return UserRepository(Supabase.instance.client);
}

class UserRepository {
  UserRepository(this._client);

  final SupabaseClient _client;

  // ── Progression ───────────────────────────────────────────────────────────

  Future<UserProgression> fetchProgression(String userId) async {
    final data = await _client
        .from('progression')
        .select()
        .eq('user_id', userId)
        .maybeSingle();
    print(data);
    if (data == null) {
      await _client.from('progression').upsert({'user_id': userId});
      return UserProgressionX.empty(userId);
    }
    
    return UserProgression.fromJson({...data, 'userId': data['user_id']});
  }

  Stream<UserProgression> watchProgression(String userId) {
    return _client
        .from('progression')
        .stream(primaryKey: ['user_id'])
        .eq('user_id', userId)
        .map((rows) {
          if (rows.isEmpty) return UserProgressionX.empty(userId);
          final data = rows.first;
          return UserProgression.fromJson({...data, 'userId': data['user_id']});
        });
  }

  // ── Ratings ───────────────────────────────────────────────────────────────

  Future<UserRatings> fetchRatings(String userId) async {
    final data = await _client
        .from('ratings')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (data == null) {
      await _client.from('ratings').upsert({'user_id': userId});
      return UserRatingsX.empty(userId);
    }

    return UserRatings.fromJson({
      ...data,
      'userId': data['user_id'],
      'ciRating': data['ci_rating'],
      'physicsRating': data['physics_rating'],
      'mathRating': data['math_rating'],
    });
  }

  Stream<UserRatings> watchRatings(String userId) {
    return _client
        .from('ratings')
        .stream(primaryKey: ['user_id'])
        .eq('user_id', userId)
        .map((rows) {
          if (rows.isEmpty) return UserRatingsX.empty(userId);
          final data = rows.first;
          return UserRatings.fromJson({
            ...data,
            'userId': data['user_id'],
            'ciRating': data['ci_rating'],
            'physicsRating': data['physics_rating'],
            'mathRating': data['math_rating'],
          });
        });
  }
}