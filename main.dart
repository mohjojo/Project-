import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/user_management_page.dart';
import 'screens/login_page.dart';
import 'screens/booking_management_page.dart';
import 'screens/register_page.dart';
import 'screens/admin_chat_page.dart';
import 'screens/admin_home_page.dart';
import 'screens/admin_notifications_page.dart';
import 'screens/service_selection_page.dart';
import 'screens/settings_page.dart';
import 'screens/user_chat_page.dart';
import 'screens/user_home_page.dart';
import 'screens/user_notifications_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shamaileh Shop',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/userManagement': (context) => const UserManagementPage(),
        '/bookingManagement': (context) => BookingManagementPage(),  // إزالة const هنا
        '/register': (context) => RegisterPage(),  // إزالة const هنا
        '/adminChat': (context) => AdminChatPage(receiverId: 'admin'),  // تحديد قيمة receiverId
        '/adminHome': (context) => AdminHomePage(),  // إزالة const هنا
        '/adminNotifications': (context) => AdminNotificationsPage(),  // إزالة const هنا
        '/serviceSelection': (context) => ServiceSelectionPage(),  // إزالة const هنا
        '/settings': (context) => SettingsPage(),  // إزالة const هنا
        '/userChat': (context) => UserChatPage(),  // إزالة const هنا
        '/userHome': (context) => UserHomePage(),  // إزالة const هنا
        '/userNotifications': (context) => UserNotificationsPage(),  // إزالة const هنا
      },
    );
  }
}