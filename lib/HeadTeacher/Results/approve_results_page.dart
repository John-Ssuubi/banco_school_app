  import 'package:banco_mobile/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
  import 'package:flutter/material.dart';

  class ResultsApprovalScreen extends StatelessWidget {
    final String schoolId;
    // final String resultsDocId;

    const ResultsApprovalScreen({
      super.key,
      required this.schoolId,
      // required this.resultsDocId,
    });

    @override
    Widget build(BuildContext context) {
      final resultsRef = FirebaseFirestore.instance
          .collection('Schools')
          .doc(schoolId)
          .collection('results')
          .doc('ResultsDoc');

      return Scaffold(
        backgroundColor: mainColor,
        appBar: AppBar(
          leading: InkWell(
            child: const Icon(Icons.arrow_back_rounded, color: Colors.white,),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          title: const Text("Results Approval", style: TextStyle(color: Colors.white),),
          backgroundColor: mainColor,
        ),
        body: StreamBuilder<DocumentSnapshot>(
          stream: resultsRef.snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = snapshot.data!.data() as Map<String, dynamic>;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _examSection(
                  title: "Beginning of Term (BOT)",
                  examKey: "BOT",
                  examData: data["BOT"],
                  resultsRef: resultsRef,
                ),
                _examSection(
                  title: "Mid Term (MID)",
                  examKey: "MID",
                  examData: data["MID"],
                  resultsRef: resultsRef,
                ),
                _examSection(
                  title: "End of Term (EOT)",
                  examKey: "EOT",
                  examData: data["EOT"],
                  resultsRef: resultsRef,
                ),
              ],
            );
          },
        ),
      );
    }

    /// -------- EXAM SECTION ----------
    Widget _examSection({
      required String title,
      required String examKey,
      required Map examData,
      required DocumentReference resultsRef,
    }) {
      return Card(
        margin: const EdgeInsets.only(bottom: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Divider(),

              ...["Term1", "Term2", "Term3"].map((term) {
                final status = examData[term] ?? 'DRAFT';

                return _termRow(
                  examKey: examKey,
                  term: term,
                  status: status,
                  resultsRef: resultsRef,
                );
              }),
            ],
          ),
        ),
      );
    }

    /// -------- TERM ROW ----------
    Widget _termRow({
      required String examKey,
      required String term,
      required String status,
      required DocumentReference resultsRef,
    }) {
      final color = _statusColor(status);

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              term,
              style: const TextStyle(fontSize: 16),
            ),

            Chip(
              label: Text(status.toUpperCase()),
              // ignore: deprecated_member_use
              backgroundColor: color.withOpacity(.15),
              labelStyle: TextStyle(color: color),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              onPressed: status == "approved"
                  ? null
                  : () {
                      resultsRef.update({
                        "$examKey.$term": "approved",
                        "approvedAt": FieldValue.serverTimestamp(),
                      });
                    },
              child: const Text("APPROVE"),
            ),
          ],
        ),
      );
    }

    /// -------- STATUS COLOR ----------
    Color _statusColor(String status) {
      switch (status) {
        case "approved":
          return Colors.green;
        case "submitted":
          return Colors.orange;
        default:
          return Colors.blue;
      }
    }
  }
