import 'package:epheproject/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'core/locale/locale_cubit.dart';
import 'features/notes/data/datasources/note_local_data_source.dart';
import 'features/notes/data/datasources/folder_local_data_source.dart';
import 'features/notes/data/repositories/note_repository_impl.dart';
import 'features/notes/data/repositories/folder_repository_impl.dart';
import 'features/notes/domain/repositories/note_repository.dart';
import 'features/notes/domain/repositories/folder_repository.dart';
import 'features/notes/presentation/bloc/notes_bloc.dart';
import 'features/notes/presentation/bloc/folders_bloc.dart';
import 'features/notes/presentation/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // SharedPreferences başlat
  final prefs = await SharedPreferences.getInstance();

  // Veritabanı yardımcısı
  final dbHelper = DatabaseHelper.instance;
  final localDataSource = NoteLocalDataSource(dbHelper);
  final folderLocalDataSource = FolderLocalDataSource(dbHelper);
  final noteRepository = NoteRepositoryImpl(localDataSource);
  final folderRepository = FolderRepositoryImpl(folderLocalDataSource);

  runApp(
    MyApp(
      prefs: prefs,
      noteRepository: noteRepository,
      folderRepository: folderRepository,
    ),
  );
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  final NoteRepository noteRepository;
  final FolderRepository folderRepository;

  const MyApp({
    super.key,
    required this.prefs,
    required this.noteRepository,
    required this.folderRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<NoteRepository>.value(value: noteRepository),
        RepositoryProvider<FolderRepository>.value(value: folderRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          // Tema yönetimi
          BlocProvider(create: (_) => ThemeCubit(prefs)),
          // Dil yönetimi
          BlocProvider(create: (_) => LocaleCubit(prefs)),
          // Not yönetimi
          BlocProvider(
            create: (_) => NotesBloc(noteRepository)..add(const LoadNotes()),
          ),
          // Klasör yönetimi
          BlocProvider(
            create: (_) =>
                FoldersBloc(folderRepository)..add(const LoadFolders()),
          ),
        ],
        child: BlocBuilder<ThemeCubit, ThemeState>(
          builder: (context, themeState) {
            return BlocBuilder<LocaleCubit, LocaleState>(
              builder: (context, localeState) {
                return MaterialApp(
                  onGenerateTitle: (context) =>
                      AppLocalizations.of(context)!.appTitle,
                  debugShowCheckedModeBanner: false,
                  theme: AppTheme.lightTheme,
                  darkTheme: AppTheme.darkTheme,
                  themeMode: themeState.themeMode,
                  locale: localeState.locale,
                  localizationsDelegates: const [
                    AppLocalizations.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  supportedLocales: AppLocalizations.supportedLocales,
                  home: const HomeScreen(),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
