// lib/services/todo_service.dart

import 'dart:convert'; // For json.decode and json.encode
import 'package:http/http.dart' as http; // Alias http for convenience
import '../models/todo.dart'; // Import your Todo model

class TodoService {
  // IMPORTANT: Replace '10.0.2.2' with 'localhost' if running on a physical Android device
  // or if your backend is accessible via 'localhost' directly from the emulator.
  // '10.0.2.2' is the special IP address to access your host machine's localhost from an Android emulator.
  // If you change the Spring Boot port from 8080, update it here too.
  static const String baseUrl = 'http://10.0.2.2:8080/api/todos';

  // Fetch all todos
  Future<List<Todo>> fetchTodos() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, parse the JSON.
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((todo) => Todo.fromJson(todo)).toList();
    } else {
      // If the server did not return a 200 OK response, throw an exception.
      throw Exception(
        'Failed to load todos: ${response.statusCode} ${response.body}',
      );
    }
  }

  // Add a new todo
  Future<Todo> addTodo(Todo todo) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(todo.toJson()), // Convert Todo object to JSON string
    );

    if (response.statusCode == 201) {
      // 201 Created is typical for POST
      return Todo.fromJson(json.decode(response.body));
    } else {
      throw Exception(
        'Failed to add todo: ${response.statusCode} ${response.body}',
      );
    }
  }

  // Update an existing todo
  Future<Todo> updateTodo(Todo todo) async {
    final response = await http.put(
      Uri.parse('$baseUrl/${todo.id}'), // Include ID in the URL for PUT
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(todo.toJson()), // Convert Todo object to JSON string
    );

    if (response.statusCode == 200) {
      return Todo.fromJson(json.decode(response.body));
    } else {
      throw Exception(
        'Failed to update todo: ${response.statusCode} ${response.body}',
      );
    }
  }

  // Delete a todo
  Future<void> deleteTodo(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));

    if (response.statusCode == 204) {
      // 204 No Content is typical for successful DELETE
      // No content to parse for 204
    } else {
      throw Exception(
        'Failed to delete todo: ${response.statusCode} ${response.body}',
      );
    }
  }
}
