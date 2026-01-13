import 'package:flutter/material.dart';

import '../views/auth/forgot_password_view.dart';
import '../views/auth/login_view.dart';
import '../views/auth/register_view.dart';
import '../views/clubs/all_clubs_view.dart';
import '../views/clubs/my_clubs_view.dart';
import '../views/clubs/register_club_view.dart';
import '../views/home/home_view.dart';
import '../views/match/start_match_view.dart';
import '../views/matches/matches_view.dart';
import '../views/onboarding/onboarding_view.dart';
import '../views/players/all_players_view.dart';
import '../views/players/register_player_view.dart';
import '../views/profile/profile_view.dart';
import '../views/tournaments/tournaments_view.dart';
import 'app_state.dart';
import 'routes.dart';
import 'themes/themes.dart';

class CricketSpiritApp extends StatelessWidget {
  const CricketSpiritApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cricket Spirit',
      debugShowCheckedModeBanner: false,
      theme: cricketSpiritTheme(),
      home: const _AppRoot(),
      routes: {
        AppRoutes.login: (_) => const LoginView(),
        AppRoutes.register: (_) => const RegisterView(),
        AppRoutes.home: (_) => const HomeView(),
        '/start-match': (_) => const StartMatchView(),
        '/profile': (_) => const ProfileView(),
        '/forgot-password': (_) => const ForgotPasswordView(),
        '/register-player': (_) => const RegisterPlayerView(),
        '/all-players': (_) => const AllPlayersView(),
        '/register-club': (_) => const RegisterClubView(),
        '/all-clubs': (_) => const AllClubsView(),
        '/my-clubs': (_) => const MyClubsView(),
        '/tournaments': (_) => const TournamentsView(),
        '/matches': (_) => const MatchesView(),
      },
    );
  }
}

class _AppRoot extends StatelessWidget {
  const _AppRoot();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        // Show loading while initializing
        if (!appState.isInitialized) {
          return const Scaffold(
            backgroundColor: CricketSpiritColors.background,
            body: Center(
              child: CircularProgressIndicator(
                color: CricketSpiritColors.primary,
              ),
            ),
          );
        }

        // Show onboarding if not seen
        if (!appState.hasSeenOnboarding) {
          return const OnboardingView();
        }

        // Show login if not logged in
        if (!appState.isLoggedIn) {
          return const LoginView();
        }

        // Show home if logged in
        return const HomeView();
      },
    );
  }
}

