import 'package:hive/hive.dart';
import '../models/note.dart';

class NotesRepository {
  static const String _boxName = 'notes';
  static const String _lastIdKey = 'lastId';
  late Box<Map> _notesBox;
  late Box<int> _metaBox;

  NotesRepository() {
    _init();
  }

  Future<void> _init() async {
    _notesBox = await Hive.openBox<Map>(_boxName);
    _metaBox = await Hive.openBox<int>('meta');
  }

  Future<int> _getNextId() async {
    await _init();
    final lastId = _metaBox.get(_lastIdKey, defaultValue: 0) ?? 0;
    final nextId = lastId + 1;
    await _metaBox.put(_lastIdKey, nextId);
    return nextId;
  }

  Future<void> saveNote(Note note) async {
    await _init();
    final now = DateTime.now();

    if (note.id == null) {
      // New note - generate ID yang valid
      final id = await _getNextId();
      final newNote = note.copyWith(
        id: id,
        createdAt: now,
        updatedAt: now,
      );
      await _notesBox.put(id, newNote.toMap());
    } else {
      // Update existing note
      final updatedNote = note.copyWith(updatedAt: now);
      await _notesBox.put(note.id, updatedNote.toMap());
    }
  }

  Future<List<Note>> getAllNotes() async {
    await _init();
    final notes = _notesBox.values
        .map((map) => Note.fromMap(Map<String, dynamic>.from(map)))
        .toList();

    notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return notes;
  }

  Future<void> deleteNote(int id) async {
    await _init();
    await _notesBox.delete(id);
  }

  Future<Note?> getNoteById(int id) async {
    await _init();
    final map = _notesBox.get(id);
    return map != null ? Note.fromMap(Map<String, dynamic>.from(map)) : null;
  }
}
