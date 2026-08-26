import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../services/task_provider.dart';
import '../widgets/task_tile.dart';
import 'add_task_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final List<TaskCategory?> _filters = [
    null, // All
    TaskCategory.work,
    TaskCategory.personal,
    TaskCategory.study,
    TaskCategory.health,
    TaskCategory.other,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _filters.length, vsync: this);
    // Load persisted tasks from SQLite as soon as the screen mounts.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().loadTasks();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _filters
              .map((f) => Tab(text: f == null ? 'All' : f.label))
              .toList(),
        ),
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, _) {
          return TabBarView(
            controller: _tabController,
            children: _filters.map((filter) {
              final tasks = filter == null
                  ? taskProvider.tasks
                  : taskProvider.tasksByCategory(filter);

              if (tasks.isEmpty) {
                return const Center(child: Text('No tasks yet'));
              }

              return ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return TaskTile(
                    task: task,
                    onToggle: () => taskProvider.toggleComplete(task),
                    onDelete: () => taskProvider.deleteTask(task),
                  );
                },
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddTaskScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
