import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ServiceSelectionPage extends StatelessWidget {
  const ServiceSelectionPage({super.key});

  Future<void> sendNotification(String userId, String service) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final FirebaseAuth _auth = FirebaseAuth.instance;

    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('notifications').add({
          'userId': userId,
          'message': 'تم حجز خدمة: $service بنجاح. سعيدون بخدمتك!',
          'timestamp': FieldValue.serverTimestamp(),
        });

        await _firestore.collection('notifications').add({
          'userId': 'admin',
          'message': 'تم حجز خدمة: $service من قبل المستخدم ${user.email}',
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print("Error sending notification: $e");
    }
  }

  Future<void> bookService(BuildContext context, String service) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final FirebaseAuth _auth = FirebaseAuth.instance;

    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('bookings').add({
          'userId': user.uid,
          'service': service,
          'status': 'Booked',
          'timestamp': FieldValue.serverTimestamp(),
          'type': 'سريع',
        });

        await sendNotification(user.uid, service);

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("تم الحجز بنجاح"),
              content: Text("لقد تم حجز خدمة: $service بنجاح. سعيدون بخدمتك!"),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('موافق'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      print("Error booking service: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("حدث خطأ أثناء الحجز")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Service")),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: ListView(
          children: [
            ListTile(
              title: const Text("غيار زيت"),
              onTap: () => bookService(context, "غيار زيت"),
            ),
            ListTile(
              title: const Text("فحص كمبيوتر"),
              onTap: () => bookService(context, "فحص كمبيوتر"),
            ),
            ListTile(
              title: const Text("غيار بريك"),
              onTap: () => bookService(context, "غيار بريك"),
            ),
            ListTile(
              title: const Text("غيار بواجي"),
              onTap: () => bookService(context, "غيار بواجي"),
            ),
            ListTile(
              title: const Text("فلاتر"),
              onTap: () => bookService(context, "فلاتر"),
            ),
          ],
        ),
      ),
    );
  }
}
