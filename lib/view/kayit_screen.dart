import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_blog/view/ana_sayfa.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class KayitScreen extends StatefulWidget {
  const KayitScreen({super.key});

  @override
  State<KayitScreen> createState() => _KayitScreenState();
}

class _KayitScreenState extends State<KayitScreen> {

  TextEditingController _isimController = TextEditingController();
  TextEditingController _telNoController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _parolaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  AppBar _buildAppBar(){
    return AppBar(
      backgroundColor: Colors.blueGrey,
      centerTitle: true,
      title: Text("Kayıt Ol" ,
      style: TextStyle(
        fontSize: 20,
        color: Colors.white
      ),
      ),
    );
  }

  Widget _buildBody(){
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("İsim-Soyisim"),
              SizedBox(height: 10,),
              Container(child: TextFormField(
                controller: _isimController,
                decoration: InputDecoration(
                  hintText: "   Adınız",
                ),
              ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white54,
                ),
              ),
              SizedBox(height: 30,),
              Text("Telefon Numarası"),
              SizedBox(height: 10,),
              Container(child: TextFormField(
                controller: _telNoController,
                decoration: InputDecoration(
                  hintText: "   Telefon Numaranız",
                ),
              ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white54,
                ),
              ),
              SizedBox(height: 30,),
              Text("E-Mail Adresi"),
              SizedBox(height: 10,),
              Container(child: TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: "   E-Mail Adresiniz",
                ),
              ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white54,
                ),
              ),
              SizedBox(height: 30,),
              Text("Parola"),
              SizedBox(height: 10,),
              Container(child: TextFormField(
                controller: _parolaController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "   Parolanız",
                ),
              ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white54,
                ),
              ),
              SizedBox(height: 60,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  ElevatedButton(
                    child: Text("Giriş Yap"),
                    onPressed: () {
                      _girisYap();
                    },
                  ),
                     SizedBox(width: 30,),
                     ElevatedButton(
                      child: Text("Kayıt Ol"),
                      onPressed: () {
                        _kayitOL();
                      },
                    ),


                ],
              )

            ],
          ),
        ),
      ],

    );
  }

  Future<void> _kayitOL() async {

    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
          email: _emailController.text, password: _parolaController.text)
          .then((kullanici) {
        FirebaseFirestore.instance
            .collection("Kullanicilar")
            .doc(_emailController.text)
            .set({
          "kullaniciAdi": _isimController.text,
          "telefonNumarasi": _telNoController.text,
          "email": _emailController.text,
          "parola": _parolaController.text,

        });
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kayıt işlemi başarılı'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kayıt sırasında bir hata oluştu: $e'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _girisYap() async {
    try {
      UserCredential kullanici = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: _emailController.text,
        password: _parolaController.text,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AnaSayfa()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Giriş sırasında bir hata oluştu: $e'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }


}
