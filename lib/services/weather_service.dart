import 'dart:async';
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/weather.dart';

class WeatherException implements Exception {
  final String message;
  WeatherException(this.message);
  @override
  String toString() => 'WeatherException: $message';
}

class WeatherService {
  final _client = http.Client();
  final _cache = <String, Map<String, dynamic>>{}; // city -> {ts, data}
  final Duration cacheTTL = Duration(minutes: 10);

  Future<Weather> fetchWeather(String city) async {
    final sanitizedCity = _sanitizeCity(city);
    if (sanitizedCity.isEmpty) throw WeatherException('Ciudad inválida');

    // Cache check
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    final cached = _cache[sanitizedCity.toLowerCase()];
    if (cached != null) {
      final ts = cached['ts'] as int? ?? 0;
      if (now - ts < cacheTTL.inMilliseconds) {
        final data = cached['data'] as Map<String, dynamic>;
        return Weather.fromJson(data);
      }
    }

    final apiKey = dotenv.env['OPENWEATHER_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) throw WeatherException('API key no configurada');

    final uri = Uri.https('api.openweathermap.org', '/data/2.5/weather', {
      'q': sanitizedCity,
      'appid': apiKey,
      'units': 'metric',
      'lang': 'es'
    });

    const int maxAttempts = 3;
    int attempt = 0;
    int delayMillis = 500; // base backoff

    while (true) {
      attempt++;
      try {
        final resp = await _client.get(uri).timeout(const Duration(seconds: 8));

        if (resp.statusCode == 200) {
          final jsonData = json.decode(resp.body) as Map<String, dynamic>;
          // Defensive check
          if (jsonData['cod'] != 200 && jsonData['cod'] != '200') {
            throw WeatherException('Respuesta inesperada del servidor');
          }

          // Cache store
          _cache[sanitizedCity.toLowerCase()] = {
            'ts': DateTime.now().toUtc().millisecondsSinceEpoch,
            'data': jsonData,
          };

          return Weather.fromJson(jsonData);
        } else if (resp.statusCode == 404) {
          throw WeatherException('Ciudad no encontrada (404)');
        } else if (resp.statusCode == 429) {
          // Rate limit — retry with backoff if attempts left
          if (attempt >= maxAttempts) throw WeatherException('Demasiadas solicitudes (429)');
          await Future.delayed(Duration(milliseconds: delayMillis));
          delayMillis *= 2;
          continue;
        } else if (resp.statusCode >= 500 && attempt < maxAttempts) {
          // Server error — retry
          await Future.delayed(Duration(milliseconds: delayMillis));
          delayMillis *= 2;
          continue;
        } else {
          throw WeatherException('Error en la petición: ${resp.statusCode}');
        }
      } on TimeoutException {
        if (attempt >= maxAttempts) rethrow;
        await Future.delayed(Duration(milliseconds: delayMillis));
        delayMillis *= 2;
        continue;
      } on http.ClientException catch (e) {
        throw WeatherException('Error de conexión: ${e.message}');
      } catch (e) {
        if (e is WeatherException) rethrow;
        throw WeatherException('Error desconocido: $e');
      }
    }
  }

  String _sanitizeCity(String input) {
    // Elimina caracteres de control, trims, limita longitud y permite letras, espacios y comas
    var s = input.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '');
    s = s.trim();
    if (s.length > 60) s = s.substring(0, 60);
    // Permitir letras, números, espacios, guiones y comas (para "Querétaro,MX")
    s = s.replaceAll(RegExp(r"[^\p{L}0-9 ,\-']", unicode: true), '');
    return s;
  }
}