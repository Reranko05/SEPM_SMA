import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/api_service.dart';
import 'services/auth_provider.dart';
import 'services/notification_service.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/meal.dart';
import 'services/background_service.dart';
import 'providers/preferences_provider.dart';
import 'providers/recommendation_provider.dart';
import 'screens/auth_screen.dart';
import 'screens/preferences_screen.dart';
import 'screens/recommendation_screen.dart';
import 'screens/home_screen.dart';
import 'screens/restaurants_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/sma_dashboard.dart';
import 'screens/profile_screen.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';

import 'providers/cart_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // initialize notifications and alarm manager
  await NotificationService().init();
  await AndroidAlarmManager.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final api = ApiService();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(api: api)),
        ChangeNotifierProxyProvider<AuthProvider, CartProvider>(
          create: (_) => CartProvider(api: api),
          update: (_, auth, cart) => cart!..updateAuth(auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, PreferencesProvider>(
          create: (_) => PreferencesProvider(api: api),
          update: (_, auth, prefs) => prefs!..updateAuth(auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, RecommendationProvider>(
          create: (_) => RecommendationProvider(api: api),
          update: (_, auth, r) => r!..updateAuth(auth),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Smart Meal Autopilot',
        theme: ThemeData(
          useMaterial3: true,
          // Color system (organic green palette)
          colorScheme: const ColorScheme(
            brightness: Brightness.light,
            primary: Color(0xFF0F2A1D), // deep green
            onPrimary: Colors.white,
            secondary: Color(0xFF6BE36B), // fresh green accent
            onSecondary: Colors.white,
            error: Colors.red,
            onError: Colors.white,
            background: Color(0xFFF5F7F6), // light neutral
            onBackground: Color(0xFF222222),
            surface: Colors.white, // card color
            onSurface: Color(0xFF222222),
          ),
          primaryColor: const Color(0xFF0F2A1D),
          scaffoldBackgroundColor: const Color(0xFFF5F7F6),
          cardColor: Colors.white,
          // Card theme: rounded, soft shadow
          cardTheme: CardThemeData(
            color: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
          ),
          // Elevated buttons: fresh green filled buttons
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6BE36B),
              foregroundColor: Colors.white,
              elevation: 2,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              textStyle: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          // Outlined buttons: soft border using secondary tint
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: const Color(0xFF1F4D2E).withOpacity(0.12)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
              foregroundColor: const Color(0xFF0F2A1D),
            ),
          ),
          // Switch theme: green accent when active
          switchTheme: SwitchThemeData(
            thumbColor: MaterialStateProperty.resolveWith((states) => const Color(0xFF6BE36B)),
            trackColor: MaterialStateProperty.resolveWith((states) => states.contains(MaterialState.selected) ? const Color(0xFF6BE36B).withOpacity(0.4) : Colors.grey.shade400),
          ),
          // Text theme basic tweaks
          textTheme: const TextTheme(
            titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF222222)),
            bodyMedium: TextStyle(color: Color(0xFF222222)),
          ),
        ),
        home: const RootShell(),
        routes: {
          '/auth': (_) => const AuthScreen(),
          '/preferences': (_) => const PreferencesScreen(),
          '/recommendation': (_) => const RecommendationScreen(),
          '/cart': (_) => CartScreen(),
          '/home': (_) => const RootShell(),
        },
      ),
    );
  }
}

class RootShell extends StatefulWidget {
  const RootShell({super.key});
  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> with WidgetsBindingObserver {
  int _index = 0;
  static final _pages = [RestaurantsScreen(), SMADashboard(), CartScreen(), ProfileScreen()];
  bool _initializedAuto = false;
    bool _checkedLogin = false;
    bool _loggedIn = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initializedAuto) {
      _initializedAuto = true;
      _checkAutoReco();
      _checkLogin();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _onResume();
    }
  }

  Future<void> _onResume() async {
    final prefs = await SharedPreferences.getInstance();
    // If background task recorded an auto_reco_added id, refresh server cart
    final addedId = prefs.getString('auto_reco_added');
    if (addedId != null && addedId.isNotEmpty) {
      final cart = Provider.of<CartProvider>(context, listen: false);
      // don't automatically fetch or add into local cart; let the user view it explicitly
      await prefs.remove('auto_reco_added');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('A recommendation was auto-added to your server cart.'),
        action: SnackBarAction(label: 'View Cart', onPressed: () async {
          try {
            await cart.fetchCart();
          } catch (_) {}
          if (mounted) setState(() => _index = 2);
        }),
      ));
    }

    // If background task stored an auto_reco (not yet added to server), prompt user instead of auto-adding
    final data = prefs.getString('auto_reco');
    if (data != null) {
      try {
        final json = jsonDecode(data) as Map<String, dynamic>;
        final meal = Meal.fromJson(json);
        // show an inline action to allow user to add or view the cart
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Recommended: ${meal.name}'),
            action: SnackBarAction(label: 'Add', onPressed: () async {
              final cart = Provider.of<CartProvider>(context, listen: false);
              try {
                await cart.add(meal);
              } catch (_) {}
            }),
          ));
        // remove the persisted recommendation so it doesn't repeat
        await prefs.remove('auto_reco');
      } catch (_) {}
    }
  }

  Future<void> _checkAutoReco() async {
    // Intentionally no-op on cold start to avoid showing prompts immediately.
    // Background recommendations are handled on resume via `_onResume`.
    return;
  }

    Future<void> _checkLogin() async {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final logged = await auth.isLoggedIn();
      if (logged) {
        final prefs = await SharedPreferences.getInstance();
        final u = prefs.getString('username');
        if (u != null) auth.username = u;
          // do NOT auto-load server cart on cold start to avoid silently showing
          // items that were added by background jobs; user can view cart explicitly.
      }
      setState(() {
        _checkedLogin = true;
        _loggedIn = logged;
      });
    }

  @override
  Widget build(BuildContext context) {
    if (!_checkedLogin) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!_loggedIn) {
      return const AuthScreen();
    }

    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: Consumer<CartProvider>(builder: (_, cart, __) {
        return BottomNavigationBar(
          currentIndex: _index,
          selectedItemColor: Theme.of(context).colorScheme.secondary,
          unselectedItemColor: Colors.grey,
          onTap: (i) {
            setState(() => _index = i);
            if (i == 2) {
              final cart = Provider.of<CartProvider>(context, listen: false);
              cart.fetchCart();
            }
          },
          items: [
            const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            const BottomNavigationBarItem(icon: Icon(Icons.auto_mode), label: 'SMA'),
            BottomNavigationBarItem(
              icon: Stack(children: [
                const Icon(Icons.shopping_cart),
                if (cart.totalCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text('${cart.totalCount}', style: const TextStyle(color: Colors.white, fontSize: 12), textAlign: TextAlign.center),
                    ),
                  ),
              ]),
              label: 'Cart',
            ),
            const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        );
      }),
    );
  }
}
