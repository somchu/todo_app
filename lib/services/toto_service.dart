import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/todo.dart';

class TodoService {
  static const String _todoKey = 'todos';
  //ดึงข้อมูล todo ทั้งหมด
  Future<List<Todo>?> getAllTodos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final todosJson = prefs.getString(_todoKey);

      if (todosJson == null || todosJson.isEmpty) {
        return [];
      }
      final List<dynamic> todoList = json.decode(todosJson);
      return todoList.map((json) => Todo.fromJson(json)).toList();
    } catch (e) {
      return null;
    }
  }

  //ดึงข้อมูล todo ตาม ID
  Future getTodoById(String id) async {
    try {
      final todos = await getAllTodos();
      return todos?.firstWhere(
        (todo) => todo.id == id,
        orElse: () => throw Exception('Todo not found'),
      );
    } catch (e) {
      return null;
    }
  }

  // เพิ่ม Todo ใหม่
  Future<void> addTodo(Todo todo) async {
    try {
      final todos = await getAllTodos();

      //ตรวจสอบว่ามี id ซ้ำหรือไม่
      if (todos!.any((existingTodo) => existingTodo.id == todo.id)) {
        throw Exception('Todo with this ID already exists');
      }

      todos.add(todo);
      await _saveTodos(todos);
    } catch (ex) {
      throw Exception('Failed to add todo: $ex');
    }
  }

  //update todo
  Future<void> updateTodo(Todo updatedTodo) async {
    try {
      final todos = await getAllTodos();
      final index = todos!.indexWhere((todo) => todo.id == updatedTodo.id);

      if (index == -1) {
        throw Exception('Todo not found');
      }
      todos[index] = updatedTodo;
      await _saveTodos(todos);
    } catch (e) {
      throw Exception('Faild to update: $e');
    }
  }

  Future<void> deleteTodo(String id) async {
    try {
      final todos = await getAllTodos();
      final initialLength = todos!.length;

      todos.removeWhere((todo) => todo.id == id);

      if (todos.length == initialLength) {
        throw Exception('Todo not found');
      }

      await _saveTodos(todos);
    } catch (e) {
      throw Exception('Failed to delete todo: $e');
    }
  }

  Future<void> deleteAllTodo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_todoKey);
    } catch (e) {
      throw Exception('Failed to delete all todo: $e');
    }
  }

  Future<void> toggleTodoStatus(String id) async {
    try {
      final todo = await getTodoById(id);
      if (todo == null) {
        throw Exception('Todo not found');
      }

      final updatedTodo = todo.copyWith(
        isCompleted: !todo.isCompleted,
        completeAt: !todo.isComplete ? DateTime.now() : null,
      );

      await updatedTodo(updatedTodo);
    } catch (e) {
      throw Exception('Failed to toggle todo status: $e');
    }
  }

  Future<List<Todo>> getCompletedTodos() async {
    try {
      final todos = await getAllTodos();
      return todos!.where((todo) => !todo.isCompleted).toList();
    } catch (e) {
      throw Exception('Failed to get pending todos: $e');
    }
  }

  Future<List<Todo>> getPendingTodos() async {
    try {
      final todos = await getAllTodos();
      return todos!.where((todo) => !todo.isCompleted).toList();
    } catch (e) {
      throw Exception('Failed to get pending todos: $e');
    }
  }

  Future<List<Todo>> searchTodos(String query) async {
    try {
      final todos = await getAllTodos();
      final lowerQuery = query.toLowerCase();

      return todos!.where((todo) {
        return todo.title.toLowerCase().contains(lowerQuery) ||
            todo.description.toLowerCase().contains(lowerQuery);
      }).toList();
    } catch (e) {
      throw Exception('Failed to search todos: $e');
    }
  }

  //เรียงลำดับ Todo
  Future<List<Todo>> getStoredTodos({
    TodoSortBy sortBy = TodoSortBy.dateCreated,
    bool ascending = true,
  }) async {
    try {
      final todos = await getAllTodos();

      todos!.sort((a, b) {
        int comparison;

        switch (sortBy) {
          case TodoSortBy.title:
            comparison = a.title.compareTo(b.title);
            break;
          case TodoSortBy.dateCreated:
            comparison = a.createAt.compareTo(b.createAt);
            break;
          case TodoSortBy.dateCompleted:
            if (a.completeAt == null && b.completeAt == null) {
              comparison = 0;
            } else if (a.completeAt == null) {
              comparison = 1;
            } else if (b.completeAt == null) {
              comparison = -1;
            } else {
              comparison = a.completeAt!.compareTo(b.completeAt!);
            }
            break;
          case TodoSortBy.status:
            comparison = a.isCompleted.toString().compareTo(
              b.isCompleted.toString(),
            );
            break;
        }
        return ascending ? comparison : -comparison;
      });
      return todos;
    } catch (e) {
      throw Exception('Failed to sort todos: $e');
    }
  }

  //นับจำนวน Todo
  Future<TodoStatistics> getTdodoStatistics() async {
    try {
      final todos = await getAllTodos();
      final completed = todos!.where((todo) => todo.isCompleted).length;
      final pending = todos.length - completed;

      return TodoStatistics(
        total: todos.length,
        completed: completed,
        pending: pending,
      );
    } catch (e) {
      throw Exception('Failed to get toso statistics $e');
    }
  }

  //บันทึก todo ลง SharedProference
  Future<void> _saveTodos(List<Todo> todos) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final todoJson = json.encode(
        (todos.map((todo) => todo.toJson()).toList()),
      );
      await prefs.setString(_todoKey, todoJson);
    } catch (ex) {
      throw Exception('Failed to save todos: $ex');
    }
  }

  //ล้างข้อมูล Sharepreference
  Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      throw Exception('Failed to clear data: $e');
    }
  }

  //import ช้อมูลจาก JSON
  Future<void> importTodos(String jsonString) async {
    try {
      final List<dynamic> todosList = json.decode(jsonString);
      final todos = todosList.map((json) => Todo.fromJson(json)).toList();
      await _saveTodos(todos);
    } catch (e) {
      throw Exception('Failed to import todos: $e');
    }
  }

  //export เป็น JSON
  Future<String> exportTodos() async {
    try {
      final todos = await getAllTodos();
      return json.encode(todos!.map((todo) => todo.toJson()).toList());
    } catch (e) {
      throw Exception('Failed to export todos: $e');
    }
  }

  static Future<bool> hasTodos() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.containsKey(_todoKey);
  }
}

enum TodoSortBy { title, dateCreated, dateCompleted, status }

class TodoStatistics {
  final int total;
  final int completed;
  final int pending;

  TodoStatistics({
    required this.total,
    required this.completed,
    required this.pending,
  });

  double get completionPercentage {
    if (total == 0) return 0.0;
    return (completed / total) * 100;
  }
}
