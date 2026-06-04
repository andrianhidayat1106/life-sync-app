import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lifesync_app/core/constants/supabase_constants.dart';

void main() {
  test('Debug Supabase projects table connection with Auth', () async {
    print("Creating SupabaseClient...");
    final client = SupabaseClient(
      SupabaseConstants.url,
      SupabaseConstants.anonKey,
      authOptions: const AuthClientOptions(
        authFlowType: AuthFlowType.implicit,
      ),
    );
    print("Supabase client initialized.");

    final email = "debug_${DateTime.now().millisecondsSinceEpoch}@example.com";
    final password = "Password123!";

    print("Signing up a temp user ($email)...");
    try {
      final authRes = await client.auth.signUp(email: email, password: password);
      final userId = authRes.user?.id;
      print("Sign up successful. User ID: $userId");
      
      print("Inserting a test project...");
      final insertRes = await client.from('projects').insert({
        'user_id': userId,
        'name': 'Test Project',
        'priority': 'medium',
      }).select();
      print("Insert successful. Result: $insertRes");

      print("Querying projects table (authenticated)...");
      final res = await client.from('projects').select();
      print("Query projects successful. Result: $res");
    } catch (e) {
      print("Test failed with error: $e");
    }
  });
}
