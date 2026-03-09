import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {

  final supabase = Supabase.instance.client;

  Future signUp(String email, String password) async {

    final response = await supabase.auth.signUp(
      email: email,
      password: password,
    );

    return response;
  }

  Future signIn(String email, String password) async {

    final response = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    return response;
  }

  Future signOut() async {

    await supabase.auth.signOut();
  }

  User? get currentUser => supabase.auth.currentUser;
}