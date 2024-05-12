//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:lottie/lottie.dart';

// class ReviewsScreen extends StatefulWidget {
//
//   final String rideId;
//   // final Map<String, dynamic> rideData;
//
//   const ReviewsScreen({super.key, required this.rideId});
//
//   @override
//   _ReviewsScreenState createState() => _ReviewsScreenState();
// }
//
// // class _ReviewsScreenState extends State<ReviewsScreen> {
// //   double _rating = 0;
// //   String _comment = '';
// //   bool _isLoading = false; // Track loading state
// //
// //   Future<void> _submitReview() async {
// //     setState(() {
// //       _isLoading = true; // Show loading indicator
// //     });
// //
// //     // Get the current user's ID
// //     FirebaseAuth auth = FirebaseAuth.instance;
// //     User? user = auth.currentUser;
// //     String? userId;
// //
// //     if (user != null) {
// //       userId = user.uid;
// //     } else {
// //       print('User is not signed in.');
// //       setState(() {
// //         _isLoading = false;
// //       });
// //       return; // Return early if the user is not signed in
// //     }
// //
// //     try {
// //       // Retrieve the driverId from the ride document
// //       DocumentSnapshot rideSnapshot = await FirebaseFirestore.instance
// //           .collection('rides')
// //           .doc(widget.rideId)
// //           .get();
// //       String driverId = rideSnapshot.get('driverId');
// //
// //       // Get the current rating of the driver
// //       DocumentSnapshot driverSnapshot = await FirebaseFirestore.instance
// //           .collection('users')
// //           .doc(driverId)
// //           .get();
// //
// //       double currentRating = (driverSnapshot.get('ratings') ?? 0).toDouble();
// //       // Calculate the new average rating
// //       double newRating = ((_rating + currentRating) / 2);
// //
// //       // Add the review and rating to the driver's document
// //       await FirebaseFirestore.instance.collection('users').doc(driverId).update({
// //         'ratings': FieldValue.increment(newRating),
// //         'reviews': FieldValue.arrayUnion([
// //           {
// //             'userId': userId,
// //             'rating': _rating,
// //             'comment': _comment,
// //           }
// //         ]),
// //       });
// //
// //       // Navigate to the Navigation screen after submission
// //       Navigator.pushReplacementNamed(context, '/navigationScreen');
// //     } catch (e) {
// //       print('Error submitting review: $e');
// //       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
// //         content: Text('Failed to submit review. Please try again later.'),
// //       ));
// //     } finally {
// //       setState(() {
// //         _isLoading = false; // Hide loading indicator
// //       });
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('Leave a Review'),
// //         backgroundColor: Colors.green,
// //         foregroundColor: Colors.white,
// //         elevation: 0.5,
// //       ),
// //       body: Stack(
// //         children: [
// //           Padding(
// //             padding: const EdgeInsets.only(top: 5.0),
// //             child: Align(
// //               alignment: Alignment.topCenter,
// //               child: Lottie.asset(
// //                 "assets/images/add_rating-animation.json",
// //                 height: MediaQuery.of(context).size.height * 0.3,
// //                 fit: BoxFit.cover,
// //               ),
// //             ),
// //           ),
// //           Positioned(
// //             top: 240,
// //             left: 0,
// //             right: 0,
// //             child: Padding(
// //               padding: const EdgeInsets.all(20.0),
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   const Text(
// //                     'Rate your experience',
// //                     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
// //                   ),
// //                   const SizedBox(height: 10),
// //                   Row(
// //                     children: [
// //                       for (int i = 1; i <= 5; i++)
// //                         IconButton(
// //                           icon: Icon(
// //                             Icons.star,
// //                             color: _rating >= i ? Colors.orange : Colors.grey,
// //                           ),
// //                           onPressed: () => setState(() => _rating = i),
// //                         ),
// //                     ],
// //                   ),
// //                   const SizedBox(height: 20),
// //                   const Text(
// //                     'Add a comment',
// //                     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
// //                   ),
// //                   const SizedBox(height: 10),
// //                   TextField(
// //                     maxLines: 5,
// //                     onChanged: (value) => setState(() => _comment = value),
// //                     decoration: const InputDecoration(
// //                       hintText: 'Type your comment here...',
// //                       border: OutlineInputBorder(),
// //                     ),
// //                   ),
// //                   const SizedBox(height: 40),
// //                   Center(
// //                     child: SizedBox(
// //                       width: double.infinity,
// //                       height: 45.0,
// //                       child: ElevatedButton(
// //                         style: ButtonStyle(
// //                           backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
// //                           foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
// //                         ),
// //                         onPressed: _isLoading ? null : _submitReview,
// //                         child: _isLoading
// //                             ? const CircularProgressIndicator(
// //                           valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
// //                         )
// //                             : const Text('Submit Review'),
// //                       ),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ReviewsScreen extends StatefulWidget {
  final String? rideId;

  const ReviewsScreen({super.key, this.rideId});

  @override
  _ReviewsScreenState createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  double _rating = 0;
  String _comment = '';
  bool _isLoading = false; // Loading flag

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false, // Prevents the user from going back
        child: Scaffold(
      appBar: AppBar(
        title: const Text('Leave a Review'),
        leading: Container(),
        leadingWidth: 0,// Removes the default back arrow
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: Align(
              alignment: Alignment.topCenter,
              child: Lottie.asset(
                "assets/images/add_rating-animation.json",
                height: MediaQuery.of(context).size.height * 0.3,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 240,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Rate your experience',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.star, color: _rating >= 1 ? Colors.orange : Colors.grey),
                        onPressed: () => setState(() => _rating = 1),
                      ),
                      IconButton(
                        icon: Icon(Icons.star, color: _rating >= 2 ? Colors.orange : Colors.grey),
                        onPressed: () => setState(() => _rating = 2),
                      ),
                      IconButton(
                        icon: Icon(Icons.star, color: _rating >= 3 ? Colors.orange : Colors.grey),
                        onPressed: () => setState(() => _rating = 3),
                      ),
                      IconButton(
                        icon: Icon(Icons.star, color: _rating >= 4 ? Colors.orange : Colors.grey),
                        onPressed: () => setState(() => _rating = 4),
                      ),
                      IconButton(
                        icon: Icon(Icons.star, color: _rating >= 5 ? Colors.orange : Colors.grey),
                        onPressed: () => setState(() => _rating = 5),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Add a comment',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    maxLines: 5,
                    onChanged: (value) => setState(() => _comment = value),
                    decoration: const InputDecoration(
                      hintText: 'Type your comment here...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: SizedBox(
                      width: double.infinity,
                      height: 45.0,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _isLoading
                            ? null
                            : () async {
                          setState(() => _isLoading = true); // Start loading
                          FirebaseAuth auth = FirebaseAuth.instance;
                          User? user = auth.currentUser;
                          String? userId = user?.uid;

                          if (user == null) {
                            print('User is not signed in.');
                            setState(() => _isLoading = false); // Stop loading
                            return;
                          }

                          try {
                            // Retrieve the driverId from the ride document
                            DocumentSnapshot rideSnapshot = await FirebaseFirestore.instance.collection('rides').doc(widget.rideId).get();
                            String driverId = rideSnapshot.get('driverId');

                            // Get the current rating information of the driver
                            DocumentSnapshot driverSnapshot = await FirebaseFirestore.instance.collection('users').doc(driverId).get();
                            Map<String, dynamic> driverData = driverSnapshot.data() as Map<String, dynamic>;
                            double currentRating = driverData['ratings'] ?? 0.0;
                            int numberOfRatings = driverData['numberOfRatings'] ?? 0;

                            // Calculate the new total rating
                            double newTotalRating = currentRating * numberOfRatings + _rating;
                            int newNumberOfRatings = numberOfRatings + 1;

                            // Calculate the new average rating
                            double newAverageRating = newTotalRating / newNumberOfRatings;

                            // Ensure the rating doesn't exceed 5.0
                            if (newAverageRating > 5.0) {
                              newAverageRating = 5.0;
                            }

                            // Update the driver's ratings and reviews
                            await FirebaseFirestore.instance.collection('users').doc(driverId).update({
                              'ratings': newAverageRating,
                              'numberOfRatings': newNumberOfRatings,
                              'reviews': FieldValue.arrayUnion([
                                {
                                  'userId': userId,
                                  'rating': _rating,
                                  'comment': _comment,
                                }
                              ]),
                            });
                            // Navigate to the navigation screen (replace with your navigation screen route)
                            Navigator.pushNamedAndRemoveUntil(context, '/navigationScreen', (route) => false,);
                            debugPrint("Pushing toooo navvvvvvvvvv");
                          } catch (e) {
                            print('Error submitting review: $e');
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Failed to submit review. Please try again later.'),
                              ),
                            );
                          } finally {
                            setState(() => _isLoading = false); // Stop loading
                          }
                        },
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white) // Loading indicator
                            : const Text('Submit Review'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }
}









// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:lottie/lottie.dart';
//
// class ReviewsScreen extends StatefulWidget {
//
//   final String rideId;
//   // final Map<String, dynamic> rideData;
//
//   const ReviewsScreen({super.key, required this.rideId});
//
//   @override
//   _ReviewsScreenState createState() => _ReviewsScreenState();
// }
//
// class _ReviewsScreenState extends State<ReviewsScreen> {
//   double _rating = 0;
//   String _comment = '';
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Leave a Review'),
//         backgroundColor: Colors.green,
//         foregroundColor: Colors.white,
//         elevation: 0.5,
//         leadingWidth: 50.0,
//       ),
//       body: Stack(
//         children: [
//           Padding(
//             padding: const EdgeInsets.only(top: 5.0),
//             // padding: const EdgeInsets.only(top: 50.0),
//             child: Align(
//               alignment: Alignment.topCenter,
//               child: Lottie.asset(
//                 "assets/images/add_rating-animation.json",
//                 height: MediaQuery.of(context).size.height * 0.3, // Adjust the height accordingly
//                 fit: BoxFit.cover,
//               ),
//             ),
//           ),
//           Positioned(
//             top: 240,
//             left: 0,
//             right: 0,
//             child: Padding(
//               padding: const EdgeInsets.all(20.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Rate your experience',
//                     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                   ),
//                   SizedBox(height: 10),
//                   Row(
//                     // mainAxisAlignment: MainAxisAlignment.start,
//                     children: [
//                       IconButton(
//                         icon: Icon(Icons.star, color: _rating >= 1 ? Colors.orange : Colors.grey),
//                         onPressed: () => setState(() => _rating = 1),
//                       ),
//                       IconButton(
//                         icon: Icon(Icons.star, color: _rating >= 2 ? Colors.orange : Colors.grey),
//                         onPressed: () => setState(() => _rating = 2),
//                       ),
//                       IconButton(
//                         icon: Icon(Icons.star, color: _rating >= 3 ? Colors.orange : Colors.grey),
//                         onPressed: () => setState(() => _rating = 3),
//                       ),
//                       IconButton(
//                         icon: Icon(Icons.star, color: _rating >= 4 ? Colors.orange : Colors.grey),
//                         onPressed: () => setState(() => _rating = 4),
//                       ),
//                       IconButton(
//                         icon: Icon(Icons.star, color: _rating >= 5 ? Colors.orange : Colors.grey),
//                         onPressed: () => setState(() => _rating = 5),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 20),
//                   const Text(
//                     'Add a comment',
//                     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                   ),
//                   SizedBox(height: 10),
//                   TextField(
//                     maxLines: 5,
//                     onChanged: (value) => setState(() => _comment = value),
//                     decoration: InputDecoration(
//                       hintText: 'Type your comment here...',
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                   SizedBox(height: 40),
//                   Center(
//                     child: SizedBox(
//                       width: double.infinity,
//                       height: 45.0,
//                       child: ElevatedButton(
//                         style: ButtonStyle(
//                           backgroundColor:
//                           MaterialStateProperty.all<Color>(Colors.green),
//                           foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
//                         ),
//                         onPressed: () async {
//                           // Here you can submit the review with rating and comment
//                           print('Rating: $_rating');
//                           print('Comment: $_comment');
//                           // You can add functionality to submit the review to a backend or save it locally
//                           // Once submitted, you can navigate back to the previous screen or a home screen
//                           // Navigator.pop(context); // Example of navigating back to previous screen
//
//                           // Get the current user's ID
//                           FirebaseAuth auth = FirebaseAuth.instance;
//                           User? user = auth.currentUser;
//                           String? userId;
//
//                           if (user != null) {
//                             userId = user.uid;
//                           } else {
//                             // Handle the case when the user is not signed in
//                             // For example, you can display an error message or navigate to the sign-in screen
//                             print('User is not signed in.');
//                           }
//
//
//                           try {
//                             // Retrieve the driverId from the ride document
//                             DocumentSnapshot rideSnapshot =
//                                 await FirebaseFirestore.instance.collection('rides').doc(widget.rideId).get();
//                             String driverId = rideSnapshot.get('driverId');
//
//                             // Get the current rating and number of ratings of the driver
//                             DocumentSnapshot driverSnapshot =
//                             await FirebaseFirestore.instance.collection('users').doc(driverId).get();
//
//                             double currentRating = (driverSnapshot.get('ratings') ?? 0).toDouble(); // Convert to double
//
//                             // Calculate the new average rating
//                             double newRating = ((_rating + currentRating) / 2);
//
//
//                             // Add the review and rating to the driver's document
//                             await FirebaseFirestore.instance.collection('users').doc(driverId).update({
//                               'ratings': FieldValue.increment(newRating),
//                               'reviews': FieldValue.arrayUnion([
//                                 {
//                                   'userId': userId,
//                                   'rating': _rating,
//                                   'comment': _comment,
//                                 }
//                               ]),
//                             });
//
//                             // Navigate back to the previous screen or a home screen
//                             // Navigator.pop(context);
//                           } catch (e) {
//                             // Handle any errors
//                             print('Error submitting review: $e');
//                             // Show an error message to the user
//                             ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                               content: Text('Failed to submit review. Please try again later.'),
//                             ));
//                           }
//                         },
//                         child: Text('Submit Review'),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ] ,
//
//       ),
//     );
//   }
// }


