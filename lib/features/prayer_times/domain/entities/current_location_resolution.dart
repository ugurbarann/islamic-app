import 'selected_prayer_location.dart';

enum CurrentLocationResolutionStatus {
  resolved,
  permissionDenied,
  permissionPermanentlyDenied,
  serviceDisabled,
  unresolved,
}

class CurrentLocationResolution {
  const CurrentLocationResolution({
    required this.status,
    this.location,
    this.usedGoogleAdministrativeLocation = false,
  });

  final CurrentLocationResolutionStatus status;
  final SelectedPrayerLocation? location;
  final bool usedGoogleAdministrativeLocation;

  bool get isResolved => status == CurrentLocationResolutionStatus.resolved;
}
