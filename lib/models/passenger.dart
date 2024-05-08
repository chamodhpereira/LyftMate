import 'package:cloud_firestore/cloud_firestore.dart';

class Passenger {
  final String id;
  final String name;
  double rating; // Add a rating property
  final String profileImageUrl; // Add profile image URL property

  Passenger({
    required this.id,
    required this.name,
    this.rating = 0.0, // Initialize rating with a default value
    this.profileImageUrl = '', // Initialize with default empty string
  });
}

class PassengerRepository {
  // Future<List<Passenger>> fetchPassengersForRide(String rideId) async {
  //   try {
  //     final rideSnapshot = await FirebaseFirestore.instance.collection('rides').doc(rideId).get();
  //     if (rideSnapshot.exists) {
  //       List<Map<String, dynamic>> passengerData = List<Map<String, dynamic>>.from(rideSnapshot.data()!['passengers']);
  //
  //       // Corrected: Cast to List<String>
  //       List<String> userIds = passengerData.map<String>((data) => data['userId']).toList();
  //
  //       Map<String, String> userNames = await fetchUserNames(userIds);
  //
  //       print("THISSSSI SSSSSSS UDERNAMESSS: $userNames");
  //
  //       // Map passenger data to Passenger objects with names
  //       List<Passenger> passengers = passengerData.map((data) {
  //         String userId = data['userId'];
  //         String name = userNames[userId] ?? 'Unknown';
  //         return Passenger(
  //           id: userId,
  //           name: name,
  //           rating: data['rating'] ?? 0.0,
  //         );
  //       }).toList();
  //
  //       return passengers;
  //     }
  //     return [];
  //   } catch (error) {
  //     print('Error fetching passengers for ride: $error');
  //     return [];
  //   }
  // }


  // Future<List<Passenger>> fetchPassengersForRide(String rideId) async {
  //   try {
  //     final rideSnapshot = await FirebaseFirestore.instance.collection('rides')
  //         .doc(rideId)
  //         .get();
  //     if (rideSnapshot.exists) {
  //       List<Map<String, dynamic>> passengerData = List<
  //           Map<String, dynamic>>.from(rideSnapshot.data()!['passengers']);
  //
  //       // Get a list of passenger IDs
  //       List<String> passengerIds = passengerData.map<String>((
  //           data) => data['userId']).toList();
  //
  //       // Fetch user names for the passenger IDs
  //       Map<String, String> userNames = await fetchUserNames(passengerIds);
  //
  //       print('User names: $userNames');
  //
  //       // Map passenger data to Passenger objects with names
  //       List<Passenger> passengers = passengerData.map((data) {
  //         String passengerId = data['userId'];
  //         String name = userNames[passengerId] ?? 'Unknown';
  //         return Passenger(
  //           id: passengerId,
  //           name: name,
  //           rating: data['rating'] ?? 0.0,
  //         );
  //       }).toList();
  //
  //       return passengers;
  //     }
  //     return [];
  //   } catch (error) {
  //     print('Error fetching passengers for ride: $error');
  //     return [];
  //   }
  // }


  Future<List<Passenger>> fetchPassengersForRide(String rideId) async {
    try {
      final rideSnapshot = await FirebaseFirestore.instance.collection('rides')
          .doc(rideId)
          .get();
      if (rideSnapshot.exists) {
        List<Map<String, dynamic>> passengerData = List<Map<String, dynamic>>.from(rideSnapshot.data()!['passengers']);
        print('Fetched passenger data: $passengerData');  // Debug statement for passenger data

        // Get a list of passenger IDs
        List<String> passengerIds = passengerData.map<String>((data) => data['userId']).toList();
        print('Passenger IDs: $passengerIds');  // Debug statement for passenger IDs

        // Fetch user details for the passenger IDs
        Map<String, Map<String, dynamic>> userDetails = await fetchUserDetails(passengerIds);
        print('User details fetched: $userDetails');  // Debug statement for user details

        // Map passenger data to Passenger objects with additional details
        List<Passenger> passengers = passengerData.map((data) {
          String passengerId = data['userId'];
          Map<String, dynamic> details = userDetails[passengerId] ?? {};
          String name = details['name'] ?? 'Unknown';
          String profileImageUrl = details['profileImageUrl'] ?? '';
          return Passenger(
            id: passengerId,
            name: name,
            rating: data['rating'] ?? 0.0,
            profileImageUrl: profileImageUrl,
          );
        }).toList();

        return passengers;
      }
      return [];
    } catch (error) {
      print('Error fetching passengers for ride: $error');
      return [];
    }
  }

  Future<Map<String, Map<String, dynamic>>> fetchUserDetails(List<String> userIds) async {
    Map<String, Map<String, dynamic>> userDetails = {};
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('users').where(FieldPath.documentId, whereIn: userIds).get();
      print('Query snapshot length: ${querySnapshot.docs.length}'); // Debug statement

      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;  // Cast to Map<String, dynamic>

        String name = 'Unknown';  // Default name if no data found
        if (data.containsKey('firstName') && data.containsKey('lastName')) {
          name = '${data['firstName']} ${data['lastName']}';
        }

        String profileImageUrl = '';  // Default empty string for profile image URL
        if (data.containsKey('profileImageUrl')) {
          profileImageUrl = data['profileImageUrl'];
        }

        userDetails[doc.id] = {
          'name': name,
          'profileImageUrl': profileImageUrl,
        };
        print('Processed user details for ID ${doc.id}: ${userDetails[doc.id]}'); // Debug statement for each user detail
      }
    } catch (error) {
      print('Error fetching user details: $error');
    }
    return userDetails;
  }
  // Future<Map<String, String>> fetchUserNames(List<String> userIds) async {
  //   try {
  //     Map<String, String> userNames = {};
  //
  //     // Query the Firestore collection to fetch user documents
  //     // QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('users').where('userId', whereIn: userIds).get();
  //     QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('users').where(FieldPath.documentId, whereIn: userIds).get();
  //
  //     print('Query snapshot length: ${querySnapshot.docs.length}'); // Debug statement
  //
  //     // Iterate through the documents and extract user names
  //     // Iterate through the query snapshot and populate the userNames map
  //     querySnapshot.docs.forEach((doc) {
  //       // Check if the document ID is in the list of user IDs
  //       if (userIds.contains(doc.id)) {
  //         userNames[doc.id] = doc['firstName'] + ' ' + doc['lastName']; // Adjust based on your user document structure
  //       }
  //     });
  //
  //     print('User names: $userNames'); // Debug statement
  //
  //     return userNames;
  //   } catch (error) {
  //     print('Error fetching user names: $error');
  //     return {};
  //   }
  // }

  Future<void> updatePassengerRating(String passengerId, double newRating) async {
    try {
      // Fetch the current rating of the passenger
      DocumentSnapshot passengerSnapshot = await FirebaseFirestore.instance.collection('users').doc(passengerId).get();

      // Get the current rating from the document snapshot and cast it to double
      double currentRating = (passengerSnapshot.get('ratings') ?? 0).toDouble();

      // Calculate the new rating by averaging the current rating and the new rating
      double updatedRating = (currentRating + newRating) / 2;

      // Update the rating field of the passenger document with the new rating
      await FirebaseFirestore.instance.collection('users').doc(passengerId).update({
        'ratings': updatedRating,
      });

      print('Passenger rating updated successfully: Passenger ID: $passengerId, New Rating: $updatedRating');
    } catch (error) {
      print('Error updating passenger rating: $error');
    }
  }
}

