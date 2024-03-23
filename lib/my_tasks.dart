import 'package:flutter/material.dart';

class MyTasksPage extends StatefulWidget {
  const MyTasksPage({super.key});

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
              return _buildTaskItem(tasks[index], isCompleted: false);
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

  Widget _buildTaskItem(Task task, {required bool isCompleted}) {
    return InkWell(
      onTap: () {
        _navigateToTaskDetails(task, isCompleted: isCompleted);
      },
      child: Container(
        margin: const EdgeInsets.all(1.0),
        padding: const EdgeInsets.all(2.5),
        child: ListTile(
          title: Text(task.title),
          trailing: const Text(
            '>',
            style: TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildCompletedTasksLabel() {
    return InkWell(
      onTap: () {
        setState(() {
          showCompletedTasks = !showCompletedTasks;
        });
      },
      child: Container(
        margin: const EdgeInsets.all(9.0),
        padding: const EdgeInsets.all(3.0),
        child: const ListTile(
          title: Text(
            'Completed Tasks',
            style: TextStyle(
              fontWeight: FontWeight.bold, // Make the text bold
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildCompletedTasksList() {
    return completedTasks.map((completedTask) {
      return InkWell(
        onTap: () {
          _navigateToTaskDetails(completedTask, isCompleted: true);
        },
        child: Container(
          margin: const EdgeInsets.all(9.0),
          padding: const EdgeInsets.all(3.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            title: Text(completedTask.title),
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
          ),
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

  const TaskDetailsPage({super.key, required this.task, required this.isCompleted});

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