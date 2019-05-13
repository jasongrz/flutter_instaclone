import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:timeago/timeago.dart' as timeago;
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Color.fromRGBO(58, 66, 86, 1.0),
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  MyHomePageState createState() => new MyHomePageState();
}

class MyAppTab extends StatelessWidget{
  List<dynamic> posts;
  List<dynamic> my_posts;
  Map<String, dynamic> profile;
  var token;
  MyAppTab(this.posts, this.my_posts, this.profile, this.token);

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      theme: new ThemeData(primaryColor: Color.fromRGBO(58, 66, 86, 1.0)),
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
          appBar: AppBar(title: Text("Fluttergram"), centerTitle: true,),
          bottomNavigationBar: new TabBar(
            tabs: <Widget>[
              Tab(
                icon: new Icon(Icons.home),
              ),
              Tab(
                icon: new Icon(Icons.add_a_photo),
              ),
              Tab(
                icon: new Icon(Icons.person),
              ),
            ],
          ),
          body:TabBarView(
            children: [
              PostFeed(posts, token),
              AddPost(token),
              Profile(profile, token, my_posts),
            ],
          ),
        ),
      ),
    );
  }
}



class AddPost extends StatefulWidget {
  var token;
  AddPost(this.token);

  _AddPostState createState() => _AddPostState(token);
}
class _AddPostState extends State<AddPost> {
  var token;
  File _image;
  TextEditingController captionController = TextEditingController();
  _AddPostState(this.token);

  void getImage() async{
    var image = await ImagePicker.pickImage(source:ImageSource.gallery);
    if(image != null){
      _image = image;
      setState((){
        
      });
    }
  }

  void uploadImage() async{
    var image = await ImagePicker.pickImage(source:ImageSource.camera);
    if(image != null){
      _image = image;
      setState((){
        
      });
    }
  }

  void upload(caption) async{
    FormData formData = new FormData.from({
      "caption": caption,
      "image": new UploadFileInfo(_image, _image.path)
    });
    Dio().post("http://serene-beach-48273.herokuapp.com/api/v1/posts", 
    data: formData, 
    options: Options(headers: {HttpHeaders.authorizationHeader: "Bearer $token"},
    ),);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Expanded(
            child: Center(
              child:  _image == null
              ? Text("No Image Selected", style: TextStyle(color: Colors.white),)
              : Image.file(_image),
            ),
          ),
          Center(child: RaisedButton(
                onPressed: getImage,
                child: Text("Gallery"),
              ),),
          TextField(
            controller: captionController,
            onSubmitted: (caption){
              upload(caption);
              captionController.clear();
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: "Add Caption",
            ),
          ),
        ],
      ),
    );
  }
}



class Profile extends StatefulWidget {

  Map<String,dynamic> profile;
  List<dynamic> my_posts;
  var token;
  Profile(this.profile, this.token, this.my_posts);
  @override
  _ProfileState createState() => _ProfileState(this.profile, this.token, this.my_posts);
}
class _ProfileState extends State<Profile> {

  Map<String,dynamic> profile;
  List<dynamic> my_posts;
  var token;
  var commentController =TextEditingController();
  _ProfileState(this.profile, this.token, this.my_posts);

   String updateTime(String postedtime){
    final now = new DateTime.now();
    final difference = now.difference(DateTime.parse(postedtime));
    String answer = timeago.format(now.subtract(difference));
    return answer;
  }

   void updateLikes(var index, var postid) async{
     var url = "https://serene-beach-48273.herokuapp.com/api/v1/posts/$postid/likes";
    if (my_posts[index]['liked'])
    {
      http.delete(url, headers: {HttpHeaders.authorizationHeader: "Bearer $token"}); 
      setState(() {
      my_posts[index]['likes_count']--;
      my_posts[index]['liked']=false;
    });
    }
    else{
      http.post(url, headers: {HttpHeaders.authorizationHeader: "Bearer $token"});
      setState(() {
      my_posts[index]['likes_count']++;
      my_posts[index]['liked']=true;
    });
    }
  }

  void showLikes(var postid) async{
    var url = "https://serene-beach-48273.herokuapp.com/api/v1/posts/$postid/likes";
    var response = await http.get(url, headers: {HttpHeaders.authorizationHeader: "Bearer $token"});
    var likes_json = jsonDecode(response.body);
    Navigator.push(context, MaterialPageRoute(builder: (context) => likesPage(likes_json, token)));
  }

  void showComments(postid) async{
    var url = "https://serene-beach-48273.herokuapp.com/api/v1/posts/$postid/comments";
    var response = await http.get(url, headers: {HttpHeaders.authorizationHeader: "Bearer $token"});
    var comments_json = jsonDecode(response.body);
    Navigator.push(context, MaterialPageRoute(builder: (context) => commentPage(comments_json, token, postid)));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child:Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(15),
                  child: Container(
                  width: 170,
                  height: 170,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      fit: BoxFit.fill,
                      image: NetworkImage(profile["profile_image_url"]),
                    ),
                  ),
                  ),
                ),
                Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.all(10),
                          child: Column(children: <Widget>[Text("100",style:TextStyle(fontWeight:FontWeight.bold,fontSize:25,color:Colors.white)),Text("Posts",style:TextStyle(color:Colors.grey),),],),
                        ),
                        Container(
                          padding: EdgeInsets.all(10),
                          child: Column(children: <Widget>[Text("500",style:TextStyle(fontWeight: FontWeight.bold, fontSize:25, color: Colors.white)),Text("Likes",style:TextStyle(color:Colors.grey),),],),
                        ),
                        Container(
                          padding: EdgeInsets.all(10),
                          child: Column(children: <Widget>[Text("25",style:TextStyle(fontWeight: FontWeight.bold, fontSize:25, color: Colors.white)),Text("Comments",style:TextStyle(color:Colors.grey),),],),
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        RaisedButton(
                            child: Text("Edit Profile"),
                            onPressed: (){
                              
                            },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(profile["email"],style:TextStyle(fontWeight:FontWeight.bold,fontSize:25,color:Colors.white)),
                      SizedBox(height: 5,),
                      Text("Member Since: "+updateTime(profile["created_at"]),style:TextStyle(color:Colors.white)),
                      SizedBox(height: 10,),
                      Text(profile["bio"],style:TextStyle(fontSize:20,color:Colors.white)),
                    ],
                  ),
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: my_posts.length,
                itemBuilder: (BuildContext context, int index){
                  return new Container(
                    child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Card(
                            elevation: 8,
                            child:Container(
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(color: Color.fromRGBO(64, 75, 96, .9)),
                              child: Column(
                                children: <Widget>[
                                  Row(children: <Widget>[
                                      Container(
                                      padding: EdgeInsets.all(15),
                                      child: Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                            fit: BoxFit.fill,
                                            image: NetworkImage(my_posts[index]["user_profile_image_url"]),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Text(my_posts[index]["user_email"], style:TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                    ],),SizedBox(height: 5,),
                                  Image.network(my_posts[index]["image_url"]),
                                  SizedBox(height: 5,),
                                  Text(my_posts[index]["caption"], style:TextStyle(color: Colors.white)),
                                ],
                              ), 
                            ),
                          ),
                          Container(
                            child:Row(
                              children: <Widget>[
                                IconButton(
                                  icon: Icon(Icons.thumb_up, color: my_posts[index]['liked']?Colors.grey:Colors.white),
                                  onPressed: (){
                                    updateLikes(index, my_posts[index]["id"]);
                                  },
                                ),
                                InkWell(
                                  child: Text("Liked by ", style: TextStyle(color: Colors.grey),),
                                  onTap: (){showLikes(my_posts[index]["id"]);},
                                ),
                                Text(my_posts[index]["likes_count"].toString(), style:TextStyle(color: Colors.white)),
                                IconButton(
                                  icon: Icon(Icons.chat_bubble_outline, color:Colors.white),
                                  onPressed: (){
                                    showComments(my_posts[index]["id"]);
                                  },
                                ),
                                Text(my_posts[index]["comments_count"].toString(), style:TextStyle(color: Colors.white)),
                                SizedBox(width: 125,),
                                Text(updateTime(my_posts[index]["created_at"]), style:TextStyle(color: Colors.white),),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}



class userProfilePage extends StatefulWidget {

  Map<String,dynamic> profile;
  List<dynamic> user_posts;
  var token;
  userProfilePage(this.profile, this.user_posts, this.token);
  @override
  _userProfilePageState createState() => _userProfilePageState(this.profile, this.user_posts, this.token);
}
class _userProfilePageState extends State<userProfilePage> {

  Map<String,dynamic> profile;
  List<dynamic> user_posts;
  var token;
  var commentController =TextEditingController();
  _userProfilePageState(this.profile, this.user_posts, this.token);

   String updateTime(String postedtime){
    final now = new DateTime.now();
    final difference = now.difference(DateTime.parse(postedtime));
    String answer = timeago.format(now.subtract(difference));
    return answer;
  }

   void updateLikes(var index, var postid) async{
    var url = "https://serene-beach-48273.herokuapp.com/api/v1/posts/$postid/likes";
    if (user_posts[index]['liked'])
    {
      http.delete(url, headers: {HttpHeaders.authorizationHeader: "Bearer $token"}); 
      setState(() {
      user_posts[index]['likes_count']--;
      user_posts[index]['liked']=false;
    });
    }
    else{
      http.post(url, headers: {HttpHeaders.authorizationHeader: "Bearer $token"});
      setState(() {
      user_posts[index]['likes_count']++;
      user_posts[index]['liked']=true;
    });
    }
  }

  void showLikes(var postid) async{
    var url = "https://serene-beach-48273.herokuapp.com/api/v1/posts/$postid/likes";
    var response = await http.get(url, headers: {HttpHeaders.authorizationHeader: "Bearer $token"});
    var likes_json = jsonDecode(response.body);
    Navigator.push(context, MaterialPageRoute(builder: (context) => likesPage(likes_json, token)));
  }

  void showComments(postid) async{
    var url = "https://serene-beach-48273.herokuapp.com/api/v1/posts/$postid/comments";
    var response = await http.get(url, headers: {HttpHeaders.authorizationHeader: "Bearer $token"});
    var comments_json = jsonDecode(response.body);
    Navigator.push(context, MaterialPageRoute(builder: (context) => commentPage(comments_json, token, postid)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
      appBar: AppBar(title: Text("Fluttergram"), centerTitle: true,),
      body: Container(
        child: Center(
          child:Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(15),
                    child: Container(
                    width: 170,
                    height: 170,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        fit: BoxFit.fill,
                        image: NetworkImage(profile["profile_image_url"]),
                      ),
                    ),
                    ),
                  ),
                  Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.all(10),
                            child: Column(children: <Widget>[Text("100",style:TextStyle(fontWeight:FontWeight.bold,fontSize:25,color:Colors.white)),Text("Posts",style:TextStyle(color:Colors.grey),),],),
                          ),
                          Container(
                            padding: EdgeInsets.all(10),
                            child: Column(children: <Widget>[Text("500",style:TextStyle(fontWeight: FontWeight.bold, fontSize:25, color: Colors.white)),Text("Likes",style:TextStyle(color:Colors.grey),),],),
                          ),
                          Container(
                            padding: EdgeInsets.all(10),
                            child: Column(children: <Widget>[Text("25",style:TextStyle(fontWeight: FontWeight.bold, fontSize:25, color: Colors.white)),Text("Comments",style:TextStyle(color:Colors.grey),),],),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(profile["email"],style:TextStyle(fontWeight:FontWeight.bold,fontSize:25,color:Colors.white)),
                        SizedBox(height: 5,),
                        Text("Member Since: "+updateTime(profile["created_at"]),style:TextStyle(color:Colors.white)),
                        SizedBox(height: 10,),
                        Text(profile["bio"],style:TextStyle(fontSize:20,color:Colors.white)),
                      ],
                    ),
                  ),
                ],
              ),
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: user_posts.length,
                  itemBuilder: (BuildContext context, int index){
                    return new Container(
                      child: Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Card(
                              elevation: 8,
                              child:Container(
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(color: Color.fromRGBO(64, 75, 96, .9)),
                                child: Column(
                                  children: <Widget>[
                                    Row(children: <Widget>[
                                        Container(
                                        padding: EdgeInsets.all(15),
                                        child: Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            image: DecorationImage(
                                              fit: BoxFit.fill,
                                              image: NetworkImage(user_posts[index]["user_profile_image_url"]),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Text(user_posts[index]["user_email"], style:TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                      ],),SizedBox(height: 5,),
                                    Image.network(user_posts[index]["image_url"]),
                                    SizedBox(height: 5,),
                                    Text(user_posts[index]["caption"], style:TextStyle(color: Colors.white)),
                                  ],
                                ), 
                              ),
                            ),
                            Container(
                              child:Row(
                                children: <Widget>[
                                  IconButton(
                                    icon: Icon(Icons.thumb_up, color: user_posts[index]['liked']?Colors.grey:Colors.white),
                                    onPressed: (){
                                      updateLikes(index, user_posts[index]["id"]);
                                    },
                                  ),
                                  InkWell(
                                    child: Text("Liked by ", style: TextStyle(color: Colors.grey),),
                                    onTap: (){showLikes(user_posts[index]["id"]);},
                                  ),
                                  Text(user_posts[index]["likes_count"].toString(), style:TextStyle(color: Colors.white)),
                                  IconButton(
                                    icon: Icon(Icons.chat_bubble_outline, color:Colors.white),
                                    onPressed: (){
                                      showComments(user_posts[index]["id"]);
                                    },
                                  ),
                                  Text(user_posts[index]["comments_count"].toString(), style:TextStyle(color: Colors.white)),
                                  SizedBox(width: 125,),
                                  Text(updateTime(user_posts[index]["created_at"]), style:TextStyle(color: Colors.white),),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



class PostFeed extends StatefulWidget {
  List<dynamic> posts;
  var token;
  PostFeed(this.posts, this.token);
  @override
  _PostFeedState createState() => _PostFeedState(posts,token);
}
class _PostFeedState extends State<PostFeed> {
  List<dynamic> posts;
  var token;
  _PostFeedState(this.posts, this.token);
  final commentController = TextEditingController();

  String updateTime(String postedtime){
    final now = new DateTime.now();
    final difference = now.difference(DateTime.parse(postedtime));
    String answer = timeago.format(now.subtract(difference));
    return answer;
  }

  void updateLikes(var index, var postid) async{
     var url = "https://serene-beach-48273.herokuapp.com/api/v1/posts/$postid/likes";
    if (posts[index]['liked'])
    {
      http.delete(url, headers: {HttpHeaders.authorizationHeader: "Bearer $token"}); 
      setState(() {
      posts[index]['likes_count']--;
      posts[index]['liked']=false;
    });
    }
    else{
      http.post(url, headers: {HttpHeaders.authorizationHeader: "Bearer $token"});
      setState(() {
      posts[index]['likes_count']++;
      posts[index]['liked']=true;
    });
    }
  }

  void showLikes(var postid) async{
    var url = "https://serene-beach-48273.herokuapp.com/api/v1/posts/$postid/likes";
    var response = await http.get(url, headers: {HttpHeaders.authorizationHeader: "Bearer $token"});
    var likes_json = jsonDecode(response.body);
    Navigator.push(context, MaterialPageRoute(builder: (context) => likesPage(likes_json, token)));
  }

  void showComments(postid) async{
    var url = "https://serene-beach-48273.herokuapp.com/api/v1/posts/$postid/comments";
    var response = await http.get(url, headers: {HttpHeaders.authorizationHeader: "Bearer $token"});
    var comments_json = jsonDecode(response.body);
    Navigator.push(context, MaterialPageRoute(builder: (context) => commentPage(comments_json, token, postid)));
  }

  void showUserProfile(var userid) async{
    var url = "https://serene-beach-48273.herokuapp.com/api/v1/users/$userid";
    var response = await http.get(url, headers: {HttpHeaders.authorizationHeader: "Bearer $token"});
    var userProfile = jsonDecode(response.body);
    var url2 = "https://serene-beach-48273.herokuapp.com/api/v1/users/$userid/posts";
    var response2 = await http.get(url2, headers: {HttpHeaders.authorizationHeader: "Bearer $token"});
    var userPosts =jsonDecode(response2.body);
    Navigator.push(context, MaterialPageRoute(builder: (context) => userProfilePage(userProfile, userPosts, token)));
  }

  @override
  Widget build(BuildContext context){
    var count = posts.length;
    return Container(
      child: ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: count,
      itemBuilder: (BuildContext context, int index){
        return new Container(
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Card(
                  elevation: 8,
                  child:Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(color: Color.fromRGBO(64, 75, 96, .9)),
                    child: Column(
                      children: <Widget>[
                        Row(children: <Widget>[
                            Container(
                              padding: EdgeInsets.all(15),
                              child: InkWell(
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                      fit: BoxFit.fill,
                                      image: NetworkImage(posts[index]["user_profile_image_url"]),
                                    ),
                                  ),
                                ),
                                onTap: (){showUserProfile(posts[index]["user_id"]);},
                              ),
                            ),
                            InkWell(
                              child: Text(posts[index]["user_email"], style:TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                              onTap: (){showUserProfile(posts[index]["user_id"]);},
                            ),
                          ],
                        ),
                        SizedBox(height: 5,),
                        Image.network(posts[index]["image_url"]),
                        SizedBox(height: 5,),
                        Text(posts[index]["caption"], style:TextStyle(color: Colors.white)),
                      ],
                    ), 
                  ),
                ),
                Container(
                  child:Row(
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.thumb_up, color: posts[index]['liked']?Colors.grey:Colors.white),
                        onPressed: (){
                          updateLikes(index, posts[index]["id"]);
                        },
                      ),
                      InkWell(
                        child: Text("Liked by ", style: TextStyle(color: Colors.grey),),
                        onTap: (){showLikes(posts[index]["id"]);},
                      ),
                      Text(posts[index]["likes_count"].toString(), style:TextStyle(color: Colors.white)),
                      IconButton(
                        icon: Icon(Icons.chat_bubble_outline, color:Colors.white),
                        onPressed: (){
                          showComments(posts[index]["id"]);
                        },
                      ),
                      Text(posts[index]["comments_count"].toString(), style:TextStyle(color: Colors.white)),
                      SizedBox(width: 125,),
                      Text(updateTime(posts[index]["created_at"]), style:TextStyle(color: Colors.white),),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ));
  }
}



class commentPage extends StatefulWidget {
  List<dynamic> comments_json;
  var token;
  var postid;
  commentPage(this.comments_json, this.token, this.postid);
  @override
  _commentPageState createState() => _commentPageState(comments_json,token,postid);
}
class _commentPageState extends State<commentPage> {
  List<dynamic> comments_json;
  var token;
  var postid;
  final commentController = new TextEditingController();
  _commentPageState(this.comments_json, this.token, this.postid);

  String updateTime(String postedtime){
    final now = new DateTime.now();
    final difference = now.difference(DateTime.parse(postedtime));
    String answer = timeago.format(now.subtract(difference));
    return answer;
  }

  void addComment(comment) async{
    var url = "https://serene-beach-48273.herokuapp.com/api/v1/posts/$postid/comments?text=$comment";
    http.post(url, headers: {HttpHeaders.authorizationHeader: "Bearer $token"});
    var url2 = "https://serene-beach-48273.herokuapp.com/api/v1/posts/$postid/comments";
    var response = await http.get(url2, headers: {HttpHeaders.authorizationHeader: "Bearer $token"});
    comments_json = jsonDecode(response.body);
    setState((){comments_json;});
  }

  void showUserProfile(var userid) async{
    var url = "https://serene-beach-48273.herokuapp.com/api/v1/users/$userid";
    var response = await http.get(url, headers: {HttpHeaders.authorizationHeader: "Bearer $token"});
    var userProfile = jsonDecode(response.body);
    var url2 = "https://serene-beach-48273.herokuapp.com/api/v1/users/$userid/posts";
    var response2 = await http.get(url2, headers: {HttpHeaders.authorizationHeader: "Bearer $token"});
    var userPosts =jsonDecode(response2.body);
    Navigator.push(context, MaterialPageRoute(builder: (context) => userProfilePage(userProfile, userPosts, token)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
      appBar: AppBar(title: Text("Fluttergram"), centerTitle: true,),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            TextField(
              controller: commentController,
              onSubmitted: (comment){
                addComment(comment);
                commentController.clear();
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Add Comment",
              ),
            ),
            SizedBox(height: 10,),
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: comments_json.length,
                itemBuilder: (BuildContext context, int index) {
                return new Container(
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Card(
                          elevation: 8,
                          child: Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(color: Color.fromRGBO(64, 75, 96, .9)),
                              child: Column(
                                children: <Widget>[
                                  Row(children: <Widget>[
                                    Container(
                                      padding: EdgeInsets.all(15),
                                      child: InkWell(
                                        child: Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            image: DecorationImage(
                                              fit: BoxFit.fill,
                                              image: NetworkImage(comments_json[index]["user"]["profile_image_url"]),
                                            ),
                                          ),
                                        ),
                                      onTap: (){showUserProfile(comments_json[index]["user_id"]);},
                                    ),
                                  ),
                                  InkWell(
                                    child: Text(comments_json[index]["user"]["email"], style:TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                    onTap: (){showUserProfile(comments_json[index]["user_id"]);},
                                  ),
                                  ],),
                                  Text(comments_json[index]["text"], style:TextStyle(color: Colors.white)),
                                  Text(updateTime(comments_json[index]["created_at"])),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}



class likesPage extends StatelessWidget {
  List<dynamic> likes_json;
  var token;
  var userImage;
  var userEmail;
  likesPage(this.likes_json, this.token);

  String updateTime(String postedtime){
    final now = new DateTime.now();
    final difference = now.difference(DateTime.parse(postedtime));
    String answer = timeago.format(now.subtract(difference));
    return answer;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
      appBar: AppBar(title: Text("Fluttergram"), centerTitle: true,),
      body: Container(
        padding: EdgeInsets.all(20),
        child: ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: likes_json.length,
          itemBuilder: (BuildContext context, int index) {
          return new Container(
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Card(
                    elevation: 8,
                    child: Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(color: Color.fromRGBO(64, 75, 96, .9)),
                        child: Column(
                          children: <Widget>[
                            Text(likes_json[index]["user_id"].toString(), style:TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                            Text(updateTime(likes_json[index]["created_at"]))
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}


class MyHomePageState extends State<MyHomePage>{
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final userIDController = TextEditingController();

  Future<String> login() async{
    String username = usernameController.text;
    String password = passwordController.text;
    String queryString = "?username=$username&password=$password";
    var url = "https://serene-beach-48273.herokuapp.com/api/login$queryString";
    var response = await http.get(Uri.encodeFull(url));
    var token = jsonDecode(response.body)["token"];
    return token;
  }

  void stuff(context) async{
    var token = await login();
    var allPosts = await getPosts(token);
    var my_posts = await myPosts(token);
    var profile = await getProfile(token);
    Navigator.push(context, MaterialPageRoute(builder: (context) => MyAppTab(allPosts, my_posts, profile, token)));
  }

  Future<dynamic> getProfile(token) async{
    var url = "https://serene-beach-48273.herokuapp.com/api/v1/my_account";
    var response = await http.get(url, headers: {HttpHeaders.authorizationHeader: "Bearer $token"});
    var profile_json = jsonDecode(response.body);
    return profile_json;
  }

  Future<List<dynamic>> getPosts(token) async{
    var url = "https://serene-beach-48273.herokuapp.com/api/v1/posts";
    var response = await http.get(url, headers: {HttpHeaders.authorizationHeader: "Bearer $token"});
    var posts_json = jsonDecode(response.body);
    return posts_json;
  }

  Future<List<dynamic>> getUserPosts(token) async{
    String user = userIDController.text;
    var url = "https://serene-beach-48273.herokuapp.com/api/v1/posts/$user";
    var response = await http.get(url, headers: {HttpHeaders.authorizationHeader: "Bearer $token"});
    var posts_json = jsonDecode(response.body);
    return posts_json;
  }

  Future<List<dynamic>> myPosts(token) async{
    var url = "https://serene-beach-48273.herokuapp.com/api/v1/my_posts";
    var response = await http.get(url, headers: {HttpHeaders.authorizationHeader: "Bearer $token"});
    var posts_json = jsonDecode(response.body);
    return posts_json;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('INSTA API LAB'), centerTitle: true,
      ),
      body: Container(
      padding: const EdgeInsets.all(20),
        child:Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Username",
                  hintText: 'Enter Username'
                ),
              ),
              SizedBox(height: 20,),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Password",
                  hintText: 'Enter Password'
                ),
              ),
              SizedBox(height: 20,),
              RaisedButton(
                onPressed: (){stuff(context);},
                child: Text("Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}