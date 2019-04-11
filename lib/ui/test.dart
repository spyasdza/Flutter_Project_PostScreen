import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class PostForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return PostFormState();
  }
}

class PostFormState extends State{
  File sampleImage;

  Future getImageGallery() async { //ฟังชั่นอัพโหลดรูป
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState((){
      sampleImage = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(

      appBar: new AppBar(
        centerTitle: true,
        title: Text("โพสต์")
      ),
      body: new Center (
        child:sampleImage==null? Text('Selecte an image'):enableUpload(),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: getImageGallery,
        tooltip: 'Add Image',
        child: new Icon(Icons.add),
      ),
    );
  }

  Widget enableUpload(){
    return Container(
      child: Column(
        children: <Widget>[
          Image.file(sampleImage, height: 300.0, width:300.0),
          RaisedButton(
              child: Text('Upload'),
              elevation: 7,
              textColor: Colors.white,
              color: Colors.blue,
              onPressed: () {
                final StorageReference firebaseStorageRef = FirebaseStorage.instance.ref().child('test');
                final StorageUploadTask task = firebaseStorageRef.putFile(sampleImage);
              },
            )
        ],),
    );
  }
}