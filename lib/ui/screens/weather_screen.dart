import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../models/weather.dart';
import '../../services/weather_service.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({Key? key}) : super(key: key);

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final _controller = TextEditingController(text: 'Querétaro,MX');
  final _service = WeatherService();
  Weather? _weather;
  String? _error;
  bool _loading = false;

  void _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
      _weather = null;
    });

    final city = _controller.text;
    try {
      final res = await _service.fetchWeather(city);
      setState(() {
        _weather = res;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Si quieres cargar automáticamente al abrir
    // WidgetsBinding.instance.addPostFrameCallback((_) => _fetch());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OpenWeather · Demo')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Ciudad',
                hintText: 'Ej: Querétaro,MX',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _fetch,
                ),
              ),
              onSubmitted: (_) => _fetch(),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Builder(builder: (_) {
                if (_loading) return const Center(child: CircularProgressIndicator());
                if (_error != null) return _buildError(_error!);
                if (_weather == null) return _buildEmpty();
                return _buildWeather(_weather!);
              }),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() => Center(child: Text('Introduce una ciudad y presiona buscar'));

  Widget _buildError(String err) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade700),
            const SizedBox(height: 8),
            Text(err, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _fetch, child: const Text('Reintentar'))
          ],
        ),
      );

  Widget _buildWeather(Weather w) {
  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          w.city,
          style: Theme.of(context).textTheme.headlineMedium, // antes headline5
        ),
        const SizedBox(height: 8),
        Text(
          '${w.temp.toStringAsFixed(1)} °C',
          style: Theme.of(context).textTheme.displayMedium, // antes headline4
        ),
        const SizedBox(height: 8),
        Text(
          w.description,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Humedad: ${w.humidity}%',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    ),
  );
  }
}