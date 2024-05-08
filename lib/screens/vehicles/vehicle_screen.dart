import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Vehicle {
  String make;
  String model;
  String licensePlate;

  Vehicle({required this.make, required this.model, required this.licensePlate});

  Map<String, dynamic> toJson() => {
    'make': make,
    'model': model,
    'licensePlate': licensePlate,
  };

  static Vehicle fromJson(Map<String, dynamic> json) => Vehicle(
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
  User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    if (user != null) {
      _loadVehicles();
    }
  }

  void _loadVehicles() async {
    final snapshot = await _firestore
        .collection('users')
        .doc(user!.uid)
        .collection('vehicles')
        .get();

    setState(() {
      vehicles = snapshot.docs.map((doc) => Vehicle.fromJson(doc.data())).toList();
    });
  }

  void _addVehicleDialog() async {
    String make = '', model = '', licensePlate = '';
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New Vehicle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Make'),
                onChanged: (value) => make = value,
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Model'),
                onChanged: (value) => model = value,
              ),
              TextField(
                decoration: InputDecoration(labelText: 'License Plate'),
                onChanged: (value) => licensePlate = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final vehicle = Vehicle(make: make, model: model, licensePlate: licensePlate);
                await _firestore
                    .collection('users')
                    .doc(user!.uid)
                    .collection('vehicles')
                    .add(vehicle.toJson());
                Navigator.of(context).pop(); // Close the dialog
                _loadVehicles(); // Refresh the list
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Vehicles'),
      ),
      body: vehicles.isEmpty
          ? Center(
        child: ElevatedButton(
          child: Text('Add New Vehicle'),
          onPressed: _addVehicleDialog,
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
              // Add edit functionality if needed
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: _addVehicleDialog,
      ),
    );
  }
}




// import 'package:flutter/material.dart';
//
// class AddVehicleScreen extends StatefulWidget {
//   @override
//   _AddVehicleScreenState createState() => _AddVehicleScreenState();
// }
//
// class _AddVehicleScreenState extends State<AddVehicleScreen> {
//   List<Map<String, dynamic>> vehicles = [];
//
//   void _addVehicle() {
//     setState(() {
//       vehicles.add({
//         'make': '',
//         'model': '',
//         'licensePlate': '',
//         'color': '',
//       });
//     });
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _addVehicle(); // Start with one vehicle
//   }
//
//   Widget _vehicleCard(int index) {
//     return Card(
//       margin: EdgeInsets.all(10),
//       child: Padding(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           children: [
//             TextField(
//               onChanged: (value) {
//                 vehicles[index]['make'] = value;
//               },
//               decoration: InputDecoration(
//                 labelText: 'Make (e.g. Toyota)',
//               ),
//             ),
//             TextField(
//               onChanged: (value) {
//                 vehicles[index]['model'] = value;
//               },
//               decoration: InputDecoration(
//                 labelText: 'Model (e.g. Corolla)',
//               ),
//             ),
//             TextField(
//               onChanged: (value) {
//                 vehicles[index]['licensePlate'] = value;
//               },
//               decoration: InputDecoration(
//                 labelText: 'License Plate Number',
//               ),
//             ),
//             TextField(
//               onChanged: (value) {
//                 vehicles[index]['color'] = value;
//               },
//               decoration: InputDecoration(
//                 labelText: 'Color (e.g. Red)',
//               ),
//             ),
//             SizedBox(height: 20),
//             if (vehicles.length > 1)
//               OutlinedButton(
//                 child: Text('Remove Vehicle'),
//                 onPressed: () {
//                   setState(() {
//                     vehicles.removeAt(index);
//                   });
//                 },
//               ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Add Your Vehicles'),
//       ),
//       body: ListView(
//         children: [
//           ...vehicles.asMap().entries.map((entry) => _vehicleCard(entry.key)),
//           Padding(
//             padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
//             child: TextButton.icon(
//               icon: Icon(Icons.add),
//               label: Text('Add New Vehicle'),
//               onPressed: _addVehicle,
//             ),
//           ),
//           ElevatedButton(
//             child: Text('Save'),
//             onPressed: () {
//               // TODO: Save vehicles to database or state management
//               print('Vehicles: $vehicles');
//             },
//             style: ElevatedButton.styleFrom(
//               // backgroundColor: Theme.of(context).primaryColor,
//               minimumSize: Size(double.infinity, 50), // double.infinity is the width and 50 is the height
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }