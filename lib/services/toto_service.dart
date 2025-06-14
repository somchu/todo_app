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

  //update todo
  Future<void> updateTodo(Todo updatedTodo) async{
    try{
      final todos = await getAllTodos();
      final index = todos!.indexWhere((todo)=>todo.id==updatedTodo.id);
      
      if(index== -1){
        throw Exception('Todo not found');
      }
      todos[index] = updatedTodo;
      await _saveTodos(todos);
    }catch(e){
      throw Exception('Faild to update')

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
