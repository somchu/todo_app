import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/todo.dart';

class TodoService {
  static const String _todoKey = 'todos';

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

  //บันทึก todo ลง SharedProference
  static Future<void> saveTodos(List<Todo> todos) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      //แปลง list <todo> เป็น list <map>
      List<Map<String, dynamic>> todosJson = todos
          .map((todo) => todo.toMap())
          .toList();

      String todosString = jsonEncode(
        todosJson,
      ); // แปลงเป็น JSON String และบันทึก

      await prefs.setString(_todoKey, todosString);
      print('Saved ${todos.length} todos to storage');
    } catch (e) {
      print('Error saving todos $e');
    }
  }

  static Future<List<Todo>> loadTodos() async {
    final prefs = await SharedPreferences.getInstance();

    final todosJson = prefs.getString(_todoKey); //อ่าน JSON String

    if (todosJson == null) {
      print('No todos found in storage');
      return [];
    }

    try {
      final todoMaps =
          jsonDecode(todosJson)
              as List<dynamic>; //แปลง JsonString เป็น List<Map<String,dynamic>>

      final todos = todoMaps
          .map((map) => Todo.fromMap(map as Map<String, dynamic>))
          .toList(); //แปลง List<dynamic> เป็น List<todo>

      print('Load ${todos.length} todos from strorage');
      return todos;
    } catch (e) {
      print('Error loading todos: $e');
      return [];
    }
  }

  static Future<void> clearTodos() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_todoKey);
    print('Cleard all todos from storage');
  }

  static Future<bool> hasTodos() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.containsKey(_todoKey);
  }
}
