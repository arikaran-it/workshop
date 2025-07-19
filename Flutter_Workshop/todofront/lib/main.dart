// lib/main.dart
import 'package:flutter/material.dart';
import 'package:todofront/models/todo.dart'; // Import your Todo model
import 'package:todofront/services/todo_service.dart'; // Import your TodoService

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo Frontend',
      theme: ThemeData(
        primarySwatch: Colors.blue, // A default blue for AppBar and button
        visualDensity: VisualDensity.adaptivePlatformDensity,
        // No custom theme configurations for a very basic look
      ),
      home: const TodoListScreen(),
    );
  }
}

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});
  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final TodoService _todoService = TodoService();
  late Future<List<Todo>> _todosFuture;
  final TextEditingController _descriptionController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _todosFuture = _todoService.fetchTodos();
  }

  void _refreshTodos() {
    setState(() {
      _todosFuture = _todoService.fetchTodos();
    });
  }

  void _addTodo() async {
    if (_descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Todo description cannot be empty!')),
      );
      return;
    }
    try {
      final newTodo = Todo(description: _descriptionController.text);
      await _todoService.addTodo(newTodo);
      _descriptionController.clear();
      _refreshTodos();
    } catch (e) {
      print('Error adding todo: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to add todo: $e')));
    }
  }

  void _toggleTodoStatus(Todo todo) async {
    setState(() {
      todo.completed = !todo.completed;
    });
    try {
      await _todoService.updateTodo(todo);
    } catch (e) {
      print('Error updating todo: $e');
      setState(() {
        todo.completed = !todo.completed;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update todo: $e')));
    }
  }

  void _deleteTodo(int id) async {
    try {
      await _todoService.deleteTodo(id);
      _refreshTodos();
    } catch (e) {
      print('Error deleting todo: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to delete todo: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshTodos),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(
              16.0,
            ), // Increased padding for the whole row
            child: Row(
              children: [
                Expanded(
                  // Wrapped TextField in a Container for custom background and shadow
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(
                        0xFFF3F2F7,
                      ), // Light greyish-purple background
                      borderRadius: BorderRadius.circular(
                        15.0,
                      ), // Rounded corners
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2), // Subtle shadow
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        hintText:
                            'What do you need to do?', // Changed hint text
                        border: InputBorder.none, // No default TextField border
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 14.0,
                        ), // Adjust padding
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 12,
                ), // Space between text field and button
                // Custom circular button with '+' icon
                GestureDetector(
                  onTap: _addTodo,
                  child: Container(
                    width: 50, // Fixed width
                    height: 50, // Fixed height to make it circular
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.deepPurple, // Purple color for the button
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepPurple.withOpacity(
                            0.3,
                          ), // Shadow matching button color
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.add, // Plus icon
                      color: Colors.white, // White icon
                      size: 28,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Todo>>(
              future: _todosFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.assignment_turned_in,
                          size: 80,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No todos yet! Add one above.',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final todo = snapshot.data![index];
                      return Column(
                        children: [
                          ListTile(
                            leading: Checkbox(
                              value: todo.completed,
                              onChanged: (bool? newValue) {
                                _toggleTodoStatus(todo);
                              },
                              activeColor: Colors.blue,
                            ),
                            title: Text(
                              todo.description,
                              style: TextStyle(
                                fontSize: 16.0,
                                decoration: todo.completed
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                                color: todo.completed
                                    ? Colors.grey[600]
                                    : Colors.black,
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteTodo(todo.id!),
                            ),
                            onTap: () {
                              _toggleTodoStatus(todo);
                            },
                          ),
                          const Divider(height: 1, indent: 16, endIndent: 16),
                        ],
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
