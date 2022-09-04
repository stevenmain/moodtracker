import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../widgets/auth/agent_auth_form.dart';

class AuthScreen extends StatefulWidget {
  static const routeName = '/agentAuthScreen';
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth = FirebaseAuth.instance;
  var _isLoading = false;

  void _submitAuthForm(
    String email,
    String password,
    String username,
    String confirmPassword,
    bool isLogin,
    BuildContext ctx,
  ) async {
    UserCredential authResult;

    try {
      setState(() {
        _isLoading = true;
      });
      if (isLogin) {
        authResult = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
         User user = authResult.user!;
        if (user.displayName == "Owner") {
          FirebaseAuth.instance.signOut();
          Scaffold.of(ctx).showSnackBar(
            SnackBar(
              content:
                  Text('Sorry you are not allow to access owner account here!'),
              backgroundColor: Theme.of(ctx).errorColor,
            ),
          );
        } else {
          Navigator.of(context).popAndPushNamed('/');
        }
        setState(() {
          _isLoading = false;
        });
      } else {
        authResult = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        User user = authResult.user!;
        await user.updateProfile(displayName: 'Agent');
        await FirebaseFirestore.instance
            .collection('agent')
            .doc(authResult.user!.uid)
            .set({
          'username': username,
          'companyName': '',
          'email': email,
          'image':
              'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MXx8bWFsZSUyMHByb2ZpbGV8ZW58MHx8MHx8&w=1000&q=80',
          'phone': '',
          'state': null,
          'description': '',
          'focusArea': [] as List<dynamic>,
          'adType': [] as List<dynamic>,
          'propertyCategories': [] as List<dynamic>
        });
        Navigator.of(context).popAndPushNamed('/');
      }
    } on PlatformException catch (err) {
      var message = 'An error occurred, pelase check your credentials!';

      if (err.message != null) {
        message = err.message!;
      }

      Scaffold.of(ctx).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(ctx).errorColor,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    } catch (err) {
      var message = 'An error occurred, pelase check your credentials!';
       Scaffold.of(ctx).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(ctx).errorColor,
        ),
      );
      print(err);
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Agent')),
      backgroundColor: Theme.of(context).primaryColor,
      body: SingleChildScrollView(
        child: AuthForm(
          _submitAuthForm,
          _isLoading,
        ),
      ),
    );
  }
}
