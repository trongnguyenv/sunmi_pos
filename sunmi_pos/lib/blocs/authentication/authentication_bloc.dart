import 'dart:async';

import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'authentication_event.dart';
import 'authentication_state.dart';
import '../../repositories/repository.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final UserRepository userRepository;

  AuthenticationBloc({@required this.userRepository})
      : assert(userRepository != null),
        super(AuthenticationItinial());

  @override
  AuthenticationState get initalizeState => AuthenticationItinial();

  @override
  Stream<AuthenticationState> mapEventToState(
      AuthenticationEvent event) async* {
    if (event is AppLoaded) yield* _mapAddLoadedToState(event);

    if (event is UserLoggedIn) yield* _mapUserLoggedInToState(event);

    if (event is UserLoggedOut) yield* _mappUserLoggedOutToState(event);
  }

  Stream<AuthenticationState> _mapAddLoadedToState(AppLoaded event) async* {
    yield AuthenticationLoading();

    try {
      await Future.delayed(Duration(milliseconds: 500));

      final bool hasToken = await userRepository.hasToken();
      if (hasToken) {
        // Check has token load authorizetion
        yield AuthenticationAuthenticated();
      } else {
        yield AuthenticationNotAuthenticated();
      }
    } catch (e) {
      yield AuthenticationFailure(
          message: e.message ?? 'An unknown error occurred.');
    }
  }

  Stream<AuthenticationState> _mapUserLoggedInToState(
      UserLoggedIn event) async* {
    yield AuthenticationLoading();
    await userRepository.persistToken(event.token);
    yield AuthenticationAuthenticated();
  }

  Stream<AuthenticationState> _mappUserLoggedOutToState(
      UserLoggedOut event) async* {
    yield AuthenticationLoading();
    await userRepository.deleteToken();
    yield AuthenticationNotAuthenticated();
  }
}
