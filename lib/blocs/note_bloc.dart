import 'dart:async';
import '../models/note_model.dart';

class NoteBloc {
  final _notesController = StreamController<List<Note>>.broadcast();
  final List<Note> _notes = [];
  int _nextId = 1;

  Stream<List<Note>> get notesStream => _notesController.stream;

  List<Note> get currentNotes => List.unmodifiable(_notes);

  NoteBloc() {
    _notesController.add(_notes);
  }

  void addNote(Note note) {
    final noteWithId = note.copyWith(
      id: _nextId++,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _notes.insert(0, noteWithId);
    _notesController.add(List.from(_notes));
  }

  void deleteNote(int id) {
    _notes.removeWhere((note) => note.id == id);
    _notesController.add(List.from(_notes));
  }

  void updateNote(Note updatedNote) {
    final index = _notes.indexWhere((note) => note.id == updatedNote.id);
    if (index != -1) {
      _notes[index] = updatedNote.copyWith(updatedAt: DateTime.now());
      _notesController.add(List.from(_notes));
    }
  }

  Note? getNoteById(int id) {
    try {
      return _notes.firstWhere((note) => note.id == id);
    } catch (e) {
      return null;
    }
  }

  void dispose() {
    _notesController.close();
  }
}
