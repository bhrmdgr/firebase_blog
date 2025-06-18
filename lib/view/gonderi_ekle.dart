import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_blog/view/ana_sayfa.dart';
import 'package:firebase_blog/view/profil_sayfa.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class GonderiEkle extends StatefulWidget {
  const GonderiEkle({super.key});

  @override
  State<GonderiEkle> createState() => _GonderiEkleState();
}

class _GonderiEkleState extends State<GonderiEkle> {

  TextEditingController _gonderiBaslikController = TextEditingController();
  TextEditingController _gonderiAciklamaController = TextEditingController();

  final FirebaseAuth auth = FirebaseAuth.instance;
  File? yuklenecekDosya;
  String? indirmeBaglantisi;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
        title: Text("Gönderi Oluştur",
          style: TextStyle(
            color: Colors.white
          ),
        ),
        elevation: 2,
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 10,),
                Text("Gönderi Başlığı"),
                Card(child:
                Expanded(
                  child: TextFormField(
                    controller: _gonderiBaslikController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)
                      ),
                    ),
                  ),
                )
                  ,color: Colors.white,),
                SizedBox(height: 15,),
                Text("Gönderi Görseli"),
                Card(
                  child: indirmeBaglantisi == null ? Icon(Icons.photo, size: 250,color: Colors.grey) :
                  Image.network(indirmeBaglantisi!,
                    height: 250,
                    width: 250,
                    fit: BoxFit.cover,
                  ),
                ),
                ElevatedButton(
                  child: Text("Görsel Ekle"),
                  onPressed: (){
                    _galeridenGorselYukle();
                  }
                  ,),
                SizedBox(height: 10,),
                Text("Açıklama Ekle"),
                SizedBox(height: 10,),
                TextFormField(
                  controller: _gonderiAciklamaController,
                    maxLines: 7,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)
                      ),
                  
                    ),
                  ),
                SizedBox(height: 50,),
                ElevatedButton(
                  child: Text("Gönderiyi Oluştur"),
                  onPressed: (){
                    _gonderiyiOlustur();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => AnaSayfa()),
                          (Route<dynamic> route) => true,

                    );
                  }
                  ,)
        
                /*ElevatedButton(
                  child: Text("Video Yükle"),
                  onPressed: (){
                    _kameradanVideoYukle();
                  },
                ),*/
              ],
            ),
      ),
    );
  }

  Future<void> _galeridenGorselYukle() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? alinanGorsel = await _picker.pickImage(source: ImageSource.gallery);

    if (alinanGorsel != null) {
      setState(() {
        yuklenecekDosya = File(alinanGorsel.path);
      });

      try {
        Reference referansYol = FirebaseStorage.instance
            .ref()
            .child("gorseller")
            .child(auth.currentUser!.uid)
            .child(_gonderiBaslikController.text)
            .child("myImage.png");

        UploadTask yuklemeGorevi = referansYol.putFile(yuklenecekDosya!);

        TaskSnapshot snapshot = await yuklemeGorevi;
        String url = await snapshot.ref.getDownloadURL();

        setState(() {
          indirmeBaglantisi = url;
        });
      } catch (e) {
        print("Dosya yükleme hatası: $e");
      }
    }
  }

  Future<void> _gonderiyiOlustur() async {
    var kullaniciId = auth.currentUser?.uid;

    await FirebaseFirestore.instance
        .collection("Kullanicilar")
        .doc(auth.currentUser?.email.toString())
        .collection("gonderiler")
        .doc(_gonderiBaslikController.text)
        .set({
      "gonderiBasligi": _gonderiBaslikController.text,
      "gonderiAciklamasi": _gonderiAciklamaController.text,
      "kullaniciId": kullaniciId,
      "gonderiGorselUrl": indirmeBaglantisi,
    });
  }


}

