import {onDocumentCreated} from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";

if (!admin.apps.length) {
  admin.initializeApp();
}

export const sendUserInboxNotification = onDocumentCreated(
  "Users/{userId}/inbox/{messageId}",
  async (event) => {
    const snap = event.data;
    if (!snap) return;

    const data = snap.data();
    if (!data) return;

    const userId = event.params.userId;

    const title = data.title || "New Message";
    const body = data.body || "";
    const token = data.fcmToken;

    if (!token) {
      console.log("No FCM token for user:", userId);
      return;
    }

    try {
      await admin.messaging().send({
        token,
        notification: {
          title,
          body,
        },
        data: {
          schoolId: data.schoolId ?? "",
          studentId: data.studentId ?? "",
          type: "inbox",
        },
      });

      console.log("Inbox notification sent to user:", userId);
    } catch (error) {
      console.error("Error sending inbox notification:", error);
    }
  }
);