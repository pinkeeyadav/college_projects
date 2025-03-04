import 'package:diet_plan_app/auth/log_in_form.dart';
import 'package:diet_plan_app/screens/user_input.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:diet_plan_app/firebase_services/auth_service.dart';

class MainDrawer extends StatefulWidget {
  const MainDrawer({
    super.key,
    // required this.onSelectScreen,
  });

  @override
  State<MainDrawer> createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  bool _showLogout = false;
  // ignore: unused_field
  final FirebaseServices _auth = FirebaseServices();

  // Function to handle the tap on the "Setting" ListTile
  void _onSettingTap() {
    setState(() {
      _showLogout = !_showLogout; // Toggle the visibility
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.secondaryFixedDim,
                  Theme.of(context)
                      .colorScheme
                      .secondaryFixedDim
                      .withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(children: [
              Icon(
                Icons.food_bank,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(
                width: 18,
              ),
              Text(
                'Diet',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ]),
          ),

          const SizedBox(height: 20),
          ListTile(
            leading: Icon(
              Icons.published_with_changes_rounded,
              size: 26,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(
              'Update personal details',
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 24,
                  ),
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => const UserInput(),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: Icon(
              Icons.settings,
              size: 26,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(
              'Setting',
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 24,
                  ),
            ),
            onTap: _onSettingTap,
          ),
          // Conditionally show the "Log Out" ListTile
          Visibility(
            visible: _showLogout,
            child: Column(
              children: [
                const SizedBox(height: 8),
                ListTile(
                    leading: Icon(
                      Icons.logout,
                      size: 26,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: Text(
                      'Log Out',
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 24,
                          ),
                    ),
                    onTap: () async {
                      try {
                        await FirebaseAuth.instance.signOut();
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (ctx) => const LogInPage()),
                          (route) => false, // Remove all previous routes
                        );
                      } catch (e) {
                        // Handle logout error here
                        print('Error logging out: $e');
                      }
                    }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
