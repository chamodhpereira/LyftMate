import 'package:flutter/material.dart';
import 'package:lyft_mate/screens/forgot_password/password_reset_screen.dart';
import '../../services/authentication/authentication_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  AuthenticationService authService = AuthenticationService();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Forget password"),
        elevation: 0,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // The image displayed above the text
                Image.asset(
                  'assets/images/carpool-forgot-password.jpg',
                  height: 350.0, // Adjust the height as needed
                ),
                const SizedBox(height: 16),
                const Text(
                  "Don't worry sometimes people can forget too, enter your email and we will send you a password reset link.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.mail_outline),
                    labelText: "E-Mail",
                    hintText: "Enter your email",
                    border: OutlineInputBorder(
                      // borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email is required.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState?.validate() ?? false) {
                      String email = _emailController.text.trim();
                      // Check if the reset email was sent successfully
                      bool success = await authService.sendPasswordResetEmail(context, email);

                      // If successful, navigate to the Password Reset Sent screen
                      if (success && context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PasswordResetSentScreen(),
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    // shape: RoundedRectangleBorder(
                    //   borderRadius: BorderRadius.circular(12),
                    // ),
                  ),
                  child: const Text("Submit"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}




// import 'package:flutter/material.dart';
// import 'package:lyft_mate/screens/forgot_password/password_reset_screen.dart';
//
// import '../../services/authentication_service.dart';
//
// class ForgotPasswordScreen extends StatefulWidget {
//   const ForgotPasswordScreen({super.key});
//
//   @override
//   State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
// }
//
// class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
//
//   final _emailController = TextEditingController();
//
//   AuthenticationService authService = AuthenticationService();
//
//   @override
//   void dispose() {
//     _emailController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.green,
//         foregroundColor: Colors.white,
//         elevation: 0.5,
//       ),
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 25.0),
//             child: Text("Enter your email and we will send you a password password reset link"),
//           ),
//           SizedBox(height: 10),
//
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 10.0),
//             child: TextFormField(
//               controller: _emailController,
//               decoration: const InputDecoration(
//                 prefixIcon: Icon(Icons.person_outline_outlined),
//                 labelText: "Email",
//                 hintText: "Enter email",
//                 border: OutlineInputBorder(),
//               ),
//               validator: (value) {
//                 if (value == null || value.isEmpty) {
//                   return 'Please enter your email';
//                 }
//                 return null;
//               },
//             ),
//           ),
//           SizedBox(height: 10),
//           ElevatedButton(
//             // onPressed: () {
//             //   authService.sendPasswordResetEmail(_emailController.text.trim());
//             // },
//             onPressed: () async {
//               String email = _emailController.text;
//               if (email.isNotEmpty) {
//                 // Check if the reset email was sent successfully
//                 bool success = await authService.sendPasswordResetEmail(context, email);
//
//                 // If successful, navigate to the Password Reset Sent screen
//                 if (success) {
//                   if(context.mounted) {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => PasswordResetSentScreen(),
//                         // builder: (context) => PasswordResetSentScreen(email: email),
//                       ),
//                     );
//                   }
//                 }
//               } else {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                     content: Text('Please enter a valid email addressQQ.'),
//                     duration: Duration(seconds: 3),
//                   ),
//                 );
//               }
//             },
//             child: Text("Reset Password"),
//             // color:  Colors.deepPurple,
//             style: ElevatedButton.styleFrom(
//               // minimumSize: const Size(double.infinity, 50),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               backgroundColor: Colors.green,
//               foregroundColor: Colors.white,
//             ),
//           ),
//
//
//     ],
//       ),
//     );
//   }
// }
