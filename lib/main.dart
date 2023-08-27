import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/views/login_view.dart';

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
  ));
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:const Text('Home'),
        backgroundColor: Colors.black,
        foregroundColor:Colors.white ,
      ),
      body: FutureBuilder(
          future: Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,

          ) ,
          builder:(context,snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                final user=FirebaseAuth.instance.currentUser;
                if(user?.emailVerified ?? false){
                  print("Email verified");
                }
                else{
                  print("Verify email or null user");
                }
                return const Text('Done');
              default:
                return const Text('Loading...');
            }


          }
      ),
    );
  }
}








