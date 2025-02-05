import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginController {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> login(BuildContext context) async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username dan password tidak boleh kosong.')),
      );
      return;
    }

    try {
      final response = await Supabase.instance.client
          .from('user')
          .select('id, username')
          .eq('username', username)
          .eq('password', password)
          .maybeSingle();

      if (response != null) {
        final userId = response['id'];
        final userName = response['username'];

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Selamat datang, $userName!')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => HomePage(userId: userId, username: userName)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login gagal. Username atau password salah.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }
  }
  
  HomePage({required userId, required username}) {}
}

