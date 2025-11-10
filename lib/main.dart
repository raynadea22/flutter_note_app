import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'blocs/notes_list_bloc/notes_list_bloc.dart';
import 'repositories/notes_repository.dart';
import 'screens/notes_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => NotesRepository(),
      child: BlocProvider(
        create: (context) =>
            NotesListBloc(context.read<NotesRepository>())..add(LoadNotes()),
        child: MaterialApp(
          title: 'Notes App',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            useMaterial3: true,
          ),
          home: const NotesListScreen(),
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
