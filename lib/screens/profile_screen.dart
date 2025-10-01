import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:lottie/lottie.dart';

String cleanResponse(String response) {
  try {
    return utf8.decode(response.runes.toList());
  } catch (e) {
    print('cleanResponse error: $e');
    return response; // fallback: bozulmadan döndür
  }
}

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 13, 13, 14),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(0, 0, 0, 1),
        title: Text("", style: TextStyle(color: Colors.black)),
        iconTheme: IconThemeData(
            color: const Color.fromARGB(255, 255, 255, 255), size: 30),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.red, size: 30),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          )
        ],
      ),
      body: Stack(
        children: [
          // Positioned.fill(
          //     child: Image.asset(
          //   'assets/img/harita10.jpg',
          //   fit: BoxFit.cover,
          // )),
          Container(
            // decoration: BoxDecoration(
            //   gradient: LinearGradient(
            //     colors: [
            //       Color.fromRGBO(247, 203, 202, 1),
            //       Color.fromRGBO(141, 215, 219, 1),
            //     ],
            //     begin: Alignment.topLeft,
            //     end: Alignment.bottomRight,
            //   ),
            // ),
            child: user == null
                ? Center(child: Text('Giriş yapılmamış'))
                : Column(
                    children: [
                      // ✅ 1️⃣ PROFİL BİLGİLERİ
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            Lottie.asset('assets/person.json',
                                width: 150, height: 150, repeat: false),
                            // Icon(Icons.person, size: 100, color: Colors.white),
                            SizedBox(height: 20),
                            Text(user.displayName ?? "Bilinmiyor",
                                style: TextStyle(
                                    fontSize: 24,
                                    color: const Color.fromARGB(
                                        255, 255, 255, 255))),
                            Text(user.email ?? "Email bulunamadı",
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white)),
                            SizedBox(height: 20),

                            // IconButton(
                            //   icon: Icon(Icons.logout, color: Colors.red, size: 30),
                            //   onPressed: () async {
                            //     await FirebaseAuth.instance.signOut();
                            //     Navigator.pushReplacementNamed(context, '/login');
                            //   },
                            // )

                            // ElevatedButton(
                            //   onPressed: () async {
                            //     await FirebaseAuth.instance.signOut();
                            //     Navigator.pushReplacementNamed(context, '/');
                            //   },

                            //   child: Text(
                            //     "Çıkış Yap",
                            //     style: TextStyle(color: Colors.white),
                            //   ),
                            //   style: ElevatedButton.styleFrom(
                            //     backgroundColor: Colors.black,
                            //     padding: EdgeInsets.symmetric(
                            //         horizontal: 40, vertical: 14),
                            //     shape: RoundedRectangleBorder(
                            //         side: BorderSide(color: Colors.red, width: 3.0),
                            //         borderRadius: BorderRadius.circular(12)),
                            //   ),
                            // ),
                          ],
                        ),
                      ),

                      Divider(),

                      // ✅ 2️⃣ ARAMA GEÇMİŞİ
                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.uid)
                              .collection('searchHistory')
                              .orderBy('searchedAt', descending: true)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            }
                            if (!snapshot.hasData ||
                                snapshot.data!.docs.isEmpty) {
                              return Center(
                                  child: Text(
                                'Henüz arama geçmişi yok',
                                style: TextStyle(color: Colors.white),
                              ));
                            }
                            return ListView.builder(
                              itemCount: snapshot.data!.docs.length,
                              itemBuilder: (context, index) {
                                final doc = snapshot.data!.docs[index];
                                final businessName = doc['businessName'];
                                final summary = doc['summary'];

                                return Card(
                                  color: Colors.white,
                                  // shape: RoundedRectangleBorder(
                                  //     side: BorderSide(
                                  //         color: Colors.lightGreen, width: 3.0),
                                  //     borderRadius: BorderRadius.circular(12)),
                                  margin: EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 16),
                                  child: ListTile(
                                    title: Text(businessName),
                                    subtitle: Text(
                                      cleanResponse(
                                        summary.length > 100
                                            ? '${summary.substring(0, 100)}...'
                                            : summary,
                                      ),
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              SearchDetailScreen(
                                            businessName: businessName,
                                            summary: summary,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

// ✅ DETAY SAYFASI:
class SearchDetailScreen extends StatelessWidget {
  final String businessName;
  final String summary;

  const SearchDetailScreen({
    Key? key,
    required this.businessName,
    required this.summary,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(businessName)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(cleanResponse(summary)),
      ),
    );
  }
}
