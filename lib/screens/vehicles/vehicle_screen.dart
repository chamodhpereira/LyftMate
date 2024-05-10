import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Vehicle {
  String id;
  String make;
  String model;
  String licensePlate;

  Vehicle({required this.id, required this.make, required this.model, required this.licensePlate});

  Map<String, dynamic> toJson() => {
    'make': make,
    'model': model,
    'licensePlate': licensePlate,
  };

  static Vehicle fromJson(String id, Map<String, dynamic> json) => Vehicle(
    id: id,
    make: json['make'],
    model: json['model'],
    licensePlate: json['licensePlate'],
  );
}

class VehicleScreen extends StatefulWidget {
  VehicleScreen({Key? key}) : super(key: key);

  @override
  _VehicleScreenState createState() => _VehicleScreenState();
}

class _VehicleScreenState extends State<VehicleScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Vehicle> vehicles = [];
  bool isLoading = true;
  bool newVehicleAdded = false; // State variable
  User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    if (user != null) {
      _loadVehicles();
    }
  }

  // Load vehicles from Firestore
  void _loadVehicles() async {
    setState(() {
      isLoading = true;
    });

    final snapshot = await _firestore
        .collection('users')
        .doc(user!.uid)
        .collection('vehicles')
        .get();

    setState(() {
      vehicles = snapshot.docs
          .map((doc) => Vehicle.fromJson(doc.id, doc.data()))
          .toList();
      isLoading = false;
    });
  }

  // Add a new vehicle using a bottom sheet
  void _addVehicleBottomSheet() {
    String make = '', model = '', licensePlate = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      'Add New Vehicle',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    decoration: const InputDecoration(labelText: 'Make'),
                    onChanged: (value) => make = value,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: const InputDecoration(labelText: 'Model'),
                    onChanged: (value) => model = value,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: const InputDecoration(labelText: 'License Plate'),
                    onChanged: (value) => licensePlate = value,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel', style: TextStyle(color: Colors.red),),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white, backgroundColor: Colors.green, // Button text color
                        ),
                        onPressed: () async {
                          final vehicle = Vehicle(
                            id: '',
                            make: make,
                            model: model,
                            licensePlate: licensePlate,
                          );
                          await _firestore
                              .collection('users')
                              .doc(user!.uid)
                              .collection('vehicles')
                              .add(vehicle.toJson());
                          Navigator.of(context).pop();
                          _loadVehicles(); // Refresh the list

                          setState(() {
                            newVehicleAdded = true; // Update the state variable
                          });
                        },
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }



  // Delete a vehicle from Firestore
  void _deleteVehicle(String id) async {
    await _firestore
        .collection('users')
        .doc(user!.uid)
        .collection('vehicles')
        .doc(id)
        .delete();
    _loadVehicles(); // Refresh the list
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Vehicles'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(newVehicleAdded); // Return the value to the previous screen
          },
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : vehicles.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'No vehicles found.',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add a new vehicle',
              style: TextStyle(fontSize: 14),
            ),
            // ElevatedButton(
            //   child: const Text('Add New Vehicle'),
            //   onPressed: _addVehicleBottomSheet,
            // ),
          ],
        ),
      )
          : ListView.builder(
        itemCount: vehicles.length,
        itemBuilder: (context, index) {
          Vehicle vehicle = vehicles[index];
          return Card(
            child: ListTile(
              title: Text('${vehicle.make} ${vehicle.model}'),
              subtitle: Text('License Plate: ${vehicle.licensePlate}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteVehicle(vehicle.id),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green, // Change the button background color to green
        foregroundColor: Colors.white,
        onPressed: _addVehicleBottomSheet, // Set the icon color to white
        child: const Icon(Icons.add),
      ),
    );
  }
}

