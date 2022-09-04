import 'package:flutter/material.dart';

import '../../../forget_password_screen.dart';

class AuthForm extends StatefulWidget {
  AuthForm(
    this.submitFn,
    this.isLoading,
  );

  final bool isLoading;
  final void Function(
    String email,
    String password,
    String userName,
    String confirmPassword,
    bool isLogin,
    BuildContext ctx,
  ) submitFn;

  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  var _isLogin = true;
  var _userEmail = '';
  var _userName = '';
  var _confirmPassword = '';
  var _userPassword = '';

  void _trySubmit() {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      _formKey.currentState!.save();
      widget.submitFn(_userEmail.trim(), _userPassword.trim(), _userName.trim(),
          _confirmPassword.trim(), _isLogin, context);
    }
  }

  bool validateStructure(String value) {
    String pattern =
        r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
    RegExp regExp = new RegExp(pattern);
    return regExp.hasMatch(value);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
           SizedBox(
            height: MediaQuery.of(context).size.height * 0.12,
          ),
          Container(
              child: Text(
            'MHproperty',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          )),
          Card(
            margin: EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextFormField(
                        key: ValueKey('email'),
                        validator: (value) {
                          if (value!.isEmpty || !value.contains('@')) {
                            return 'Please enter a valid email address.';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email address',
                        ),
                        onSaved: (value) {
                          _userEmail = value!;
                        },
                      ),
                      if (!_isLogin)
                        TextFormField(
                          key: ValueKey('username'),
                          validator: (value) {
                            if (value!.isEmpty || value.length < 4) {
                              return 'Please enter at least 4 characters';
                            } else if (value.length > 20) {
                              return 'Username cannot length no more than 20 character';
                            }
                            return null;
                          },
                          decoration: InputDecoration(labelText: 'Username'),
                          onSaved: (value) {
                            _userName = value!;
                          },
                        ),
                      TextFormField(
                        key: ValueKey('password'),
                        validator: (value) {
                          if (!validateStructure(value!) && !_isLogin) {
                            return 'Should contain upper,lower,digit and Special character.';
                          } else if (value.isEmpty && _isLogin) {
                            return 'Please enter a password.';
                          }
                          _userPassword = value;
                          return null;
                        },
                        decoration: InputDecoration(labelText: 'Password'),
                        obscureText: true,
                        onSaved: (value) {
                          setState(() {
                            _userPassword = value!;
                          });
                        },
                      ),
                      if (!_isLogin)
                        TextFormField(
                          key: ValueKey('Confirm Password'),
                          validator: (value) {
                            if (value!.isEmpty || value != _userPassword) {
                              return 'Passwords do not match!';
                            }
                            return null;
                          },
                          decoration:
                              InputDecoration(labelText: 'Confirm Password'),
                          obscureText: true,
                          onSaved: (value) {
                            _confirmPassword = value!;
                          },
                        ),
                      SizedBox(height: 12),
                      if (widget.isLoading) CircularProgressIndicator(),
                      if (!widget.isLoading)
                        RaisedButton(
                          child: Text(_isLogin ? 'Login' : 'Signup'),
                          onPressed: _trySubmit,
                        ),
                      if (!widget.isLoading)
                        FlatButton(
                          textColor: Theme.of(context).primaryColor,
                          child: Text(_isLogin
                              ? 'Create new account'
                              : 'I already have an account'),
                          onPressed: () {
                            setState(() {
                              _isLogin = !_isLogin;
                            });
                          },
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (_isLogin)
                            FlatButton(
                              textColor: Theme.of(context).primaryColor,
                              child: Text(
                                'Forget Passowrd?',
                              ),
                              onPressed: () {
                                Navigator.of(context)
                                    .pushNamed(ForgotPassword.routeName);
                                // setState(() {
                                //   // _isLogin = !_isLogin;
                                // });
                              },
                            )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
