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

export const triggerNotification = v2.https.onRequest(async (req, res) => {
  try {
    const rideId = req.body.rideId;
    const passengerId = req.body.passengerId;
    if (!rideId || !passengerId) {
      res.status(400).send("Missing ride ID or passenger ID");
      return;
    }

    // Fetch ride details from Firestore
    const rideSnapshot = await admin.firestore().doc(`rides/${rideId}`).get();
    if (!rideSnapshot.exists) {
      res.status(404).send("Ride not found");
      return;
    }

    const rideData = rideSnapshot.data();
    if (!rideData) {
      res.status(500).send("Error fetching ride data");
      return;
    }

    // Fetch passenger details and send notification
    const passengerSnapshot = await admin
      .firestore()
      .doc(`users/${passengerId}`)
      .get();
    if (passengerSnapshot.exists) {
      const passengerData = passengerSnapshot.data();
      if (passengerData) {
        const notificationToken = passengerData.notificationToken;
        if (notificationToken) {
          await admin.messaging().send({
            token: notificationToken,
            notification: {
              title: "Ride Status Update",
              body: "Your ride is within 1km. Please be ready for pickup.",
            },
          });
          console.log("Notification sent successfully");
          res.status(200).send("Notification sent successfully");
          return;
        } else {
          console.error(
            `Notification token not found for passenger ${passengerId}`
          );
          res.status(404).send("Notification token not found");
          return;
        }
      }
    } else {
      console.error(`Passenger ${passengerId} not found`);
      res.status(404).send("Passenger not found");
      return;
    }
  } catch (error) {
    console.error("Error triggering notification:", error);
    res.status(500).send("Internal server error");
  }
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
