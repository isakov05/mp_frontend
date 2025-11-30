import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/api_service.dart';
import '../services/auth_storage.dart';
import '../theme/theme_controller.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final api = ApiService();

  bool loading = true;
  String email = "";

  final nameCtrl = TextEditingController();

  final calorieCtrl = TextEditingController();
  final proteinCtrl = TextEditingController();
  final fatCtrl = TextEditingController();
  final carbsCtrl = TextEditingController();

  final oldPassCtrl = TextEditingController();
  final newPassCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadAllData();
  }

  Future<void> loadAllData() async {
    final token = await AuthStorage.getToken();
    if (token == null) return;

    try {
      final userRes = await api.getProfile(token);
      nameCtrl.text = userRes.data["name"] ?? "";
      email = userRes.data["email"] ?? "";

      final settingsRes = await api.getSettings(token);
      calorieCtrl.text = "${settingsRes.data["daily_calorie_goal"] ?? 2000}";
      proteinCtrl.text = "${settingsRes.data["daily_protein_goal"] ?? 0}";
      fatCtrl.text = "${settingsRes.data["daily_fat_goal"] ?? 0}";
      carbsCtrl.text = "${settingsRes.data["daily_carbs_goal"] ?? 0}";

      setState(() => loading = false);
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Failed to load: $e")));
    }
  }

  Future<void> saveName() async {
    final token = await AuthStorage.getToken();
    if (token == null) return;

    try {
      await api.updateName(token, nameCtrl.text.trim());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Name updated ✔")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed: $e")),
      );
    }
  }

  Future<void> saveGoals() async {
    final token = await AuthStorage.getToken();
    if (token == null) return;

    try {
      await api.updateGoals(
        token,
        int.parse(calorieCtrl.text),
        int.parse(proteinCtrl.text),
        int.parse(fatCtrl.text),
        int.parse(carbsCtrl.text),
      );

      await AuthStorage.saveGoal(int.parse(calorieCtrl.text));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Goals updated ✔")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed: $e")),
      );
    }
  }

  Future<void> changePassword() async {
    final token = await AuthStorage.getToken();
    if (token == null) return;

    try {
      await api.updatePassword(
        token,
        oldPassCtrl.text.trim(),
        newPassCtrl.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password changed ✔")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [

                // ----------------------------
                // Profile Header
                // ----------------------------
                Center(
                  child: CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.teal.shade100,
                    child: const Icon(Icons.person, size: 50, color: Colors.teal),
                  ),
                ),

                const SizedBox(height: 10),

                Center(
                  child: Text(email, style: TextStyle(color: Colors.grey[600])),
                ),

                const SizedBox(height: 30),

                // ----------------------------
                // THEME MODE SWITCH (SLIDER)
                // ----------------------------
                const Text(
                  "Appearance",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(
                      value: ThemeMode.system,
                      label: Text("System"),
                      icon: Icon(Icons.settings_suggest),
                    ),
                    ButtonSegment(
                      value: ThemeMode.light,
                      label: Text("Light"),
                      icon: Icon(Icons.light_mode),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      label: Text("Dark"),
                      icon: Icon(Icons.dark_mode),
                    ),
                  ],
                  selected: { themeController.themeMode },
                  onSelectionChanged: (selection) {
                    themeController.setTheme(selection.first);
                  },
                ),

                const SizedBox(height: 30),

                // ----------------------------
                // NAME
                // ----------------------------
                const Text(
                  "Name",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 8),
                FilledButton(
                  onPressed: saveName,
                  child: const Text("Save Name"),
                ),

                const SizedBox(height: 30),

                // ----------------------------
                // PASSWORD
                // ----------------------------
                const Text(
                  "Change Password",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: oldPassCtrl,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Old Password",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: newPassCtrl,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "New Password",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 12),
                FilledButton(
                  onPressed: changePassword,
                  child: const Text("Update Password"),
                ),

                const SizedBox(height: 30),

                // ----------------------------
                // GOALS
                // ----------------------------
                const Text(
                  "Daily Goals",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                _goalField(calorieCtrl, "Calories (kcal)"),
                const SizedBox(height: 10),

                _goalField(proteinCtrl, "Protein (g)"),
                const SizedBox(height: 10),

                _goalField(fatCtrl, "Fat (g)"),
                const SizedBox(height: 10),

                _goalField(carbsCtrl, "Carbs (g)"),
                const SizedBox(height: 12),

                FilledButton(
                  onPressed: saveGoals,
                  child: const Text("Save Goals"),
                ),

                const SizedBox(height: 40),

                // ----------------------------
                // LOGOUT
                // ----------------------------
                FilledButton.tonal(
                  onPressed: () async {
                    await AuthStorage.clear();
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      "/login",
                      (route) => false,
                    );
                  },
                  child: const Text("Logout"),
                ),
              ],
            ),
    );
  }

  Widget _goalField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
