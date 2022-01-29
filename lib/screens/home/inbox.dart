import 'package:chat_demo/screens/authenticate/login.dart';
import 'package:chat_demo/screens/home/chat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../config.dart';


class InboxScreen extends StatelessWidget {
  const InboxScreen({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(bottomRight: Radius.circular(10),bottomLeft: Radius.circular(10))),
        centerTitle: true,
        title: const Text('Inbox',style: TextStyle(),),
        actions: [
          IconButton(
              onPressed: (){
                FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginScreen()));
              },
              icon: const Icon(Icons.logout)
          )
        ],
      ),
      body: InboxView()
    );
  }
}

class InboxView extends StatefulWidget {
  const InboxView({Key? key}) : super(key: key);


  @override
  State<InboxView> createState() => _InboxViewState();
}

class _InboxViewState extends State<InboxView> {
  
  
  void startChat(String name, String email)async{
    int uniqueId=currentUser!.email.compareTo(email);
    String id;
    if(uniqueId>0){
      id=currentUser!.email+email;
      FirebaseFirestore.instance.collection("ChatRooms").doc(id).set({
        'Members':[currentUser!.name,name]
      });
    }
    else{
      id=email+currentUser!.email;
      FirebaseFirestore.instance.collection("ChatRooms").doc(id).set({
        'Members':[name,currentUser!.name]
      });
    }

    Navigator.push(context, MaterialPageRoute(
        builder: (context)=>ChatScreen(id: id, name: name)
    ));

  }
  
  
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context,snapshot){
        if(!snapshot.hasData||snapshot.data==null)return const Center(child: CircularProgressIndicator());

        var users=snapshot.data!.docs;

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context,index) {

            if(currentUser!.email==users[index].get('Email'))return Container();

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Card(
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                  child: ListTile(
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                    contentPadding: const EdgeInsets.all(8),
                    leading: const CircleAvatar(child: Icon(Icons.person),),
                    title: Text(users[index].get('Name')),
                    onTap: (){
                      startChat(users[index].get('Name'), users[index].get('Email'));
                    },
                  )
              ),
            );
          },
        );
      },
    );
  }
}

