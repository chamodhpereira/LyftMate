import * as v2 from "firebase-functions/v2";
import * as v1 from "firebase-functions/v1";
import * as admin from "firebase-admin";

admin.initializeApp();

type Indexable = { [key: string]: string };

export const helloWorld = v2.https.onRequest((req, res) => {
  debugger;
  // when an event is trigger the custom logic is placed in the function callback
  const name = req.params[0].replace("/", "");
  const items: Indexable = { lamp: "this is a lamp", table: "this is a table" };
  const message = items[name];
  res.send(`<h1>${message}</h1>`); // this is the response that will be sent back to the client
});

exports.notifyPassengersOnRideStarted = v1.firestore
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
            const passengerName = passengerData.firstName;
            const passengerNotificationToken = passengerData.notificationToken;

            // Send notification to passenger
            const payload: admin.messaging.MessagingPayload = {
              notification: {
                title: "Ride Status: Your Ride Is Now In Progress",
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

// exports.notifyPassengersOnRideCancelled = v1.firestore
//   .document("rides/{rideId}")
//   .onUpdate(async (change, context) => {
//     // Retrieve new and previous values of the ride document
//     const newValue = change.after.data() as FirebaseFirestore.DocumentData;
//     const previousValue =
//       change.before.data() as FirebaseFirestore.DocumentData;

//     // Check if ride status has changed to "Cancelled"
//     if (
//       newValue.rideStatus === "Cancelled" &&
//       previousValue.rideStatus !== "Cancelled"
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
//             const passengerName = passengerData.firstName;
//             const passengerNotificationToken = passengerData.notificationToken;

//             // Prepare and send the notification to the passenger
//             const payload: admin.messaging.MessagingPayload = {
//               notification: {
//                 title: "Ride Status: Your Ride Has Been Cancelled",
//                 body: `${passengerName}, your ride has been cancelled. Please make alternative arrangements.`,
//               },
//             };

//             const response = await admin.messaging().send({
//               token: passengerNotificationToken,
//               notification: payload.notification,
//             });
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

export const notifyDriverOnRideRequest = v1.firestore
  .document("rides/{rideId}")
  .onUpdate(async (change, context) => {
    // Retrieve old and new document data
    const before = change.before.data() as FirebaseFirestore.DocumentData;
    const after = change.after.data() as FirebaseFirestore.DocumentData;

    // Extract the ride requests before and after the update
    const oldRequests = before.rideRequests || ([] as Array<any>);
    const newRequests = after.rideRequests || ([] as Array<any>);

    // Check if there's a new ride request
    if (newRequests.length > oldRequests.length) {
      // Assume the new request is appended at the end
      const newRequest = newRequests[newRequests.length - 1];
      const passengerId: string = newRequest.passengerId;

      try {
        // Retrieve passenger details
        const passengerDoc = await admin
          .firestore()
          .doc(`users/${passengerId}`)
          .get();
        if (passengerDoc.exists) {
          const passengerData = passengerDoc.data() as {
            firstName: string;
            lastName: string;
          };
          const { firstName, lastName } = passengerData;

          // Retrieve driver information
          const driverId: string = after.driverId;
          const driverDoc = await admin
            .firestore()
            .doc(`users/${driverId}`)
            .get();
          if (driverDoc.exists) {
            const driverData = driverDoc.data() as {
              notificationToken: string;
            };
            const driverNotificationToken = driverData.notificationToken;

            // Construct and send the notification to the driver
            const message: admin.messaging.Message = {
              notification: {
                title: "Ride Alert: New Passenger Request",
                body: `${firstName} ${lastName} requested to join your ride.`,
              },
              token: driverNotificationToken,
            };

            await admin.messaging().send(message);
            console.log("Notification sent to the driver:", driverId);
          } else {
            console.error("Driver not found:", driverId);
          }
        } else {
          console.error("Passenger not found:", passengerId);
        }
      } catch (error) {
        console.error("Error sending notification:", error);
      }
    }

    // Return a null response to finish the Cloud Function execution
    return null;
  });

// export const notifyPassengerOnRequestAccepted = v1.firestore
//   .document("rides/{rideId}")
//   .onUpdate(async (change, context) => {
//     // Retrieve old and new document data
//     const before = change.before.data() as FirebaseFirestore.DocumentData;
//     const after = change.after.data() as FirebaseFirestore.DocumentData;

//     // Extract passengers before and after the update
//     const oldPassengers: { userId: string }[] = before.passengers || [];
//     const newPassengers: { userId: string }[] = after.passengers || [];

//     // Find which passengers have been newly added
//     const newPassengerIds = newPassengers
//       .map((p) => p.userId)
//       .filter((id) => !oldPassengers.some((op) => op.userId === id));

//     // Notify newly added passengers
//     for (const passengerId of newPassengerIds) {
//       try {
//         // Retrieve passenger data
//         const passengerDoc = await admin
//           .firestore()
//           .doc(`users/${passengerId}`)
//           .get();
//         if (passengerDoc.exists) {
//           const passengerData = passengerDoc.data() as {
//             firstName: string;
//             notificationToken: string;
//           };
//           const { firstName, notificationToken } = passengerData;

//           // Construct and send the notification
//           const message: admin.messaging.Message = {
//             notification: {
//               title: "Ride Approved: Your Seat Is Reserved!",
//               body: `${firstName}, your ride request has been accepted by the driver. Enjoy your journey!`,
//             },
//             token: notificationToken,
//           };

//           await admin.messaging().send(message);
//           console.log("Notification sent to passenger:", passengerId);
//         } else {
//           console.error("Passenger not found:", passengerId);
//         }
//       } catch (error) {
//         console.error("Error sending notification to passenger:", error);
//       }
//     }

//     // Return a null response to finish the Cloud Function execution
//     return null;
//   });

export const triggerRideNearbyNotification = v2.https.onRequest(
  async (req, res) => {
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
  }
);

exports.notifyPassengersOnRideCancelled = v1.firestore
  .document("rides/{rideId}")
  .onUpdate(async (change, context) => {
    const newValue = change.after.data() as FirebaseFirestore.DocumentData;
    const previousValue =
      change.before.data() as FirebaseFirestore.DocumentData;

    if (
      newValue.rideStatus === "Cancelled" &&
      previousValue.rideStatus !== "Cancelled"
    ) {
      // Correctly extract the userId from each passenger object
      const passengers: { userId: string }[] = newValue.passengers || [];

      // Iterate through each passenger and send a notification
      passengers.forEach(async (passenger) => {
        const passengerId = passenger.userId; // Correctly accessing the userId property
        try {
          const doc = await admin.firestore().doc(`users/${passengerId}`).get();
          if (doc.exists) {
            const passengerData = doc.data() as {
              firstName: string;
              notificationToken: string;
            };
            const passengerName = passengerData.firstName;
            const passengerNotificationToken = passengerData.notificationToken;

            const payload: admin.messaging.MessagingPayload = {
              notification: {
                title: "Ride Status: Your Ride Has Been Cancelled",
                body: `${passengerName}, your ride has been cancelled. Please make alternative arrangements.`,
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

export const notifyPassengerOnRequestAccepted = v1.firestore
  .document("rides/{rideId}")
  .onUpdate(async (change, context) => {
    const before = change.before.data() as FirebaseFirestore.DocumentData;
    const after = change.after.data() as FirebaseFirestore.DocumentData;

    // Extract rideRequests before and after the update
    const beforeRideRequests: { passengerId: string }[] =
      before.rideRequests || [];
    const afterRideRequests: { passengerId: string }[] =
      after.rideRequests || [];

    // Find which rideRequests have been removed (approved)
    const approvedRequestIds = beforeRideRequests
      .filter(
        (br) =>
          !afterRideRequests.some((ar) => ar.passengerId === br.passengerId)
      )
      .map((req) => req.passengerId);

    // Extract passengers after the update
    const newPassengers: { userId: string }[] = after.passengers || [];

    // Notify only those whose requests were approved and added to passengers
    for (const passengerId of approvedRequestIds) {
      if (newPassengers.some((np) => np.userId === passengerId)) {
        try {
          const passengerDoc = await admin
            .firestore()
            .doc(`users/${passengerId}`)
            .get();
          if (passengerDoc.exists) {
            const passengerData = passengerDoc.data() as {
              firstName: string;
              notificationToken: string;
            };
            const { firstName, notificationToken } = passengerData;

            const message: admin.messaging.Message = {
              notification: {
                title: "Ride Approved: Your Seat Is Reserved!",
                body: `${firstName}, your ride request has been accepted by the driver. Enjoy your journey!`,
              },
              token: notificationToken,
            };

            await admin.messaging().send(message);
            console.log("Notification sent to passenger:", passengerId);
          } else {
            console.error("Passenger not found:", passengerId);
          }
        } catch (error) {
          console.error("Error sending notification to passenger:", error);
        }
      }
    }

    return null;
  });
