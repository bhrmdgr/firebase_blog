import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_blog/view/profil_sayfa.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfiliDuzenle extends StatefulWidget {
  @override
  State<ProfiliDuzenle> createState() => _ProfiliDuzenleState();
}

class _ProfiliDuzenleState extends State<ProfiliDuzenle> {
  TextEditingController _isimController = TextEditingController();
  TextEditingController _telNoController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _parolaController = TextEditingController();

  String? kullaniciAdi;
  String? kullaniciMail;
  String? kullaniciTel;
  String? kullaniciSifre;

  final FirebaseAuth auth = FirebaseAuth.instance;
  File? yuklenecekDosya;
  String? indirmeBaglantisi;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _kullaniciBilgileriniGetir();
      baglantiAl();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),

    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      centerTitle: true,
      title: Text("Profilimi Düzenle",
        style: TextStyle(
          color: Colors.white
        ),
      ),
      backgroundColor: Colors.blueGrey,
      elevation: 2,
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => ProfilSayfa()),
                (Route<dynamic> route) => false,
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 50),
          ClipOval(
            child: indirmeBaglantisi == null
                ? Icon(Icons.person, size: 150, color: Colors.grey)
                : Image.network(
              indirmeBaglantisi!,
              height: 170,
              width: 170,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 25),
          ElevatedButton(
            child: Text("Profil Resmi Güncelle"),
            onPressed: _galeridenYukle,
          ),
          SizedBox(height: 50),
          _kullaniciBilgileri(),
          SizedBox(height: 60),
          ElevatedButton(
            child: Text("Bilgileri Kaydet"),
            onPressed: (){
              _bilgileriKaydet();
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => ProfilSayfa()),
                    (Route<dynamic> route) => false);
            },
          )
        ],
      ),
    );
  }

  Widget _kullaniciBilgileri() {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Container(
              child: TextFormField(
                controller: _isimController..text = kullaniciAdi ?? '',
                decoration: InputDecoration(
                  hintText: "Kullanıcı Adı",
                ),
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white70,
              ),
            ),
            SizedBox(height: 20),
            Container(
              child: TextFormField(
                controller: _emailController..text = kullaniciMail ?? '',
                decoration: InputDecoration(
                  hintText: "Email",
                ),
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white70,
              ),
            ),
            SizedBox(height: 20),
            Container(
              child: TextFormField(
                controller: _telNoController..text = kullaniciTel ?? '',
                decoration: InputDecoration(
                  hintText: "Telefon Numarası",
                ),
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white70,
              ),
            ),
            SizedBox(height: 20),
            Container(
              child: TextFormField(
                controller: _parolaController,
                decoration: InputDecoration(
                  hintText: "Parola",
                ),
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white70,
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _galeridenYukle() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? alinanGorsel = await _picker.pickImage(source: ImageSource.gallery);

    if (alinanGorsel != null) {
      setState(() {
        yuklenecekDosya = File(alinanGorsel.path);
      });

      try {
        Reference referansYol = FirebaseStorage.instance
            .ref()
            .child("profilResimleri")
            .child(auth.currentUser!.uid)
            .child("profilResmi.png");

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

  Future<void> _bilgileriKaydet() async {
    // Mevcut kullanıcı verilerini al
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection("Kullanicilar")
        .doc(auth.currentUser?.email)
        .get();

    // Mevcut verileri değişkenlere ata, eğer kontrolörler boşsa
    String yeniKullaniciAdi = _isimController.text.isNotEmpty
        ? _isimController.text
        : snapshot["kullaniciAdi"];
    String yeniEmail = _emailController.text.isNotEmpty
        ? _emailController.text
        : snapshot["email"];
    String yeniTelefonNumarasi = _telNoController.text.isNotEmpty
        ? _telNoController.text
        : snapshot["telefonNumarasi"];
    String yeniParola = _parolaController.text.isNotEmpty
        ? _parolaController.text
        : snapshot["parola"];

    // Güncelleme yap
    await FirebaseFirestore.instance
        .collection("Kullanicilar")
        .doc(auth.currentUser?.email)
        .update({
      "kullaniciAdi": yeniKullaniciAdi,
      "email": yeniEmail,
      "telefonNumarasi": yeniTelefonNumarasi,
      "parola": yeniParola,
    });
  }


  void baglantiAl() async {
    try {
      String baglanti = await FirebaseStorage.instance
          .ref()
          .child("profilResimleri")
          .child(auth.currentUser!.uid)
          .child("profilResmi.png")
          .getDownloadURL();

      setState(() {
        indirmeBaglantisi = baglanti;
      });
    } catch (e) {
      print("Profil resmi alma hatası: $e");
    }
  }

  void _kullaniciBilgileriniGetir() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection("Kullanicilar")
        .doc(auth.currentUser?.email)
        .get();

    setState(() {
      kullaniciAdi = snapshot["kullaniciAdi"];
      kullaniciMail = snapshot["email"];
      kullaniciTel = snapshot["telefonNumarasi"];
      kullaniciSifre = snapshot["parola"];

      _isimController.text = kullaniciAdi ?? '';
      _emailController.text = kullaniciMail ?? '';
      _telNoController.text = kullaniciTel ?? '';
    });
  }
}
