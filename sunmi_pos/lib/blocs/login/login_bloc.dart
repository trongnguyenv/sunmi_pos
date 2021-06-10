import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import 'login_event.dart';
import 'login_state.dart';
import '../authentication/authentication.dart';
import '../../repositories/repository.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthenticationBloc authenticationBloc;
  final UserRepository userRepository;

  LoginBloc({
    @required this.userRepository,
    @required this.authenticationBloc,
  })  : assert(userRepository != null),
        assert(authenticationBloc != null),
        super(LoginInitial());

  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {
    if (event is LoginButtonPressed) yield* _mapLoginToState(event);
  }

  Stream<LoginState> _mapLoginToState(LoginButtonPressed event) async* {
    yield LoginLoading();

    try {
      final token = await userRepository.login(event.username, event.password);

      if (token != null) {
        userRepository.hasToken();
        authenticationBloc.add(UserLoggedIn(token: token));

        yield LoginSuccess();
        yield LoginInitial();
      } else
        yield LoginFailure(error: 'Oops. Something went wrong');
    } catch (err) {
      yield LoginFailure(error: err.message ?? 'Oops. Something went wrong');
    }
  }
}
