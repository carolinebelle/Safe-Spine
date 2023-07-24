import 'package:authentication_repository/authentication_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._authenticationRepository)
      : super(SettingsState(user: _authenticationRepository.currentUser));

  final AuthenticationRepository _authenticationRepository;

  void passwordResetRequested() {
    emit(state.copyWith(status: SettingsStatus.loading, message: null));
    String? email = state.user?.email;
    if (email != null) {
      _authenticationRepository
          .sendPasswordResetEmail(email)
          .then((_) => emit(state.copyWith(
              status: SettingsStatus.success,
              message: "Password reset email has been sent to $email.")))
          .catchError((Object error) => emit(state.copyWith(
              status: SettingsStatus.failure, message: error.toString())));
    } else {
      emit(state.copyWith(
          status: SettingsStatus.failure,
          message: "No user signed in, please sign in first."));
      return;
    }
  }

  void signOutRequested() {
    emit(state.copyWith(status: SettingsStatus.loading, message: null));
    _authenticationRepository
        .logOut()
        .then((_) => emit(state.copyWith(
            status: SettingsStatus.success,
            user: null,
            message: "Signed out.")))
        .catchError((Object error) => emit(state.copyWith(
            status: SettingsStatus.failure, message: error.toString())));
  }

  void deleteUserRequested() {
    emit(state.copyWith(status: SettingsStatus.loading, message: null));
    _authenticationRepository
        .deleteUser()
        .then((_) => emit(state.copyWith(
            status: SettingsStatus.success,
            user: null,
            message: "Account deleted.")))
        .catchError((Object error) => emit(state.copyWith(
            status: SettingsStatus.failure,
            user: null,
            message: error.toString())));
  }
}
