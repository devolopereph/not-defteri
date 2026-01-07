import 'package:epheproject/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/constants/app_constants.dart';
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
import 'features/notes/presentation/pages/onboarding_page.dart';

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

class MyApp extends StatefulWidget {
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
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool _showOnboarding;

  @override
  void initState() {
    super.initState();
    // Onboarding tamamlanmış mı kontrol et
    _showOnboarding =
        !(widget.prefs.getBool(AppConstants.onboardingCompletedKey) ?? false);
  }

  void _completeOnboarding() {
    widget.prefs.setBool(AppConstants.onboardingCompletedKey, true);
    setState(() {
      _showOnboarding = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<NoteRepository>.value(value: widget.noteRepository),
        RepositoryProvider<FolderRepository>.value(
          value: widget.folderRepository,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          // Tema yönetimi
          BlocProvider(create: (_) => ThemeCubit(widget.prefs)),
          // Dil yönetimi
          BlocProvider(create: (_) => LocaleCubit(widget.prefs)),
          // Not yönetimi
          BlocProvider(
            create: (_) =>
                NotesBloc(widget.noteRepository)..add(const LoadNotes()),
          ),
          // Klasör yönetimi
          BlocProvider(
            create: (_) =>
                FoldersBloc(widget.folderRepository)..add(const LoadFolders()),
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
                  home: _showOnboarding
                      ? OnboardingPage(onCompleted: _completeOnboarding)
                      : const HomeScreen(),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
