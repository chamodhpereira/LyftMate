import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';
import 'package:lyft_mate/models/passenger.dart';

class PassengerReviewsScreen extends StatefulWidget {
  final String rideId;

  const PassengerReviewsScreen({Key? key, required this.rideId}) : super(key: key);

  @override
  _PassengerReviewsScreenState createState() => _PassengerReviewsScreenState();
}

class _PassengerReviewsScreenState extends State<PassengerReviewsScreen> {
  late List<Passenger> passengers = [];
  final PassengerRepository _repository = PassengerRepository(); // Instantiate the repository


  @override
  void initState() {
    super.initState();
    fetchPassengers(); // Call fetchPassengers() in initState()
  }

  // Future<void> fetchPassengers() async {
  //   // Fetch passengers for the given rideId
  //   passengers = await _repository.fetchPassengersForRide(widget.rideId);
  //   setState(() {}); // Update the UI after fetching passengers
  // }

  // Future<void> fetchPassengers() async {
  //   // Fetch passengers for the given rideId
  //   List<Map<String, dynamic>> passengerData = await _repository.fetchPassengersForRide(widget.rideId);
  //
  //   print('Passenger data: $passengerData');
  //
  //   // Convert the fetched data to a list of Passenger objects
  //   passengers = passengerData.map((data) => Passenger(
  //     id: data['userId'],
  //     name: data['firstName'],
  //     // Add other properties as needed
  //   )).toList();
  //
  //   setState(() {}); // Update the UI after fetching passengers
  // }

  Future<void> fetchPassengers() async {
    // Fetch passengers for the given rideId
    List<Passenger> passengerData = await _repository.fetchPassengersForRide(widget.rideId);

    print('Passenger data: $passengerData');

    setState(() {
      passengers = passengerData;
    });
  }

  Future<void> submitRatings() async {
    // Iterate through the list of passengers and update their ratings

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm"),
          content: Text("Are you sure you want to submit these ratings?"),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                for (final passenger in passengers) {
                  await _repository.updatePassengerRating(passenger.id, passenger.rating);
                  debugPrint('Passenger ${passenger.name} - Rating: ${passenger.rating}');
                }
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Add navigation or additional action upon confirmation
              },
              child: Text("Submit"),
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
        title: Text('Rate Your Passengers'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0.5,
        leadingWidth: 50.0,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5.0),
            // padding: const EdgeInsets.only(top: 50.0),
            child: Align(
              alignment: Alignment.topCenter,
              child: Lottie.asset(
                "assets/images/add_rating-animation.json",
                height: MediaQuery.of(context).size.height * 0.3, // Adjust the height accordingly
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 150,
            left: 0,
            right: 0,
            bottom: 0,  // Add this to define how far down the list should extend
            child: Padding(
              padding: const EdgeInsets.only(top: 100.0),
              child: passengers.isNotEmpty
                  ? ListView.builder(
                itemCount: passengers.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 30.0,
                      backgroundImage: passengers[index].profileImageUrl.isNotEmpty
                          ? NetworkImage(passengers[index].profileImageUrl)
                          : null,
                      child: passengers[index].profileImageUrl.isEmpty
                          ? Icon(Icons.person, color: Colors.black)  // Show an icon instead of text
                          : null,
                    ),
                    title: Text(passengers[index].name),
                    subtitle: StarRatingWidget(
                      onRatingChanged: (rating) {
                        setState(() {
                          passengers[index].rating = rating;
                        });
                      },
                    ),
                  );
                },
              )
                  : Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
          Positioned(
            // top: 150,
            left: 0,
            right: 0,
            bottom: 15,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: double.infinity,
                height: 45.0,
                child: ElevatedButton(
                  onPressed: () {
                    submitRatings();
                    debugPrint("Submit prssssd");
                  },
                  style: ButtonStyle(
                    backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.green),
                    foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                  ),

                  child: Text('Submit Review'),
                ),
              ),
            ),
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: submitRatings,
      //   child: Icon(Icons.check),
      // ),


    );
  }
}

class StarRatingWidget extends StatefulWidget {
  final ValueChanged<double>? onRatingChanged; // Define the onRatingChanged callback

  StarRatingWidget({this.onRatingChanged});

  @override
  _StarRatingWidgetState createState() => _StarRatingWidgetState();
}

class _StarRatingWidgetState extends State<StarRatingWidget> {
  double _rating = 0; // Initial rating

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return IconButton(
          onPressed: () {
            // Update the rating when a star is tapped
            setState(() {
              _rating = index + 1;
            });
            // Call the onChanged callback if provided
            if (widget.onRatingChanged != null) {
              widget.onRatingChanged!(_rating);
            }
          },
          icon: Icon(
            index < _rating ? Icons.star : Icons.star_border,
            color: Colors.orange,
          ),
        );
      }),
    );
  }
}
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:lottie/lottie.dart';
// import 'package:lyft_mate/models/passenger.dart';
//
// class PassengerReviewsScreen extends StatefulWidget {
//   final String rideId;
//
//   const PassengerReviewsScreen({Key? key, required this.rideId}) : super(key: key);
//
//   @override
//   _PassengerReviewsScreenState createState() => _PassengerReviewsScreenState();
// }
//
// class _PassengerReviewsScreenState extends State<PassengerReviewsScreen> {
//   late List<Passenger> passengers = [];
//   final PassengerRepository _repository = PassengerRepository();
//
//   @override
//   void initState() {
//     super.initState();
//     fetchPassengers();
//   }
//
//   Future<void> fetchPassengers() async {
//     List<Passenger> passengerData = await _repository.fetchPassengersForRide(widget.rideId);
//     setState(() {
//       passengers = passengerData;
//     });
//   }
//
//   Future<void> submitRatings() async {
//     for (final passenger in passengers) {
//       await _repository.updatePassengerRating(passenger.id, passenger.rating);
//     }
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Confirm"),
//           content: Text("Are you sure you want to submit these ratings?"),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: Text("Cancel"),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 // Add navigation or additional action upon confirmation
//               },
//               child: Text("Submit"),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Passenger Reviews'),
//         backgroundColor: Colors.green,
//       ),
//       body: Column(
//         children: [
//           Lottie.asset(
//             "assets/images/add_rating-animation.json",
//             height: 120,
//             width: MediaQuery.of(context).size.width,
//             fit: BoxFit.fill,
//           ),
//           Expanded(
//             child: passengers.isNotEmpty
//                 ? ListView.builder(
//               itemCount: passengers.length,
//               itemBuilder: (context, index) {
//                 return ListTile(
//                   leading: CircleAvatar(
//                     // backgroundImage: NetworkImage(passengers[index].photoUrl ?? ""),
//                     child: Text(passengers[index].name[0]),
//                   ),
//                   title: Text(passengers[index].name),
//                   subtitle: StarRatingWidget(
//                     onRatingChanged: (rating) {
//                       setState(() {
//                         passengers[index].rating = rating;
//                       });
//                     },
//                   ),
//                 );
//               },
//             )
//                 : Center(child: CircularProgressIndicator()),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: submitRatings,
//         child: Icon(Icons.check),
//       ),
//     );
//   }
// }
//
// class StarRatingWidget extends StatefulWidget {
//   final ValueChanged<double>? onRatingChanged;
//
//   StarRatingWidget({this.onRatingChanged});
//
//   @override
//   _StarRatingWidgetState createState() => _StarRatingWidgetState();
// }
//
// class _StarRatingWidgetState extends State<StarRatingWidget> {
//   double _rating = 0;
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: List.generate(5, (index) {
//         return IconButton(
//           icon: Icon(
//             index < _rating ? Icons.star : Icons.star_border,
//             color: Colors.orange,
//           ),
//           onPressed: () {
//             setState(() {
//               _rating = index + 1;
//             });
//             if (widget.onRatingChanged != null) {
//               widget.onRatingChanged!(_rating);
//             }
//           },
//         );
//       }),
//     );
//   }
// }

