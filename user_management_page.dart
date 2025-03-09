import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'admin_chat_page.dart'; // تأكد من استيراد الصفحة بشكل صحيح

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  _UserManagementPageState createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // جلب المستخدم الحالي
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // ترقية المستخدم إلى مسؤول
  Future<void> upgradeUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({'role': 'admin'});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User upgraded to admin")),
        );
      }
    } catch (e) {
      debugPrint("Error upgrading user: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to upgrade user")),
        );
      }
    }
  }

  // حظر المستخدم
  Future<void> blockUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({'status': 'blocked'});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User blocked successfully")),
        );
      }
    } catch (e) {
      debugPrint("Error blocking user: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to block user")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = getCurrentUser();

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("User Management")),
        body: const Center(child: Text("No user is currently signed in.")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("User Management")),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection('users').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(child: Text("Error loading users"));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text("No users found"));
            }

            final users = snapshot.data!.docs;

            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                var user = users[index];

                // التحقق من أن البيانات غير فارغة
                String name = user['name'] ?? "Unknown";
                String email = user['email'] ?? "No Email";
                String role = user['role'] ?? "User";
                String status = user['status'] ?? "Active";

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    leading: const Icon(Icons.person, color: Colors.blue),
                    title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(email),
                        Text("Role: $role"),
                        Text("Status: $status"),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.person_add, color: Colors.green),
                          onPressed: () => upgradeUser(user.id),
                        ),
                        IconButton(
                          icon: const Icon(Icons.block, color: Colors.red),
                          onPressed: () => blockUser(user.id),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chat, color: Colors.orange),
                          onPressed: () {
                            if (mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AdminChatPage(receiverId: user.id),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
