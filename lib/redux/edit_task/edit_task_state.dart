class EditTaskState {
  final bool requesting;
  final bool saved;
  final Object? error;

  const EditTaskState({
    this.requesting = false,
    this.saved = false,
    this.error,
  });

  EditTaskState copyWith({
    bool? requesting,
    bool? saved,
    Object? error,
    bool clearError = false,
  }) {
    return EditTaskState(
      requesting: requesting ?? this.requesting,
      saved: saved ?? this.saved,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
