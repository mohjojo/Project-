import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DetailedBookingPage extends StatefulWidget {
  const DetailedBookingPage({super.key, required this.service});

  final String service;

  @override
  _DetailedBookingPageState createState() => _DetailedBookingPageState();
}

class _DetailedBookingPageState extends State<DetailedBookingPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _issueController = TextEditingController();
  final TextEditingController _carModelController = TextEditingController();
  File? _imageFile;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

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

  Future<void> bookService(BuildContext context) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final FirebaseAuth _auth = FirebaseAuth.instance;

    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('bookings').add({
          'userId': user.uid,
          'service': widget.service,
          'status': 'Booked',
          'timestamp': FieldValue.serverTimestamp(),
          'type': 'مفصل',
          'details': {
            'name': _nameController.text,
            'phone': _phoneController.text,
            'issue': _issueController.text,
            'carModel': _carModelController.text,
            'imageURL': _imageFile != null ? _imageFile!.path : null,
          }
        });

        await sendNotification(user.uid, widget.service);

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("تم الحجز بنجاح"),
              content: Text("لقد تم حجز خدمة: ${widget.service} بنجاح. سعيدون بخدمتك!"),
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
      appBar: AppBar(
        title: Text('تفاصيل الحجز - ${widget.service}'),
        backgroundColor: Colors.blueGrey,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: "اسم العميل",
                    labelStyle: TextStyle(color: Colors.white),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: "رقم الهاتف",
                    labelStyle: TextStyle(color: Colors.white),
                  ),
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _issueController,
                  decoration: const InputDecoration(
                    labelText: "نوع العطل",
                    labelStyle: TextStyle(color: Colors.white),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _carModelController,
                  decoration: const InputDecoration(
                    labelText: "نوع السيارة",
                    labelStyle: TextStyle(color: Colors.white),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: const Text("اختيار صورة للعطل"),
                ),
                if (_imageFile != null)
                  Image.file(
                    _imageFile!,
                    height: 200,
                    width: 200,
                    fit: BoxFit.cover,
                  ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => bookService(context),
                  child: const Text("إرسال الحجز"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
