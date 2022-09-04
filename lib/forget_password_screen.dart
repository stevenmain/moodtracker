import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPassword extends StatefulWidget {
  static const routeName = '/forgetPassword';

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _auth = FirebaseAuth.instance;

  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  var email = '';

  void _trySubmit() {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      _formKey.currentState!.save();
      // _auth.sendPasswordResetEmail(email: email);
      resetPassword(email: email);
    }
  }

  Future<void> resetPassword({required String email}) async {
    await _auth
        .sendPasswordResetEmail(email: email)
        .then((value) => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Email sent successful'),
                duration: Duration(seconds: 3),
              ),
            ))
        .catchError((e) => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('This email address cannot be found!'),
                duration: Duration(seconds: 3),
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Reset Password')),
      backgroundColor: Theme.of(context).backgroundColor,
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Email Your Email',
                style: TextStyle(fontSize: 30),
              ),
              TextFormField(
                textInputAction: TextInputAction.done,
                // keyboardType: TextInputType.emailAddress,
                controller: _emailController,
                validator: (value) {
                  if (value!.isEmpty || !value.contains('@')) {
                    return 'Please enter a valid email address.';
                  }

                  return null;
                },
                onSaved: (value) {
                  setState(() {
                    email = value!;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Email',
                  icon: Icon(
                    Icons.mail,
                  ),
                  errorStyle: TextStyle(color: Colors.red),
                  labelStyle: TextStyle(color: Colors.black),
                  hintStyle: TextStyle(color: Colors.black),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  errorBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
              ),
              SizedBox(height: 20),
              RaisedButton(
                child: Text('Send Email'),
                onPressed: () {
                  _trySubmit();
                  // _auth.sendPasswordResetEmail(email: email);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
