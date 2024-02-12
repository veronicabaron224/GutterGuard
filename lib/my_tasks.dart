import 'package:flutter/material.dart';

class MyTasksPage extends StatefulWidget {
  const MyTasksPage({Key? key}) : super(key: key);

  @override
  MyTasksPageState createState() => MyTasksPageState();
}

class MyTasksPageState extends State<MyTasksPage> {
  List<Task> tasks = [
    Task(title: 'Task 1', isCompleted: false),
    Task(title: 'Task 2', isCompleted: true),
  ];

  List<Task> completedTasks = [];

  bool showCompletedTasks = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildTasksList(),
    );
  }

  Widget _buildTasksList() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(tasks[index].title),
                onTap: () {
                  _navigateToTaskDetails(tasks[index], isCompleted: false);
                },
              );
            },
          ),
        ),
        if (completedTasks.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(),
              _buildCompletedTasksLabel(),
              if (showCompletedTasks) ..._buildCompletedTasksList(),
            ],
          ),
      ],
    );
  }

  Widget _buildCompletedTasksLabel() {
    return ListTile(
      title: const Text('Completed Tasks'),
      onTap: () {
        setState(() {
          showCompletedTasks = !showCompletedTasks;
        });
      },
    );
  }

  List<Widget> _buildCompletedTasksList() {
    return completedTasks.map((completedTask) {
      return ListTile(
        title: Text(completedTask.title),
        onTap: () {
          _navigateToTaskDetails(completedTask, isCompleted: true);
        },
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                _setTaskAsIncomplete(completedTask);
              },
              child: const Text('Set as Incomplete'),
            ),
          ],
        ),
      );
    }).toList();
  }

  void _navigateToTaskDetails(Task task, {required bool isCompleted}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TaskDetailsPage(task: task, isCompleted: isCompleted)),
    );

    if (result != null && result is bool) {
      if (result) {
        // If task is completed, move it to the completedTasks list
        setState(() {
          tasks.remove(task);
          completedTasks.add(task);
        });
      } else {
        // If "Unassign Myself" is clicked, delete the task
        setState(() {
          tasks.remove(task);
        });
      }
    }
  }

  void _setTaskAsIncomplete(Task task) {
    setState(() {
      completedTasks.remove(task);
      tasks.add(task);
    });
  }
}

class TaskDetailsPage extends StatelessWidget {
  final Task task;
  final bool isCompleted;

  const TaskDetailsPage({Key? key, required this.task, required this.isCompleted}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(task.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Task Details: ${task.title}'),
            if (!isCompleted) ...[
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Set task as completed and pop the page
                      Navigator.pop(context, true);
                    },
                    child: const Text('Set as Completed'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      // Unassign oneself from the task and remove it from the list
                      Navigator.pop(context, false);
                    },
                    child: const Text('Unassign Myself'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class Task {
  final String title;
  final bool isCompleted;

  Task({required this.title, required this.isCompleted});
}

void main() {
  runApp(const MaterialApp(
    home: MyTasksPage(),
  ));
}
