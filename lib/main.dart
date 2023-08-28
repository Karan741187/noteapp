import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/views/login_view.dart';
import 'package:mynotes/views/register_view.dart';
import 'package:mynotes/views/verify_email_view.dart';
import 'firebase_options.dart';
import 'dart:developer' as devtools show log;

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
      loginRoute: (context) => LoginView(),
      registerRoute: (context) => RegisterView(),
      notesRoute:(context) => NotesView()
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
                  return const NotesView();
                }else{
                  return const VerifyEmailView();
                }
             }else{
               return LoginView();
             }

            default:
              return const CircularProgressIndicator();
          }
        });
  }
}

enum MenuAction{ logout }

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Main UI'),
          actions: [
            PopupMenuButton<MenuAction>(
              itemBuilder: (context) {
                return const [PopupMenuItem<MenuAction>(
                  value: MenuAction.logout ,
                  child: Text('Logout'),
                ),
              ];
              },
              onSelected: (value) async{
                switch(value) {
                  case MenuAction.logout:
                    final shouldLogout =await showLogOutDialog(context);
                    if(shouldLogout) {
                      await FirebaseAuth.instance.signOut();
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          loginRoute,
                              (_) => false);
                    }
                    break;
                }
              },
            )
          ],
      ),
      body: const Text('Hello world'),
    );
  }
}
Future<bool> showLogOutDialog(BuildContext context){
  return  showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Sign out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
                onPressed: (){
                  Navigator.of(context).pop(false);
                },
                child: const Text('Cancel')
            ),
            TextButton(
                onPressed: (){
                  Navigator.of(context).pop(true);
                },
                child: const Text('Logout')
            )
          ],
        );
      }

  ).then((value)=> value ?? false);
}

