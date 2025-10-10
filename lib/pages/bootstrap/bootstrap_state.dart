import '../../common/enums/request_status.dart';

enum BootstrapStatus { initial, authenticated, unauthenticated }

class BootstrapState {
  final BootstrapStatus status;
  final RequestStatus requestStatus;

  const BootstrapState({
    this.status = BootstrapStatus.initial,
    this.requestStatus = RequestStatus.initial,
  });

  BootstrapState copyWith({
    BootstrapStatus? status,
    RequestStatus? requestStatus,
  }) {
    return BootstrapState(
      status: status ?? BootstrapStatus.initial,
      requestStatus: requestStatus ?? RequestStatus.initial,
    );
  }
}
