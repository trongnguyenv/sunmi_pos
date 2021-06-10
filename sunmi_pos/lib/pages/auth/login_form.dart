import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/blocs.dart';
import '../../repositories/repository.dart';

class LoginForm extends StatelessWidget {
  final UserRepository userRepository;
  LoginForm({Key key, @required this.userRepository})
      : assert(userRepository != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: SafeArea(
          minimum: const EdgeInsets.all(16),
          child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
            builder: (context, state) {
              final authBloc = BlocProvider.of<AuthenticationBloc>(context);
              if (state is AuthenticationNotAuthenticated) {
                return _AuthForm(
                  userRepository: userRepository,
                );
              }
              if (state is AuthenticationFailure) {
                return Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(state.message),
                    FlatButton(
                      textColor: Theme.of(context).primaryColor,
                      child: Text('Retry'),
                      onPressed: () {
                        authBloc.add(AppLoaded());
                      },
                    )
                  ],
                ));
              }
              // return splash screen
              return Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              );
            },
          )),
    );
  }
}

class _AuthForm extends StatefulWidget {
  final UserRepository userRepository;
  _AuthForm({Key key, @required this.userRepository})
      : assert(userRepository != null),
        super(key: key);

  @override
  State<_AuthForm> createState() => _LoginFormState(userRepository);
}

class _LoginFormState extends State<_AuthForm> {
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  final UserRepository userRepository;
  _LoginFormState(this.userRepository);
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _autoValidate = false;
  bool _isHidden = true;

  @override
  Widget build(BuildContext context) {
    final logo = Hero(
      tag: 'easy-salon',
      child: Center(
        child: Container(
          width: 250,
          height: 65,
          child: Image.asset('assets/images/logo-my.png'),
        ),
      ),
    );

    final textIntro = Text(
      'ĐĂNG NHẬP',
      textAlign: TextAlign.center,
      style: TextStyle(
        height: 5,
        fontWeight: FontWeight.bold,
        fontSize: 25,
        color: Colors.blue[400],
      ),
    );

    final username = TextFormField(
      autofocus: false,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.person),
        labelText: 'Tên đăng nhập hoặc email',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
        isDense: true,
        filled: true,
      ),
      controller: _usernameController,
      keyboardType: TextInputType.emailAddress,
      autocorrect: false,
      validator: (value) {
        if (value.isEmpty)
          return 'Nhập tên đăng nhập hoặc email';
        else
          return null;
      },
    );

    final password = TextFormField(
      autofocus: false,
      obscureText: _isHidden,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.lock),
        suffix: InkWell(
          onTap: _togglePasswordView,
          child: Icon(_isHidden ? Icons.visibility : Icons.visibility_off),
        ),
        labelText: 'Mật khẩu',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
      controller: _passwordController,
      validator: (value) {
        if (value.isEmpty)
          return 'Nhập mật khẩu';
        else
          return null;
      },
    );

    final copyright = Center(
      child: Text(
          'Easysalon \u00a9 ${DateTime.now().year.toString()} CTNET Digital'),
    );

    _onLoginButtonPressed() {
      if (_key.currentState.validate()) {
        BlocProvider.of<LoginBloc>(context).add(
          LoginButtonPressed(
            username: _usernameController.text,
            password: _passwordController.text,
          ),
        );
      } else {
        setState(() {
          _autoValidate = true;
        });
      }
    }

    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state is LoginFailure) {
          Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Text("Tên tài khoản hoặc mật khẩu không đúng."),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: BlocBuilder<LoginBloc, LoginState>(
        builder: (context, state) {
          if (state is LoginLoading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return Form(
            key: _key,
            autovalidateMode: _autoValidate
                ? AutovalidateMode.always
                : AutovalidateMode.disabled,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(height: 50.0),
                  logo,
                  textIntro,
                  SizedBox(height: 15.0),
                  username,
                  SizedBox(height: 10.0),
                  password,
                  SizedBox(height: 50.0),
                  RaisedButton(
                    color: Theme.of(context).primaryColor,
                    textColor: Colors.white,
                    padding: const EdgeInsets.all(14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text('Đăng Nhập'),
                    onPressed:
                        state is LoginLoading ? () {} : _onLoginButtonPressed,
                  ),
                  SizedBox(height: 50.0),
                  copyright
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _togglePasswordView() {
    setState(() {
      _isHidden = !_isHidden;
    });
  }
}
