import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_manager/core/providers/repository_providers.dart';
import 'package:task_manager/data/entities/task.dart';
import 'package:task_manager/data/repositories/interafaces/i_task_repository.dart';
import 'package:task_manager/core/extensions/date_extension.dart';

class CreateUpdateTaskForm extends ConsumerStatefulWidget {
  final String categoryId;
  final Task? task;
  const CreateUpdateTaskForm({super.key, required this.categoryId, this.task});

  @override
  ConsumerState<CreateUpdateTaskForm> createState() => CreateUpdateTaskState();
}

class CreateUpdateTaskState extends ConsumerState<CreateUpdateTaskForm> {
  late ITaskRepository _taskRepository;

  final _nameController = TextEditingController();
  final _noteController = TextEditingController();
  final _dateController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _taskRepository = ref.read(taskRepositoryProvider);
    if (widget.task != null) {
      _nameController.text = widget.task!.title;
      _noteController.text = widget.task!.description;
      _selectedDate = widget.task!.date;
    } else {
      _nameController.text = '';
      _noteController.text = '';
      _selectedDate = DateTime.now();
    }
    _dateController.text = _selectedDate.formatDate();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _noteController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (widget.task != null) {
        final task = Task(
          id: widget.task!.id,
          title: _nameController.text,
          description: _noteController.text,
          date: _selectedDate,
          priority: 0,
          status: 0,
          categoryId: widget.categoryId,
          createdAt: DateTime.now(),
        );
        await _taskRepository.updateTask(task);
      } else {
        final task = Task(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: _nameController.text,
          description: _noteController.text,
          date: _selectedDate,
          priority: 0,
          status: 0,
          categoryId: widget.categoryId,
          createdAt: DateTime.now(),
        );
        await _taskRepository.createTask(task);
      }

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.task != null
              ? 'Task updated successfully'
              : 'Task created successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 5)),
    );
    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        // ignore: use_build_context_synchronously
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
      );
      if (pickedTime != null) {
        setState(() {
          _selectedDate = pickedDate;
        });
        _dateController.text = _selectedDate.formatDate();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          widget.task != null ? "Update Task" : "New Task",
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.close)),
        ],
      ),
      body: Column(
        children: [
          Expanded(
              child: Container(
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            color: Colors.white,
            child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Title',
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                                fontWeight: FontWeight.bold))),
                    const SizedBox(height: 8),
                    TextFormField(
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                      controller: _nameController,
                      decoration: InputDecoration(
                          hintStyle: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.normal),
                          hintText: "Enter title",
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(5),
                          )),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter title";
                        }
                        return null;
                      },
                      onChanged: (value) {},
                    ),
                    const SizedBox(height: 15),
                    const Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Due Date',
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                                fontWeight: FontWeight.bold))),
                    const SizedBox(height: 8),
                    TextFormField(
                      style: const TextStyle(
                        fontSize: 14, // 👈 giảm size chữ
                      ),
                      controller: _dateController,
                      readOnly: true,
                      onTap: _pickDate,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        suffixIcon: const Icon(Icons.calendar_today),
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Note',
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                                fontWeight: FontWeight.bold))),
                    const SizedBox(height: 8),
                    TextFormField(
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                      controller: _noteController,
                      decoration: InputDecoration(
                          hintStyle: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.normal),
                          hintText: "Enter note",
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(5),
                          )),
                    ),
                  ],
                )),
          )),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
                elevation: 0,
              ),
              child: Text(
                widget.task != null ? "Update" : "Create",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
