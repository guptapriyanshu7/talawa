import 'package:flutter/material.dart';
import 'package:talawa/locator.dart';
import 'package:talawa/models/events/event_model.dart';
import 'package:talawa/services/navigation_service.dart';
import 'package:talawa/view_model/after_auth_view_models/event_view_models/tasks_view_model.dart';
import 'package:talawa/views/base_view.dart';

class AddTaskPage extends StatelessWidget {
  const AddTaskPage({Key? key, required this.event}) : super(key: key);

  final Event event;

  @override
  Widget build(BuildContext context) {
    return BaseView<CreateTaskViewModel>(
      builder: (_, model, __) => Scaffold(
        appBar: AppBar(
          title: const Text('Add Task'),
        ),
        body: Form(
          key: model.formKey,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Task Title',
                  ),
                  onSaved: (value) => model.title = value!,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Task name is required'
                      : null,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Task Description',
                  ),
                  onSaved: (value) => model.description = value!,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Task description is required'
                      : null,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Task Due Date',
                  ),
                  onSaved: (value) => model.deadline = value!,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Task due date is required'
                      : null,
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (model.formKey.currentState!.validate()) {
                      model.formKey.currentState!.save();
                      await model.addTask(event);
                    }
                  },
                  child: const Text('Add Task'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
