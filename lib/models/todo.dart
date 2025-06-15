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

  //สร้าง Todo จาก  JSON
  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      isCompleted: json['isCompleted'] as bool? ?? false,
      createAt: DateTime.parse(json['crateAt'] as String),
      completeAt: json['completeAt'] != null
          ? DateTime.parse(json['completeAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    //แปลง Todo เป็น JSON
    return {
      'id': id,
      'title': title,
      'description': description,
      'isComplete': isCompleted,
      'createAt': createAt
          .toIso8601String(), //แปลง datetime เป็นตัวเลขเพื่อเก็บ
      'completeAt': completeAt
          ?.toIso8601String(), //ถ้า completeAt เป็นค่า null จะ return null ก่อนแปลง datetime เป็นตัวเลข
    };
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
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Todo &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.isCompleted == isCompleted &&
        other.completeAt == completeAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      title,
      description,
      isCompleted,
      createAt,
      completeAt,
    );
  }

  @override
  String toString() {
    return 'Todo(id:$id,title:$title,description:$description,'
        'isCompleted: $isCompleted,createAt:$createAt,completeAt: $completeAt)';
  }

  // ตรวจสอบว่าเป็น Todo ที่เสร็จแล้วหรือไม่
  bool get isDone => isCompleted;

  //ตรวจสอบว่าเป็ฯ Todo ที่เสร็จแล้วหรือไม่
  bool get isPending => !isCompleted;

  // คำนวณระยะเวลาที่ใช้ในการทำให้เสร็จ
  Duration? get completeDuration {
    if (completeAt == null) return null;
    return completeAt!.difference(createAt);
  }

  // ตรวจสอบว่าเป็น Todo ที่สร้างวันนี้หรือไม่
  bool get isCreateToday {
    final now = DateTime.now();
    return createAt.year == now.year &&
        createAt.month == now.month &&
        createAt.day == now.day;
  }

  // ตรวจสอบว่าเป็น Todo ที่เสร็จสิ้นวันนี้หรือไม่
  bool get isCompleteToday {
    if (completeAt == null) return false;
    final now = DateTime.now();
    return completeAt!.year == now.year &&
        completeAt!.month == now.month &&
        completeAt!.day == now.day;
  }
}
