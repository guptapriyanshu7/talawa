import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:talawa/locator.dart';
import 'package:talawa/models/events/event_model.dart';
import 'package:talawa/services/navigation_service.dart';
import 'package:talawa/view_model/after_auth_view_models/event_view_models/tasks_view_model.dart';
import 'package:talawa/views/base_view.dart';

class EventTasksPage extends StatelessWidget {
  const EventTasksPage({Key? key, required this.event}) : super(key: key);

  final Event event;

  @override
  Widget build(BuildContext context) {
    return BaseView<TasksViewModel>(
      onModelReady: (model) => model.fetchTasks(event),
      builder: (_, model, __) => RefreshIndicator(
        onRefresh: () => model.fetchTasks(event),
        child: Scaffold(
          appBar: AppBar(
            title: Text(event.title ?? 'Event Tasks'),
          ),
          body: model.isBusy
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : ListView.builder(
                  itemCount: model.tasks.length,
                  itemBuilder: (context, index) {
                    final dateTime = DateTime.fromMillisecondsSinceEpoch(
                      int.parse(model.tasks[index].deadline),
                    );
                    return ListTile(
                      leading: Checkbox(
                        value: false,
                        onChanged: (_) {},
                      ),
                      title: Text(model.tasks[index].title),
                      subtitle: Text(model.tasks[index].description),
                      trailing: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                              "Creator: ${model.tasks[index].creator.firstName}"),
                          Text(
                            "Deadline: ${DateFormat('MM/dd/yyyy').format(dateTime)}",
                          ),
                        ],
                      ),
                      onLongPress: () {
                        locator<NavigationService>().pushDialog(
                          AlertDialog(
                            title: const Text('Delete Task'),
                            actions: [
                              TextButton(
                                child: const Text('Delete'),
                                onPressed: () {
                                  model.deleteTask(
                                    model.tasks[index].id,
                                    model.tasks[index].creator.id!,
                                  );
                                  locator<NavigationService>().pop();
                                },
                              ),
                              TextButton(
                                child: const Text('Cancel'),
                                onPressed: () =>
                                    locator<NavigationService>().pop(),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              final result = await locator<NavigationService>().pushScreen(
                '/addTask',
                arguments: event,
              );
              if (result != null) {
                model.addTask(result as Task);
              }
            },
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}
