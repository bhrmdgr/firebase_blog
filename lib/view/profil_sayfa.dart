import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_blog/view/ana_sayfa.dart';
import 'package:firebase_blog/view/gonderi_detay.dart';
import 'package:firebase_blog/view/profili_duzenle.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'giris_screen.dart';
import 'gonderi_ekle.dart';

class ProfilSayfa extends StatefulWidget {
  const ProfilSayfa({super.key});

  @override
  State<ProfilSayfa> createState() => _ProfilSayfaState();
}

class _ProfilSayfaState extends State<ProfilSayfa> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  File? yuklenecekDosya;
  String? indirmeBaglantisi;

  String? kullaniciAdi;
  String? kullaniciMail;
  String? kullaniciTel;
  String? kullaniciSifre;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => baglantiAl());
    WidgetsBinding.instance.addPostFrameCallback((_) => _kullaniciBilgileriniGetir());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => GonderiEkle()),
                (Route<dynamic> route) => true,
          );
        },
      ),
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => AnaSayfa()), // Ana sayfa widget'ınızı buraya ekleyin
                (Route<dynamic> route) => false,
          );
        },
      ),
      centerTitle: true,
      title: Text(
        "Profilim",
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.blueGrey,
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.exit_to_app),
          color: Colors.white,
          onPressed: () {
            _oturumuKapatOnay(context);
          },
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Column(children: [
      SizedBox(
        height: 30,
      ),
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
      SizedBox(
        height: 20,
      ),
      Text(kullaniciAdi.toString()),
      SizedBox(
        height: 5,
      ),
      Text(kullaniciMail.toString()),
      SizedBox(
        height: 20,
      ),
      /*Text(kullaniciTel.toString()),
      SizedBox(
        height: 20,
      ),*/
      ElevatedButton(
        child: Text("Profilimi Düzenle"),
        onPressed: _profilDuzenleSayfasinaGec,
      ),
      SizedBox(
        height: 20,
      ),
      Text(
        "Gönderilerim",
        style: TextStyle(
          fontSize: 18,
        ),
      ),
      Divider(
        color: Colors.grey, // Çizginin rengi
        thickness: 1, // Çizginin kalınlığı
        indent: 20, // Başlangıç tarafındaki boşluk
        endIndent: 20, // Bitiş tarafındaki boşluk
      ),
      SizedBox(height: 20),
      Expanded(
        child: _buildGonderiler(),
      ),
    ]);
  }

  Widget _buildGonderiler() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("Kullanicilar")
          .doc(auth.currentUser?.email.toString())
          .collection("gonderiler")
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Bir hata oluştu: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('Gönderi bulunamadı.'));
        }

        var gonderiler = snapshot.data!.docs;

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 4.0,
            mainAxisSpacing: 4.0,
          ),
          itemCount: gonderiler.length,
          itemBuilder: (context, index) {
            var gonderiData = gonderiler[index].data() as Map<String, dynamic>;
            var gonderiId = gonderiler[index].id; // Gönderi ID'sini alın
            var gonderiBasligi = gonderiData["gonderiBasligi"];
            var gonderiAciklamasi = gonderiData["gonderiAciklamasi"];
            var gonderiGorselUrl = gonderiData["gonderiGorselUrl"];

            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GonderiDetay(
                        gonderiData: gonderiData, gonderiId: gonderiId),
                  ),
                );
              },
              child: SingleChildScrollView(
                child: Card(
                  elevation: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (gonderiGorselUrl != null &&
                          gonderiGorselUrl.isNotEmpty)
                        Card(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              gonderiGorselUrl,
                              height: 106,
                              width: 200,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                    child: Text('Görsel yüklenemedi'));
                              },
                            ),
                          ),
                        )
                      else
                        Center(child: Text('Görsel mevcut değil')),
                      Text(
                        gonderiBasligi ?? 'Başlık Yok',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        gonderiAciklamasi ?? 'Açıklama Yok',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _gonderiSilOnay(context, gonderiId);
                        },
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
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

  void _profilDuzenleSayfasinaGec() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => ProfiliDuzenle()),
          (Route<dynamic> route) => false,
    );
  }

  void _oturumuKapatOnay(BuildContext context){
    showDialog(
        context: context,
        builder: (BuildContext context){
         return AlertDialog(
           title: Text("Oturumu Kapat"),
           content: Text("Çıkış yapmak istediğinize emin misiniz") ,
           actions: [
             TextButton(
               child: Text("İptal"),
               onPressed: () {
                 Navigator.of(context).pop();
               },
             ),
             TextButton(
               child: Text("Çıkış yap"),
               onPressed: () {
                 _oturumuKapat(context);
                 Navigator.of(context).pop();
               },
             ),

           ],
         );
        }
    );
  }

  void _oturumuKapat(BuildContext context) {
    FirebaseAuth.instance.signOut().then((_) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => GirisScreen()),
            (Route<dynamic> route) => false,
      );
    });
  }

  void _gonderiSilOnay(BuildContext context, String gonderiId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Gönderiyi Sil"),
          content: Text("Bu gönderiyi silmek istediğinize emin misiniz?"),
          actions: [
            TextButton(
              child: Text("İptal"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Sil"),
              onPressed: () {
                _gonderiSil(gonderiId);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _gonderiSil(String gonderiId) async {
    try {
      // Firestore'dan gönderiyi sil
      await FirebaseFirestore.instance
          .collection("Kullanicilar")
          .doc(auth.currentUser?.email.toString())
          .collection("gonderiler")
          .doc(gonderiId)
          .delete();

      // Firebase Storage'dan gönderiye ait görseli sil (varsa)
      await FirebaseStorage.instance
          .ref()
          .child("gonderiResimleri")
          .child(auth.currentUser!.uid)
          .child("$gonderiId.png")
          .delete();
    } catch (e) {
      print("Gönderi silme hatası: $e");
    }
  }

  void _kullaniciBilgileriniGetir() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final userData = await FirebaseFirestore.instance
          .collection('Kullanicilar')
          .doc(user.email)
          .get();

      setState(() {
        kullaniciAdi = userData['kullaniciAdi'] ?? 'Ad bilgisi eksik';
        kullaniciMail = user.email ?? 'Mail bilgisi eksik';
        kullaniciTel = userData['kullaniciTel'] ?? 'Telefon bilgisi eksik';
        kullaniciSifre = userData['kullaniciSifre'] ?? 'Şifre bilgisi eksik';
      });
    }
  }
}
