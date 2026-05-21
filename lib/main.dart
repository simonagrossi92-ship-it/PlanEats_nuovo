import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' show PlatformDispatcher;

import 'app_state.dart';
import 'screens/menu_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/recipes_screen.dart';
import 'screens/shopping_screen.dart';
import 'screens/report_screen.dart';

// #region debug-point snack-manual-redscreen:reporter
Future<void> _dbgReport({
  required String hypothesisId,
  required String msg,
  Map<String, Object?>? data,
}) async {
  try {
    var sessionId = 'snack-manual-redscreen';
    final urls = <String>[];
    try {
      final env = File('.dbg/snack-manual-redscreen.env').readAsStringSync();
      for (final line in env.split('\n')) {
        if (line.startsWith('DEBUG_SERVER_URL=')) {
          urls.add(line.substring('DEBUG_SERVER_URL='.length).trim());
        } else if (line.startsWith('DEBUG_SESSION_ID=')) {
          sessionId = line.substring('DEBUG_SESSION_ID='.length).trim();
        }
      }
    } catch (_) {}
    if (urls.isEmpty) {
      urls.addAll([
        'http://10.0.2.2:7777/event',
        'http://127.0.0.1:7777/event',
        'http://localhost:7777/event',
      ]);
    }

    final normalized = <String>{};
    for (final u in urls) {
      final v = u.trim();
      if (v.isEmpty) continue;
      normalized.add(v);
      if (v.contains('127.0.0.1')) {
        normalized.add(v.replaceFirst('127.0.0.1', '10.0.2.2'));
      }
      if (v.contains('localhost')) {
        normalized.add(v.replaceFirst('localhost', '10.0.2.2'));
      }
    }

    for (final url in normalized) {
      try {
        final client = HttpClient();
        final req = await client.postUrl(Uri.parse(url));
        req.headers.contentType = ContentType.json;
        req.write(
          jsonEncode({
            'sessionId': sessionId,
            'runId': 'pre-fix',
            'hypothesisId': hypothesisId,
            'location': 'main.dart',
            'msg': '[DEBUG] $msg',
            'data': data ?? const {},
            'ts': DateTime.now().millisecondsSinceEpoch,
          }),
        );
        await req.close();
        client.close(force: true);
        break;
      } catch (_) {}
    }
  } catch (_) {}
}
// #endregion

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (details) {
    _dbgReport(
      hypothesisId: 'E',
      msg: 'FlutterError',
      data: {
        'exception': details.exceptionAsString(),
        'stack': details.stack?.toString(),
      },
    );
    FlutterError.presentError(details);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    _dbgReport(
      hypothesisId: 'E',
      msg: 'PlatformDispatcherError',
      data: {'error': error.toString(), 'stack': stack.toString()},
    );
    return false;
  };
  runApp(const PlanEatsApp());
}

class PlanEatsApp extends StatefulWidget {
  const PlanEatsApp({super.key});

  @override
  State<PlanEatsApp> createState() => _PlanEatsAppState();
}

class _PlanEatsAppState extends State<PlanEatsApp> {
  final AppState _state = AppState();

  @override
  void initState() {
    super.initState();
    _state.init();
  }

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PlanEats',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8BA888), // Verde Salvia
          primary: const Color(0xFF8BA888),
          surface: const Color(0xFFFDF5E6), // Old Lace (#FDF5E6)
        ),
        scaffoldBackgroundColor: const Color(0xFFFDF5E6), // Sfondo Old Lace
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFDF5E6),
          elevation: 0,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: const Color(0xFF8BA888).withValues(alpha: 0.2),
          height: 80, // Altezza fissa per la barra di navigazione
        ),
      ),
      home: AnimatedBuilder(
        animation: _state,
        builder: (context, _) {
          if (!_state.isReady) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return HomeShell(state: _state);
        },
      ),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.state});
  final AppState state;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0; // default: Menù

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      MenuScreen(state: widget.state),
      ShoppingScreen(state: widget.state),
      ReportScreen(state: widget.state),
      RecipesScreen(state: widget.state),
      ProfileScreen(state: widget.state),
    ];

    return Scaffold(
      body: pages[_index],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black
                  .withValues(alpha: 0.1), // Ombra leggermente più marcata
              blurRadius: 15,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: NavigationBar(
          elevation: 8, // Aggiunta elevazione alla NavigationBar stessa
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.restaurant_menu_outlined),
              selectedIcon: Icon(Icons.restaurant_menu),
              label: 'Menù',
            ),
            NavigationDestination(
              icon: Icon(Icons.shopping_cart_outlined),
              selectedIcon: Icon(Icons.shopping_cart),
              label: 'Spesa',
            ),
            NavigationDestination(
              icon: Icon(Icons.inventory_2_outlined),
              selectedIcon: Icon(Icons.inventory_2),
              label: 'Report',
            ),
            NavigationDestination(
              icon: Icon(Icons.menu_book_outlined),
              selectedIcon: Icon(Icons.menu_book),
              label: 'Ricettario',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profilo',
            ),
          ],
        ),
      ),
    );
  }
}
