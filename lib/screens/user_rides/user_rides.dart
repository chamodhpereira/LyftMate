import 'package:flutter/material.dart';

class UserRides extends StatefulWidget {
  @override
  _UserRidesState createState() => _UserRidesState();
}

class _UserRidesState extends State<UserRides> with SingleTickerProviderStateMixin {
  late TabController _tabController;



  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rides'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0.5,
        leadingWidth: 50.0,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Published'),
            Tab(text: 'Booked'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Published Rides Tab
          Center(
            child: Text('No any Published Rides'),
          ),
          // Booked Rides Tab
          ListView(
            children: [
              _buildBookedRideCard('Upcoming'),
              _buildBookedRideCard('Cancelled'),
              _buildBookedRideCard('Completed'),
              _buildBookedRideCard('Upcoming'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBookedRideCard(String rideStatus) {
    // Replace this with your actual ride data
    String startingPoint = 'Starting Point';
    String endingPoint = 'Ending Point';
    double price = 50.0;
    DateTime rideDate = DateTime.now();
    TimeOfDay startingTime = TimeOfDay(hour: 8, minute: 0);
    TimeOfDay endingTime = TimeOfDay(hour: 10, minute: 0);
    int passengers = 3;
    String driverName = 'John Doe';
    double driverRating = 4.5;
    int numberOfReviews = 20;

    return Card(
      margin: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text('$startingPoint -> $endingPoint'),
            trailing: Chip(
              label: Text(rideStatus),
              backgroundColor: rideStatus == 'Upcoming'
                  ? Colors.blue
                  : rideStatus == 'Cancelled'
                  ? Colors.red
                  : Colors.green,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.attach_money),
                SizedBox(width: 8),
                Text('\$$price'),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.calendar_today),
                SizedBox(width: 8),
                Text('${rideDate.year}-${rideDate.month}-${rideDate.day}'),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.access_time),
                SizedBox(width: 8),
                Text('${startingTime.format(context)} - ${endingTime.format(context)}'),
              ],
            ),
          ),
          ListTile(
            leading: CircleAvatar(
              // Replace with driver's profile image
              backgroundColor: Colors.blue,
              child: Icon(Icons.person),
            ),
            title: Text('$driverName'),
            subtitle: Row(
              children: [
                Icon(Icons.star, color: Colors.yellow),
                SizedBox(width: 4),
                Text('$driverRating ($numberOfReviews Reviews)'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
