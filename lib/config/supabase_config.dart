import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://eneajtmprugcevuacxix.supabase.co';
  static const String supabaseAnonKey = 'sb_publishable_bgGRAQ2l5SsXL0VgTY92cg_ewPS6l0m';
  
  static SupabaseClient? _client;
  
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
    _client = Supabase.instance.client;
  }
  
  static SupabaseClient get client {
    if (_client == null) {
      throw Exception('Supabase not initialized. Call initialize() first.');
    }
    return _client!;
  }
  
  // Table names
  static const String favoriteCitiesTable = 'favorite_cities';
}

