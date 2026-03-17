// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddEventsPage extends StatefulWidget {
  final String schoolId;
  final String? eventId; // <-- for editing
  final Map<String, dynamic>? existingEvent; // <-- for editing
  const AddEventsPage({super.key, required this.schoolId, required this.eventId, required this.existingEvent});

  @override
  State<AddEventsPage> createState() => _AddEventsPageState();
}

class _AddEventsPageState extends State<AddEventsPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController =
      TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  DateTime? _selectedDateTime;
  bool _isLoading = false;

  /* ---------------- PICK DATE & TIME ---------------- */

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
      initialDate: DateTime.now(),
    );

    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time == null) return;

    setState(() {
      _selectedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  /* ---------------- SAVE EVENT ---------------- */

  Future<void> _saveEvent() async {
  print("SAVE STARTED");

  if (!_formKey.currentState!.validate()) return;

  if (_selectedDateTime == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please select date & time")),
    );
    return;
  }

  setState(() => _isLoading = true);

  try {
    print("WRITING TO FIRESTORE");

    await FirebaseFirestore.instance
        .collection('Schools')
        .doc(widget.schoolId)
        .collection('events')
        .add({
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'location': _locationController.text.trim(),
      'date': Timestamp.fromDate(_selectedDateTime!),
      'schoolId': widget.schoolId,
      'createdAt': Timestamp.now(),
    });

    print("WRITE SUCCESS");

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Event added successfully")),
      );
      Navigator.pop(context);
    }
  } catch (e) {
    print("ERROR");

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Error adding event")),
    );
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}


  /* ---------------- UI ---------------- */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Event", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(
                controller: _titleController,
                label: "Event Title",
                icon: Icons.title,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _descriptionController,
                label: "Description",
                icon: Icons.description,
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _locationController,
                label: "Location",
                icon: Icons.location_on,
              ),
              const SizedBox(height: 16),

              InkWell(
                onTap: _pickDateTime,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_month),
                      const SizedBox(width: 12),
                      Text(
                        _selectedDateTime == null
                            ? "Select Date & Time"
                            : DateFormat(
                                    'dd MMM yyyy • hh:mm a')
                                .format(_selectedDateTime!),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveEvent,
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text("Add Event"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /* ---------------- REUSABLE TEXT FIELD ---------------- */

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: (value) =>
          value == null || value.isEmpty ? "Required" : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
