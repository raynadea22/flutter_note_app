import 'package:flutter/material.dart';
import '../models/note_model.dart';
import '../providers/note_provider.dart';
import 'package:provider/provider.dart'; // ✅ IMPORT YANG BENAR

class AddNotePage extends StatefulWidget {
  const AddNotePage({super.key}); // ✅ TANDA KURUNG DIBENARKAN

  @override
  State<AddNotePage> createState() => _AddNotePageState();
}

class _AddNotePageState extends State<AddNotePage> {
  final _titleController =
      TextEditingController(); // ✅ TANDA UNDERSCORE DITAMBAH
  final _contentController =
      TextEditingController(); // ✅ TANDA UNDERSCORE DITAMBAH
  final _formKey = GlobalKey<FormState>(); // ✅ TIPE DATA DIBENARKAN

  Note? _editingNote;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getArguments();
    });
  }

  void _getArguments() {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments != null && arguments is Note) {
      setState(() {
        _editingNote = arguments;
        _titleController.text = _editingNote!.title;
        _contentController.text = _editingNote!.content;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editingNote == null ? 'Add New Note' : 'Edit Note'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_editingNote != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _deleteNote(context),
              tooltip: 'Delete Note',
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                  hintText: 'Enter note title',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Expanded(
                child: TextFormField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    labelText: 'Content',
                    border: OutlineInputBorder(),
                    hintText: 'Enter your note content...',
                    alignLabelWithHint: true,
                  ),
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter some content';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => _saveNote(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    _editingNote == null ? 'Save Note' : 'Update Note',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveNote(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final noteProvider = Provider.of<NoteProvider>(context, listen: false);

      if (_editingNote == null) {
        // Add new note
        final newNote = Note(
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        noteProvider.addNote(newNote);
        _showSnackBar(context, 'Note added successfully');
      } else {
        // Update existing note
        final updatedNote = _editingNote!.copyWith(
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          updatedAt: DateTime.now(),
        );
        noteProvider.updateNote(updatedNote);
        _showSnackBar(context, 'Note updated successfully');
      }

      Navigator.pop(context);
    }
  }

  void _deleteNote(BuildContext context) {
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Note'),
          content: const Text('Are you sure you want to delete this note?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                noteProvider.deleteNote(_editingNote!.id!);
                Navigator.of(context)
                  ..pop()
                  ..pop();
                _showSnackBar(context, 'Note deleted successfully');
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}
