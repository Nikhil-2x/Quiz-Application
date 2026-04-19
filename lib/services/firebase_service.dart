import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final db = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchQuestions() async {
    var snapshot = await db.collection('questions').get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }
}
