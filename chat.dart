import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';

String id;

class MyApp6 extends StatelessWidget{


@override 
Widget build(BuildContext context){
  
return MaterialApp(

title:"chat",
routes: {
 "home-page":(context)=>MyHomePage(),
 "login-page":(context)=> LoginPage(), 
// "chat":(context)=>Chat(peerId:peerId,peerAvatar: peerAvatar ),
  
},
home:LoginPage(),
);

}}

class LoginPage extends StatelessWidget {
SharedPreferences prefs;
final FirebaseAuth _auth=FirebaseAuth.instance;
//FirebaseUser currentUser;
final GoogleSignIn googleSignIn=new GoogleSignIn();
 Future <FirebaseUser> _signin() async{
   prefs=await SharedPreferences.getInstance();

   GoogleSignInAccount googleSignInAccount=await googleSignIn.signIn();
  GoogleSignInAuthentication gSA=await googleSignInAccount.authentication;
  FirebaseUser user=await _auth.signInWithGoogle(idToken:gSA.idToken,accessToken:gSA.accessToken);
  print(user);

  if (user != null) {
      // Check is already sign up
      final QuerySnapshot result =
      await Firestore.instance.collection('users').where('id', isEqualTo: user.uid).getDocuments();
      final List<DocumentSnapshot> documents = result.documents;
      if (documents.length == 0) {
        // Update data to server if new user
        Firestore.instance.collection('users').document(user.uid).setData(
            {'nickname': user.displayName, 'photoUrl': user.photoUrl, 'id': user.uid});

        // Write data to local
        await prefs.setString('id', user.uid);
        await prefs.setString('nickname', user.displayName);
        await prefs.setString('photoUrl', user.photoUrl);

id=user.uid;
 }
  }
 return user ;
 } 

//Future<FirebaseUser> currentUser=await _signin();
void _signout(){
  googleSignIn.signOut();
  print("signed out");
}
Future <bool> _loginUser() async{
var api=await _signin();
print("apo=$api");
if (api!= null){

return true;

}
else{
return false;
}

}



@override
 Widget build(BuildContext context){
return new Scaffold(
appBar:AppBar(
title:Text("log in page"),


),
body:Builder(
  builder:(context)=>Center(
  child:Column(
  children: <Widget>[
    FlatButton(
      color: Colors.red,
      child: Text("Sign in"),
      padding: EdgeInsets.fromLTRB(15.0, 100.0, 15.0, 10.0),

      onPressed:()  async{
                          _signin();
                          //print("current is $currentUser");
                          bool b = await _loginUser();
                          
                          print(b);
                         b?Navigator.of(context).push(MaterialPageRoute(builder: (_)=>MyHomePage(
                          // user:currentUser
                         )))
                              // ? Navigator.of(context).pushNamed('home-page')
                              : Scaffold.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Wrong Email!'),
                                    ),
                                  );
                          
                           },),
    FlatButton(
      padding: EdgeInsets.fromLTRB(15.0, 100.0, 15.0, 10.0),
      child:Text("Sign out!"),
      onPressed:_signout,
      color: Colors.grey,
    )
  ])
)
)
);
}
}


class MyHomePage extends StatefulWidget{
final FirebaseUser user;
  @override
MyHomePageState createState(){
  return new MyHomePageState();
}
}

class MyHomePageState extends State<MyHomePage>{

@override
Widget build(BuildContext context){
return Scaffold(
appBar: AppBar(
  title: Text('mmmmmmm'),
),
body:Center(
  child: StreamBuilder(
    stream: Firestore.instance.collection("users").snapshots(),
    builder: (BuildContext context, snapshot){
      if (!snapshot.hasData){
        return Center(child: CircularProgressIndicator());
      }
      else{
        String n=snapshot.data.documents[0]["nickname"];
        print("nick$n");
        
                return ListView.builder(
          itemCount: snapshot.data.documents.length,
          itemBuilder: (context,int index)=>
          FlatButton(

            
            child: Row(
              children: <Widget>[
               Material(child: CachedNetworkImage(
                  placeholder: CircularProgressIndicator(),
                  imageUrl: snapshot.data.documents[index]["photoUrl"],
                  fit: BoxFit.cover,
                  height: 50.0,

                )
               ),
               Flexible(child:  Text(snapshot.data.documents[index]["nickname"])),


              ],
            ),
            onPressed:(){
              Navigator.push(
                context,
                new MaterialPageRoute(
                    builder: (context) => new ChatScreen(
                          peerId: snapshot.data.documents[index]["id"],
                          peerAvatar:snapshot.data.documents[index]['photoUrl'],
                         // user:widget.user,
                        )));
              
            },

padding: EdgeInsets.fromLTRB(25.0, 10.0, 25.0, 10.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          ),
        );
      }
    }
  )
)


);
}
}
class ChatScreen extends StatefulWidget {
  final String peerId;
  final String peerAvatar;
 // final FirebaseUser user;
  ChatScreen({Key key, @required this.peerId, @required this.peerAvatar}) : super(key: key);

  @override
  State createState() => new ChatScreenState(peerId: peerId, peerAvatar: peerAvatar);
}

class ChatScreenState extends State<ChatScreen> {
  ChatScreenState({Key key, @required this.peerId, @required this.peerAvatar});

  String peerId;
  String peerAvatar;
  String id="3";
  SharedPreferences prefs;
  String groupChatId;
    List listMessage;
    final TextEditingController textEditingController =new TextEditingController();
      final ScrollController listScrollController = new ScrollController();


@override
void initState() {
    super.initState();

   String groupChatId = '';

   String imageUrl = '';

    readLocal();
  }
  readLocal()async{
   FirebaseUser user= await FirebaseAuth.instance.currentUser();
   id=user.uid;
   print("user is$user");
   print("idinlo=$id");
  print("object2");
    print("is$id");
    print("peer is$peerId");
    
    if (id.hashCode <= peerId.hashCode) {
      groupChatId = '$id-$peerId';
    } else {
      groupChatId = '$peerId-$id';
    }

    setState(() {});
    id=user.uid;
    print("ch is$groupChatId");
  }

Future<Null> _textmessagesubmitted(String text) async {
    String trial=textEditingController.text;
    print("textfield:$trial");
    textEditingController.clear();
      
    }  




  Widget buildList(){
      return Flexible(
        child:groupChatId==''?
        Center(child: CircularProgressIndicator()):
        StreamBuilder(
          stream: Firestore.instance.collection("messages").document(groupChatId).collection(groupChatId).snapshots(),
          builder:(context,snapshot){

            if(!snapshot.hasData){
              return Center(child: CircularProgressIndicator(),);
            }
            else{
              return ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context,index){
                 if(snapshot.data.documents[index]["idFrom"]==id){
                  return Container(
                    child: Text(snapshot.data.documents[index]["content"]),
                    margin:EdgeInsets.only(right: 50.0),
                    padding: EdgeInsets.fromLTRB(250.0, 0.0, 15.0, 50.0),

                  );}
                  else{
                  return Container(
                   child:  Text(snapshot.data.documents[index]["content"]),
                  margin:EdgeInsets.only(left: 10.0)

                  );}

                },
              controller: listScrollController,

                );
                
              
            }

          } ,



        )
        );




  }


  @override
   Widget build(BuildContext context ){
    return Scaffold(
      appBar:AppBar(
        title: Text('chat'),
        centerTitle: true,

      ),
      
      body:Column(
        children: <Widget>[
          buildList(),
          Row(
            children: <Widget>[
            Flexible(child: TextField(
                controller: textEditingController,
                onSubmitted: _textmessagesubmitted,
                  decoration: InputDecoration.collapsed(
                  hintText: 'Type your message...',
                  hintStyle: TextStyle(color:Colors.grey),
                ),

              )),
             Container(child: IconButton (
                
             icon: Icon(Icons.send),
             onPressed: () {
               String content=textEditingController.text;
               print("icon:$content");
                  textEditingController.clear();
            var documentReference = Firestore.instance.collection('messages').document(groupChatId).collection(groupChatId).document(DateTime.now().millisecondsSinceEpoch.toString());

      Firestore.instance.runTransaction((transaction) async {
        await transaction.set(
          documentReference,
          {
            'idFrom': id,
            'idTo': peerId,
            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
            'content': content,
          },
        );
      });



             }
             ))
            ],

          )
        ],
      ),
    );
   }
  
  
}

// class Chat extends StatefulWidget{
//   final String peerId;
//   final String peerAvatar;
//   Chat({Key key ,@required this.peerId, @required this.peerAvatar}): super(key:key);

// @override
// State creatState()=> new ChatState(peerId:peerId,peerAvatar:peerAvatar);
// }

// class ChatState extends State<Chat>{
// String peerId;
// String peerAvatar;

// ChatState({Key key ,@required this.peerId, @required this.peerAvatar});
// Widget buildList(){
//   StreamBuilder(
//               stream: Firestore.instance.collection('messages').document(groupChatId).collection(groupChatId)
//                   .orderBy('timestamp', descending: true)
//                   .limit(20)
//                   .snapshots(),
//               builder: (context, snapshot) {
//                 if (!snapshot.hasData) {
//                   return Center(
//                       child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>( Colors.blue)));
//                 } else {
//                 var  listMessage = snapshot.data.documents;
//                   return ListView.builder(
//                     padding: EdgeInsets.all(10.0),
//                     itemBuilder: (context, index) => buildItem(index, snapshot.data.documents[index]),
//                     itemCount: snapshot.data.documents.length,
//                     reverse: true,
//                     controller: listScrollController,
//                   );
//                 }
//               },
//             );}


// @override
// Widget build(BuildContext context){
//   return Scaffold(
//     appBar:AppBar (title:Text('hiiii')),
//    body:Center(),
//   );
// }



// }