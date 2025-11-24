import 'package:flutter/material.dart';
import '../services/profile_service.dart';
import 'change_password_screen.dart';
import 'edit_profile_screen.dart';
import 'daily_goal_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String userName = "";
  String userEmail = "";
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final user = await ProfileService.getProfile();

    if (user != null) {
      setState(() {
        userName = user["name"] ?? "User";
        userEmail = user["email"] ?? "";
        loading = false;
      });
    } else {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // Profile Picture
            CircleAvatar(
              radius: 55,
              backgroundColor: Colors.green.shade200,
              child: const Icon(Icons.person, size: 60, color: Colors.white),
            ),

            const SizedBox(height: 20),

            // Name
            Text(
              userName,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 6),

            // Email
            Text(
              userEmail,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 30),

            _ProfileButton(
              title: "Edit Profile",
              icon: Icons.edit,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditProfileScreen(currentName: userName),
                  ),
                ).then((_) => loadProfile()); // refresh after edit
              },
            ),

            _ProfileButton(
              title: "Change Password",
              icon: Icons.lock_outline,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ChangePasswordScreen(),
                  ),
                );
              },
            ),
            _ProfileButton(
              title: "Daily Goal",
              icon: Icons.track_changes_rounded,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) =>DailyGoalScreen()),
                );
              },
            ),



            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),

            // LOGOUT BUTTON
            ElevatedButton.icon(
              onPressed: () async {
                await ProfileService.storage.delete(key: "token");

                Navigator.pushNamedAndRemoveUntil(
                    context, '/', (route) => false);
              },
              icon: const Icon(Icons.logout),
              label: const Text("Logout"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade400,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _ProfileButton({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      leading: CircleAvatar(
        radius: 22,
        backgroundColor: Colors.green.shade100,
        child: Icon(icon, color: Colors.green.shade700),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
