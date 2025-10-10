part of 'profile_cubit.dart';

enum ProfileStatus { initial, loading, success, failure }

class ProfileState extends Equatable {
  final ProfileStatus status;
  const ProfileState({this.status = ProfileStatus.initial});

  @override
  List<Object> get props => [status];
}
