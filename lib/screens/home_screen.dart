import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lottie/lottie.dart';
import 'package:smart/services/google_place_service.dart';
import 'package:smart/services/openai_service.dart';
import 'dart:convert';

// uygulamada metin turundeki bazı karakterlerin duzgun yazilabilmesi icin "uft8" cagırılır
String cleanResponse(String response) {
  return utf8.decode(response.runes.toList());
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Class yapisi icerisindeki kullanılacak degiskenler tanimlanir
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _reviews = [];
  List<dynamic> _photos = [];
  late GooglePlaceService _googlePlaceService;
  late OpenAIService _openAIService;
  String? _summary;

  // Kullanacagimiz API keyleri uygulama calistiğinde burada cagiriyoruz
  @override
  void initState() {
    super.initState();
    // Yorumlari cekebilmek icin "google place api" keyini tanimliyoruz
    _googlePlaceService =
        GooglePlaceService(dotenv.env['Google_Maps_API_Key']!);
    // verileri yorumlatabilmek icin kullanacagimiz yapayzeka keyimizi yaziyoruz
    _openAIService = OpenAIService(dotenv.env['Open_Ai_API_Key']!);
  }

  // Burada bir method tanimliyoruz bu method isletmenin adini girdigimizde o isletmenin place id'sini buluyor ve place api ile o isletmeye ait yorumlari cekiyor
  void searchBusiness(String businessName) async {
    // burada try-cacth yapisi ile place id'yi try icerisindeki if yapilanmasinin icerisine giriyor bulamaz ise cacth ile hata mesaji veriyor
    try {
      final placeId = await _googlePlaceService.fetchPlaceId(businessName);
      if (placeId != null) {
        final details = await _googlePlaceService.fetchPlaceDetails(placeId);
        setState(() {
          _reviews = details['reviews'];
          _photos = details['photos'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('İşletme bulunamadı')),
        );
      }

      if (_reviews.isNotEmpty) {
        final reviewTexts = _reviews
            .map<String>((r) => r['text'] as String? ?? '')
            .where((text) => text.isNotEmpty)
            .toList();

        final summary = await _openAIService.summarizeReviews(reviewTexts);
        setState(() {
          _summary = cleanResponse(summary);
        });

        // Yapilan aramalari firestore database'e kaydediyor profil kisminda gosterebilmek icin
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('searchHistory')
              .add({
            'businessName': businessName,
            'summary': summary,
            'searchedAt': Timestamp.now(),
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
      );
    }
  }

//Yaptigimiz arama kayitlarini tamizlemek icin bir butonumuz var bu butona atamak icin bir method yazılır bütün arama sonuclarını siler ama database'den silmez
  void _clearResults() {
    setState(() {
      _summary = null;
      _reviews.clear();
      _photos.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isSearching =
        _summary != null || _reviews.isNotEmpty || _photos.isNotEmpty;

// Scaffold yani uygulamamizin arka perde yapisini hazirlar arka plan, islemler vs herşey burada gozukur
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Color.fromARGB(245, 0, 0, 0),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.6,
              child: Image.asset(
                'assets/img/harita10.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(55, 255, 0, 0),
            child: Lottie.asset('assets/point.json',
                width: 50, height: 50, repeat: true),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: isSearching
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: Icon(Icons.person, size: 40),
                      color: Colors.white,
                      onPressed: () {
                        Navigator.pushNamed(context, '/profile');
                      },
                    ),
                  ),
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "İşletme Adını Tam Giriniz...",
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      final input = _searchController.text.trim();
                      if (input.isNotEmpty) {
                        FocusScope.of(context).unfocus();
                        searchBusiness(input);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text("Lütfen bir işletme adı girin")),
                        );
                      }
                    },
                    icon: Icon(Icons.search, color: Colors.black),
                    label: Text("ARA",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromRGBO(247, 203, 202, 1),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  if (isSearching)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: _clearResults,
                          icon: Icon(Icons.close,
                              color: const Color.fromARGB(255, 0, 0, 0)),
                          label: Text("Temizle",
                              style: TextStyle(
                                  color: const Color.fromARGB(255, 0, 0, 0))),
                          style: TextButton.styleFrom(
                            backgroundColor:
                                const Color.fromRGBO(247, 203, 202, 1),
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  if (isSearching) Expanded(child: _buildSearchResults()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return ListView(
      children: [
        if (_summary != null) _buildSectionTitle('Yapay Zeka Yorumu'),
        if (_summary != null) _buildSummaryCard(),
        if (_photos.isNotEmpty) _buildSectionTitle('Fotoğraflar'),
        if (_photos.isNotEmpty) _buildPhotoList(),
        if (_reviews.isNotEmpty) _buildSectionTitle('Yorumlar'),
        if (_reviews.isNotEmpty) ..._reviews.map(_buildReviewCard).toList(),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      color: const Color.fromRGBO(241, 247, 247, 1),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: const Color.fromARGB(255, 0, 0, 0), width: 3.0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text('$_summary',
            style: TextStyle(
                fontSize: 16, color: const Color.fromARGB(255, 0, 0, 0))),
      ),
    );
  }

  Widget _buildPhotoList() {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _photos.length,
        itemBuilder: (context, index) {
          final photoReference = _photos[index]['photo_reference'];
          final photoUrl =
              'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=$photoReference&key=${_googlePlaceService.apiKey}';

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                    color: const Color.fromARGB(255, 0, 0, 0), width: 3.0),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(255, 0, 0, 0).withOpacity(1),
                    spreadRadius: 2,
                    blurRadius: 10,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  photoUrl,
                  fit: BoxFit.cover,
                  width: 300,
                  height: 200,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildReviewCard(dynamic review) {
    return Card(
      color: const Color.fromRGBO(241, 247, 247, 1),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: const Color.fromARGB(255, 0, 0, 0), width: 3.0),
        borderRadius: BorderRadius.circular(12),
      ),
      margin: EdgeInsets.symmetric(vertical: 2),
      child: ListTile(
        leading: review['profile_photo_url'] != null
            ? CircleAvatar(
                backgroundImage: NetworkImage(review['profile_photo_url']),
              )
            : null,
        title: Text(review['author_name'] ?? 'Anonim'),
        subtitle: Text(review['text'] ?? ''),
        textColor: const Color.fromARGB(255, 0, 0, 0),
      ),
    );
  }
}
