import { onDocumentCreated } from "firebase-functions/v2/firestore";
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

export const notifyParentsOnEvent = onDocumentCreated(
  "Schools/{schoolId}/events/{eventId}",
  async (event) => {
    try {
      console.log("notifyParentsOnEvent started");

      const snap = event.data;
      if (!snap) return;

      const eventData = snap.data();
      const schoolId = event.params.schoolId;
      const eventId = event.params.eventId;

      const parentsSnap = await admin.firestore()
        .collection("Schools")
        .doc(schoolId)
        .collection("linkedParents")
        .get();

      if (parentsSnap.empty) {
        console.log("No parents found");
        return;
      }

      console.log("Parents found:", parentsSnap.size);

      const batch = admin.firestore().batch();
      const pushPromises: Promise<any>[] = [];

      // ✅ use for...of so await works
      for (const doc of parentsSnap.docs) {
        const parentId = doc.id;

        console.log("Processing:", parentId);

        /* -------- INBOX (NO DUPLICATES) -------- */

        const inboxRef = admin.firestore()
          .collection("Users")
          .doc(parentId)
          .collection("inbox")
          .doc(eventId);

        batch.set(
          inboxRef,
          {
            title: "New School Event",
            body: eventData?.title ?? "New event added",
            schoolFrom: schoolId,
            timestamp: admin.firestore.FieldValue.serverTimestamp(),
            status: "pending",
            type: "Events",
          },
          { merge: true }
        );

        /* -------- GET REAL TOKEN -------- */

        const userDoc = await admin.firestore()
          .collection("Users")
          .doc(parentId)
          .get();

        const token = userDoc.data()?.fcmToken;

        if (!token) {
          console.log("No token in Users for:", parentId);
          continue;
        }

        /* -------- SEND PUSH -------- */

        const push = admin.messaging().send({
          token,
          notification: {
            title: "New School Event ",
            body: eventData?.title ?? "New event added",
          },
          data: {
            type: "event",
            schoolId,
            eventId,
          },
        });

        pushPromises.push(push);
      }

      // Save inbox
      await batch.commit();
      console.log("Inbox messages saved");

      // Send pushes
      if (pushPromises.length > 0) {
        await Promise.all(pushPromises);
        console.log("Push notifications sent:", pushPromises.length);
      }

    } catch (error) {
      console.error("notifyParentsOnEvent ERROR:", error);
    }
  }
);

export const notifyParentsOnAlert = onDocumentCreated(
  "Schools/{schoolId}/alerts/{alertId}",
  async (event) => {
    try {
      console.log("notifyParentsOnAlert started");

      const snap = event.data;
      if (!snap) return;

      const eventData = snap.data();
      const schoolId = event.params.schoolId;
      const alertId = event.params.alertId;

      const parentsSnap = await admin.firestore()
        .collection("Schools")
        .doc(schoolId)
        .collection("linkedParents")
        .get();

      if (parentsSnap.empty) {
        console.log("No parents found");
        return;
      }

      console.log("Parents found:", parentsSnap.size);

      const batch = admin.firestore().batch();
      const pushPromises: Promise<any>[] = [];

      // ✅ use for...of so await works
      for (const doc of parentsSnap.docs) {
        const parentId = doc.id;

        console.log("Processing:", parentId);

        /* -------- INBOX (NO DUPLICATES) -------- */

        const inboxRef = admin.firestore()
          .collection("Users")
          .doc(parentId)
          .collection("inbox")
          .doc(alertId);

        batch.set(
          inboxRef,
          {
            title: "New School Alert",
            body: eventData?.description ?? "New alert added",
            schoolFrom: schoolId,
            timestamp: admin.firestore.FieldValue.serverTimestamp(),
            status: "pending",
            type: "Alerts",
          },
          { merge: true }
        );

        /* -------- GET REAL TOKEN -------- */

        const userDoc = await admin.firestore()
          .collection("Users")
          .doc(parentId)
          .get();

        const token = userDoc.data()?.fcmToken;

        if (!token) {
          console.log("No token in Users for:", parentId);
          continue;
        }

        /* -------- SEND PUSH -------- */

        const push = admin.messaging().send({
          token,
          notification: {
            title: "New School Event ",
            body: eventData?.title ?? "New event added",
          },
          data: {
            type: "alert",
            schoolId,
            alertId,
          },
        });

        pushPromises.push(push);
      }

      // Save inbox
      await batch.commit();
      console.log("Inbox messages saved");

      // Send pushes
      if (pushPromises.length > 0) {
        await Promise.all(pushPromises);
        console.log("Push notifications sent:", pushPromises.length);
      }

    } catch (error) {
      console.error("notifyParentsOnEvent ERROR:", error);
    }
  }
);
