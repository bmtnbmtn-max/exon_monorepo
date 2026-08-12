import 'package:exon_admin/screens/home_screen.dart';
import 'package:exon_admin/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://innbcavuxbnzvztlehoy.supabase.co',
    anonKey: 'sb_publishable_5C1MC8lQw2h7ReG6XJPx3Q_MeJ18a0j',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Exon Admin',

      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueGrey,
          brightness: Brightness.light,
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blueGrey,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 2,
        ),

        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.blueGrey,
          foregroundColor: Colors.white,
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueGrey, // බටන් එකේ බැක්ග්‍රවුන්ඩ් පාට
            foregroundColor: Colors.white, // අකුරු වල පාට
            minimumSize: const Size(double.infinity, 50), // බටන් එකේ ප්‍රමාණය
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10), // දාර වටකුරු කිරීම
            ),
          ),
        ),

        snackBarTheme: SnackBarThemeData(
          backgroundColor: Colors.black,
          contentTextStyle: const TextStyle(color: Colors.red),
          behavior:
              SnackBarBehavior.floating, // ස්නැක්බාර් එක පාවෙන පෙනුමක් ලබා දෙයි
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // දාර වටකුරු කිරීම
          ),
        ),

        cardTheme: CardThemeData(
          color: Colors.white, // Card එකේ background පාට
          elevation: 3, // Card එක ඉස්සිලා පේන ප්‍රමාණය (Shadow)
          shadowColor: Colors.black26, // shadow එකේ පාට
          margin: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 6,
          ), // Card එක වටා ඉඩ
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // දාර වටකුරු කිරීම
            side: BorderSide(
              color: Colors.blueGrey,
              width: 1,
            ), // සිහින් border එකක්
          ),
        ),
      ),

      // පේළි අංක 65 සිට මේ විදිහට update කරන්න
      initialRoute: '/', // මුලින්ම පෙන්විය යුතු Screen එකේ නම
      routes: {
        '/': (context) => const LoginScreen(), // මුලින්ම Login පෙන්වන්න
        '/home': (context) => const HomeScreen(), // Home එකට යන පාර
      },
    );
  }
}
