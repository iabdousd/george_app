import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:stackedtasks/constants/models/inbox_item.dart';
import 'package:stackedtasks/models/Goal.dart';
import 'package:stackedtasks/models/InboxItem.dart';
import 'package:stackedtasks/repositories/stack/stack_repository.dart';
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

  static Stream<List<TasksStack>> getInboxStacks() {
    return FirebaseFirestore.instance
        .collection(USERS_KEY)
        .doc(getCurrentUser().uid)
        .collection(INBOX_COLLECTION)
        .where(INBOX_ITEM_TYPE, isEqualTo: INBOX_STACK_ITEM_TYPE)
        .orderBy(INBOX_ITEM_CREATION_DATE, descending: true)
        .snapshots()
        .asyncMap(
      (event) async {
        return event.docs
            .map((e) => TasksStack.fromJson(
                  e.data(),
                  id: e.id,
                  goalRef: 'inbox',
                  goalTitle: 'Inbox',
                )..itemType = INBOX_STACK_ITEM_TYPE)
            .toList();
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
    List<TasksStack> stacks,
    Goal goal,
  ) async {
    try {
      await toggleLoading(state: true);
      for (final stack in stacks) {
        final oldStackId = stack.id;
        stack.id = null;
        stack.goalRef = goal.id;
        stack.goalTitle = goal.title;
        stack.color = goal.color;
        await stack.save();
        await deleteInboxItem(oldStackId);
        final tasks = await StackRepository.getStackTasks(
          stack.copyWith(
            id: oldStackId,
          ),
        );
        for (Task task in tasks) {
          await task.delete();
          task.id = null;
          task.goalRef = goal.id;
          task.goalTitle = goal.title;
          task.stackRef = stack.id;
          task.stackTitle = stack.title;
          task.stackColor = goal.color;
          await task.save();
        }
      }
      await toggleLoading(state: false);
      showFlushBar(
        title: 'Goal Saved',
        message: 'The selected stacks were grouped into a goal successfully',
        success: true,
      );
      return true;
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
    List<Task> tasks,
    TasksStack stack,
  ) async {
    try {
      await toggleLoading(state: true);

      for (final task in tasks) {
        task.goalRef = stack.goalRef;
        task.goalTitle = stack.goalTitle;
        task.stackTitle = stack.title;
        task.stackRef = stack.id;
        task.stackColor = stack.color;
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
    } catch (e) {
      print(e);
      await toggleLoading(state: false);
      showFlushBar(
        title: 'Grouping Error',
        message: 'Couldn\'t group your tasks, please try again later.',
        success: false,
      );
      return false;
    }
  }
}
