import 'package:flutter/material.dart';
import 'package:mhproperty/agent/screens/deal_screen.dart';
import 'package:mhproperty/agent/screens/follower/follower_screen.dart';
import 'package:mhproperty/forget_password_screen.dart';
import 'package:mhproperty/owner/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import './owner/screens/chat_screen.dart';
import './owner/screens/auth_screen.dart';
import './owner/screens/property/property_upload_screen.dart';
import 'package:provider/provider.dart';
import './owner/models/images.dart';
import './owner/models/dummyData.dart';
import './owner/widgets/drawer.dart';
import './owner/screens/home_screen.dart';
import './owner/screens/property/property_screen.dart';
import './owner/screens/property/property_upload_screen.dart';
import './owner/screens/property/propertyDetails_screen.dart';
import 'owner/models/notification.dart';
import 'owner/screens/notification.dart';
import 'owner/screens/subcribe/subcriber_screen.dart';
import 'owner/widgets/property/property_image.dart';
import './owner/screens/property/property_edit_screen.dart';
import 'owner/screens/profile/profile.dart';
import './owner/models/owner.dart';
import 'option_screen.dart';
import './owner/screens/agent/agent_screen.dart';

// agent
import './agent/screens/agent_auth_screen.dart' as agent_auth;
import './agent/screens/agent_home_screen.dart' as agent_home;
import './agent/models/images.dart' as agent_image;
import './agent/models/agent.dart' as agent;
import './agent/screens/property/agent_property_screen.dart' as agent_property;
import './agent/screens/property/agent_property_details_screen.dart'
    as agent_propertyDetail;
import 'agent/models/property.dart' as agent_propertyModal;

void main() async {
  // Firebase.initializeApp();
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var me;
  var list = ['testing'];
  var index = 0;
  var data;
  var data2;
  bool exist = false;
  @override
  void initState() {
    me = FirebaseAuth.instance.currentUser;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    me = FirebaseAuth.instance.currentUser;
    return MultiProvider(
      providers: [
        // owner
        ChangeNotifierProvider(
          create: (ctx) => ImagesProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => dummyDataProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => OwnersProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => NotificationProvider(),
        ),
        // agent
        ChangeNotifierProvider(
          create: (ctx) => agent_image.ImagesProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => agent_propertyModal.PropertyProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => agent.AgentsProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
            backgroundColor: Color.fromARGB(255, 197, 248, 251),
            // backgroundColor: Color.fromARGB(255, 64, 239, 233),
            
            // backgroundColor: Color.fromARGB(255, 92, 255, 250),
            primarySwatch: Colors.blue,
            accentColor: Color.fromARGB(255, 1, 96, 101),
            primaryColor: Color.fromARGB(255, 0, 186, 207),
            
            fontFamily: 'Quicksand',
            textTheme: ThemeData.light().textTheme.copyWith(
                  headline6: TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Colors.yellow[600],
                  ),
                  button: TextStyle(color: Colors.white),
                ),
            appBarTheme: AppBarTheme(
              color: Color.fromARGB(255, 1, 96, 101),
              textTheme: ThemeData.light().textTheme.copyWith(
                    headline6: TextStyle(
                      color: Colors.yellow[600],
                      fontFamily: 'Quicksand',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
            )),
        // initialRoute: '/', // default is '/'
        routes: {
          '/': (ctx) => StreamBuilder(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (ctx, userSnapshot) {
                if (userSnapshot.hasData) {
                  me = FirebaseAuth.instance.currentUser;
                  if (me.displayName == 'Agent') {
                    return agent_home.HomeScreen();
                  } else {
                    return HomeScreen();
                  }
                }
                return OptionScreen();
              }),
          PropertyScreen.routeName: (ctx) => PropertyScreen(),
          PropertyUploadScreen.routeName: (ctx) => PropertyUploadScreen(),
          HomeScreen.routeName: (ctx) => const HomeScreen(),
          SliderShowFullmages.routeName: (ctx) => SliderShowFullmages(),
          AuthScreen.routeName: (ctx) => AuthScreen(),
          AgentScreen.routeName: (ctx) => AgentScreen(),
          SubcribeScreen.routeName: (ctx) => SubcribeScreen(),
           ForgotPassword.routeName: (ctx) => ForgotPassword(),
          // NotificationScreen.routeName: (ctx) => NotificationScreen(),
          // agent
          agent_home.HomeScreen.routeName: (ctx) => agent_home.HomeScreen(),
          agent_auth.AuthScreen.routeName: (ctx) => agent_auth.AuthScreen(),
          agent_property.PropertyScreen.routeName: (ctx) =>
              agent_property.PropertyScreen(),
          FollowerScreen.routeName: (ctx) => FollowerScreen(),
          DealScreen.routeName: (ctx) => DealScreen(),
        },
      ),
    );
  }
}
