// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:banco_mobile/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class SchoolFees extends StatefulWidget {
  const SchoolFees({super.key});

  @override
  State<SchoolFees> createState() => _SchoolFeesState();
}

class _SchoolFeesState extends State<SchoolFees> with SingleTickerProviderStateMixin {
  String? schoolId;
  String? selectedClass;
  List<String> classList = [];
  String? searchQuery;

  // Filter states
  String? selectedFilter; // 'all', 'paid', 'unpaid', 'overpaid'
  String? selectedSort; // 'balance_high', 'balance_low'
  
  // Term selection
  int selectedTerm = 1; // 1, 2, or 3
  
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          selectedTerm = _tabController.index + 1;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'School Fees',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: mainColor,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: _buildSearchField(),
                ),
                const SizedBox(width: 8),
                _buildFilterButton(),
                const SizedBox(width: 8),
                _buildSortButton(),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Term Tabs
          _buildTermTabs(),
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildTermTabs() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: mainColor,
        unselectedLabelColor: Colors.grey.shade600,
        indicatorColor: mainColor,
        indicatorWeight: 3,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
        tabs: const [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.looks_one, size: 18),
                SizedBox(width: 6),
                Text('Term 1'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.looks_two, size: 18),
                SizedBox(width: 6),
                Text('Term 2'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.looks_3, size: 18),
                SizedBox(width: 6),
                Text('Term 3'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        onChanged: (value) => setState(() => searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Search students...',
          hintStyle: TextStyle(color: Colors.grey.shade400),
          prefixIcon: Icon(Icons.search, color: Colors.grey.shade400, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          suffixIcon: searchQuery != null && searchQuery!.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.grey.shade400, size: 18),
                  onPressed: () => setState(() => searchQuery = null),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildFilterButton() {
    return PopupMenuButton<String>(
      onSelected: (value) => setState(() => selectedFilter = value),
      icon: Container(
        height: 42,
        width: 42,
        decoration: BoxDecoration(
          color: selectedFilter != null && selectedFilter != 'all'
              ? mainColor
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          Icons.filter_list,
          color: selectedFilter != null && selectedFilter != 'all'
              ? Colors.white
              : Colors.grey.shade600,
          size: 20,
        ),
      ),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'all',
          child: Row(
            children: [
              Icon(Icons.list, size: 18),
              SizedBox(width: 10),
              Text('All Students'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'paid',
          child: Row(
            children: [
              Icon(Icons.check_circle, size: 18, color: Colors.green),
              SizedBox(width: 10),
              Text('Fully Paid (Balance = 0)'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'overpaid',
          child: Row(
            children: [
              Icon(Icons.account_balance_wallet, size: 18, color: Colors.blue),
              SizedBox(width: 10),
              Text('Overpaid (Balance < 0)'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'unpaid',
          child: Row(
            children: [
              Icon(Icons.pending, size: 18, color: Colors.orange),
              SizedBox(width: 10),
              Text('Unpaid (Balance > 0)'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSortButton() {
    return PopupMenuButton<String>(
      onSelected: (value) => setState(() => selectedSort = value),
      icon: Container(
        height: 42,
        width: 42,
        decoration: BoxDecoration(
          color: selectedSort != null ? mainColor : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          Icons.sort,
          color: selectedSort != null ? Colors.white : Colors.grey.shade600,
          size: 20,
        ),
      ),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'balance_high',
          child: Row(
            children: [
              Icon(Icons.arrow_downward, size: 18, color: Colors.red),
              SizedBox(width: 10),
              Text('Balance: High to Low'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'balance_low',
          child: Row(
            children: [
              Icon(Icons.arrow_upward, size: 18, color: Colors.green),
              SizedBox(width: 10),
              Text('Balance: Low to High'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('Users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .get(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }
        if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
          return _buildErrorState('User data not found');
        }

        final userData = userSnapshot.data!.data() as Map<String, dynamic>;
        final linkedClasses = List<Map<String, dynamic>>.from(
          userData['linkedClasses'] ?? [],
        );

        if (linkedClasses.isEmpty) {
          return _buildErrorState('No classes linked to your account');
        }

        schoolId = linkedClasses.first['schoolId'];
        if (selectedClass == null && linkedClasses.isNotEmpty) {
          selectedClass = linkedClasses.first['className'];
        }

        // Extract class names
        classList = linkedClasses.map((e) => e['className'] as String).toList();

        return Column(
          children: [
            _buildClassFilterChips(),
            Expanded(
              child: _buildFeesData(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildClassFilterChips() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: classList.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final className = classList[index];
          final isSelected = selectedClass == className;
          return FilterChip(
            label: Text(className),
            selected: isSelected,
            onSelected: (_) => setState(() => selectedClass = className),
            backgroundColor: Colors.white,
            selectedColor: mainColor,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : Colors.grey.shade700,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isSelected ? mainColor : Colors.grey.shade200,
              ),
            ),
            elevation: 0,
          );
        },
      ),
    );
  }

  Widget _buildFeesData() {
    if (schoolId == null || selectedClass == null) {
      return const Center(child: Text('No class selected'));
    }

    // Reference to studentModel collection for this class
    final collectionPath =
        'Schools/$schoolId/Years/2026/studentModel$selectedClass';

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(collectionPath)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }
        if (snapshot.hasError) {
          return _buildErrorState('Error: ${snapshot.error}');
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState();
        }

        // Process student data - always calculate from fresh data
        List<StudentFeeData> students = [];
        for (var doc in snapshot.data!.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final name = data['studentName'] ?? 'Unknown';
          final classIn = data['classIn'] ?? selectedClass;
          
          // Always calculate fresh values from data
          final total = _calculateTotal(data);
          final paid = _calculatePaid(data);
          final balance = total - paid;

          students.add(StudentFeeData(
            id: doc.id,
            name: name,
            classIn: classIn,
            total: total,
            paid: paid,
            balance: balance,
            docRef: doc.reference,
            data: data,
          ));
        }

        // Apply search filter
        if (searchQuery != null && searchQuery!.isNotEmpty) {
          students = students.where((s) =>
              s.name.toLowerCase().contains(searchQuery!.toLowerCase())).toList();
        }

        // Apply paid/unpaid filter
        if (selectedFilter == 'paid') {
          students = students.where((s) => s.balance == 0).toList();
        } else if (selectedFilter == 'overpaid') {
          students = students.where((s) => s.balance < 0).toList();
        } else if (selectedFilter == 'unpaid') {
          students = students.where((s) => s.balance > 0).toList();
        }

        // Apply sorting
        if (selectedSort == 'balance_high') {
          students.sort((a, b) => b.balance.compareTo(a.balance));
        } else if (selectedSort == 'balance_low') {
          students.sort((a, b) => a.balance.compareTo(b.balance));
        }

        return _buildSpreadsheet(students);
      },
    );
  }

  double _calculateTotal(Map<String, dynamic> data) {
    double total = 0;
    
    // Get the appropriate term amount based on selected term
    final termKey = 'amountTerm$selectedTerm';
    final termAmount = data[termKey];
    
    if (termAmount is double) {
      total += termAmount;
    } else if (termAmount is int) {
      total += termAmount.toDouble();
    } else if (termAmount is String) {
      total += double.tryParse(termAmount) ?? 0;
    }
   
    // If no term data, use default based on term
    if (total == 0) {
      if (selectedTerm == 1) {total = 500000;}
      else if (selectedTerm == 2) {total = 750000;}
      else if (selectedTerm == 3) {total = 950000;}
    }
    return total;
  }

  double _calculatePaid(Map<String, dynamic> data) {
    double paid = 0;
    
    // Get the appropriate paid amount based on selected term
    // ONLY use the paidAmountTermX field, NOT the paymentList
    // to avoid double counting
    final paidKey = 'paidAmountTerm$selectedTerm';
    final paidAmount = data[paidKey];
    
    if (paidAmount is double) {
      paid = paidAmount;
    } else if (paidAmount is int) {
      paid = paidAmount.toDouble();
    } else if (paidAmount is String) {
      paid = double.tryParse(paidAmount) ?? 0;
    }

    // NOTE: We are NOT adding paymentList amounts here to avoid double counting
    // The paidAmountTermX field is the source of truth for each term's payment

    return paid;
  }

  Widget _buildSpreadsheet(List<StudentFeeData> students) {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: mainColor.withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Expanded(flex: 3, child: _headerCell('Name')),
                Expanded(flex: 2, child: _headerCell('Class')),
                Expanded(flex: 2, child: _headerCell('Total (UGX)')),
                Expanded(flex: 2, child: _headerCell('Paid (UGX)')),
                Expanded(flex: 2, child: _headerCell('Balance (UGX)')),
                Expanded(flex: 1, child: _headerCell('Action')),
              ],
            ),
          ),
          // Data rows
          Expanded(
            child: ListView.builder(
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];
                final isEven = index % 2 == 0;
                return Container(
                  decoration: BoxDecoration(
                    color: isEven ? Colors.grey.shade50 : Colors.white,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade100),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Row(
                      children: [
                        Expanded(flex: 3, child: _dataCell(student.name)),
                        Expanded(flex: 2, child: _dataCell(student.classIn)),
                        Expanded(flex: 2, child: _dataCell(_formatCurrency(student.total))),
                        Expanded(
                          flex: 2,
                          child: _editablePaidCell(student),
                        ),
                        Expanded(
                          flex: 2,
                          child: _balanceCell(student.balance),
                        ),
                        Expanded(
                          flex: 1,
                          child: IconButton(
                            icon: Icon(Icons.edit, size: 18, color: mainColor),
                            onPressed: () => _showEditPaidDialog(student),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Footer with summary
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: mainColor.withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Students: ${students.length}',
                  style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                ),
                Text(
                  // ignore: avoid_types_as_parameter_names
                  'Total Balance: ${_formatCurrency(students.fold(0, (sum, s) => sum + s.balance))}',
                  style: TextStyle(fontWeight: FontWeight.bold, color: mainColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerCell(String text) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 12,
        color: Colors.grey.shade700,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _dataCell(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 13),
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _editablePaidCell(StudentFeeData student) {
    return GestureDetector(
      onTap: () => _showEditPaidDialog(student),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: mainColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          _formatCurrency(student.paid),
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _balanceCell(double balance) {
    Color textColor;
    if (balance == 0) {
      textColor = Colors.green.shade700;
    } else if (balance > 0) {
      textColor = Colors.red.shade700;
    } else {
      textColor = Colors.blue.shade700;
    }
    return Text(
      _formatCurrency(balance),
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
    );
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat('#,##0');
    return formatter.format(amount);
  }

  void _showEditPaidDialog(StudentFeeData student) {
    // Use the current paid value from the student object
    final controller = TextEditingController(text: student.paid.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Edit Payment for ${student.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Enter the paid amount for Term $selectedTerm in UGX:'),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount (UGX)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.attach_money),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newPaid = double.tryParse(controller.text);
              if (newPaid != null && newPaid >= 0) {
                _updatePaidAmount(student.docRef, newPaid);
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid amount')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: mainColor),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _updatePaidAmount(DocumentReference docRef, double newPaid) async {
    try {
      // Update ONLY the specific term's paid amount - this is the source of truth
      final paidKey = 'paidAmountTerm$selectedTerm';
      await docRef.update({
        paidKey: newPaid,
        'lastUpdated': DateTime.now().toIso8601String(),
      });
      
      // Also update the payment list for history (optional, but keep it)
      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        final paymentList = List<Map<String, dynamic>>.from(data['paymentList'] ?? []);
        
        // Remove any existing payment for this term
        final updatedList = paymentList.where((payment) {
          return payment['term'] != selectedTerm;
        }).toList();
        
        // Add the new payment
        updatedList.add({
          'term': selectedTerm,
          'amount': newPaid,
          'date': DateTime.now().toIso8601String(),
        });
        
        // Update the paymentList (for history only)
        await docRef.update({
          'paymentList': updatedList,
        });
      }
      
      // No setState() needed - StreamBuilder will auto-update when data changes
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment for Term $selectedTerm updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No students found in this class',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

class StudentFeeData {
  final String id;
  final String name;
  final String classIn;
  final double total;
  final double paid;
  final double balance;
  final DocumentReference docRef;
  final Map<String, dynamic> data;

  StudentFeeData({
    required this.id,
    required this.name,
    required this.classIn,
    required this.total,
    required this.paid,
    required this.balance,
    required this.docRef,
    required this.data,
  });
}