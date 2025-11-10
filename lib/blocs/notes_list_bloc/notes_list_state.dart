part of 'notes_list_bloc.dart';

abstract class NotesListState extends Equatable {
  const NotesListState();

  @override
  List<Object> get props => [];
}

class NotesListInitial extends NotesListState {}

class NotesListLoading extends NotesListState {}

class NotesListLoaded extends NotesListState {
  final List<Note> notes;

  const NotesListLoaded({required this.notes});

  @override
  List<Object> get props => [notes];
}

class NotesListError extends NotesListState {
  final String error;

  const NotesListError({required this.error});

  @override
  List<Object> get props => [error];
}
