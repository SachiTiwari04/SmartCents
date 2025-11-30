// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smartcents/theme/app_theme.dart';
import 'package:smartcents/screens/app_guide_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late TextEditingController _nameController;
  bool _isEditingName = false;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _nameController = TextEditingController(text: user?.displayName ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _updateDisplayName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && _nameController.text.trim().isNotEmpty) {
      try {
        await user.updateDisplayName(_nameController.text.trim());
        await user.reload();
        
        // Refresh the current user reference
        final updatedUser = FirebaseAuth.instance.currentUser;
        
        if (mounted) {
          setState(() {
            _isEditingName = false;
            _nameController.text = updatedUser?.displayName ?? '';
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully!'),
              backgroundColor: AppTheme.successGreen,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error updating profile: $e'),
              backgroundColor: AppTheme.errorRed,
            ),
          );
        }
      }
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        title: const Text('Logout', style: TextStyle(color: AppTheme.primaryCyan)),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout', style: TextStyle(color: AppTheme.errorRed)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await FirebaseAuth.instance.signOut();
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error logging out: $e'),
              backgroundColor: AppTheme.errorRed,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get user directly from FirebaseAuth instead of provider
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBg,
        title: const Text('Profile Settings', style: TextStyle(color: AppTheme.primaryCyan)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryCyan),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: user == null
          ? const Center(
              child: Text(
                'No user logged in',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Picture Section
                  Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppTheme.cardBg,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.primaryCyan,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryCyan.withValues(alpha: 0.3),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.account_circle,
                        size: 80,
                        color: AppTheme.primaryCyan,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // User Info Section
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.primaryCyan,
                        width: 1.5,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'USER INFORMATION',
                            style: TextStyle(
                              color: AppTheme.primaryCyan,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Display Name
                          if (_isEditingName)
                            Column(
                              children: [
                                TextField(
                                  controller: _nameController,
                                  style: const TextStyle(color: AppTheme.textPrimary),
                                  decoration: InputDecoration(
                                    hintText: 'Enter your name',
                                    hintStyle: TextStyle(color: AppTheme.textSecondary.withValues(alpha: 0.5)),
                                    prefixIcon: const Icon(Icons.person, color: AppTheme.primaryCyan),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(color: AppTheme.primaryCyan),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(color: AppTheme.primaryCyan, width: 2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: _updateDisplayName,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppTheme.primaryCyan,
                                          foregroundColor: AppTheme.darkBg,
                                        ),
                                        child: const Text('Save'),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () {
                                          setState(() => _isEditingName = false);
                                          _nameController.text = user.displayName ?? '';
                                        },
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(color: AppTheme.primaryCyan),
                                          foregroundColor: AppTheme.primaryCyan,
                                        ),
                                        child: const Text('Cancel'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          else
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text(
                                'Display Name',
                                style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                              ),
                              subtitle: Text(
                                user.displayName ?? 'Not set',
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.edit, color: AppTheme.primaryCyan),
                                onPressed: () => setState(() => _isEditingName = true),
                              ),
                            ),
                          const Divider(color: AppTheme.primaryCyan, height: 32),
                          // Email
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.email, color: AppTheme.primaryCyan),
                            title: const Text(
                              'Email',
                              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                            ),
                            subtitle: Text(
                              user.email ?? 'Not available',
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // App Settings Section
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.primaryCyan,
                        width: 1.5,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'APP SETTINGS',
                            style: TextStyle(
                              color: AppTheme.primaryCyan,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Notifications', style: TextStyle(color: AppTheme.textPrimary)),
                            subtitle: const Text('Enable push notifications', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                            trailing: Switch(
                              value: true,
                              onChanged: (value) {},
                              activeThumbColor: AppTheme.primaryCyan,
                            ),
                          ),
                          const Divider(color: AppTheme.primaryCyan, height: 32),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Currency', style: TextStyle(color: AppTheme.textPrimary)),
                            subtitle: const Text('Indian Rupee (₹)', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.primaryCyan),
                            onTap: () {},
                          ),
                          const Divider(color: AppTheme.primaryCyan, height: 32),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Language', style: TextStyle(color: AppTheme.textPrimary)),
                            subtitle: const Text('English', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.primaryCyan),
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Help & Support Section
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.primaryCyan,
                        width: 1.5,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'HELP & SUPPORT',
                            style: TextStyle(
                              color: AppTheme.primaryCyan,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('App Guide', style: TextStyle(color: AppTheme.textPrimary)),
                            subtitle: const Text('Learn how to use SmartCents', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.primaryCyan),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const AppGuideScreen()),
                              );
                            },
                          ),
                          const Divider(color: AppTheme.primaryCyan, height: 32),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('About', style: TextStyle(color: AppTheme.textPrimary)),
                            subtitle: const Text('Version 1.0.0', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.primaryCyan),
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Account Actions Section
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.primaryCyan,
                        width: 1.5,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ACCOUNT',
                            style: TextStyle(
                              color: AppTheme.primaryCyan,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _logout,
                              icon: const Icon(Icons.logout),
                              label: const Text('Logout'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.errorRed,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}