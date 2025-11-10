import 'package:bloc/bloc.dart';
import '../../models/note.dart';

class NoteFormCubit extends Cubit<Note> {
  NoteFormCubit()
      : super(Note(
          title: '',
          content: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));

  void updateTitle(String title) {
    emit(state.copyWith(title: title));
  }

  void updateContent(String content) {
    emit(state.copyWith(content: content));
  }

  void loadNote(Note note) {
    emit(note);
  }

  void reset() {
    emit(Note(
      title: '',
      content: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));
  }

  bool get isValid =>
      state.title.trim().isNotEmpty && state.content.trim().isNotEmpty;
}
