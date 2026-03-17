import 'package:banco_mobile/Auth/create_account_admin.dart';
import 'package:banco_mobile/Auth/create_account_headteacher.dart';
import 'package:banco_mobile/Auth/create_account_teacher.dart';
import 'package:banco_mobile/Auth/security_create_account.dart';
import 'package:flutter/material.dart';

class StaffSelect extends StatefulWidget {
  const StaffSelect({super.key});

  @override
  State<StaffSelect> createState() => _StaffSelectState();
}

class _StaffSelectState extends State<StaffSelect> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Staff")),
      body: Column(
        // itemBuilder: (index, dimensions) {

        // return
        children: [
          InkWell(
            child: ListTile(
              leading: CircleAvatar(
                // backgroundColor: ,
                child: Text(
                  'HT',
                  style: TextStyle(
                    // color: theme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                'Head Teacher',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              subtitle: const Text("Access to all classes"),
              trailing: const Icon(Icons.chevron_right_rounded),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateAccountHeadteacher()),
              );
            },
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateAccountAdmin()),
              );
            },
            child: ListTile(
              leading: CircleAvatar(
                // backgroundColor: ,
                child: Text(
                  'Ad',
                  style: TextStyle(
                    // color: theme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                'Administrator',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              subtitle: const Text("Access to all classes"),
              trailing: const Icon(Icons.chevron_right_rounded),
            ),
          ),
          InkWell(
            child: ListTile(
              leading: CircleAvatar(
                // backgroundColor: ,
                child: Text(
                  'CT ',
                  style: TextStyle(
                    // color: theme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                'Class Teacher',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: const Text("School Management"),
              trailing: const Icon(Icons.chevron_right_rounded),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateAccountTeacher()),
              );
            },
          ),
          InkWell(
            child: ListTile(
              leading: CircleAvatar(
                // backgroundColor: ,
                child: Text(
                  'S',
                  style: TextStyle(
                    // color: theme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                'Security',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              subtitle: const Text("Attendance Tracking"),
              trailing: const Icon(Icons.chevron_right_rounded),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SecurityCreateAccount()),
              );
            },
          ),
        ],
      ),
    );
  }
}
