import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import '../../redux/app/app_state.dart';
import '../../redux/auth/auth_actions.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  Future<void> _confirmSignOut(BuildContext context) async {
    final shouldSignOut = await showModalBottomSheet<bool>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Would you want to sign out?'),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Sign Out'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );

    if (shouldSignOut == true && context.mounted) {
      StoreProvider.of<AppState>(context).dispatch(signOut());
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AuthState>(
      converter: (store) => store.state.authState,
      builder: (context, authState) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 64),
                Icon(Icons.account_circle,
                    size: 120, color: Theme.of(context).colorScheme.onSurface),
                const SizedBox(height: 16),
                Text(
                  authState.user?.username ?? 'Unknown name',
                  style: const TextStyle(fontSize: 28),
                ),
                const SizedBox(height: 64),
                OutlinedButton(
                  onPressed: authState.user == null
                      ? null
                      : () => _confirmSignOut(context),
                  style: OutlinedButton.styleFrom(
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                  ),
                  child: const Text('Sign Out',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
