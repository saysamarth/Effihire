import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io'; // Import for Platform detection
import '../../auth/splash_screen.dart';
import '../../auth/login_screen.dart';
import '../../auth/Fetch Location/Views/location_screen.dart';
import '../../app/bottom_navbar.dart';

class AppRouter {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    redirect: (BuildContext context, GoRouterState state) async {
      // Skip login screen on iOS - go directly to location after splash
      if (state.matchedLocation == '/splash') {
        return null;
      }

      final User? user = _auth.currentUser;
      final bool isLoggedIn = user != null;
      final bool isIOS = Platform.isIOS; // Check if running on iOS

      // iOS specific logic - skip login screen
      if (isIOS) {
        // If user is not logged in
        if (!isLoggedIn) {
          // Allow access to location screen
          if (state.matchedLocation == '/location') {
            return null;
          }
          // Allow access to main app routes (since we're skipping login)
          if (state.matchedLocation.startsWith('/main/')) {
            return null;
          }
          // Redirect to location screen from other routes
          return '/location';
        }

        // If user is logged in and trying to access login, redirect to home
        if (state.matchedLocation == '/login' ||
            state.matchedLocation == '/logout-login') {
          return '/main/home';
        }

        // If logged in and on location, redirect to main app
        if (state.matchedLocation == '/location') {
          return '/main/home';
        }

        return null;
      }

      // Android logic - keep existing behavior (show login screen)
      if (!isLoggedIn) {
        if (state.matchedLocation == '/login' ||
            state.matchedLocation == '/logout-login') {
          return null;
        }
        return '/login'; // Redirect to login on Android when not logged in
      }

      // If logged in and trying to access login pages, redirect to location
      if (state.matchedLocation == '/login' ||
          state.matchedLocation == '/logout-login') {
        return '/location';
      }

      if (state.matchedLocation == '/location') {
        return null;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/logout-login',
        name: 'logout-login',
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var begin = Offset(-1.0, 0.0);
            var end = Offset.zero;
            var curve = Curves.easeInOutCubic;
            var tween = Tween(
              begin: begin,
              end: end,
            ).chain(CurveTween(curve: curve));
            return SlideTransition(
              position: animation.drive(tween),
              child: FadeTransition(opacity: animation, child: child),
            );
          },
          transitionDuration: Duration(milliseconds: 600),
        ),
      ),
      GoRoute(
        path: '/location',
        name: 'location',
        builder: (context, state) => LocationScreen(),
        // Add routes for iOS users to navigate after location
        routes: [
          GoRoute(
            path: 'continue',
            name: 'location-continue',
            builder: (context, state) {
              // Navigate to main home after location is set
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.go('/main/home');
              });
              return const SizedBox(); // Temporary widget
            },
          ),
        ],
      ),

      ShellRoute(
        builder: (context, state, child) {
          return BottomNavBar(child: child);
        },
        routes: [
          GoRoute(
            path: '/main/referral',
            name: 'referral',
            builder: (context, state) => const SizedBox(),
          ),
          GoRoute(
            path: '/main/tasks',
            name: 'tasks',
            builder: (context, state) => const SizedBox(),
          ),
          GoRoute(
            path: '/main/home',
            name: 'home',
            builder: (context, state) => const SizedBox(),
            // routes: [
            //     path: 'personal-registration',
            //     name: 'home-personal-registration',
            //     builder: (context, state) => const RegistrationScreen(),
            //   ),
            //   GoRoute(
            //     path: 'bank-registration',
            //     name: 'home-bank-registration',
            //     builder: (context, state) => const BankDetailsScreen(),
            //   ),
            // ],
          ),
          GoRoute(
            path: '/main/payment',
            name: 'payment',
            builder: (context, state) =>
                const SizedBox(), // Placeholder - not used
          ),
          GoRoute(
            path: '/main/profile',
            name: 'profile',
            builder: (context, state) =>
                const SizedBox(), // Placeholder - not used
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found: ${state.matchedLocation}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/splash'),
              child: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    ),
  );
}
