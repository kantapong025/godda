import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(BookManagerApp());
}

class BookManagerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Book Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
      ),
      home: AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          return BookListPage();
        }
        return LoginPage();
      },
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  void _login() async {
    setState(() => isLoading = true);
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      String message = 'เกิดข้อผิดพลาด';
      if (e.code == 'user-not-found') {
        message = 'ไม่พบผู้ใช้นี้';
      } else if (e.code == 'wrong-password') {
        message = 'รหัสผ่านไม่ถูกต้อง';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _navigateToRegister() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => RegisterPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Icon(Icons.lock, size: 80, color: Colors.deepPurple),
                const SizedBox(height: 20),
                const Text("เข้าสู่ระบบ",
                    style:
                        TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                const SizedBox(height: 30),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: "อีเมล",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "รหัสผ่าน",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _login,
                    child: isLoading
                        ? const CircularProgressIndicator(color: Color.fromARGB(255, 255, 255, 255))
                        : const Text("เข้าสู่ระบบ"),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("ยังไม่มีบัญชี? "),
                    TextButton(
                      onPressed: _navigateToRegister,
                      child: const Text("สมัครสมาชิก"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  void _register() async {
    setState(() => isLoading = true);
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String message = 'เกิดข้อผิดพลาด';
      if (e.code == 'email-already-in-use') {
        message = 'อีเมลนี้มีบัญชีอยู่แล้ว';
      } else if (e.code == 'weak-password') {
        message = 'รหัสผ่านอ่อนเกินไป';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("สมัครสมาชิก")),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "อีเมล",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "รหัสผ่าน",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _register,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("สมัครสมาชิก"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// BookListPage ยังคงเดิม ไม่เปลี่ยนแปลงจากที่ให้มา


// --------------------------- BOOK LIST PAGE ---------------------------
class BookListPage extends StatefulWidget {
  @override
  State<BookListPage> createState() => _BookListPageState();
}

class _BookListPageState extends State<BookListPage> {
  final CollectionReference booksCollection =
      FirebaseFirestore.instance.collection('books');

  void showBookDialog({DocumentSnapshot? doc}) {
    final nameController = TextEditingController(text: doc?['name']);
    final volumeController =
        TextEditingController(text: doc?['volume']?.toString());
    final storeController = TextEditingController(text: doc?['store']);
    final priceController =
        TextEditingController(text: doc?['price']?.toString());

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(doc == null ? 'เพิ่มหนังสือใหม่' : 'แก้ไขหนังสือ'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'ชื่อหนังสือ'),
              ),
              TextField(
                controller: volumeController,
                decoration: InputDecoration(labelText: 'เล่มที่'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: storeController,
                decoration: InputDecoration(labelText: 'ซื้อที่'),
              ),
              TextField(
                controller: priceController,
                decoration: InputDecoration(labelText: 'ราคาที่ซื้อ'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: Text('ยกเลิก'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: Text(doc == null ? 'บันทึก' : 'อัปเดต'),
            onPressed: () async {
              String name = nameController.text.trim();
              int volume = int.tryParse(volumeController.text.trim()) ?? 1;
              String store = storeController.text.trim();
              double price =
                  double.tryParse(priceController.text.trim()) ?? 0.0;

              if (name.isEmpty || store.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('กรุณากรอกชื่อหนังสือและสถานที่ซื้อ')),
                );
                return;
              }

              final data = {
                'name': name,
                'volume': volume,
                'store': store,
                'price': price,
                'updatedAt': FieldValue.serverTimestamp(),
              };

              try {
                if (doc == null) {
                  await booksCollection.add(data);
                } else {
                  await booksCollection.doc(doc.id).update(data);
                }
                Navigator.pop(context);
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> deleteBook(String docId) async {
    try {
      await booksCollection.doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ลบข้อมูลเรียบร้อย')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ลบข้อมูลไม่สำเร็จ: $e')),
      );
    }
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    // หลัง logout StreamBuilder ที่ AuthWrapper จะจับได้และเปลี่ยนไปหน้า LoginPage
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('รายการหนังสือที่เคยซื้อ'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: 'ออกจากระบบ',
            onPressed: _logout,
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: booksCollection.orderBy('name').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return Center(child: Text('ยังไม่มีข้อมูลหนังสือ'));
          }

          return ListView.builder(
            padding: EdgeInsets.all(8),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              return Card(
                margin: EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 3,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.deepPurple.shade200,
                    child: Text('${data['volume'] ?? ''}',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        )),
                  ),
                  title: Text(data['name'] ?? '',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: Text(
                      'ซื้อที่: ${data['store'] ?? ''}\nราคา: ${data['price']?.toStringAsFixed(2) ?? '0.00'} บาท'),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.orange),
                        tooltip: 'แก้ไข',
                        onPressed: () => showBookDialog(doc: doc),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        tooltip: 'ลบ',
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text('ยืนยันการลบ'),
                              content: Text(
                                  'คุณต้องการลบหนังสือ "${data['name']}" ใช่หรือไม่?'),
                              actions: [
                                TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: Text('ยกเลิก')),
                                ElevatedButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: Text('ลบ')),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await deleteBook(doc.id);
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
      floatingActionButton: FloatingActionButton(
        tooltip: 'เพิ่มหนังสือใหม่',
        child: Icon(Icons.add),
        onPressed: () => showBookDialog(),
      ),
    );
  }
}
