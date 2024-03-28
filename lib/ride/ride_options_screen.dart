import 'package:flutter/material.dart';
// import 'package:lyft_mate/src/screens/home_screen.dart';

class RideOptions extends StatefulWidget {
  const RideOptions({Key? key}) : super(key: key);

  @override
  _RideOptionsState createState() => _RideOptionsState();
}

class _RideOptionsState extends State<RideOptions> {
  String _selectedLuggageOption = 'Select Luggage';
  String _selectedPaymentOption = 'Select Payment';
  String _selectedApprovalOption = 'Select Approval';
  List<String> _selectedPreferences = [];


  void _showBottomSheet(BuildContext context, String title,
      List<String> options, Function(String) onSelect) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Column(
                children: options.map((option) {
                  return ListTile(
                    title: Text(option),
                    onTap: () {
                      Navigator.pop(context);
                      onSelect(option);
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPreferencesBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Select Preferences',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Column(
                    children:
                    ['Non-smoking', 'Music', 'Pet-friendly'].map((option) {
                      bool isSelected = _selectedPreferences.contains(option);
                      return CheckboxListTile(
                        title: Text(option),
                        value: isSelected,
                        onChanged: (value) {
                          setState(() {
                            if (value != null && value) {
                              _selectedPreferences.add(option);
                            } else {
                              _selectedPreferences.remove(option);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Publish Ride'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0.5,
        // leadingWidth: 50.0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios), // Back button icon
          onPressed: () {
            Navigator.pop(context); // Handle back navigation
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 100,
                    color: Colors.green,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Your ride is created',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Got anything to add about the ride?',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              'eg: Flexible about when and where to meet/ got limited space in the boot/ need passengers to be punctual/ etc.',
              style: TextStyle(fontSize: 12),
            ),
            SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                hintText: 'Enter your additional notes (max 100 characters)',
                border: OutlineInputBorder(),
              ),
              maxLength: 100,
              maxLines: 3,
            ),
            SizedBox(height: 20),
            ListTile(
              title: Text('Luggage Allowance'),
              trailing: Text(_selectedLuggageOption),
              onTap: () {
                _showBottomSheet(
                  context,
                  'Select Luggage',
                  ['Small', 'Medium', 'Large'],
                      (option) {
                    setState(() {
                      _selectedLuggageOption = option;
                    });
                  },
                );
              },
            ),
            ListTile(
              title: Text('Mode of Payment'),
              trailing: Text(_selectedPaymentOption),
              onTap: () {
                _showBottomSheet(
                  context,
                  'Select Payment',
                  ['Cash', 'Card'],
                      (option) {
                    setState(() {
                      _selectedPaymentOption = option;
                    });
                  },
                );
              },
            ),
            ListTile(
              title: Text('Ride Approval'),
              trailing: Text(_selectedApprovalOption),
              onTap: () {
                _showBottomSheet(
                  context,
                  'Select Approval',
                  ['Instant', 'Request'],
                      (option) {
                    setState(() {
                      _selectedApprovalOption = option;
                    });
                  },
                );
              },
            ),
            ListTile(
              title: Text('Preferences'),
              // trailing: _selectedPreferences.isNotEmpty
              //     ? Text('Change Preferences')
              //     : Text('Select Preferences'),
              trailing: Icon(Icons.arrow_drop_down),
              onTap: () {
                _showPreferencesBottomSheet(context);
              },
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 18.0, right: 18.0, bottom: 18.0),
        child: SizedBox(
            width: double.infinity,
            height: 50.0,
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
              ),
              onPressed: () {
                // Navigator.pushAndRemoveUntil(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => NewHomeScreen(),
                //   ),
                //       (route) => false,
                // );
              },
              child: Text(
                "Publish Ride",
                style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
              ),
            )),
      ),
    );
  }
}
