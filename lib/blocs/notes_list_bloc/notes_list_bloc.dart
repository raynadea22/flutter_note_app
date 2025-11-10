import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/note.dart';
import '../../repositories/notes_repository.dart';

part 'notes_list_event.dart';
part 'notes_list_state.dart';

class NotesListBloc extends Bloc<NotesListEvent, NotesListState> {
  final NotesRepository notesRepository;

  NotesListBloc(this.notesRepository) : super(NotesListInitial()) {
    on<LoadNotes>(_onLoadNotes);
    on<DeleteNote>(_onDeleteNote);
  }

  Future<void> _onLoadNotes(
      LoadNotes event, Emitter<NotesListState> emit) async {
    emit(NotesListLoading());
    try {
      final notes = await notesRepository.getAllNotes();
      emit(NotesListLoaded(notes: notes));
    } catch (e) {
      emit(NotesListError(error: e.toString()));
    }
  }

  Future<void> _onDeleteNote(
      DeleteNote event, Emitter<NotesListState> emit) async {
    try {
      await notesRepository.deleteNote(event.noteId);
      final notes = await notesRepository.getAllNotes();
      emit(NotesListLoaded(notes: notes));
    } catch (e) {
      emit(NotesListError(error: e.toString()));
    }
  }
}
