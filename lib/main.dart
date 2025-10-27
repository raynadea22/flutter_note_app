import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // ✅ IMPORT PACKAGE PROVIDER
import 'providers/note_provider.dart';
import 'pages/home_page.dart';
import 'pages/add_note_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => NoteProvider(), // ✅ PROVIDER ANDA
      child: MaterialApp(
        title: 'Notes App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const HomePage(),
          '/add-note': (context) => const AddNotePage(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
