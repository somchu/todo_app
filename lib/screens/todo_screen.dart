import 'package:flutter/material.dart';
import 'package:todo_app/services/toto_service.dart';
import '../models/todo.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  List<Todo> todos = [];
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TodoService _todoService = TodoService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final loadedTodos = await _todoService.getAllTodos();
      setState(() {
        todos = loadedTodos!;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Error loading todos: $e');
    }
  }

  // void _loadINitialTodos() {
  //   setState(() {
  //     todos = [
  //       Todo(
  //         id: '1',
  //         title: 'Learn Flutter',
  //         description: 'Complete Todo App tutorial',
  //         createAt: DateTime.now().subtract(Duration(days: 1)),
  //       ),
  //       Todo(
  //         id: '2',
  //         title: 'Buy groceries',
  //         description: 'Milk,Bread,Eggs',
  //         createAt: DateTime.now().subtract(Duration(days: 2)),
  //       ),
  //     ];
  //   });
  // }

  void _addTodo() async {
    if (_textController.text.trim().isEmpty) return;
    try {
      final newTodo = Todo(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: _textController.text.trim(),
        description: _descriptionController.text.trim(),
        createAt: DateTime.now(),
      );
      await _todoService.addTodo(newTodo);

      _textController.clear();
      _descriptionController.clear();
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
      _showSuccessSnackBar('Todo added Successfully');
    } catch (e) {
      _showErrorSnackBar('Error adding todos: $e');
    }
  }

  void _toggleTodo(String id) async {
    try {
      int index = todos.indexWhere((todo) => todo.id == id);

      if (index != -1) {
        final updatedTodo = todos[index].copyWith(
          isCompleted: !todos[index].isCompleted,
          completeAt: !todos[index].isCompleted ? DateTime.now() : null,
        );
        await _todoService.updateTodo(updatedTodo);

        setState(() {
          todos[index] = updatedTodo;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error updating todo: $e');
    }
  }

  void _deleteTodo(String id) async {
    try {
      await _todoService.deleteTodo(id);

      setState(() {
        todos.removeWhere((todo) => todo.id == id);
      });

      _showSuccessSnackBar('Todo deleted suggessfully');
    } catch (e) {
      _showErrorSnackBar('Error deleting todo: $e');
    }
  }

  void _showAddTodoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New Todo'),
        content: Column(
          children: [
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: 'Enter Todo title...',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'Enter Description...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              onSubmitted: (_) => _addTodo(),
            ),
          ],
        ),

        actions: [
          TextButton(
            onPressed: () {
              _textController.clear();
              _descriptionController.clear();
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(onPressed: _addTodo, child: Text('Add')),
        ],
      ),
    );
  }

  void _showEditTodoDialog(Todo todo) {
    _textController.text = todo.title;
    _descriptionController.text = todo.description;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Todo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _textController.clear();
              _descriptionController.clear();
              Navigator.of(context).pop();
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _updateTodo(String id) async {
    if (_textController.text.trim().isEmpty) return;

    try {
      int index = todos.indexWhere((todo) => todo.id == id);
      if (index != -1) {
        final updatedTodo = todos[index].copyWith(
          title: _textController.text.trim(),
          description: _descriptionController.text.trim(),
        );
        await _todoService.updateTodo(updatedTodo);
      }
    } catch (e) {
      _showErrorSnackBar('Error Updating todo: $e');
    }
  }

  Future<void> _refreshTodos() async {
    await _loadTodos();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Todo App'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              onPressed: _refreshTodos,
              icon: Icon(Icons.refresh),
              tooltip: 'Refresh',
            ),
          ],
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : todos.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.checklist, size: 80, color: Colors.grey),
                    SizedBox(height: 8),
                    Text(
                      'No Todos yet!!!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: _refreshTodos,
                child: ListView.builder(
                  itemCount: todos.length,
                  itemBuilder: (context, index) {
                    final todo = todos[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      elevation: 2,
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
                            color: todo.isCompleted
                                ? Colors.grey
                                : Colors.black,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (todo.description.isNotEmpty)
                              Text(
                                todo.description,
                                style: TextStyle(
                                  color: todo.isCompleted
                                      ? Colors.grey
                                      : Colors.black54,
                                ),
                              ),
                            SizedBox(height: 4),
                            Text(
                              'Created: ${_formatDate(todo.createAt)})',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green[600],
                              ),
                            ),
                            if (todo.isCompleted != null)
                              Text(
                                'Completed: ${_formatDate(todo.completeAt!)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.green[600],
                                ),
                              ),
                          ],
                        ),
                        trailing: PopupMenuButton(
                          onSelected: (value) {
                            switch (value) {
                              case 'edit':
                                _showEditTodoDialog(todo);
                                break;
                              case 'delete':
                                _showDeleteConfirmation(todo.id, todo.title);
                                break;
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'edit',
                              child: ListTile(
                                leading: Icon(Icons.edit, size: 20),
                                title: Text('Edit'),
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: ListTile(
                                leading: Icon(
                                  Icons.delete,
                                  size: 20,
                                  color: Colors.red,
                                ),
                                title: Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                        ),
                        onTap: () => _showEditTodoDialog(todo),
                      ),
                    );
                  },
                ),
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddTodoDialog,
          backgroundColor: Colors.blue,
          child: Icon(Icons.add),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(String id, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Todo'),
        content: Text('Are yoe sure you want to delete "$title"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteTodo(id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:';
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
