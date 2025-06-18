import 'package:flutter/material.dart';

class GonderiDetay extends StatelessWidget {
  final Map<String, dynamic> gonderiData;
  final String gonderiId;

  GonderiDetay({required this.gonderiData, required this.gonderiId});


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: _buildBody(context),
    );
  }



  Widget _buildBody(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Şeffaf AppBar benzeri yapı
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 80, // Yükseklik
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3), // Şeffaf arka plan
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.of(context).pop(); // Geri gitme işlemi
                    },
                  ),
                  SizedBox(width: 48), // IconButton genişliği kadar
                ],
              ),
            ),
          ),
          // Görsel
          Positioned(
            top: 60,  // Görselin ekranda biraz aşağıda yer almasını sağlar
            child: Image.network(
              gonderiData['gonderiGorselUrl'],
              width: MediaQuery.of(context).size.width,
              height: 400,
              fit: BoxFit.cover,
            ),
          ),
          // İçerik
          Positioned(
            top: 400,  // Görselin altında içerik görünür
            left: 10,
            right: 10,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.0), // Köşelere borderRadius ekler
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 5), // Gölge efekti
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        gonderiData['gonderiBasligi'] ?? '',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      gonderiData['gonderiAciklamasi'],
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
