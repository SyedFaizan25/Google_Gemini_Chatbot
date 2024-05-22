import 'dart:convert';

import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Google Gemini ChatBot',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Google Gemini ChatBot'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ChatUser myself = ChatUser(id: '1', firstName: 'Syed', lastName: 'Faizan');
  ChatUser bot = ChatUser(id: '2', firstName: 'Google', lastName: 'Gemini');

  List<ChatMessage> allMessage = [];
  List<ChatUser> typing = [];




  getAllData(ChatMessage m) async {
    typing.add(bot);
    allMessage.insert(0, m);
    setState(() {});

    const url='https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=userKey';
    final header= {
      'Content-Type': 'application/json'
    };
    var data={"contents":[{"parts":[{"text":m.text}]}]};

    await http.post(Uri.parse(url),headers: header,body: jsonEncode(data))
        .then((value) {

          if(value.statusCode==200){
            var result=jsonDecode(value.body);
            debugPrint("***********$result");
             debugPrint(result['candidates'][0]['content']['parts'][0]['text']);
             ChatMessage m1=ChatMessage(
               user: bot,
               createdAt: DateTime.now(),
               text: result['candidates'][0]['content']['parts'][0]['text'].toString(),
             );

             allMessage.insert(0, m1);

             
          }else{

            debugPrint('Error');
          }

    } ).catchError((e){

    });

    typing.remove(bot);
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        body: DashChat(
          typingUsers: typing,

            currentUser: myself,
            onSend: (ChatMessage chatMessage) {
              getAllData(chatMessage);
            },
            messages: allMessage));
  }
}
