import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/additional_info_item.dart';
import 'package:weather_app/hourly_forcaste_item.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/secrets.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<Map<String, dynamic>> weather;
  Future<Map<String, dynamic>> getCurrentWeather() async{
  try {
    String cityName = 'London';
    final res = await http.get(
      Uri.parse('https://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=$openWeatherAPIKey'),
    );
    
    final data = jsonDecode(res.body);

    if (data['cod'] != '200') {
      throw data['message'];
      // throw ' An unexpected error occured';
    }

    return data;

  } catch (e) {
    throw e.toString();
  }
  }

  @override
  void initState() {
    super.initState();
    weather = getCurrentWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text (
          'Weather App',
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                weather = getCurrentWeather();
              });
            },
            icon: const Icon(Icons.refresh),
            padding: const EdgeInsets.only(right:20.0),
            ),
        ],
      ),


      body: FutureBuilder(
        future: weather,
        builder:(context,snapshot) {
          
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator.adaptive(), //adaptive changes CircularProgressIndicator based on operating system its on.
            );
          }

          if(snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final data = snapshot.data!;

          final cuurrentWeatherData = data['list'][0];
          final currentTemp = cuurrentWeatherData['main']['temp'];
          final currentSky = cuurrentWeatherData['weather'][0]['main'];

          final currentPressure = cuurrentWeatherData['main']['pressure'];
          final currentHumidity = cuurrentWeatherData['main']['humidity'];
          final currentWindSpeed = cuurrentWeatherData['wind']['speed'];

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                    
                    
                //main card Section
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    elevation: 20,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusGeometry.circular(16.0),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadiusGeometry.circular(16.0),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX:10, sigmaY:10),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text('${(currentTemp - 273.15).toStringAsFixed(2)} °C',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Icon(
                                currentSky == 'Clouds'
                                  ? Icons.cloud
                                  : currentSky == 'Rain'
                                    ? Icons.cloudy_snowing
                                    : currentSky == 'Clear'
                                      ? Icons.wb_sunny
                                      : Icons.cloud,
                                size: 64,
                              ),
                              const SizedBox(height: 16),
                              Text('$currentSky',
                              style: TextStyle(
                                fontSize: 24,
                              ),
                              ),
                            ]
                          ),
                        ),
                      ),
                    )
                  ),
                ),
                const SizedBox(height: 20),
            
                    
                // WeatherForecast Cards Section
                Align(
                  alignment: Alignment.centerLeft,
                  child: const Text('Hourly Forecast',              
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,                
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                    
                // HourlyForecast Cards
                // SingleChildScrollView(
                //   scrollDirection: Axis.horizontal,
                //   child: Row(
                //     children: [
                //       for (int i = 0; i < 12; i++)
                //       HourlyForecastWidget(
                //         icon: data['list'][i+1]['weather'][0]['main'] == 'Clouds' || data['list'][i+1]['weather'][0]['main'] == 'Rain' 
                //           ? Icons.cloud 
                //           : Icons.sunny,
                //         time: data['list'][i+1]['dt'].toString(),
                //         temp: data['list'][i+1]['main']['temp'].toString(),
                //       ),            
                //     ],
                //   ),
                // ),
            
                SizedBox(
                  height: 120,
                  child: ListView.builder( // list view builder is used to build cards only when we scroll to them, thus improving performance.
                    itemCount: 12,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      final hourlyForecast = data['list'][index+1];
                      final hourlySky = data['list'][index+1]['weather'][0]['main'];
                      final hourlyTemp = hourlyForecast['main']['temp'].toString();
                      final time = DateTime.parse(hourlyForecast['dt_txt']);
                      return HourlyForecastWidget(
                        icon: hourlySky == 'Clouds'
                            ? Icons.cloud
                            : hourlySky == 'Rain'
                              ? Icons.cloudy_snowing
                              : hourlySky == 'Clear'
                                ? Icons.wb_sunny
                                : Icons.cloud,
                        //time: DateFormat('HH:mm').format(time),
                        //If you want 12-hour format with AM/PM
                        time: DateFormat('h a').format(time),
                        temp: '${(double.parse(hourlyTemp) - 273.15).toStringAsFixed(2)} °C',
                      );
                    }
                    ),
                ),
                const SizedBox(height: 20),
                  
                
              // Additional Information Section
              Align(
                alignment: Alignment.centerLeft,
                child: const Text('Additional Information',              
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,                
                  ),
                ),
              ),
              const SizedBox(height: 12),
               Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: AdditionalInfoItem(
                      icon: Icons.water_drop,
                      label: 'Humidity',
                      value: '${currentHumidity.toString()}%',
                    ),
                  ),
                    
                  Expanded(
                    child: AdditionalInfoItem(
                      icon: Icons.air,
                      label: 'Wind Speed',
                      value: '${(currentWindSpeed * 3.6).toStringAsFixed(2)} km/h',
                    ),
                  ),
                    
                  Expanded(
                    child: AdditionalInfoItem(
                      icon: Icons.thermostat,
                      label: 'Pressure',
                      value: '${currentPressure.toString()} hPa',  // hPa = hetropascal
                    ),
                  ),
                ],
              ),
                
              ],
            ),
          ),
             );
        },
      ),
    );
  }
}



