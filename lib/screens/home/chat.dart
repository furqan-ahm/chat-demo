import 'package:chat_demo/config.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../loading.dart';


class ChatScreen extends StatelessWidget {
  ChatScreen({Key? key,required this.id,required this.name}) : super(key: key);

  final String id;
  final String name;

  final _messageCont=TextEditingController();


  void sendMessage(){
    if(_messageCont.text.isEmpty)return;

    FirebaseFirestore.instance.collection('ChatRooms').doc(id).collection('messages').add(
      {
        'content':_messageCont.text,
        'sentBy':currentUser!.email,
        'DateTime':DateTime.now()
      }
    );
    _messageCont.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(bottomRight: Radius.circular(10),bottomLeft: Radius.circular(10))),
        title: Text(name),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(child: MessageList(id: id,),),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: _messageCont,
                    style: const TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      hintText: 'Send a Message',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20))
                    ),
                  ),
                ),
              ),
              IconButton(
                  color: Colors.teal,
                  onPressed: (){
                    sendMessage();
                  },
                  icon: const Icon(Icons.send_rounded)
              )
            ],
          )
        ],
      ),
    );
  }
}

class MessageList extends StatefulWidget {
  const MessageList({Key? key,required this.id}) : super(key: key);

  final String id;

  @override
  _MessageListState createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('ChatRooms').doc(widget.id).collection('messages').orderBy('DateTime').snapshots(),
      builder: (context, snapshot) {

        if(!snapshot.hasData)return const LoadingScreen();

        var docs=snapshot.data!.docs.reversed.toList();

        
        return ListView.builder(
            shrinkWrap: true,
            reverse: true,
            itemCount: docs.length,
            itemBuilder: (context,index){
              return MessageBox(sentBy: docs[index].get('sentBy'), content: docs[index].get('content'), isMe: currentUser!.email==docs[index].get('sentBy'));
            }
        );
      }
    );
  }
}

class MessageBox extends StatelessWidget {
  const MessageBox({Key? key, required this.sentBy, required this.content, required this.isMe,}) : super(key: key);

  final String sentBy;
  final String content;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: isMe?CrossAxisAlignment.end:CrossAxisAlignment.start,
        children: [
          isMe?Container():Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(sentBy),
          ),
          Card(
              color: isMe?Colors.teal:Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topRight: const Radius.circular(15),
                    topLeft: const Radius.circular(15,),
                    bottomLeft: Radius.circular(isMe?15:0),
                    bottomRight: Radius.circular(isMe?0:15),
                  )
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(content,style: TextStyle(color: isMe?Colors.white:Colors.black),),
              )
          )
        ],
      ),
    );
  }
}

