import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService {
  final _supabase = Supabase.instance.client;

  Future<void> checkOrCreateProfile(String uid, int initialYear) async {
    try {
      final profile = await _supabase
          .from('profiles')
          .select()
          .eq('user_id', uid)
          .maybeSingle();

      if (profile == null) {
        await _supabase.from('profiles').insert({
          'user_id': uid,
          'current_year': initialYear,
          'current_semester': 1,
        });
      }
    } catch (e) {
      print("Supabase Profile Error: $e");
    }
  }

  Future<Map<String, dynamic>?> getProfile(String uid) async {
    try {
      return await _supabase
          .from('profiles')
          .select()
          .eq('user_id', uid)
          .single();
    } catch (e) {
      return null;
    }
  }

  Future<void> updateStatus(String uid, int year, int semester) async {
    await _supabase
        .from('profiles')
        .update({'current_year': year, 'current_semester': semester})
        .eq('user_id', uid);
  }

  Future<void> updateMaxYear(String uid, int maxYear) async {
    await _supabase
        .from('profiles')
        .update({'max_year': maxYear})
        .eq('user_id', uid);
  }
}
