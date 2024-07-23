import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LocationsDropdown extends StatefulWidget {
  final TextEditingController textEditingController;
  final void Function(String selectedLocation)? onChanged;

  const LocationsDropdown({
    Key? key,
    required this.textEditingController,
    this.onChanged,
  }) : super(key: key);

  @override
  _LocationsDropdownState createState() => _LocationsDropdownState();
}

class _LocationsDropdownState extends State<LocationsDropdown> {
  String? _selectedLocation;
  List<String> locationList = [];

  @override
  void initState() {
    super.initState();
    _fetchLocations();
  }

  Future<void> _fetchLocations() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('ألمواقع').get();
    setState(() {
      locationList =
          querySnapshot.docs.map((doc) => doc['name'] as String).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            Container(
              height: 50, // Set the height as per your requirement
              width: MediaQuery.of(context).size.width * 0.21,
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(15), // Set the border radius
                border: Border.all(
                  width: 0.5, // Set the border width
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: DropdownButton<String>(
                  value: _selectedLocation,
                  onChanged: (newValue) {
                    setState(() {
                      _selectedLocation = newValue;
                      widget.textEditingController.text =
                          _selectedLocation ?? '';

                      if (widget.onChanged != null) {
                        widget.onChanged!(newValue!);
                      }
                    });
                  },
                  items: locationList.map((location) {
                    return DropdownMenuItem<String>(
                      value: location,
                      child: Text(location),
                    );
                  }).toList(),
                  hint: const Text('اختيار الموقع'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
