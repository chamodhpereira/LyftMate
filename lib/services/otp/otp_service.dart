// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:twilio_phone_verify/twilio_phone_verify.dart';
//
// class TwilioVerification {
//   static TwilioVerification? _instance;
//
//   final TwilioPhoneVerify _twilioPhoneVerify;
//
//   // Factory constructor to control the instance creation
//   factory TwilioVerification() {
//     _instance ??= TwilioVerification._internal(
//       TwilioPhoneVerify(
//         accountSid: dotenv.env['TWILIO_ACCOUNT_SID']!,
//         authToken: dotenv.env['TWILIO_AUTH_TOKEN']!,
//         serviceSid: dotenv.env['TWILIO_SERVICE_SID']!,
//       ),
//     );
//     return _instance!;
//   }
//
//   // Internal constructor for real usage
//   TwilioVerification._internal(this._twilioPhoneVerify);
//
//   // Optionally, provide a public static getter to access the instance
//   static TwilioVerification get instance => _instance!;
//
//
//   // Static method to allow replacing the singleton instance (for testing)
//   static void setMock(TwilioVerification mock) {
//     _instance = mock;
//   }
//
//
//   Future<String> sendCode(String phoneNumber) async {
//     TwilioResponse twilioResponse = await _twilioPhoneVerify.sendSmsCode(phoneNumber);
//     return twilioResponse.successful! ? 'Successful' : twilioResponse.errorMessage.toString();
//   }
//
//   Future<String> verifyCode(String phoneNumber, String otp) async {
//     TwilioResponse twilioResponse = await _twilioPhoneVerify.verifySmsCode(
//       phone: phoneNumber,
//       code: otp,
//     );
//     if (twilioResponse.successful!) {
//       return twilioResponse.verification!.status == VerificationStatus.approved ? "Successful" : 'Invalid code';
//     } else {
//       return twilioResponse.errorMessage.toString();
//     }
//   }
// }





















import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:twilio_phone_verify/twilio_phone_verify.dart';

class TwilioVerification {
  static final instance = TwilioVerification();

  final TwilioPhoneVerify _twilioPhoneVerify = TwilioPhoneVerify(
    accountSid: dotenv.env['TWILIO_ACCOUNT_SID']!,
    authToken: dotenv.env['TWILIO_AUTH_TOKEN']!,
    serviceSid: dotenv.env['TWILIO_SERVICE_SID']!,
  );

  Future<String> sendCode(phoneNumberController) async {
    TwilioResponse twilioResponse =
    await _twilioPhoneVerify.sendSmsCode(phoneNumberController);

    if (twilioResponse.successful!) {
      return 'Successful';
    } else {
      print(twilioResponse.errorMessage.toString());
      return twilioResponse.errorMessage.toString();
    }
  }

  Future<String> verifyCode(phoneNumber, otp) async {

    TwilioResponse twilioResponse = await _twilioPhoneVerify.verifySmsCode(
        phone: phoneNumber, code: otp);
    if (twilioResponse.successful!) {
      if (twilioResponse.verification!.status == VerificationStatus.approved) {
        return "Successful";
      } else {
        return 'Invalid code';
      }
    } else {
      debugPrint(twilioResponse.errorMessage.toString());
      return twilioResponse.errorMessage.toString();
    }

  }
}