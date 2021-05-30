import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();
const firestore = admin.firestore();

export const newFeedPost = functions.firestore
  .document("feed/{documentID}")
  .onUpdate(async (snapshot) => {
    const newFeedObject = snapshot.after.data();
    const oldFeedObject = snapshot.before.data();

    const shouldGoPrivate =
      !(newFeedObject.to as string[]).includes("*") &&
      (oldFeedObject.to as string[]).includes("*");

    const shouldGoPublic =
      (newFeedObject.to as string[]).includes("*") &&
      !(oldFeedObject.to as string[]).includes("*");

    if (shouldGoPublic) {
      const followersList: string[] = (
        await firestore
          .collection("followers")
          .where("followed", "==", newFeedObject.userID)
          .get()
      ).docs.map((e) => e.data().follower);

      await snapshot.after.ref.update({
        to: [...newFeedObject.to, ...followersList],
      });
    } else if (shouldGoPrivate) {
      const partners: string[] = newFeedObject.partnersIDs;

      await snapshot.after.ref.update({
        to: [newFeedObject.userID, ...partners],
      });
    }
  });

export const followUser = functions.firestore
  .document("followers/{documentID}")
  .onCreate(async (snapshot) => {
    const follower = await firestore
      .collection("users")
      .doc(snapshot.data().follower)
      .get();
    const followed = await firestore
      .collection("users")
      .doc(snapshot.data().followed)
      .get();

    await followed.ref.update({
      followersCount: (followed.data()?.followersCount ?? 0) + 1,
    });
    await follower.ref.update({
      followingCount: (follower.data()?.followingCount ?? 0) + 1,
    });
    if (followed.data()) {
      const posts = (
        await firestore
          .collection("feed")
          .where("userID", "==", followed.id)
          .where("to", "array-contains", "*")
          .get()
      ).docs;
      for (let i = 0; i < posts.length; i++) {
        await posts[i].ref.update({
          to: [...posts[i].data().to, follower.id],
        });
      }
    }
  });

export const unfollowUser = functions
  .runWith({ timeoutSeconds: 540, memory: "1GB" })
  .firestore.document("followers/{documentID}")
  .onDelete(async (snapshot) => {
    const follower = await firestore
      .collection("users")
      .doc(snapshot.data().follower)
      .get();
    const followed = await firestore
      .collection("users")
      .doc(snapshot.data().followed)
      .get();

    await followed.ref.update({
      followersCount: Math.min((followed.data()?.followersCount ?? 0) - 1),
    });
    await follower.ref.update({
      followingCount: Math.min(0, (follower.data()?.followingCount ?? 0) - 1),
    });
    if (followed.data()) {
      const posts = (
        await firestore
          .collection("feed")
          .where("userID", "==", followed.id)
          .where("to", "array-contains", "*")
          .get()
      ).docs;
      for (let i = 0; i < posts.length; i++) {
        await posts[i].ref.update({
          to: [
            ...(posts[i].data().to
              ? (posts[i].data().to as []).filter((e) => e != follower.id)
              : []),
          ],
        });
      }
    }
  });
