class Weather {
  final String city;
  final double temp;
  final String description;
  final int humidity;

  Weather({required this.city, required this.temp, required this.description, required this.humidity});

  factory Weather.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as String? ?? '—';
    final main = json['main'] as Map<String, dynamic>? ?? {};
    final weatherList = json['weather'] as List<dynamic>? ?? [];
    final desc = (weatherList.isNotEmpty) ? (weatherList[0]['description'] as String?) ?? '—' : '—';

    return Weather(
      city: name,
      temp: (main['temp'] as num?)?.toDouble() ?? 0.0,
      description: desc,
      humidity: (main['humidity'] as num?)?.toInt() ?? 0,
    );
  }
}