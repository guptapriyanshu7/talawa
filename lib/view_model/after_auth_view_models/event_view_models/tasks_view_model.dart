import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:talawa/enums/enums.dart';
import 'package:talawa/locator.dart';
import 'package:talawa/models/events/event_model.dart';
import 'package:talawa/models/user/user_info.dart';
import 'package:talawa/services/database_mutation_functions.dart';
import 'package:talawa/services/navigation_service.dart';
import 'package:talawa/services/user_config.dart';
import 'package:talawa/utils/task_queries.dart';
import 'package:talawa/view_model/base_view_model.dart';

class Task {
  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.deadline,
    required this.creator,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      createdAt: json['createdAt'] as String,
      deadline: json['deadline'] as String,
      creator: User.fromJson(
        json['creator'] as Map<String, dynamic>,
        fromOrg: true,
      ),
    );
  }

  final String id;
  final String title;
  final String description;
  final String createdAt;
  final String deadline;
  final User creator;
}

class TasksViewModel extends BaseModel {
  final _tasks = <Task>[];

  List<Task> get tasks => _tasks;

  void addTask(Task task) {
    setState(ViewState.busy);
    _tasks.add(task);
    setState(ViewState.idle);
  }

  Future<void> fetchTasks(Event event) async {
    setState(ViewState.busy);
    _tasks.clear();

    final res = await locator<DataBaseMutationFunctions>()
        .gqlAuthQuery(TaskQueries.eventTasks(event.id!)) as QueryResult;

    final tasksList = res.data!['tasksByEvent'] as List;
    tasksList.forEach((task) {
      _tasks.add(Task.fromJson(task as Map<String, dynamic>));
    });

    setState(ViewState.idle);
  }

  Future<void> deleteTask(String taskId, String creatorId) async {
    if (creatorId == locator<UserConfig>().currentUser.id) {
      setState(ViewState.busy);

      await locator<DataBaseMutationFunctions>()
          .gqlAuthMutation(TaskQueries.deleteTask(taskId)) as QueryResult;

      _tasks.removeWhere((task) => task.id == taskId);

      setState(ViewState.idle);
    }
  }
}

class CreateTaskViewModel extends BaseModel {
  late final String title;
  late final String description;
  late final String deadline;
  final formKey = GlobalKey<FormState>();

  Future<void> addTask(Event event) async {
    final res = await locator<DataBaseMutationFunctions>()
        .gqlAuthMutation(TaskQueries.addTask(
      title: title,
      description: description,
      deadline: deadline,
      eventId: event.id!,
    ));

    final task = Task.fromJson(res.data!['createTask'] as Map<String, dynamic>);

    locator<NavigationService>().pop(task);
  }
}
