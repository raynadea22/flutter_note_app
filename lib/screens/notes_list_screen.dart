import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/notes_list_bloc/notes_list_bloc.dart';
import '../blocs/note_form_cubit/note_form_cubit.dart';
import '../models/note.dart'; // PASTIKAN INI DITAMBAHKAN
import 'note_form_screen.dart';

class NotesListScreen extends StatelessWidget {
  const NotesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Saya'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<NotesListBloc>().add(LoadNotes());
            },
          ),
        ],
      ),
      body: BlocListener<NotesListBloc, NotesListState>(
        listener: (context, state) {
          // Handle state changes jika diperlukan
          if (state is NotesListError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.error}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<NotesListBloc, NotesListState>(
          builder: (context, state) {
            if (state is NotesListLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is NotesListError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Terjadi kesalahan',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.error,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<NotesListBloc>().add(LoadNotes());
                      },
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              );
            } else if (state is NotesListLoaded) {
              final notes = state.notes;

              if (notes.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.note_add, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Belum ada catatan',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      Text(
                        'Tekan + untuk membuat catatan baru',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<NotesListBloc>().add(LoadNotes());
                },
                child: ListView.builder(
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    return _buildNoteItem(context, note);
                  },
                ),
              );
            } else {
              // Initial state - load notes for the first time
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.read<NotesListBloc>().add(LoadNotes());
              });

              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Memuat catatan...'),
                  ],
                ),
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _navigateToNoteForm(context, null);
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildNoteItem(BuildContext context, Note note) {
    return Dismissible(
      key: Key('note-${note.id}'),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await _showDeleteDialog(context, note);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: ListTile(
          leading: const Icon(Icons.note, color: Colors.blue),
          title: Text(
            note.title.isEmpty ? '(Tanpa Judul)' : note.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                note.content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                'Diperbarui: ${_formatDate(note.updatedAt)}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          onTap: () {
            _navigateToNoteForm(context, note);
          },
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              _showDeleteDialog(context, note);
            },
          ),
        ),
      ),
    );
  }

  void _navigateToNoteForm(BuildContext context, Note? note) {
    final isEditing = note != null;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) {
            final cubit = NoteFormCubit();
            if (isEditing) {
              cubit.loadNote(note!);
            }
            return cubit;
          },
          child: NoteFormScreen(
            isEditing: isEditing,
            existingNote: note,
          ),
        ),
      ),
    ).then((result) {
      // Refresh list when returning from form
      if (result == true || result == null) {
        context.read<NotesListBloc>().add(LoadNotes());
      }
    });
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final noteDate = DateTime(date.year, date.month, date.day);

    if (noteDate == today) {
      return 'Hari ini ${_formatTime(date)}';
    } else if (noteDate == today.subtract(const Duration(days: 1))) {
      return 'Kemarin ${_formatTime(date)}';
    } else {
      return '${date.day}/${date.month}/${date.year} ${_formatTime(date)}';
    }
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<bool?> _showDeleteDialog(BuildContext context, Note note) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hapus Catatan'),
          content: Text(
            'Yakin ingin menghapus "${note.title.isEmpty ? '(Tanpa Judul)' : note.title}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                context.read<NotesListBloc>().add(DeleteNote(note.id!));
                Navigator.pop(context, true);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }
}
