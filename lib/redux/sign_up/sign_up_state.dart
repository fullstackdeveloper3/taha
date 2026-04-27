class SignUpState {
  final bool requesting;
  final Object? error;

  const SignUpState({this.requesting = false, this.error});

  SignUpState copyWith({
    bool? requesting,
    Object? error,
    bool clearError = false,
  }) {
    return SignUpState(
      requesting: requesting ?? this.requesting,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
