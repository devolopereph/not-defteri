import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:equatable/equatable.dart';

part 'locale_state.dart';

/// Dil yönetimi için Cubit
class LocaleCubit extends Cubit<LocaleState> {
  static const String _localeKey = 'app_locale';
  final SharedPreferences _prefs;

  LocaleCubit(this._prefs) : super(LocaleState.initial()) {
    _loadLocale();
  }

  /// Desteklenen diller
  static const List<Locale> supportedLocales = [
    Locale('en'), // English
    Locale('tr'), // Turkish
  ];

  /// Kayıtlı dil tercihini yükle
  void _loadLocale() {
    final localeCode = _prefs.getString(_localeKey);
    if (localeCode != null) {
      final locale = Locale(localeCode);
      if (supportedLocales.contains(locale)) {
        emit(LocaleState(locale: locale));
      }
    }
  }

  /// Dili değiştir
  void setLocale(Locale locale) {
    if (supportedLocales.contains(locale)) {
      _prefs.setString(_localeKey, locale.languageCode);
      emit(LocaleState(locale: locale));
    }
  }

  /// Mevcut dil kodu
  String get languageCode => state.locale.languageCode;
}
