import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import moment = require("moment");

admin.initializeApp();
const firestore = admin.firestore();
const fcm = admin.messaging();

// --- PRIVATE FUNCTIONS
const sendNotificationToUser = async (
  userID: string,
  title: string,
  body: string,
  action: string,
  icon: string,
  saveNotification: boolean,
  senderID?: string,
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
      data: JSON.stringify(data ?? {}),
    },
  };

  if (saveNotification) {
    const snapshot = await firestore.collection("notifications").add({
      userID,
      senderID: senderID ?? "",
      creationDate: admin.firestore.Timestamp.now(),
      status: 0,
      title,
      body,
      icon,
      action,
      data: data ?? {},
    });
    await snapshot.update({ uid: snapshot.id });
  }
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

const getChatByUsers = async (users: string[]) => {
  let chats = await firestore
    .collection("chat")
    .where("usersIDs", "==", users)
    .get();
  if (chats.empty || chats.docs.length == 0) {
    chats = await firestore
      .collection("chat")
      .where("usersIDs", "==", [...users].reverse())
      .get();
  }
  return chats.docs.length > 0 ? chats.docs[0] : null;
};

const createChatBetweenUsers = async (users: string[]): Promise<void> => {
  const alreadyChat = await getChatByUsers(users);
  if (alreadyChat == null) {
    const newChat = await firestore.collection("chat").add({
      usersIDs: users,
      status: 1,
      lastMessage: "Be the first one to send a message!",
      lastMessageDate: admin.firestore.Timestamp.now(),
      newMessages: {},
    });
    await newChat.update({ chatUID: newChat.id });
  }
};

const deleteChatBetweenUsers = async (
  users: string[],
  options?: {
    hardDelete: false;
  }
): Promise<void> => {
  const alreadyChat = await getChatByUsers(users);
  if (alreadyChat != null) {
    if (options?.hardDelete) await alreadyChat.ref.delete();
    else
      await alreadyChat.ref.update({
        status: -1,
      });
  }
};

// -- EXPORTED FUNCTIONS

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
      await createChatBetweenUsers([
        snapshot.data().follower,
        snapshot.data().followed,
      ]);

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
      follower.data()?.profilePicture,
      true,
      follower.id,
      follower.data()
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

    await deleteChatBetweenUsers([
      snapshot.data().follower,
      snapshot.data().followed,
    ]);

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
            "TASK_STARTING",
            "",
            false
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
                "PARTNER_TASK_STARTING",
                "",
                true,
                userID
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
            "TASK_STARTING",
            "",
            false
          )
        );

        if (partnersIDs && partnersIDs.length > 0) {
          for (let i = 0; i < partnersIDs.length; i++) {
            jobs.push(
              sendNotificationToUser(
                partnersIDs[i],
                "Upcoming Partner Task",
                `${title}`,
                "PARTNER_TASK_STARTING",
                "",
                true,
                userID
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
          "GOAL_ALMOST_DONE",
          "",
          true
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
      const { userID, title, partnersIDs } = snapshot.data();

      if (partnersIDs && partnersIDs.length > 0) {
        for (let i = 0; i < partnersIDs.length; i++) {
          jobs.push(
            sendNotificationToUser(
              partnersIDs[i],
              "Partner Task Ended",
              `${title}`,
              "PARTNER_TASK_ENDED",
              "",
              true,
              userID
            )
          );
        }
      }
    }

    for (let i = 0; i < endingRecurringTasks.size; i++) {
      const snapshot = endingRecurringTasks.docs[i];
      const {
        userID,
        title,
        partnersIDs,
      }: { userID: string; title: string; partnersIDs: string[] } =
        snapshot.data() as any;

      if (partnersIDs && partnersIDs.length > 0) {
        for (let i = 0; i < partnersIDs.length; i++) {
          jobs.push(
            sendNotificationToUser(
              partnersIDs[i],
              "Partner Task Ended",
              `${title}`,
              "PARTNER_TASK_ENDED",
              "",
              true,
              userID
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
            "WEEK_SUMMARY",
            "",
            true
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
              "TODAY_SUMMARY",
              "",
              true
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
    const { taskRef, attachmentsCount, userID } = snapshot.data();
    if (taskRef) {
      const task = await firestore.collection("tasks").doc(taskRef).get();

      if (task.exists) {
        const user = await firestore.collection("users").doc(userID).get();
        // if (snapshot.data().status == 0) {
        //   await addTaskLog(
        //     task.id,
        //     `${user.data()?.fullName} left ${
        //       snapshot.data().attachmentsCount > 0
        //         ? snapshot.data().attachmentsCount > 1
        //           ? "attachments"
        //           : "an attachment"
        //         : "a comment"
        //     }`,
        //     0,
        //     admin.firestore.Timestamp.now()
        //   );
        // }
        if (userID != task.data()?.userID) {
          await sendNotificationToUser(
            task.data()?.userID,
            user.data()?.fullName,
            `${
              attachmentsCount > 0
                ? `Added ${attachmentsCount} photos`
                : "Commented"
            } in %*b${task.data()?.title}%*n`,
            "COMMENT_RECIEVED",
            user.data()?.profilePicture,
            true,
            user.id,
            {
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
          (chat.newMessages ? chat.newMessages[toSendTo[0]] ?? 0 : 0) + 1;

        const newChat: Record<string, any> = {
          newMessages: newMessages,
          lastMessage: snapshot.data().content,
          lastMessageDate: admin.firestore.Timestamp.now(),
          lastMessageDateSenderID: snapshot.data()?.senderID,
        };

        await firestore.collection("chat").doc(chat.chatUID).update(newChat);

        for (let i = 0; i < toSendTo.length; i++) {
          const userID = toSendTo[i];
          const user = await firestore.collection("users").doc(userID).get();

          await sendNotificationToUser(
            userID,
            user.data()?.fullName,
            `New message: ${snapshot.data()?.content}`,
            "MESSAGE_RECIEVED",
            user.data()?.profilePicture,
            true,
            user.id,
            {
              ...chat,
              lastMessageDate:
                (
                  chat.lastMessageDate as admin.firestore.Timestamp
                )?.toMillis() ??
                admin.firestore.Timestamp.fromDate(new Date()).toMillis(),
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
      // const invitationType = snapshot.data()?.type;
      const { title, body } = snapshot.data();
      const sender = await firestore
        .collection("users")
        .doc(snapshot.data().senderID)
        .get();

      await sendNotificationToUser(
        userID,
        title,
        // invitationType == "TASK_PARTNER_INVITATION"
        //   ? "Task Partnership Invitation"
        //   : invitationType == "GOAL_PARTNER_INVITATION"
        //   ? "Goal Partnership Invitation"
        //   : invitationType == "STACK_PARTNER_INVITATION"
        //   ? "Stack Partnership Invitation"
        //   : "New Notification",
        body,
        // invitationType == "TASK_PARTNER_INVITATION"
        //   ? `You got invited to: ${snapshot.data().taskTitle}`
        //   : invitationType == "GOAL_PARTNER_INVITATION"
        //   ? `You got invited to: ${snapshot.data().goalTitle}`
        //   : invitationType == "STACK_PARTNER_INVITATION"
        //   ? `You got invited to: ${snapshot.data().stackTitle}`
        //   : snapshot.data().content ?? "",
        "INVITATION_TO_TASK",
        sender.data()?.profilePicture,
        false,
        sender.id,
        snapshot.data().data
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
    const { userID, senderID, title, body } = snapshot.after.data();
    if (senderID) {
      const accepted = snapshot.after.data()?.accepted;
      // const invitationType = snapshot.before.data()?.action;

      const reciever = await firestore.collection("users").doc(userID).get();

      await sendNotificationToUser(
        senderID,
        title,
        (body as string).replace(
          "Invited you",
          `${accepted ? "Accepted" : "Declined"} your invitation`
        ),
        // invitationType == "TASK_PARTNER_INVITATION"
        //   ? `${reciever.data()?.fullName} joined: "${snapshot.before.data().taskTitle}"`
        //   : invitationType == "GOAL_PARTNER_INVITATION"
        //   ? `${reciever.data()?.fullName} joined: "${snapshot.before.data().goalTitle}"`
        //   : invitationType == "STACK_PARTNER_INVITATION"
        //   ? `${reciever.data()?.fullName} joined: "${snapshot.before.data().stackTitle}"`
        //   : snapshot.before.data().content ?? "",
        "INVITATION_TO_TASK",
        reciever.data()?.profilePicture,
        true,
        snapshot.before.data().data
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
      liker.data()?.profilePicture,
      true,
      liker.id,
      {
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
      }
    );
  });

const addTaskLog = async (
  taskID: string,
  title: string,
  status: number,
  creationDate?: admin.firestore.Timestamp
) => {
  // await firestore.collection("taskLogs").add({
  //   taskID,
  //   log: title,
  //   creationDateTime: creationDate ?? admin.firestore.Timestamp.now(),
  //   status: status ?? 1,
  // });
};

export const onTaskCreation = functions.firestore
  .document("tasks/{taskID}")
  .onCreate(async (snapshot, _context) => {
    await addTaskLog(
      snapshot.id,
      `"${snapshot.data()["title"]}" created`,
      1,
      admin.firestore.Timestamp.now()
    );
  });

export const onTaskAdditionToStack = functions.firestore
  .document("tasks/{taskID}")
  .onUpdate(async (snapshot, context) => {
    if (
      snapshot.after.data().stackRef != "inbox" &&
      snapshot.before.data().stackRef == "inbox"
    ) {
      const stack = await firestore
        .collection("inbox-items")
        .doc(snapshot.after.data().stackRef)
        .get();

      await firestore.collection("taskLogs").add({
        taskID: snapshot.after.id,
        log: `"${snapshot.after.data().title}" added to "${
          stack.data()?.title
        }"`,
        creationDateTime: admin.firestore.Timestamp.now(),
        status: 1,
      });
    }
  });
