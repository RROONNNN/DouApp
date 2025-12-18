part of 'mistake_cubit.dart';

class MistakeState extends Equatable {
  final RequestStatus status;
  final List<Map<Unit, List<Question>>> mistakes;
  const MistakeState({
    this.status = RequestStatus.initial,
    this.mistakes = const [],
  });

  @override
  List<Object> get props => [status, mistakes];

  MistakeState copyWith({
    RequestStatus? status,
    List<Map<Unit, List<Question>>>? mistakes,
  }) {
    return MistakeState(
      status: status ?? this.status,
      mistakes: mistakes ?? this.mistakes,
    );
  }
}
