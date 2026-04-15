import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Card(child: ListTile(title: Text(auth.username ?? 'Guest'), subtitle: const Text('Member since now'))),
          const SizedBox(height: 12),
          ListTile(leading: const Icon(Icons.settings), title: const Text('Preferences'), onTap: () => Navigator.pushNamed(context, '/preferences')),
          ListTile(leading: const Icon(Icons.logout), title: const Text('Logout'), onTap: () async { await auth.logout(); Navigator.pushReplacementNamed(context, '/auth'); }),
        ]),
      ),
    );
  }
}
