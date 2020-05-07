import 'package:flutter/material.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:tflite/tflite.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import 'dart:async';
void main() =>
    runApp(MaterialApp(
      navigatorKey: nav,
      title: "Covid",
      home: new MyApp(),
      theme: ThemeData(brightness: Brightness.dark, fontFamily: 'Carter'),
      debugShowCheckedModeBanner: false,
    ));

final GlobalKey<NavigatorState> nav = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return new SplashScreen(
      title: new Text(
        'Welcome',
        style: new TextStyle(
            fontWeight: FontWeight.bold, fontSize: 20.0, color: Colors.blueGrey),
      ),
      photoSize: 120.0,
      seconds: 6,
      backgroundColor: Colors.black,
      image: Image.network(
        "https://www.metodogabla.com/wp-content/uploads/CORONAVIRUS-GABLA-ACT-300x300.png",
      ),
      navigateAfterSeconds: new AfterSplash(),
    );
  }
}

class AfterSplash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      theme: ThemeData(brightness: Brightness.dark, fontFamily: 'Carter'),
      home: homePage(),
    );
  }
}

class homePage extends StatefulWidget{
  @override
  _AppState createState()=>_AppState();
}

class _AppState extends State<homePage>{
//VARIABLES DE CONTROL
  List _salidas;
  File _Imagen;
  bool _isLoading = false;

  @override
  void initState(){
    super.initState();
    _isLoading = true;
    loadModel().then((value){
      setState(() {
        _isLoading = false;
      });
    });

  }

  @override
  Widget build(BuildContext context) {
// TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("IMAGE RECOGNITION COVID"),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: _isLoading ? Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ): Container(
        width: MediaQuery.of(context).size.width,//Ajusta a ancho de pantalla
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _Imagen == null ? Container():Image.file(_Imagen),
            SizedBox(
              height: 20,
            ),
            _salidas != null ? Text("${_salidas[0]["label"]}",
              style: TextStyle(
                color: Colors.black,
                fontSize: 30.0,
                background: Paint()..color = Colors.blue,
              ),
            )
                : Container()
          ],
        ),

      ),
      floatingActionButton: SpeedDial(
        backgroundColor: Colors.purpleAccent,
        animatedIcon: AnimatedIcons.menu_close,
        children: [
          SpeedDialChild(
              child: Icon(Icons.camera),
              backgroundColor: Colors.yellow[700],
              onTap: getImage
          ),
          SpeedDialChild(
              child: Icon(Icons.image),
              backgroundColor: Colors.green[500],
              onTap: pickImage
          ),
          SpeedDialChild(
              child: Icon(Icons.arrow_back),
              backgroundColor: Colors.cyan[300],
              onTap: goBack
          )
        ],
      ),
      endDrawer: Drawer(
        elevation: 16.0,
        child: ListView(
          children: const <Widget>[
            DrawerHeader(
              child: Text("Datos Personales:",
                  style: TextStyle(fontFamily: 'Carter', fontSize: 25)),
              decoration: BoxDecoration(color: Colors.cyan),
            ),
            ListTile(
              title: Text(
                "+  Paulina Lizeth Escorcia Diaz",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
              ),
            ),
            ListTile(
                title: Text(
                  "+  TI 41",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                )),
            ListTile(
                title: Text(
                  "+  1718110950",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                )),
          ],
        ),
      ),
    );
  }


  getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    if(image == null) return null;
    setState(() {
      _isLoading = true;
      _Imagen = image;
    });

    clasificar(image);
  }



  pickImage() async {
    var imagen = await ImagePicker.pickImage(source: ImageSource.gallery);
    if(imagen == null) return null;
    setState(() {
      _isLoading = true;
      _Imagen = imagen;
    });

    clasificar(imagen);
  }

  goBack() async {
    setState(() {
      Navigator.push(context,
          new MaterialPageRoute(
              builder: (context)
              => new homePage() ));
    });
  }

  clasificar(File image) async{
    var output = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 5,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      _isLoading = false;
      _salidas = output;
    });
  }


  loadModel() async{
    await Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt",
    );
  }
  @override
  void dispose(){
    Tflite.close();
    super.dispose();
  }

}