import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_blog/view/ana_sayfa.dart';
import 'package:firebase_blog/view/kayit_screen.dart';
import 'package:flutter/material.dart';

class GirisScreen extends StatefulWidget {
  const GirisScreen({super.key});

  @override
  State<GirisScreen> createState() => _GirisScreenState();
}

class _GirisScreenState extends State<GirisScreen> {

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
      title: Text("Kayıt Ol Veya Giriş Yap",
        style: TextStyle(
          fontSize: 20,
          color: Colors.white

        ),
      ),
    );
  }

  Widget _buildBody(){
    return Center(
      child: Column(
        children: [
          SizedBox(height: 70,),
          Icon(Icons.supervised_user_circle,
          size: 150,
          color: Colors.blueGrey,
          ),
          SizedBox(height: 70,),
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              children: [
                Container(child: TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                   hintText: "   e-mail",
                  ),
                ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white54,
                  ),
                ),
                Container(child: TextFormField(
                  obscureText: true,
                  controller: _parolaController,
                  decoration: InputDecoration(
                    hintText: "   password"
                  ),
                ),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white54 ,
                  ),
                ),
              ],
            ),

          ),
          SizedBox(height: 50,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               ElevatedButton(
                  child: Text("Giriş Yap"),
                  onPressed: (){
                    _girisYap();
                  },
               ),
              SizedBox(width: 30,),
              ElevatedButton(
                child: Text("Kayıt Ol"),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(
                          builder: (context) => KayitScreen()
                      )
                  );
                }

              ),

            ],
          ),


        ],
      ),
    );
  }

  void _girisYap(){
    FirebaseAuth.instance
        .signInWithEmailAndPassword(email: _emailController.text, password: _parolaController.text)
        .then((kullanici){
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AnaSayfa())
      );
    });
  }

  void _kayitSayfaGit(BuildContext context){
    Navigator.push(context,
        MaterialPageRoute(
            builder: (context) => KayitScreen()
        )
    );
  }
}
