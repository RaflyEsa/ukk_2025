import 'package:flutter/material.dart';
import 'package:ukk_2025/login/login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://yxwuaybfpzfrneexluit.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inl4d3VheWJmcHpmcm5lZXhsdWl0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzg3MTM1NzksImV4cCI6MjA1NDI4OTU3OX0.LHy4nreaoVw9eG9aDGMLgKPfoC0xzPJVgwzzlgISxaY',
  );
  runApp(MyApp());
}
        
        

        class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login', 
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
    );
  }
}