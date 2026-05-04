import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'core/constants/api_constants.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/domain/entities/user.dart';
import 'features/dashboard/presentation/pages/main_page.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await sb.Supabase.initialize(
    url: ApiConstants.supabaseUrl,
    anonKey: ApiConstants.supabaseAnonKey,
  );

  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = sb.Supabase.instance.client;
    final session = supabase.auth.currentSession;
    
    Widget initialScreen;
    if (session != null) {
      // Jika sudah login, buat objek User dari data sesi
      final user = session.user;
      initialScreen = MainPage(
        user: User(
          id: user.id,
          username: user.email?.split('@')[0] ?? 'user',
          fullName: user.userMetadata?['full_name'] ?? 'User',
          role: user.userMetadata?['role']?.toString() ?? '2', // Default Pegawai
        ),
      );
    } else {
      initialScreen = const LoginPage();
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => di.sl<AuthBloc>(),
        ),
      ],
      child: MaterialApp(
        title: 'Tempura',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.dark,
        theme: AppTheme.darkGoldTheme,
        darkTheme: AppTheme.darkGoldTheme,
        home: initialScreen,
      ),
    );
  }
}
