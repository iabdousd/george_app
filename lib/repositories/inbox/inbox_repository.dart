import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:stackedtasks/constants/models/inbox_item.dart';
import 'package:stackedtasks/models/Goal.dart';
import 'package:stackedtasks/models/InboxItem.dart';
import 'package:stackedtasks/services/feed-back/flush_bar.dart';
import 'package:stackedtasks/services/feed-back/loader.dart';

import '../../constants/models/stack.dart';
import '../../constants/user.dart';
import '../../models/Stack.dart';
import '../../models/Task.dart';
import '../../services/user/user_service.dart';

class InboxRepositoryResult {
  bool status;
  dynamic result;
  InboxRepositoryResult({
    this.status,
    this.result,
  });
}

class InboxRepository {
  static Future<Task> getInboxTask(String taskRef) async {
    final res = await FirebaseFirestore.instance
        .collection(USERS_KEY)
        .doc(getCurrentUser().uid)
        .collection(TASKS_KEY)
        .doc(taskRef)
        .get();

    return Task.fromJson(
      res.data(),
      id: res.id,
    );
  }

  static Future<TasksStack> getInboxStack(String reference) async {
    final res = await FirebaseFirestore.instance
        .collection(USERS_KEY)
        .doc(getCurrentUser().uid)
        .collection(INBOX_COLLECTION)
        .doc(reference)
        .get();

    if (res.data() != null)
      return TasksStack.fromJson(
        res.data(),
        id: res.id,
      );
    return null;
  }

  static Stream<List<InboxItem>> getInboxItems() {
    return FirebaseFirestore.instance
        .collection(USERS_KEY)
        .doc(getCurrentUser().uid)
        .collection(INBOX_COLLECTION)
        .orderBy(INBOX_ITEM_CREATION_DATE, descending: true)
        .snapshots()
        .asyncMap(
      (event) async {
        List<InboxItem> items = [];
        for (final e in event.docs) {
          if (e.data()[INBOX_ITEM_TYPE] == INBOX_STACK_ITEM_TYPE)
            items.add(TasksStack.fromJson(
              e.data(),
              id: e.id,
              goalRef: 'inbox',
              goalTitle: 'Inbox',
            )..itemType = INBOX_STACK_ITEM_TYPE);
          else {
            final task = await getInboxTask(e.id);
            items.add(
              task..itemType = INBOX_TASK_ITEM_TYPE,
            );
          }
        }
        return items;
      },
    );
  }

  static Future<InboxRepositoryResult> saveInboxItem(
    String type, {
    String reference,
    Map<String, dynamic> data: const {},
  }) async {
    try {
      if (reference != null && reference.isNotEmpty) {
        final res = FirebaseFirestore.instance
            .collection(USERS_KEY)
            .doc(getCurrentUser().uid)
            .collection(INBOX_COLLECTION)
            .doc(reference);

        await res.set(
          {
            INBOX_ITEM_TYPE: type,
            INBOX_ITEM_CREATION_DATE: Timestamp.fromDate(
              DateTime.now(),
            ),
            ...data,
          },
        );
        return InboxRepositoryResult(
          status: true,
          result: res.id,
        );
      } else {
        final res = await FirebaseFirestore.instance
            .collection(USERS_KEY)
            .doc(getCurrentUser().uid)
            .collection(INBOX_COLLECTION)
            .add(
          {
            INBOX_ITEM_TYPE: type,
            ...data,
          },
        );

        return InboxRepositoryResult(
          status: true,
          result: res.id,
        );
      }
    } catch (e) {
      return InboxRepositoryResult(
        status: false,
      );
    }
  }

  static Future<bool> deleteInboxItem(String docRef) async {
    try {
      await FirebaseFirestore.instance
          .collection(USERS_KEY)
          .doc(getCurrentUser().uid)
          .collection(INBOX_COLLECTION)
          .doc(docRef)
          .delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> groupStacks(
    List<TasksStack> stacks, {
    String goalRef,
    String goalTitle,
    DateTime goalStartDate,
    DateTime goalEndDate,
  }) async {
    try {
      assert(goalRef != null || (goalTitle != null && goalTitle.isNotEmpty));
      await toggleLoading(state: true);
      if (goalRef != null) {
        // TODO:
        return true;
      } else {
        final goal = Goal(
          title: goalTitle,
          creationDate: DateTime.now(),
          startDate: goalStartDate,
          endDate: goalEndDate,
          color: Theme.of(Get.context).primaryColor.value.toRadixString(16),
        );
        await goal.save();
        for (final stack in stacks) {
          stack.goalRef = goal.id;
          await stack.save();
          await deleteInboxItem(stack.id);
        }
        await toggleLoading(state: false);
        showFlushBar(
          title: 'Goal Saved',
          message: 'The selected stacks were grouped into a goal successfully',
          success: true,
        );
        return true;
      }
    } catch (e) {
      print(e);
      await toggleLoading(state: false);
      showFlushBar(
        title: 'Grouping Error',
        message: 'Couldn\'t group your stacks, please try again later.',
        success: false,
      );
      return false;
    }
  }

  static Future<bool> groupTasks(
    List<Task> tasks, {
    String stackRef,
    String stackTitle,
  }) async {
    try {
      assert(stackRef != null || (stackTitle != null && stackTitle.isNotEmpty));
      await toggleLoading(state: true);
      if (stackRef != null) {
        // TODO:
        return true;
      } else {
        final stack = TasksStack(
          title: stackTitle,
          goalRef: 'inbox',
          creationDate: DateTime.now(),
          goalTitle: 'Inbox',
          color: Theme.of(Get.context).primaryColor.value.toRadixString(16),
        );
        final res = await saveInboxItem(
          INBOX_STACK_ITEM_TYPE,
          data: stack.toJson(),
        );
        for (final task in tasks) {
          task.stackRef = res.result;
          await task.save();
          await deleteInboxItem(task.id);
        }
        await toggleLoading(state: false);
        showFlushBar(
          title: 'Stack Saved',
          message: 'The selected tasks were grouped into a stack successfully',
          success: true,
        );
        return true;
      }
    } catch (e) {
      return false;
    }
  }
}
