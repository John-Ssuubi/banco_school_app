const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

// Trigger when a new student is marked present
exports.pushNotificationOnAttendance = functions.firestore
  .document("Schools/{schoolId}/attendance/{date}/students/{studentName}")
  .onCreate(async (snap, context) => {
    try {
      const data = snap.data();
      const studentName = data.studentName || "Student";
      const parentToken = data.parentFcmToken;

      console.log("Attendance marked!");
      console.log("School ID:", context.params.schoolId);
      console.log("Date:", context.params.date);
      console.log("Student Name:", context.params.studentName);
      console.log("Parent FCM Token:", parentToken);

      if (!parentToken) {
        console.log("⚠️ No parent FCM token found for", studentName);
        return null;
      }

      const payload = {
        notification: {
          title: "Attendance Update",
          body: `${studentName} has been marked present today ✅`,
          click_action: "FLUTTER_NOTIFICATION_CLICK", // Required for Flutter
        },
      };

      const response = await admin.messaging().sendToDevice(parentToken, payload);
      console.log("Push notification sent successfully:", response);
      return null;
    } catch (error) {
      console.error("Error sending push notification:", error);
      return null;
    }
  });
