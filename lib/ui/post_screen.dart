import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fit_post/services/place_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:location/location.dart';
import 'package:flutter/services.dart';
import 'package:random_string/random_string.dart';

class PostForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return PostFormState();
  }
}

class PostFormState extends State {
  final _formKey = GlobalKey<FormState>();
  String post; // เนื้อหาของโพสต์
  File _image; // ไฟล์รูปภาพ
  static String tagged = ""; // สถานที่

  //ฟังชั่นถ่ายรูป
  Future getImageCamera() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      _image = image;
    });
  }

  //ฟังชั่นอัพโหลดรูป
  Future getImageGallery() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: <Widget>[
            //หัวเรื่อง
            OutlineButton(
                child: Text(
                  "สร้างโพสต์",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                onPressed: null,
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(10.0))),

            //กล่องข้อความในการโพสต์        
            TextFormField(
                decoration: InputDecoration(
                  hintText: "คุณกำลังคิดอะไรอยู่?",
                  contentPadding: new EdgeInsets.symmetric(vertical: 20.0),
                ),
                maxLines: null,

                //เช็คไม่ให้โพสต์ว่าง
                validator: (post) {
                  if (post.isEmpty) {
                    this.post = "";
                    return "โพสต์ของคุณว่างเปล่า";
                  } else {
                    this.post = post;
                  }
                }),

            //ปุ่มสำหรับกดเช็คอิน
            Row(
              children: <Widget>[
                FlatButton(
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.place,
                        color: Colors.grey,
                      ),
                      Text(
                        tagged == "" ? "เช็คอิน" : tagged,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  onPressed: () {
                    PlacesService.lat = currentLocation["latitude"];   //เซ็ต Latitude และ Longitude ใน PlaceService
                    PlacesService.long = currentLocation["longitude"];
                    Navigator.pushNamed(context, "/second");  //ย้ายไปหน้าแสดงสถานที่ในรัศมี 500 เมตร
                  },
                ),
              ],
            ),

            //แสดงรูปที่จะอัพโหลด
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10.0),
              child: _image == null
                  ? Image.asset("resources/noimage.jpg",
                      height: 100, width: 100)
                  : Image.file(
                      _image,
                      height: 100,
                      width: 100,
                    ),
              alignment: FractionalOffset.bottomLeft,
            ),

            //แถวสำหรับปุ่ม ถ่ายรูป และ อัพโหลดรูป
            Row(
              children: <Widget>[
                //ถ่ายรูป
                Container(
                  alignment: FractionalOffset.bottomLeft,
                  margin: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: OutlineButton(
                    child: Column(
                      children: <Widget>[
                        Icon(Icons.add_a_photo),
                      ],
                    ),
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(20.0)),
                    onPressed: () {
                      getImageCamera();
                    },
                  ),
                ),

                //อัพโหลดรูป
                Container(
                  alignment: FractionalOffset.bottomLeft,
                  margin: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: OutlineButton(
                    child: Column(
                      children: <Widget>[
                        Icon(Icons.file_upload),
                      ],
                    ),
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(20.0)),
                    onPressed: () {
                      getImageGallery();
                    },
                  ),
                ),
              ],
            ),

            //ปุ่มสำหรับอัพโหลดข้อมูลทั้งหมดลง Firebase
            Container(
              alignment: FractionalOffset.bottomRight,
              child: RaisedButton(
                child: Text(
                  "แชร์",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                color: Colors.blue,
                onPressed: () async {
                  _formKey.currentState.validate();

                  Firestore.instance.collection('posts').add({

                    'dateCreated': DateTime.parse(DateTime.now().toString()).millisecondsSinceEpoch, //วันที่โพสต์

                    'detail': post, //ข้อความที่โพสต์

                    'user': 'lhEcuY2c6hQCnKoJrpRtYyJzSfA3', //User สมมุติของ Q

                    'photo': await uploadImg(), //path ของรูป

                    'place': tagged //ชื่อสถานที่
                  });
                },
              ),
            ),

            //เช็ด Latitude และ Longitude (เดี๋ยวลบออก)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Lat/Lng: ${currentLocation["latitude"]} / ${currentLocation["longitude"]}',
                  style: TextStyle(fontSize: 20.0, color: Colors.blueAccent),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  //อัพโหลดรูปและ return path
  Future<String> uploadImg() async {
    var url = "";
    var imgName = randomAlphaNumeric(20);

    if(_image != null){
      final StorageReference firebaseStorageRef =
        FirebaseStorage.instance.ref().child('posts/${imgName}');
      final StorageUploadTask task = firebaseStorageRef.putFile(_image);

      var downUrl = await (await task.onComplete).ref.getPath();
      url = downUrl.toString();

      print(url);
    }

    Fluttertoast.showToast(
      msg: 'Upload Completed',
      toastLength: Toast.LENGTH_SHORT,
    );

    return url;
  }

  //Get latitude และ Longitude
  Map<String, double> currentLocation = new Map();
  StreamSubscription<Map<String, double>> locationSubscription;

  Location location = new Location();
  String error;

  @override
  void initState() {
    super.initState();

    //เซ็ต Latitude, Longitude ตอนเริ่มเป็น 0
    currentLocation['latitude'] = 0.0;
    currentLocation['longitude'] = 0.0;

    initPlatformState();
    locationSubscription = location.onLocationChanged().listen((Map<String, double> result) {
      setState(() {
        currentLocation = result;
      });
    });
    print(currentLocation);
  }

  void initPlatformState() async {
    Map<String, double> my_location;

    try {
      my_location = await location.getLocation();
      error = "";
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED')
        error = 'Permission denied';
      else if (e.code == 'PERMISSION_DENIED_NEVER_ASK')
        error =
            'Permission denied - please ask the user to enable it from the app setting';

      my_location = null;
    }

    setState(() {
      currentLocation = my_location;
    });
  }
}