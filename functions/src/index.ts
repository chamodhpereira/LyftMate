// /**
//  * Import function triggers from their respective submodules:
//  *
//  * import {onCall} from "firebase-functions/v2/https";
//  * import {onDocumentWritten} from "firebase-functions/v2/firestore";
//  *
//  * See a full list of supported triggers at https://firebase.google.com/docs/functions
//  */

// import {onRequest} from "firebase-functions/v2/https";
// import * as logger from "firebase-functions/logger";

// // Start writing functions
// // https://firebase.google.com/docs/functions/typescript

// // export const helloWorld = onRequest((request, response) => {
// //   logger.info("Hello logs!", {structuredData: true});
// //   response.send("Hello from Firebase!");
// // });

import * as v2 from "firebase-functions/v2";
import * as v1 from "firebase-functions/v1";
import * as admin from "firebase-admin";

admin.initializeApp();

// when the cloud function is deployed you'll get a url that will allow you to access/trigger this function

type Indexable = { [key: string]: string };

export const helloWorld = v2.https.onRequest((req, res) => {
  debugger;
  // when an event is trigger the custom logic is placed in the function callback
  const name = req.params[0].replace("/", "");
  const items: Indexable = { lamp: "this is a lamp", table: "this is a table" };
  const message = items[name];
  res.send(`<h1>${message}</h1>`); // this is the response that will be sent back to the client
});

exports.notifyPassengersOnRideProgress = v1.firestore
  .document("rides/{rideId}")
  .onUpdate(async (change, context) => {
    const newValue = change.after.data() as FirebaseFirestore.DocumentData;
    const previousValue =
      change.before.data() as FirebaseFirestore.DocumentData;

    // Check if ride status changed to "In Progress"
    if (
      newValue.rideStatus === "In Progress" &&
      previousValue.rideStatus !== "In Progress"
    ) {
      const passengers: string[] = newValue.passengers;

      // Iterate through each passenger and send a notification
      passengers.forEach(async (passengerId: string) => {
        try {
          // Retrieve passenger's data
          const doc = await admin.firestore().doc(`users/${passengerId}`).get();
          if (doc.exists) {
            const passengerData = doc.data() as {
              firstName: string;
              notificationToken: string;
            };
            const passengerName = passengerData.firstName; // Adjust according to your user schema
            const passengerNotificationToken = passengerData.notificationToken; // Adjust according to your user schema

            // Send notification to passenger
            const payload: admin.messaging.MessagingPayload = {
              notification: {
                title: "Ride Status Update",
                body: `${passengerName}, your ride is now in progress. Enjoy your journey!`,
              },
            };

            const response = await admin.messaging().send({
              token: passengerNotificationToken,
              notification: payload.notification,
            });
            console.log("Notification sent successfully:", response);
          } else {
            console.error(`Passenger with ID ${passengerId} not found.`);
          }
        } catch (error) {
          console.error("Error retrieving passenger data:", error);
        }
      });
    }

    return null;
  });

// exports.notifyPassengersOnRideProgress = v1.firestore
//   .document("rides/{rideId}")
//   .onUpdate(async (change, context) => {
//     const newValue = change.after.data() as FirebaseFirestore.DocumentData;
//     const previousValue =
//       change.before.data() as FirebaseFirestore.DocumentData;

//     // Check if ride status changed to "In Progress"
//     if (
//       newValue.rideStatus === "In Progress" &&
//       previousValue.rideStatus !== "In Progress"
//     ) {
//       const passengers: string[] = newValue.passengers;

//       // Iterate through each passenger and send a notification
//       passengers.forEach(async (passengerId: string) => {
//         try {
//           // Retrieve passenger's data
//           const doc = await admin.firestore().doc(`users/${passengerId}`).get();
//           if (doc.exists) {
//             const passengerData = doc.data() as {
//               firstName: string;
//               notificationToken: string;
//             };
//             const passengerName = passengerData.firstName; // Adjust according to your user schema
//             const passengerNotificationToken = passengerData.notificationToken; // Adjust according to your user schema

//             // Send notification to passenger
//             const payload: admin.messaging.MessagingPayload = {
//               notification: {
//                 title: "Ride Status Update",
//                 body: `${passengerName}, your ride is now in progress. Enjoy your journey!`,
//               },
//             };

//             const response = await admin
//               .messaging()
//               .send(passengerNotificationToken, payload);
//             console.log("Notification sent successfully:", response);
//           } else {
//             console.error(`Passenger with ID ${passengerId} not found.`);
//           }
//         } catch (error) {
//           console.error("Error retrieving passenger data:", error);
//         }
//       });
//     }

//     return null;
//   });
