import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/views/login_view.dart';
import 'package:mynotes/views/register_view.dart';
import 'package:mynotes/views/verify_email_view.dart';

import 'firebase_options.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
      primarySwatch: Colors.orange,
      useMaterial3: true,
    ),
    home: const HomePage(),
    routes: {
      '/login': (context) => LoginView(),
      '/register': (context) => RegisterView()
    },
  ));
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              final user = FirebaseAuth.instance.currentUser;
              // if (user?.emailVerified ?? false) {
              //   return const Text('Done');
              // } else { //Critical segment
              //   //To get time for the parent to build using future
              //   // Future.delayed(Duration.zero,(){
              //   //   Navigator.of(context).push(MaterialPageRoute(
              //   //       builder: (context) => const VerifyEmailView()));
              //   // });
              //   return const VerifyEmailView();
             if(user!= null){
                if(user.emailVerified){
                  print("Email Verified");
                }else{
                  return const VerifyEmailView();
                }
             }else{
               return LoginView();
             }
            return const Text("Done");
            default:
              return const CircularProgressIndicator();
          }
        });
  }
}

