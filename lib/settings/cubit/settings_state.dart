part of 'settings_cubit.dart';

enum SettingsStatus { initial, loading, success, failure }

final class SettingsState extends Equatable {
  const SettingsState(
      {this.status = SettingsStatus.initial, this.user, this.message});

  final SettingsStatus status;
  final User? user;
  final String? message;

  @override
  List<Object?> get props => [status, user, message];

  SettingsState copyWith(
      {SettingsStatus? status, User? user, String? message}) {
    return SettingsState(
        status: status ?? this.status,
        user: user ?? this.user,
        message: message ?? this.message);
  }
}
