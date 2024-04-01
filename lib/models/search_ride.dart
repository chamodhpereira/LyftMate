// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:geoflutterfire2/geoflutterfire2.dart';
//
// class RideSearch {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final GeoFlutterFire _geo = GeoFlutterFire();
//
//   Stream<List<DocumentSnapshot>> filterRidesByDestinationNearUser(
//       GeoFirePoint userLocation, GeoFirePoint userDestination) {
//     double radius = 50; // Adjust this radius as needed
//     GeoFirePoint userDestinationNear = GeoFirePoint(
//         (userDestination.latitude + userLocation.latitude) / 2,
//         (userDestination.longitude + userLocation.longitude) / 2);
//
//     var collectionReference = _firestore.collection('rides');
//     var query = collectionReference
//         .where('destination',
//         isLessThanOrEqualTo: _geo.point(
//           latitude: userDestinationNear.latitude,
//           longitude: userDestinationNear.longitude,
//         )
//             .distance(
//           center: _geo.point(
//             latitude: userLocation.latitude,
//             longitude: userLocation.longitude,
//           ),
//           radius: radius,
//           field: 'position', // assuming 'position' is the field containing GeoFirePoint
//           strictMode: true,
//         ))
//         .where('destination',
//         isGreaterThanOrEqualTo: _geo.point(
//           latitude: userDestinationNear.latitude,
//           longitude: userDestinationNear.longitude,
//         )
//             .distance(
//           center: _geo.point(
//             latitude: userLocation.latitude,
//             longitude: userLocation.longitude,
//           ),
//           radius: 0,
//           field: 'position', // assuming 'position' is the field containing GeoFirePoint
//           strictMode: true,
//         ));
//
//     return _geo.collection(collectionRef: query).within(
//       center: userLocation,
//       radius: radius,
//       field: 'position', // assuming 'position' is the field containing GeoFirePoint
//     );
//   }
// }
