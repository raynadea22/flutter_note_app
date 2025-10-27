import 'package:flutter/material.dart';
import 'blocs/note_bloc.dart';
import 'pages/home_page_bloc.dart';
import 'pages/add_note_page_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes App with BLoC',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomePageBloc(bloc: NoteBloc()),
        '/add-note': (context) =>
            AddNotePageBloc(bloc: NoteBloc()), // ✅ DIPERBAIKI
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
