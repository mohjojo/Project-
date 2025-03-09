import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // دالة لاسترجاع بيانات المستخدم الحالي
  Future<User?> getUser() async {
    User? user = _auth.currentUser;
    return user;
  }

  // دالة لإضافة حجز جديد
  Future<void> addBooking(Map<String, dynamic> bookingData) async {
    try {
      // إضافة بيانات الحجز مع توقيت الحجز
      await _firestore.collection('bookings').add({
        'service': bookingData['service'],  // نوع الخدمة
        'customerName': bookingData['customerName'],  // اسم العميل
        'phone': bookingData['phone'],  // رقم الهاتف
        'carModel': bookingData['carModel'],  // نوع السيارة
        'issue': bookingData['issue'],  // العطل الذي تم تحديده
        'timestamp': FieldValue.serverTimestamp(),  // إضافة التوقيت الحالي
      });
      print('Booking added successfully');
    } catch (e) {
      print('Error adding booking: $e');
    }
  }

  // دالة لاسترجاع قائمة الحجوزات
  Future<List<Map<String, dynamic>>> getBookings() async {
    try {
      // استرجاع كل البيانات من مجموعة "bookings"
      QuerySnapshot querySnapshot = await _firestore.collection('bookings').get();
      return querySnapshot.docs.map((doc) {
        return doc.data() as Map<String, dynamic>;
      }).toList();
    } catch (e) {
      print("Error getting bookings: $e");
      return [];
    }
  }

  // دالة لاسترجاع المستخدمين
  Future<List<Map<String, dynamic>>> getUsers() async {
    try {
      // استرجاع كل البيانات من مجموعة "users"
      QuerySnapshot querySnapshot = await _firestore.collection('users').get();
      return querySnapshot.docs.map((doc) {
        return doc.data() as Map<String, dynamic>;
      }).toList();
    } catch (e) {
      print("Error getting users: $e");
      return [];
    }
  }
}
