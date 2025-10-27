import 'package:flutter/material.dart';
import '../models/note_model.dart';

class NoteProvider with ChangeNotifier {
  final List<Note> _notes = [];
  int _nextId = 1;

  List<Note> get notes => List.unmodifiable(_notes);

  void addNote(Note newNote) {
    final noteWithId = newNote.copyWith(
      id: _nextId++,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _notes.insert(0, noteWithId); // Tambah di awal untuk urutan terbaru
    notifyListeners();
  }

  void deleteNote(int id) {
    _notes.removeWhere((note) => note.id == id);
    notifyListeners();
  }

  void updateNote(Note updatedNote) {
    final index = _notes.indexWhere((note) => note.id == updatedNote.id);
    if (index != -1) {
      _notes[index] = updatedNote.copyWith(updatedAt: DateTime.now());
      notifyListeners();
    }
  }

  Note? getNoteById(int id) {
    try {
      return _notes.firstWhere((note) => note.id == id);
    } catch (e) {
      return null;
    }
  }
}
