import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/note_form_cubit/note_form_cubit.dart';
import '../models/note.dart'; // PASTIKAN INI DITAMBAHKAN
import '../repositories/notes_repository.dart';

class NoteFormScreen extends StatefulWidget {
  final bool isEditing;
  final Note? existingNote; // Tambahkan parameter untuk note yang diedit

  const NoteFormScreen({
    super.key,
    required this.isEditing,
    this.existingNote, // Parameter opsional untuk note existing
  });

  @override
  State<NoteFormScreen> createState() => _NoteFormScreenState();
}

class _NoteFormScreenState extends State<NoteFormScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeNote();
  }

  void _initializeNote() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final noteCubit = context.read<NoteFormCubit>();

      if (widget.isEditing && widget.existingNote != null) {
        // Load note yang akan diedit
        noteCubit.loadNote(widget.existingNote!);
        _titleController.text = widget.existingNote!.title;
        _contentController.text = widget.existingNote!.content;
      } else {
        // Reset untuk note baru
        noteCubit.reset();
        _titleController.clear();
        _contentController.clear();
      }

      setState(() {
        _isInitialized = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Catatan' : 'Buat Catatan Baru'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          BlocBuilder<NoteFormCubit, Note>(
            builder: (context, state) {
              return IconButton(
                onPressed: (state.title.trim().isNotEmpty &&
                        state.content.trim().isNotEmpty)
                    ? () => _saveNote(context)
                    : null,
                icon: const Icon(Icons.save),
                tooltip: 'Simpan',
              );
            },
          ),
        ],
      ),
      body: _isInitialized
          ? _buildFormContent()
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildFormContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              hintText: 'Judul catatan...',
              border: InputBorder.none,
              hintStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            onChanged: (value) {
              context.read<NoteFormCubit>().updateTitle(value);
            },
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                hintText: 'Tulis catatanmu di sini...',
                border: InputBorder.none,
                alignLabelWithHint: true,
              ),
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              onChanged: (value) {
                context.read<NoteFormCubit>().updateContent(value);
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveNote(BuildContext context) async {
    final noteCubit = context.read<NoteFormCubit>();
    final notesRepository = context.read<NotesRepository>();

    // Validasi input
    if (noteCubit.state.title.trim().isEmpty ||
        noteCubit.state.content.trim().isEmpty) {
      _showErrorSnackBar(context, 'Judul dan konten tidak boleh kosong');
      return;
    }

    try {
      await notesRepository.saveNote(noteCubit.state);
      if (mounted) {
        Navigator.pop(context, true); // Return true untuk trigger refresh
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(context, 'Gagal menyimpan catatan: $e');
      }
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}
