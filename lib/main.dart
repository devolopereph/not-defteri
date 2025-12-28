import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'features/notes/data/datasources/note_local_data_source.dart';
import 'features/notes/data/repositories/note_repository_impl.dart';
import 'features/notes/domain/repositories/note_repository.dart';
import 'features/notes/presentation/bloc/notes_bloc.dart';
import 'features/notes/presentation/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // SharedPreferences başlat
  final prefs = await SharedPreferences.getInstance();

  // Veritabanı yardımcısı
  final dbHelper = DatabaseHelper.instance;
  final localDataSource = NoteLocalDataSource(dbHelper);
  final noteRepository = NoteRepositoryImpl(localDataSource);

  runApp(MyApp(prefs: prefs, noteRepository: noteRepository));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  final NoteRepository noteRepository;

  const MyApp({super.key, required this.prefs, required this.noteRepository});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Tema yönetimi
        BlocProvider(create: (_) => ThemeCubit(prefs)),
        // Not yönetimi
        BlocProvider(
          create: (_) => NotesBloc(noteRepository)..add(const LoadNotes()),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            title: 'Stitch Notes',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeState.themeMode,
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
