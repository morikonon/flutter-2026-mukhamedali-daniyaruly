import 'package:flutter/material.dart';

import 'data/seed.dart';
import 'models/profile.dart';
import 'models/session.dart';
import 'routes.dart';
import 'tabs/favourites_tab.dart';
import 'tabs/list_tab.dart';
import 'tabs/profile_tab.dart';
import 'widgets/confirm_dialog.dart';

const _titles = ['Sessions', 'Favourites', 'Profile'];

/// Owns the sessions and the profile. Tabs and pushed screens get them
/// through constructors and send changes back through callbacks.
class Shell extends StatefulWidget {
  const Shell({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  List<Session> _sessions = seedItems();
  Profile _profile = const Profile.empty();
  int _tab = 0;

  void _openTab(int index) => setState(() => _tab = index);

  // Immutable updates: a new list every time, never list.add or list[i] =.
  void _replace(Session updated) => setState(() {
    _sessions = _sessions.map((s) => s.id == updated.id ? updated : s).toList();
  });

  void _delete(String id) =>
      setState(() => _sessions = _sessions.where((s) => s.id != id).toList());

  void _toggleFavourite(Session session) =>
      _replace(session.copyWith(isFavourite: !session.isFavourite));

  void _changeProfile(Profile profile) => setState(() => _profile = profile);

  Future<void> _openForm() async {
    final created = await Navigator.of(context)
        .pushNamed<Session>(Routes.form, arguments: const FormArgs(null));
    if (!mounted || created == null) return;
    setState(() => _sessions = [..._sessions, created]);
  }

  void _openDetail(Session session) {
    Navigator.of(context).pushNamed(
      Routes.detail,
      arguments: DetailArgs(
        session: session,
        profileName: _profile.name,
        onChanged: _replace,
        onDelete: _delete,
        onOpenProfile: () => _openTab(2),
      ),
    );
  }

  void _showAbout() {
    Navigator.of(context).pop(); // closes the drawer
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('About StudyBuddy'),
        content: const Text(
          'Find peer tutoring sessions at the university and join them. '
          'Everything lives in memory: closing the app resets it.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _resetData() async {
    Navigator.of(context).pop(); // closes the drawer
    final ok = await confirm(
      context,
      title: 'Reset data?',
      message: 'All sessions go back to the start and the profile is cleared.',
      action: 'Reset',
    );
    if (!mounted || !ok) return;
    setState(() {
      _sessions = seedItems();
      _profile = const Profile.empty();
    });
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_tab])),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text('StudyBuddy', style: text.headlineSmall),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About'),
              onTap: _showAbout,
            ),
            ListTile(
              leading: const Icon(Icons.restart_alt),
              title: const Text('Reset data'),
              onTap: _resetData,
            ),
          ],
        ),
      ),
      // IndexedStack keeps every tab alive, so search and filters survive.
      body: IndexedStack(
        index: _tab,
        children: [
          ListTab(
            sessions: _sessions,
            onOpen: _openDetail,
            onToggleFavourite: _toggleFavourite,
          ),
          FavouritesTab(
            sessions: _sessions,
            onOpen: _openDetail,
            onToggleFavourite: _toggleFavourite,
            onBrowseAll: () => _openTab(0),
          ),
          ProfileTab(
            profile: _profile,
            sessions: _sessions,
            onProfileChanged: _changeProfile,
          ),
        ],
      ),
      floatingActionButton: _tab == 0
          ? FloatingActionButton(
              tooltip: 'New session',
              onPressed: _openForm,
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: _openTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.event_note_outlined),
            selectedIcon: Icon(Icons.event_note),
            label: 'Sessions',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favourites',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
