import 'package:flutter/material.dart';

void main() {
  runApp(ToDoApp());
}

class ToDoApp extends StatelessWidget {
  const ToDoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.yellow,
            foregroundColor: Colors.black,
          ),
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.green; // Цвет, когда галочка СТОИТ
            }
            return Colors.grey[350]; // Цвет, когда галочка ПУСТАЯ
          }),
          checkColor: WidgetStateProperty.all(Colors.white),
          // colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        ),
      ),
      home: MainPage(),
    );
  }
}

class Task {
  final String id;
  final String title;
  final String? description;
  bool isCompleted;

  Task({
    required this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
  });
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<Task> tasks = [
    Task(id: '1', title: 'Make a dinner'),
    Task(id: '2', title: 'Call back Salta', description: 'One miss call'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('My tasks')),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              final Task? newTask = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddTaskPage()),
              );

              if (newTask != null) {
                setState(() {
                  tasks.add(newTask);
                });
              }
            },
          ),
        ],
      ),
      body: tasks.isEmpty
          ? Center(
              child: Text(
                'No tasks yet',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];

                return ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TaskDetailPage(task: task),
                      ),
                    );
                  },
                  leading: Checkbox(
                    value: task.isCompleted,
                    onChanged: (value) {
                      setState(() {
                        task.isCompleted = value!;
                      });
                    },
                  ),
                  subtitle: task.description != null
                      ? Text(
                          task.description!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        )
                      : null,
                  title: Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({super.key});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        centerTitle: true,
        title: Text(
          'Add a new Task',
          style: TextStyle(color: const Color.fromARGB(255, 40, 111, 43)),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 20, top: 60),
            child: Text(
              'Title',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 20, right: 20, top: 10),
            child: TextField(
              controller: titleController,
              decoration: InputDecoration(
                hintText: 'Title',
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 15,
                ),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 20, top: 30),
            child: Text(
              'Description',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 20, right: 20, top: 10),
            child: TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Description',
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 15,
                ),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  String title = titleController.text;
                  String description = descriptionController.text;

                  if (title.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please enter the title'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  Task newTask = Task(
                    id: DateTime.now().toString(),
                    title: title,
                    description: description.isEmpty ? null : description,
                  );
                  Navigator.pop(context, newTask);
                  titleController.clear();
                  descriptionController.clear();
                },
                child: Text('Add task', style: TextStyle(fontSize: 18)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}

class TaskDetailPage extends StatefulWidget {
  final Task task;

  const TaskDetailPage({super.key, required this.task});

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  final TextEditingController newTitleController = TextEditingController();
  late TextEditingController titleController;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.task.title);
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked; // Обновляем экран
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.task.title}')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 20, top: 30),
              child: Text(
                'Title: ${widget.task.title}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 12),
            Padding(
              padding: EdgeInsets.only(left: 20),
              child: Text(
                'Description:',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 20),
              child: Text(
                widget.task.description?.isEmpty ?? true
                    ? 'The description is missing'
                    : widget.task.description!,
                style: TextStyle(
                  fontSize: (widget.task.description?.isEmpty ?? true)
                      ? 13
                      : 15,
                  color: (widget.task.description?.isEmpty ?? true)
                      ? Colors.grey[530]
                      : Colors.grey[750],
                  fontStyle: (widget.task.description?.isEmpty ?? true)
                      ? FontStyle.italic
                      : FontStyle.normal,
                ),
              ),
            ),
            SizedBox(height: 12),
            Padding(
              padding: EdgeInsets.only(left: 20),
              child: Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(
                      text: 'Task status: ',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: widget.task.isCompleted
                          ? 'Completed'
                          : 'Not completed',
                      style: TextStyle(
                        // Цвет меняется в зависимости от условия
                        color: widget.task.isCompleted
                            ? Colors.green
                            : Colors.red,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30),
            Row(
              children: [
                Padding(
                  padding: EdgeInsetsGeometry.only(left: 20),
                  child: ElevatedButton(
                    onPressed: _pickDate,
                    child: Text('Choose date'),
                  ),
                ),
                SizedBox(width: 25),
                Text(
                  "${selectedDate.day.toString().padLeft(2, '0')}.${selectedDate.month.toString().padLeft(2, '0')}.${selectedDate.year}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsetsGeometry.only(left: 40),
                  child: ElevatedButton(
                    onPressed: () {
                      print('Edited');
                    },
                    child: Text('Edit'),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsGeometry.only(right: 40),
                  child: ElevatedButton(
                    onPressed: () {
                      print('Deleted');
                    },
                    child: Text('Delete'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
