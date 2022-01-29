import 'package:chat_demo/models/user_model.dart';
import 'package:chat_demo/screens/authenticate/login.dart';
import 'package:chat_demo/screens/home/inbox.dart';
import 'package:chat_demo/screens/widgets/MyButton.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../config.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {


  bool loading=false;

  final _formKey=GlobalKey<FormState>();

  final TextEditingController _name=TextEditingController();

  final TextEditingController _email=TextEditingController();

  final TextEditingController _pass=TextEditingController();

  void SignUp(BuildContext context)async {
    try {
      UserCredential userCred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
          email: _email.text, password: _pass.text);

      if (userCred.user != null) {
        FirebaseFirestore.instance.collection('users')
            .doc(userCred.user!.uid)
            .set(
            {
              'Name': _name.text,
              'Email': _email.text
            }
        );
        currentUser=MyUser(name: _name.text, email: _email.text);
        String email=_email.text;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => InboxScreen()),
        );
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not signup, please try again.')),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('The account already exists for that email.')),
        );
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Could not Sign Up, Please try again')),
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
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 100,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Yen',style: TextStyle(fontSize: 30,color: Colors.teal),),
                      const Text('Chat',style: TextStyle(fontSize: 30),),
                      Flexible(child: Image.asset('assets/yen.png',width: 40,height: 30,)),
                    ],
                  ),
                  const SizedBox(height: 10,),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      controller: _name,
                      decoration: decoration.copyWith(
                        prefixIcon: const Icon(Icons.mail),
                        hintText: "Name",
                      ),
                      validator: (val){
                        if(val==null||val.isEmpty) {
                          return 'This field can not be empty';
                        } else {
                          return null;
                        }
                      },
                    ),
                  ),
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
                        else if(!RegExp(r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
                            .hasMatch(val)){
                          return 'Enter a valid email';
                        }
                        else {
                          return null;
                        }
                      }
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      controller: _pass,
                      decoration: decoration.copyWith(
                          prefixIcon: const Icon(Icons.lock),
                          hintText: "Password"
                      ),
                      validator: (val){
                        if(val==null||val.isEmpty) {
                          return 'This field can not be empty';
                        }
                        else if(val.length<6){
                          return 'Password must be of length 6 or greater';
                        }
                        else return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 20,),
                  MyButton(
                    onPressed: (){
                      if(_formKey.currentState!.validate()){
                        SignUp(context);
                      }
                    },
                    title: 'SignUp',
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Already a user?'),
                      TextButton(
                        onPressed: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LoginScreen()),
                        ),
                        child: const Text('Login'),
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
