import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/repositories/user_repository.dart';
import '../../domain/models/user_progression.dart';
import '../../domain/models/user_ratings.dart';

part 'user_provider.g.dart';

// ─── Progression stream ───────────────────────────────────────────────────────

@riverpod
Stream<UserProgression> userProgression(Ref ref) {
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null) return const Stream.empty();
  return ref.watch(userRepositoryProvider).watchProgression(userId);
}

// ─── Ratings stream ───────────────────────────────────────────────────────────

@riverpod
Stream<UserRatings> userRatings(Ref ref) {
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null) return const Stream.empty();
  return ref.watch(userRepositoryProvider).watchRatings(userId);
}