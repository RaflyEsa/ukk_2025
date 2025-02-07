import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ukk_2025/home_page/home_page.dart';


class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Username dan password tidak boleh kosong.')),
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
              builder: (context) =>
                  HomePage(userId: userId, username: userName)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Login gagal. Username atau password salah.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }

}