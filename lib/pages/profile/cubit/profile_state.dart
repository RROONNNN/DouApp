part of 'profile_cubit.dart';

enum ProfileStatus { initial, loading, success, failure }

class ProfileState extends Equatable {
  final ProfileStatus status;
  final User? user;
  final String? message;
  const ProfileState({
    this.status = ProfileStatus.initial,
    this.user,
    this.message,
  });

  @override
  List<Object?> get props => [status, user, message];

  ProfileState copyWith({ProfileStatus? status, User? user, String? message}) {
    return ProfileState(
      status: status ?? this.status,
      user: user ?? this.user,
      message: message ?? this.message,
    );
  }
}
