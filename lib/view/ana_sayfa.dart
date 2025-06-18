import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'profil_sayfa.dart';
import 'gonderi_detay.dart';

class AnaSayfa extends StatefulWidget {
  const AnaSayfa({super.key});

  @override
  State<AnaSayfa> createState() => _AnaSayfaState();
}

class _AnaSayfaState extends State<AnaSayfa> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.blueGrey,
      centerTitle: true,
      title: Text(
        "Ana Sayfa",
        style: TextStyle(
          fontSize: 20,
          color: Colors.white,
        ),
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.person),
          color: Colors.white,
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => ProfilSayfa()),
                  (Route<dynamic> route) => true,
            );
          },
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: StreamBuilder<List<DocumentSnapshot>>(
        stream: _getAllPostsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Bir hata oluştu: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Gönderi bulunamadı.'));
          }

          var allPosts = snapshot.data!;

          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              crossAxisSpacing: 4.0,
              mainAxisSpacing: 4.0,
            ),
            itemCount: allPosts.length,
            itemBuilder: (context, index) {
              var gonderiData = allPosts[index].data() as Map<String, dynamic>;
              var gonderiId = allPosts[index].id; // Gönderi ID'sini alın
              var gonderiBasligi = gonderiData["gonderiBasligi"];
              var gonderiAciklamasi = gonderiData["gonderiAciklamasi"];
              var gonderiGorselUrl = gonderiData["gonderiGorselUrl"];

              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GonderiDetay(gonderiData: gonderiData, gonderiId: gonderiId),
                    ),
                  );
                },
                child: SingleChildScrollView(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (gonderiGorselUrl != null && gonderiGorselUrl.isNotEmpty)
                          Card(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                gonderiGorselUrl,
                                height: 300,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(child: Text('Görsel yüklenemedi'));
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
                        Padding(
                          padding: const EdgeInsets.all(25.0),
                          child: Text(
                            gonderiAciklamasi ?? 'Açıklama Yok',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
              );
            },
          );
        },
      ),
    );
  }

  Stream<List<DocumentSnapshot>> _getAllPostsStream() {
    return FirebaseFirestore.instance
        .collection("Kullanicilar")
        .snapshots()
        .asyncMap((usersSnapshot) async {
      List<DocumentSnapshot> allPosts = [];

      for (var userDoc in usersSnapshot.docs) {
        var email = userDoc.id;
        var postsSnapshot = await FirebaseFirestore.instance
            .collection("Kullanicilar")
            .doc(email)
            .collection("gonderiler")
            .get();

        allPosts.addAll(postsSnapshot.docs);
      }

      return allPosts;
    });
  }
}
