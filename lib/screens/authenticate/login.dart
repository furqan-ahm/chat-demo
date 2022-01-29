import 'package:chat_demo/models/user_model.dart';
import 'package:chat_demo/screens/authenticate/signup.dart';
import 'package:chat_demo/screens/home/inbox.dart';
import 'package:chat_demo/screens/widgets/MyButton.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../config.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool loading=false;

  final _formKey=GlobalKey<FormState>();

  final TextEditingController _email=TextEditingController();

  final TextEditingController _pass=TextEditingController();

  void Login(BuildContext context)async{
    try {
      final userCredentials = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
          email: _email.text, password: _pass.text);

      final email = userCredentials.user?.email;

      if (email != null) {
        await FirebaseFirestore.instance.collection('users').doc(userCredentials.user!.uid).get().then((value) {
          currentUser=MyUser(name: value.get('Name'), email: email);
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const InboxScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No user found for that email.')),
        );
      }

    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No user found on that email.')),
        );
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Wrong password provided for that user.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 100,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Yen',style: TextStyle(fontSize: 50,color: Colors.teal),),
                      const Text('Chat',style: TextStyle(fontSize: 50),),
                      Flexible(child: Image.asset('assets/yen.png',width: 80,height: 80,)),
                    ],
                  ),
                  const SizedBox(height: 10,),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      controller: _email,
                      decoration: decoration.copyWith(
                        prefixIcon: const Icon(Icons.mail),
                        hintText: "Email",
                      ),
                      validator: (val){
                        if(val==null||val.isEmpty) {
                          return 'This field can not be empty';
                        }
                        else return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      obscureText: true,
                      controller: _pass,
                      decoration: decoration.copyWith(
                        prefixIcon: const Icon(Icons.lock),
                        hintText: "Password"
                      ),
                      validator: (val){
                        if(val==null||val.isEmpty) {
                          return 'This field can not be empty';
                        }
                        else return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 20,),
                  MyButton(
                      onPressed: (){
                        if(_formKey.currentState!.validate())Login(context);
                      },
                      title: 'LogIn',
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('New to the app?'),
                      TextButton(
                        onPressed: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SignupScreen()),
                        ),
                        child: const Text('Signup'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
