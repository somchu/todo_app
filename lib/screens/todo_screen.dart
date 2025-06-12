import 'package:flutter/material.dart';
import '../models/todo.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  List<Todo> todos = [];
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadINitialTodos();
  }

  void _loadINitialTodos() {
    setState(() {
      todos = [
        Todo(
          id: '1',
          title: 'Learn Flutter',
          description: 'Complete Todo App tutorial',
          createAt: DateTime.now().subtract(Duration(days: 1)),
        ),
        Todo(
          id: '2',
          title: 'Buy groceries',
          description: 'Milk,Bread,Eggs',
          createAt: DateTime.now().subtract(Duration(days: 2)),
        ),
      ];
    });
  }

  void _addTodo() {
    if (_textController.text.trim().isEmpty) return;

    setState(() {
      todos.add(
        Todo(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          title: _textController.text.trim(),
          createAt: DateTime.now(),
        ),
      );
    });

    _textController.clear();
    Navigator.of(context).pop();
  }

  void _toggleTodo(String id) {
    setState(() {
      int index = todos.indexWhere((todo) => todo.id == id);
      //หาตำแหน่งของ id ที่ส่งเข้่ามา ถ้า -1 คือหาไม่เจอ
      if (index != -1) {
        todos[index] = todos[index].copyWith(
          isCompleted: !todos[index].isCompleted,
          completeAt: !todos[index].isCompleted ? DateTime.now() : null,
        );
      }
    });
  }

  void _deleteTodo(String id) {
    setState(() {
      todos.removeWhere((todo) => todo.id == id);
    });
  }

  void _showAddTodoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New Todo'),
        content: TextField(
          controller: _textController,
          decoration: InputDecoration(
            hintText: 'Enter Todo title...',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
          onSubmitted: (_) => _addTodo(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(onPressed: _addTodo, child: Text('Add')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Todo App'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: todos.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.checklist, size: 80, color: Colors.grey),
                    SizedBox(height: 8),
                    Text(
                      'Tap to add your first Todo',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: todos.length,
                itemBuilder: (context, index) {
                  final todo = todos[index];
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: ListTile(
                      leading: Checkbox(
                        value: todo.isCompleted,
                        onChanged: (_) => _toggleTodo(todo.id),
                      ),
                      title: Text(
                        todo.title,
                        style: TextStyle(
                          decoration: todo.isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          color: todo.isCompleted ? Colors.grey : Colors.black,
                        ),
                      ),
                      subtitle: todo.description.isNotEmpty
                          ? Text(
                              todo.description,
                              style: TextStyle(
                                color: todo.isCompleted
                                    ? Colors.grey
                                    : Colors.black54,
                              ),
                            )
                          : null,
                      trailing: IconButton(
                        onPressed: () => _deleteTodo(todo.id),
                        icon: Icon(Icons.delete, color: Colors.red),
                      ),
                    ),
                  );
                },
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddTodoDialog,
          backgroundColor: Colors.blue,
          child: Icon(Icons.add),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
