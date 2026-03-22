import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'providers/auth_provider.dart' as app_auth;
import 'services/firebase_service.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/auth/sign_in_screen.dart';
import 'screens/main_nav_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';

void main() async {
  // Keep native splash visible until we're ready
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark));

  runApp(ChangeNotifierProvider(
      create: (_) => app_auth.AuthProvider(), child: const PlanGoApp()));
}

class PlanGoApp extends StatelessWidget {
  const PlanGoApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PlanGo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const AppRouter(),
    );
  }
}

class AppRouter extends StatefulWidget {
  const AppRouter({super.key});
  @override
  State<AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<AppRouter> {
  bool _splashRemoved = false;

  void _removeSplash() {
    if (!_splashRemoved) {
      _splashRemoved = true;
      FlutterNativeSplash.remove();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<app_auth.AuthProvider>();

    // Still loading Firebase auth state — show splash
    if (auth.loading) return const SplashScreen(autoNavigate: false);

    // Auth state resolved — remove the native splash
    _removeSplash();

    if (auth.isLoggedIn) {
      FirebaseService.seedDestinationsIfEmpty();
      if (auth.isAdmin) return const AdminHomeWrapper();
      return const MainNavScreen();
    }

    return const _OnboardingGate();
  }
}

class AdminHomeWrapper extends StatelessWidget {
  const AdminHomeWrapper({super.key});
  @override
  Widget build(BuildContext context) => const AdminDashboardScreen(isHome: true);
}

class _OnboardingGate extends StatefulWidget {
  const _OnboardingGate();
  @override
  State<_OnboardingGate> createState() => _OnboardingGateState();
}

class _OnboardingGateState extends State<_OnboardingGate> {
  bool? _seen;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) setState(() => _seen = prefs.getBool('onboarding_done') ?? false);
  }

  @override
  Widget build(BuildContext context) {
    if (_seen == null) return const SplashScreen(autoNavigate: false);
    return _seen! ? const SignInScreen() : const OnboardingScreen();
  }
}
