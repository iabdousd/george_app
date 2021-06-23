import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import moment = require("moment");

admin.initializeApp();
const firestore = admin.firestore();
const fcm = admin.messaging();

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

    await sendNotificationToUser(
      followed.id,
      "New Follower",
      follower.data()?.fullName,
      "NEW_FOLLOW",
      {
        user: JSON.stringify(follower.data()),
      }
    );
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

export const onFeedPostDeletion = functions.firestore
  .document("feed/{documentID}")
  .onDelete(async (snapshot) => {
    await firestore.recursiveDelete(
      firestore.collection("feed").doc(snapshot.id).collection("feed-likes")
    );
  });

const sendNotificationToUser = async (
  userID: string,
  title: string,
  body: string,
  action: string,
  data?: any
) => {
  const userTokens: string[] = (
    await firestore.collection("users").doc(userID).get()
  ).data()?.fcmTokens;
  const payLoad: admin.messaging.MessagingPayload = {
    notification: {
      title,
      body,
      clickaction: "FLUTTER_NOTIFICATION_CLICK",
    },
    data: {
      clickaction: "FLUTTER_NOTIFICATION_CLICK",
      priority: "normal",
      "apns-priority": "5",
      action,
      ...data,
    },
  };

  return await fcm
    .sendToDevice(userTokens, payLoad, {
      priority: "high",
      android: {
        clickAction: "FLUTTER_NOTIFICATION_CLICK",
        priority: "high",
      },
      apns: {
        headers: {
          "apns-priority": "5",
        },
      },
    })
    .then(() =>
      functions.logger.log(`SENT NOTIFICATION OF ${title} to ${userID}`)
    );
};

export const eventsRunner = functions
  .runWith({ memory: "2GB" })
  .pubsub.schedule("* * * * *")
  .onRun(async () => {
    const now = new Date();
    const oneTimeQuery = firestore
      .collection("tasks")
      .where("repetition", "==", null)
      .where(
        "startDate",
        "==",
        admin.firestore.Timestamp.fromMillis(
          new Date(
            now.getUTCFullYear(),
            now.getUTCMonth(),
            now.getUTCDate()
          ).getTime()
        )
      )
      .where(
        "startTime",
        "==",
        admin.firestore.Timestamp.fromMillis(
          Date.UTC(1970, 0, 1, now.getUTCHours(), now.getUTCMinutes() + 10)
        )
      );

    const oneTimeTasks = await oneTimeQuery.get();

    const recurringQuery = firestore
      .collection("tasks")
      .where("repetition", "!=", null)
      .where(
        "dueDates",
        "array-contains",
        admin.firestore.Timestamp.fromMillis(
          new Date(
            now.getUTCFullYear(),
            now.getUTCMonth(),
            now.getUTCDate()
          ).getTime()
        )
      )
      .where(
        "startTime",
        "==",
        admin.firestore.Timestamp.fromMillis(
          Date.UTC(1970, 0, 1, now.getUTCHours(), now.getUTCMinutes() + 10)
        )
      );

    const recurringTasks = await recurringQuery.get();

    const jobs: Promise<any>[] = [];

    for (let i = 0; i < oneTimeTasks.size; i++) {
      const snapshot = oneTimeTasks.docs[i];
      const { userID, title, partnersIDs } = snapshot.data();

      if (userID) {
        jobs.push(
          sendNotificationToUser(
            userID,
            "Upcoming Task In 10 minutes !",
            `${title}`,
            "TASK_STARTING"
          ).then((_) =>
            functions.logger.log(`SENT NOTIFICATION OF ${title} to ${userID}`)
          )
        );
        if (partnersIDs && partnersIDs.length > 0) {
          for (let i = 0; i < partnersIDs.length; i++) {
            jobs.push(
              sendNotificationToUser(
                partnersIDs[i],
                "Upcoming Partner Task",
                `${title}`,
                "PARTNER_TASK_STARTING"
              )
            );
          }
        }
      }
    }

    for (let i = 0; i < recurringTasks.size; i++) {
      const snapshot = recurringTasks.docs[i];
      const {
        userID,
        title,
        partnersIDs,
      }: { userID: string; title: string; partnersIDs: string[] } =
        snapshot.data() as any;

      if (userID) {
        jobs.push(
          sendNotificationToUser(
            userID,
            "Upcoming Task In 10 minutes !",
            `${title}`,
            "TASK_STARTING"
          )
        );

        if (partnersIDs && partnersIDs.length > 0) {
          for (let i = 0; i < partnersIDs.length; i++) {
            jobs.push(
              sendNotificationToUser(
                partnersIDs[i],
                "Upcoming Partner Task",
                `${title}`,
                "PARTNER_TASK_STARTING"
              )
            );
          }
        }
      }
    }

    // GOALS END DATE REMINDER
    const endingGoals = await firestore
      .collection("goals")
      .where(
        "endDate",
        "==",
        admin.firestore.Timestamp.fromMillis(
          new Date(
            now.getUTCFullYear(),
            now.getUTCMonth(),
            now.getUTCDate() - 3,
            now.getUTCHours(),
            now.getUTCMinutes()
          ).getTime()
        )
      )
      .get();

    for (let i = 0; i < endingGoals.size; i++) {
      const snapshot = endingGoals.docs[i];
      const { userID, title } = snapshot.data();

      jobs.push(
        sendNotificationToUser(
          userID,
          "Goal Almost Accomlished",
          `Congrats! You are just three days behind accomplishing your goal \"${title}\" !`,
          "GOAL_ALMOST_DONE"
        )
      );
    }

    // ENDING PARTNERS TASKS
    const endingOneTimeQuery = firestore
      .collection("tasks")
      .where("repetition", "==", null)
      .where(
        "startDate",
        "==",
        admin.firestore.Timestamp.fromMillis(
          new Date(
            now.getUTCFullYear(),
            now.getUTCMonth(),
            now.getUTCDate()
          ).getTime()
        )
      )
      .where(
        "endTime",
        "==",
        admin.firestore.Timestamp.fromMillis(
          Date.UTC(1970, 0, 1, now.getUTCHours(), now.getUTCMinutes())
        )
      );

    const endingOneTimeTasks = await endingOneTimeQuery.get();

    const endingRecurringQuery = firestore
      .collection("tasks")
      .where("repetition", "!=", null)
      .where(
        "dueDates",
        "array-contains",
        admin.firestore.Timestamp.fromMillis(
          new Date(
            now.getUTCFullYear(),
            now.getUTCMonth(),
            now.getUTCDate()
          ).getTime()
        )
      )
      .where(
        "endTime",
        "==",
        admin.firestore.Timestamp.fromMillis(
          Date.UTC(1970, 0, 1, now.getUTCHours(), now.getUTCMinutes())
        )
      );

    const endingRecurringTasks = await endingRecurringQuery.get();

    for (let i = 0; i < endingOneTimeTasks.size; i++) {
      const snapshot = endingOneTimeTasks.docs[i];
      const { title, partnersIDs } = snapshot.data();

      if (partnersIDs && partnersIDs.length > 0) {
        for (let i = 0; i < partnersIDs.length; i++) {
          jobs.push(
            sendNotificationToUser(
              partnersIDs[i],
              "Partner Task Ended",
              `${title}`,
              "PARTNER_TASK_ENDED"
            )
          );
        }
      }
    }

    for (let i = 0; i < endingRecurringTasks.size; i++) {
      const snapshot = endingRecurringTasks.docs[i];
      const { title, partnersIDs }: { title: string; partnersIDs: string[] } =
        snapshot.data() as any;

      if (partnersIDs && partnersIDs.length > 0) {
        for (let i = 0; i < partnersIDs.length; i++) {
          jobs.push(
            sendNotificationToUser(
              partnersIDs[i],
              "Partner Task Ended",
              `${title}`,
              "PARTNER_TASK_ENDED"
            )
          );
        }
      }
    }

    return await Promise.all(jobs);
  });

export const weeklyEvent = functions
  .runWith({ memory: "2GB" })
  .pubsub.schedule("0 11 * * 1")
  .onRun(async () => {
    const usersSnapshot = await firestore.collection("users").get();
    const jobs: Promise<any>[] = [];

    function getMonday(d: Date) {
      d = new Date(d);
      var day = d.getDay(),
        diff = d.getDate() - day + (day == 0 ? -6 : 1);
      return new Date(d.setDate(diff));
    }

    for (let i = 0; i < usersSnapshot.size; i++) {
      const snapshot = usersSnapshot.docs[i];
      const userID = snapshot.id;
      const previousWeekKey: string =
        moment(getMonday(new Date())).format("yyyy-MM-dd") + " 00:00:00.000";

      const lastWeekSnapshot = await firestore
        .collection("statistics")
        .doc(userID + new Date().getUTCFullYear().toString())
        .collection("weekly")
        .doc(previousWeekKey)
        .get();

      if (lastWeekSnapshot.data()) {
        jobs.push(
          sendNotificationToUser(
            userID,
            "Previous week summary",
            `Congratulations! You have completed ${
              lastWeekSnapshot.data()?.accomplishedTasks ?? 0
            } task(s) last week !`,
            "WEEK_SUMMARY"
          )
        );
      }
    }

    return await Promise.all(jobs);
  });

export const dailyEvent = functions
  .runWith({ memory: "2GB" })
  .pubsub.schedule("0 22 * * *")
  .onRun(async () => {
    const usersSnapshot = await firestore.collection("users").get();
    const jobs: Promise<any>[] = [];

    for (let i = 0; i < usersSnapshot.size; i++) {
      const snapshot = usersSnapshot.docs[i];
      const userID = snapshot.id;
      const userTokens: string[] = (
        await firestore.collection("users").doc(userID).get()
      ).data()?.fcmTokens;
      if (userTokens) {
        const now = new Date();
        const nowDate = new Date(
          now.getUTCFullYear(),
          now.getUTCMonth(),
          now.getUTCDate()
        );
        const todayTasks = await firestore
          .collection("tasks")
          .where(
            "dueDates",
            "array-contains",
            admin.firestore.Timestamp.fromMillis(nowDate.getTime())
          )
          .get();

        if (todayTasks.size > 0) {
          const accomplishedTasks = todayTasks.docs.filter(
            (e) =>
              (e.data().repetition != null &&
                e
                  .data()
                  ?.donesHistory?.contains(
                    admin.firestore.Timestamp.fromMillis(nowDate.getTime())
                  )) ||
              e.data().status == 1
          );

          jobs.push(
            sendNotificationToUser(
              userID,
              "Today's summary",
              accomplishedTasks.length > 0
                ? `Congratulations! You have completed ${accomplishedTasks.length} task(s) today !`
                : `You missed out ${todayTasks.size} tasks !`,
              "TODAY_SUMMARY"
            )
          );
        }
      }
    }

    return await Promise.all(jobs);
  });

export const onComment = functions.firestore
  .document("notes/{documentID}")
  .onCreate(async (snapshot) => {
    const { taskRef, userID } = snapshot.data();
    if (taskRef) {
      const task = await firestore.collection("tasks").doc(taskRef).get();
      if (task.exists) {
        if (userID != task.data()?.userID) {
          await sendNotificationToUser(
            task.data()?.userID,
            "New Comment",
            `There's a new comment in your task: ${task.data()?.title}`,
            "COMMENT_RECIEVED",
            {
              task: JSON.stringify({
                ...task.data(),
                id: snapshot.data().feedArticleID,
                creationDate: (
                  task.data()?.creationDate as admin.firestore.Timestamp
                ).toMillis(),
                dueDates: (
                  task.data()?.dueDates as admin.firestore.Timestamp[]
                ).map((e) => e.toMillis()),
                donesHistory: (
                  task.data()?.donesHistory as admin.firestore.Timestamp[]
                ).map((e) => e.toMillis()),
                startDate: (
                  task.data()?.startDate as admin.firestore.Timestamp
                ).toMillis(),
                endDate: (
                  task.data()?.endDate as admin.firestore.Timestamp
                ).toMillis(),
                startTime: (
                  task.data()?.startTime as admin.firestore.Timestamp
                ).toMillis(),
                endTime: (
                  task.data()?.endTime as admin.firestore.Timestamp
                ).toMillis(),
              }),
            }
          );
        }
      }
    }
  });

export const onMessage = functions.firestore
  .document("chat/{chatID}/chatMessages/{messageID}")
  .onCreate(async (snapshot, context) => {
    const chatID = context.params.chatID;

    const chat = (await firestore.collection("chat").doc(chatID).get()).data();

    if (chat) {
      if (chat.usersIDs) {
        const toSendTo: string[] = [...(chat.usersIDs as string[])].filter(
          (e) => e != snapshot.data()?.senderID
        );
        const newMessages = {
          ...(chat.newMessages ?? {}),
        };

        newMessages[`${toSendTo[0]}`] =
          (chat.newMessages[toSendTo[0]] ?? 0) + 1;

        await firestore.collection("chat").doc(chat.chatUID).update({
          newMessages: newMessages,
          lastMessage: snapshot.data().content,
          lastMessageDate: admin.firestore.Timestamp.now(),
        });

        for (let i = 0; i < toSendTo.length; i++) {
          const userID = toSendTo[i];
          await sendNotificationToUser(
            userID,
            "New Message",
            snapshot.data()?.content,
            "MESSAGE_RECIEVED",
            {
              chat: JSON.stringify({
                ...chat,
                lastMessageDate: (
                  chat.lastMessageDate as admin.firestore.Timestamp
                ).toMillis(),
              }),
            }
          );
        }
      }
    }
  });

export const onInvite = functions.firestore
  .document("notifications/{notificationID}")
  .onCreate(async (snapshot) => {
    const userID = snapshot.data()?.reciever;
    if (userID) {
      const invitationType = snapshot.data()?.type;

      await sendNotificationToUser(
        userID,
        invitationType == "TASK_PARTNER_INVITATION"
          ? "Task Partnership Invitation"
          : invitationType == "GOAL_PARTNER_INVITATION"
          ? "Goal Partnership Invitation"
          : invitationType == "STACK_PARTNER_INVITATION"
          ? "Stack Partnership Invitation"
          : "New Notification",
        invitationType == "TASK_PARTNER_INVITATION"
          ? `You got invited to: ${snapshot.data().taskTitle}`
          : invitationType == "GOAL_PARTNER_INVITATION"
          ? `You got invited to: ${snapshot.data().goalTitle}`
          : invitationType == "STACK_PARTNER_INVITATION"
          ? `You got invited to: ${snapshot.data().stackTitle}`
          : snapshot.data().content ?? "",
        "INVITATION_TO_TASK"
      )
        .catch(functions.logger.error)
        .then((res) =>
          functions.logger.log(
            `SENDING NOTIFICATION SUCCEED: ${JSON.stringify(res)}`
          )
        );
    }
  });

export const onInviteUpdate = functions.firestore
  .document("notifications/{notificationID}")
  .onUpdate(async (snapshot) => {
    if (snapshot.after.data().status == 0) return;
    const userID = snapshot.after.data()?.senderID;
    if (userID) {
      const accepted = snapshot.after.data()?.accepted;
      const invitationType = snapshot.before.data()?.type;

      await sendNotificationToUser(
        userID,
        accepted ? "Invitation Accepted" : "Invitation Declined",
        invitationType == "TASK_PARTNER_INVITATION"
          ? `${snapshot.before.data().taskTitle}`
          : invitationType == "GOAL_PARTNER_INVITATION"
          ? `${snapshot.before.data().goalTitle}`
          : invitationType == "STACK_PARTNER_INVITATION"
          ? `${snapshot.before.data().stackTitle}`
          : snapshot.before.data().content ?? "",
        "INVITATION_TO_TASK"
      )
        .catch(functions.logger.error)
        .then((res) =>
          functions.logger.log(
            `SENDING NOTIFICATION SUCCEED: ${JSON.stringify(res)}`
          )
        );
    }
  });

export const onLike = functions.firestore
  .document("feed/{feedID}/feed-likes/{feedLikeID}")
  .onCreate(async (snapshot, context) => {
    const { userID } = snapshot.data();

    const liker = await firestore.collection("users").doc(userID).get();

    const feedPost = await firestore
      .collection("feed")
      .doc(context.params.feedID)
      .get();

    await sendNotificationToUser(
      feedPost.data()?.userID,
      "New Like",
      `${liker.data()?.fullName} liked your post: ${feedPost.data()?.title}`,
      "NEW_LIKE",
      {
        task: JSON.stringify({
          ...feedPost.data(),
          id: feedPost.id,
          creationDate: (
            feedPost.data()?.creationDate as admin.firestore.Timestamp
          ).toMillis(),
          dueDates: (
            feedPost.data()?.dueDates as admin.firestore.Timestamp[]
          ).map((e) => e.toMillis()),
          donesHistory: (
            feedPost.data()?.donesHistory as admin.firestore.Timestamp[]
          ).map((e) => e.toMillis()),
          startDate: (
            feedPost.data()?.startDate as admin.firestore.Timestamp
          ).toMillis(),
          endDate: (
            feedPost.data()?.endDate as admin.firestore.Timestamp
          ).toMillis(),
          startTime: (
            feedPost.data()?.startTime as admin.firestore.Timestamp
          ).toMillis(),
          endTime: (
            feedPost.data()?.endTime as admin.firestore.Timestamp
          ).toMillis(),
        }),
      }
    );
  });
