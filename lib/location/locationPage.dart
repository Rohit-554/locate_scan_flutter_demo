import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutterdemoapp/barcode_scanner/bar_code_scanner.dart';
import 'package:flutterdemoapp/location/mapscreen.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../colors/AppColors.dart';

class LocationPage extends HookWidget {
  const LocationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _currentAddress = useState<String?>(null);
    final _currentPosition = useState<Position?>(null);

    Future<bool> _handleLocationPermission() async {
      bool _serviceEnabled;
      LocationPermission _permission;

      _serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!_serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location services are disabled.')));
        return false;
      }

      _permission = await Geolocator.checkPermission();
      if (_permission == LocationPermission.denied) {
        _permission = await Geolocator.requestPermission();
        if (_permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permissions are denied')));
          return false;
        }
      }

      if (_permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Location permissions are permanently denied, we cannot request permissions.'),
          ),
        );
        return false;
      }

      return true;
    }

    Future<void> _getAddressFromLatLng(Position position) async {
      final placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        final place = placemarks[0];
        _currentAddress.value =
            '${place.street}, ${place.subLocality}, ${place.subAdministrativeArea}, ${place.postalCode}';
      }
    }

    Future<void> _getCurrentPosition() async {
      final hasPermission = await _handleLocationPermission();

      if (!hasPermission) return;

      try {
        final position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        _currentPosition.value = position;
        _getAddressFromLatLng(position);
      } catch (e) {
        debugPrint(e.toString());
      }
    }

    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Theme(
        data: ThemeData(
          splashColor: Colors.transparent,

          highlightColor: Colors.transparent,
        ),
        child: Scaffold(
          appBar: appBar(context),
          body: TabBarView(
            children: <Widget>[
              locationWidget(_currentPosition, _currentAddress, _getCurrentPosition,context),
              const BarCodeScanner(),

            ],
          ),
        ),
      ),
    );
  }

  AppBar appBar(BuildContext context) {
    return AppBar(
      elevation: 0.5,
      shadowColor: Theme.of(context).shadowColor,
      title: Text('Tasvir'),
      backgroundColor: appBarColor,
      scrolledUnderElevation: 0.0,
      bottom: const TabBar(
          indicatorColor: Colors.red,
          indicator: BoxDecoration(
            border: Border(bottom: BorderSide(color: themeColor, width: 2.0)),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: Colors.black,
          labelStyle: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
          ),
          tabs: <Widget>[
            Tab(
              text: 'Location & Map',
            ),
            Tab(
              text: 'Bar Code scanner',
            ),
          ]),
    );
  }

  Center locationWidget(
      ValueNotifier<Position?> _currentPosition,
      ValueNotifier<String?> _currentAddress,
      Future<void> Function() _getCurrentPosition,
      BuildContext context,
      ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Latitude: ${_currentPosition.value?.latitude ?? 'N/A'}'),
          Text('Longitude: ${_currentPosition.value?.longitude ?? 'N/A'}'),
          Text('Address: ${_currentAddress.value ?? 'N/A'}'),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton(
              onPressed: () async {
                _currentPosition.value = null;


                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                );

                await _getCurrentPosition();

                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32.0),
                ),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Get Coordinates'),
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton(
              onPressed: _currentPosition.value != null
                  ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MapScreen(
                      latitude:
                      _currentPosition.value?.latitude ?? 0.0,
                      longitude:
                      _currentPosition.value?.longitude ?? 0.0,
                    ),
                  ),
                );
              }
                  : null,
              child: const Text('View on Map'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32.0),
                ),
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ),
        ],
      ),
    );
  }

}



