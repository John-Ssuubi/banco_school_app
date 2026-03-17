// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditableScoreField extends StatefulWidget {
  final String studentId; // Firestore doc ID
  final String subjectName; // Subject to update (e.g. "Math")
  final double initialScore; // Current score
  final String scoreKey; // e.g. "scoreEOT", "scoreBOT", "scoreMT"
  final String time; // e.g. "EOT", "BOT", "MID"
  final String model;
  final String schoolId;
  const EditableScoreField({
    super.key,
    required this.studentId,
    required this.subjectName,
    required this.initialScore,
    required this.scoreKey,
    required this.time,
    required this.model,
    required this.schoolId,
  });

  @override
  State<EditableScoreField> createState() => _EditableScoreFieldState();
}

class _EditableScoreFieldState extends State<EditableScoreField> {
  late TextEditingController _controller;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialScore.toString());
  }

  Future<void> _updateScore(String value) async {
    final newScore = double.tryParse(value);
    if (newScore == null) return;

    setState(() => _isUpdating = true);

    try {
      final docRef = FirebaseFirestore.instance
          .collection('Schools')
          .doc(widget.schoolId)
          .collection(widget.model)
          .doc(widget.studentId);

      final docSnap = await docRef.get();
      if (!docSnap.exists) return;

      final data = docSnap.data()!;
      final subjects = List<Map<String, dynamic>>.from(data['subjectsScore']);

      for (var sub in subjects) {
        if (sub['subjectName'] == widget.subjectName) {
          sub[widget.scoreKey] =
              newScore; // dynamically update scoreEOT, BOT, or MT
        }
      }

      await docRef.update({
        'subjectsScore': subjects,
        'lastUpdated': DateTime.now().toIso8601String(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ ${widget.subjectName} updated")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Error: $e")));
    } finally {
      setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(widget.time)),
        SizedBox(
          width: 80,
          child: TextField(
            controller: _controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              suffixIcon: _isUpdating
                  ? const SizedBox(height: 12, width: 12, child: Text('...'))
                  : null,
            ),
            // onChanged: (value) {
            //   // Optional: add a short delay before updating Firestore
            //   // to avoid too many writes while typing
            //   if (value.isNotEmpty) {
            //     Future.delayed(const Duration(seconds: 1), () {
            //       if (value == _controller.text) {
            //         _updateScore(value);
            //       }
            //     });
            //   }
            // },
            onSubmitted: _updateScore,
          ),
        ),
      ],
    );
  }
}

class EditableScoreFieldTerm2 extends StatefulWidget {
  final String studentId; // Firestore doc ID
  final String subjectName; // Subject to update (e.g. "Math")
  final double initialScore; // Current score
  final String scoreKey; // e.g. "scoreEOT", "scoreBOT", "scoreMT"
  final String time; // e.g. "EOT", "BOT", "MID"
  final String model;
  final String schoolId;
  const EditableScoreFieldTerm2({
    super.key,
    required this.studentId,
    required this.subjectName,
    required this.initialScore,
    required this.scoreKey,
    required this.time,
    required this.model,
    required this.schoolId,
  });

  @override
  State<EditableScoreFieldTerm2> createState() => _EditableScoreFieldTerm2State();
}

class _EditableScoreFieldTerm2State extends State<EditableScoreFieldTerm2> {
  late TextEditingController _controller;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialScore.toString());
  }

  Future<void> _updateScore(String value) async {
    final newScore = double.tryParse(value);
    if (newScore == null) return;

    setState(() => _isUpdating = true);

    try {
      final docRef = FirebaseFirestore.instance
          .collection('Schools')
          .doc(widget.schoolId)
          .collection(widget.model)
          .doc(widget.studentId);

      final docSnap = await docRef.get();
      if (!docSnap.exists) return;

      final data = docSnap.data()!;
      final subjects = List<Map<String, dynamic>>.from(data['subjectsScoreTerm2']);

      for (var sub in subjects) {
        if (sub['subjectName'] == widget.subjectName) {
          sub[widget.scoreKey] =
              newScore; // dynamically update scoreEOT, BOT, or MT
        }
      }

      await docRef.update({
        'subjectsScoreTerm2': subjects,
        'lastUpdated': DateTime.now().toIso8601String(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ ${widget.subjectName} updated")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Error: $e")));
    } finally {
      setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(widget.time)),
        SizedBox(
          width: 80,
          child: TextField(
            controller: _controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              suffixIcon: _isUpdating
                  ? const SizedBox(height: 12, width: 12, child: Text('...'))
                  : null,
            ),
            // onChanged: (value) {
            //   // Optional: add a short delay before updating Firestore
            //   // to avoid too many writes while typing
            //   if (value.isNotEmpty) {
            //     Future.delayed(const Duration(seconds: 1), () {
            //       if (value == _controller.text) {
            //         _updateScore(value);
            //       }
            //     });
            //   }
            // },
            onSubmitted: _updateScore,
          ),
        ),
      ],
    );
  }
}


class EditableScoreFieldTerm3 extends StatefulWidget {
  final String studentId; // Firestore doc ID
  final String subjectName; // Subject to update (e.g. "Math")
  final double initialScore; // Current score
  final String scoreKey; // e.g. "scoreEOT", "scoreBOT", "scoreMT"
  final String time; // e.g. "EOT", "BOT", "MID"
  final String model;
  final String schoolId;
  const EditableScoreFieldTerm3({
    super.key,
    required this.studentId,
    required this.subjectName,
    required this.initialScore,
    required this.scoreKey,
    required this.time,
    required this.model,
    required this.schoolId,
  });

  @override
  State<EditableScoreFieldTerm3> createState() => _EditableScoreFieldTerm3State();
}

class _EditableScoreFieldTerm3State extends State<EditableScoreFieldTerm3> {
  late TextEditingController _controller;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialScore.toString());
  }

  Future<void> _updateScore(String value) async {
    final newScore = double.tryParse(value);
    if (newScore == null) return;

    setState(() => _isUpdating = true);

    try {
      final docRef = FirebaseFirestore.instance
          .collection('Schools')
          .doc(widget.schoolId)
          .collection(widget.model)
          .doc(widget.studentId);

      final docSnap = await docRef.get();
      if (!docSnap.exists) return;

      final data = docSnap.data()!;
      final subjects = List<Map<String, dynamic>>.from(data['subjectsScoreTerm3']);

      for (var sub in subjects) {
        if (sub['subjectName'] == widget.subjectName) {
          sub[widget.scoreKey] =
              newScore; // dynamically update scoreEOT, BOT, or MT
        }
      }

      await docRef.update({
        'subjectsScoreTerm3': subjects,
        'lastUpdated': DateTime.now().toIso8601String(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ ${widget.subjectName} updated")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Error: $e")));
    } finally {
      setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(widget.time)),
        SizedBox(
          width: 80,
          child: TextField(
            controller: _controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              suffixIcon: _isUpdating
                  ? const SizedBox(height: 12, width: 12, child: Text('...'))
                  : null,
            ),
            // onChanged: (value) {
            //   // Optional: add a short delay before updating Firestore
            //   // to avoid too many writes while typing
            //   if (value.isNotEmpty) {
            //     Future.delayed(const Duration(seconds: 1), () {
            //       if (value == _controller.text) {
            //         _updateScore(value);
            //       }
            //     });
            //   }
            // },
            onSubmitted: _updateScore,
          ),
        ),
      ],
    );
  }
}
