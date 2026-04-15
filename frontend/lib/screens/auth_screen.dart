import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  void _submit() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final u = _userCtrl.text.trim();
    final p = _passCtrl.text.trim();
    try {
      if (isLogin) await auth.login(u, p);
      else await auth.register(u, p);
      if (mounted) Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4F2),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 32),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                child: Column(children: [
                  const Icon(Icons.restaurant_menu, size: 48, color: Colors.orange),
                  const SizedBox(height: 12),
                  const Text('Welcome to SMA', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('Smart Meal Autopilot - Your meals, automated', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(children: [
                      TextField(controller: _userCtrl, decoration: const InputDecoration(prefixIcon: Icon(Icons.email), hintText: 'Email')),
                      const SizedBox(height: 12),
                      TextField(controller: _passCtrl, decoration: const InputDecoration(prefixIcon: Icon(Icons.lock), hintText: 'Password'), obscureText: true),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: auth.loading ? null : _submit,
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                          child: auth.loading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text(isLogin ? 'Login' : 'Create Account'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(onPressed: () => setState(() => isLogin = !isLogin), child: Text(isLogin ? 'Don\'t have an account? Sign Up' : 'Have an account? Login'))
                    ]),
                  )
                ]),
              )
            ]),
          ),
        ),
      ),
    );
  }
}
