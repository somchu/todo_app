class Todo {
  String id;
  String title;
  String description;
  bool isCompleted;
  DateTime createAt;
  DateTime? completeAt;

  Todo({
    required this.id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    required this.createAt,
    this.completeAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isComplete': isCompleted,
      'createAt':
          createAt.millisecondsSinceEpoch, //แปลง datetime เป็นตัวเลขเพื่อเก็บ
      'completeAt': completeAt
          ?.millisecondsSinceEpoch, //ถ้า completeAt เป็นค่า null จะ return null ก่อนแปลง datetime เป็นตัวเลข
    };
  }

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'],
      title: map['title'],
      description: map['description'] ?? '',
      isCompleted: map['isCompleted'],
      createAt: DateTime.fromMillisecondsSinceEpoch(map['createAt']),
      completeAt: map['completeAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['completeAt'])
          : null,
    );
  }

  //property: newValue ?? originalValue ถ้า  newValue เป็น null ใช้ค่าเดิม ถ้าไม่ใช่ ให้ใช้ค่าใหม่
  Todo copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? createAt,
    DateTime? completeAt,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createAt: createAt ?? this.createAt,
      completeAt: completeAt ?? this.completeAt,
    );
  }

  @override
  String toString() {
    return 'Todo{id: $id,title: $title,isComplete: $isComplete}';
  }
}
