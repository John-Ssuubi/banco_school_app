import {onDocumentCreated} from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";

if (!admin.apps.length) {
  admin.initializeApp();
}

export const sendSchoolNotification = onDocumentCreated(
  "Schools/{schoolId}/notifications/{notificationId}",
  async (event) => {
    const snap = event.data;
    if (!snap) {
      console.log("No data associated with the event");
      return;
    }

    const data = snap.data();
    if (!data) {
      return;
    }

    const schoolId = event.params.schoolId;

    const title = data.title || "New School Notification";
    const message = data.body || "";

    try {
      const parentsSnap = await admin
        .firestore()
        .collection("Schools")
        .doc(schoolId)
        .collection("students")
        .where("parentFcmToken", "!=", "")
        .get();

      const tokens = Array.from(
        new Set(
          parentsSnap.docs
            .map((doc) => doc.data().parentFcmToken)
            .filter(Boolean)
        )
      ) as string[];

      if (tokens.length === 0) {
        console.log("No tokens found for school:", schoolId);
        return;
      }

      const basePayload = {
        notification: {
          title,
          body: message,
        },
        data: {
          schoolId,
          type: "school_notification",
        },
      };

      const chunkSize = 500;
      const tokenChunks: string[][] = [];

      for (let i = 0; i < tokens.length; i += chunkSize) {
        tokenChunks.push(tokens.slice(i, i + chunkSize));
      }

      await Promise.all(
        tokenChunks.map(async (chunk) => {
          const response = await admin.messaging().sendEachForMulticast({
            tokens: chunk,
            ...basePayload,
          });

          console.log(
            "Batch sent:",
            response.successCount,
            "success,",
            response.failureCount,
            "failed"
          );
        })
      );
    } catch (error) {
      console.error("Error in sendSchoolNotification:", error);
    }
  }
);
