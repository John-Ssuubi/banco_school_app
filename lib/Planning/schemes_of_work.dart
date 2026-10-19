// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:banco_mobile/Planning/scheme_of_work.dart';
import 'package:banco_mobile/Planning/schemes_form_screen.dart';
import 'package:banco_mobile/Planning/schemes_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:banco_mobile/styles.dart';

// ─── View mode enum ───────────────────────────────────────
enum SchemeViewMode { schemes, topics }

class SchemesOfWorkScreen extends StatefulWidget {
  final String schoolId;
  final String classId;
  final String className;
  final String teacherUid;
  final String teacherName;
  final String role;

  /// Optional: force the screen to open in "By Topic" view
  final SchemeViewMode initialView;

  const SchemesOfWorkScreen({
    super.key,
    required this.schoolId,
    required this.classId,
    required this.className,
    required this.teacherUid,
    required this.teacherName,
    this.role = 'teacher',
    this.initialView = SchemeViewMode.schemes,
  });

  @override
  State<SchemesOfWorkScreen> createState() => _SchemesOfWorkScreenState();
}

class _SchemesOfWorkScreenState extends State<SchemesOfWorkScreen>
    with SingleTickerProviderStateMixin {
  final SchemesService _service = SchemesService();
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  late SchemeViewMode _viewMode;

  String? _selectedTerm;
  int? _selectedYear;
  String? _selectedStatus;

  // Expanded subject groups in the "By Topic" view
  final Set<String> _expandedSubjects = {};

  @override
  void initState() {
    super.initState();
    _viewMode = widget.initialView;
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  // ─── Build ────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: _buildAppBar(),
      floatingActionButton: _viewMode == SchemeViewMode.schemes
          ? FloatingActionButton.extended(
              onPressed: _openCreateForm,
              backgroundColor: mainColor,
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: const Text(
                'New Scheme',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600),
              ),
            )
          : null,
      body: StreamBuilder<List<SchemeOfWork>>(
        stream: _service.streamSchemes(
          schoolId: widget.schoolId,
          classId: widget.classId,
          term: _selectedTerm,
          year: _selectedYear,
          status: _selectedStatus,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoading();
          }
          final schemes = snapshot.data ?? [];
          return FadeTransition(
            opacity: _fadeAnimation,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _buildHeroHeader(schemes)),
                SliverToBoxAdapter(child: _buildViewToggle()),
                SliverToBoxAdapter(child: _buildFilterBar()),
                if (schemes.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildEmptyState(),
                  )
                else if (_viewMode == SchemeViewMode.schemes)
                  _buildSchemesList(schemes)
                else
                  _buildTopicsList(schemes),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [mainColor, Color.lerp(mainColor, Colors.black, 0.2)!],
          ),
        ),
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Schemes of Work',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          Text(
            widget.className,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Hero header (stats) ──────────────────────────────────
  Widget _buildHeroHeader(List<SchemeOfWork> schemes) {
    final total = schemes.length;
    final approved =
        schemes.where((s) => s.status == SchemeStatus.approved).length;
    final pending =
        schemes.where((s) => s.status == SchemeStatus.pending).length;
    final drafts =
        schemes.where((s) => s.status == SchemeStatus.draft).length;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            mainColor,
            Color.lerp(mainColor, const Color(0xFF000033), 0.3)!,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: mainColor.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            right: 20,
            bottom: -40,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.description_outlined,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.className,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(Icons.lock_rounded,
                                  size: 11,
                                  color: Colors.white.withOpacity(0.7)),
                              const SizedBox(width: 4),
                              Text(
                                'Class locked from previous step',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    _buildStatPill('$total', 'Total', Colors.white),
                    const SizedBox(width: 8),
                    _buildStatPill(
                        '$approved', 'Approved', const Color(0xFF69F0AE)),
                    const SizedBox(width: 8),
                    _buildStatPill(
                        '$pending', 'Pending', const Color(0xFFFFD54F)),
                    const SizedBox(width: 8),
                    _buildStatPill(
                        '$drafts', 'Drafts', const Color(0xFFFFAB91)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatPill(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.10),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.15)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.65),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── View toggle (Schemes ⇄ By Topic) ─────────────────────
  Widget _buildViewToggle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            _toggleButton(
              label: 'Schemes',
              icon: Icons.view_agenda_rounded,
              selected: _viewMode == SchemeViewMode.schemes,
              onTap: () =>
                  setState(() => _viewMode = SchemeViewMode.schemes),
            ),
            _toggleButton(
              label: 'By Topic',
              icon: Icons.account_tree_rounded,
              selected: _viewMode == SchemeViewMode.topics,
              onTap: () => setState(() => _viewMode = SchemeViewMode.topics),
            ),
          ],
        ),
      ),
    );
  }

  Widget _toggleButton({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: selected ? mainColor : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: mainColor.withOpacity(0.30),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    )
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: selected ? Colors.white : Colors.grey.shade600,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Filter bar ───────────────────────────────────────────
  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip(
              label: _selectedTerm ?? 'Term',
              active: _selectedTerm != null,
              onTap: _pickTerm,
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: _selectedYear?.toString() ?? 'Year',
              active: _selectedYear != null,
              onTap: _pickYear,
            ),
            if (_viewMode == SchemeViewMode.schemes) ...[
              const SizedBox(width: 8),
              _buildFilterChip(
                label: _selectedStatus != null
                    ? SchemeStatus.labelOf(_selectedStatus!)
                    : 'Status',
                active: _selectedStatus != null,
                onTap: _pickStatus,
              ),
            ],
            if (_selectedTerm != null ||
                _selectedYear != null ||
                _selectedStatus != null) ...[
              const SizedBox(width: 8),
              ActionChip(
                avatar: const Icon(Icons.close_rounded, size: 14),
                label: const Text('Clear', style: TextStyle(fontSize: 12)),
                onPressed: () => setState(() {
                  _selectedTerm = null;
                  _selectedYear = null;
                  _selectedStatus = null;
                }),
                backgroundColor: Colors.grey.shade200,
                side: BorderSide.none,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: active ? mainColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? mainColor : Colors.grey.shade300,
          ),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: mainColor.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: active ? Colors.white : Colors.grey.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down_rounded,
              size: 16,
              color: active ? Colors.white : Colors.grey.shade700,
            ),
          ],
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════
  // VIEW 1 — SCHEMES (existing list)
  // ═════════════════════════════════════════════════════════
  Widget _buildSchemesList(List<SchemeOfWork> schemes) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, i) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _buildSchemeCard(schemes[i], i),
          ),
          childCount: schemes.length,
        ),
      ),
    );
  }

  Widget _buildSchemeCard(SchemeOfWork scheme, int index) {
    final statusColor = SchemeStatus.colorOf(scheme.status);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 60)),
      curve: Curves.easeOut,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 16 * (1 - value)),
          child: child,
        ),
      ),
      child: GestureDetector(
        onTap: () => _openDetail(scheme),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                mainColor,
                                Color.lerp(mainColor, Colors.black, 0.25)!,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.menu_book_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                scheme.subject,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1A202C),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${scheme.term} · ${scheme.year} · ${scheme.teacherName}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _statusChip(scheme.status),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        _metaChip(Icons.calendar_view_week_rounded,
                            '${scheme.totalWeeks} weeks'),
                        const SizedBox(width: 8),
                        _metaChip(Icons.schedule_rounded,
                            '${scheme.totalPeriods} periods'),
                        const SizedBox(width: 8),
                        if (scheme.updatedAt != null)
                          _metaChip(
                            Icons.update_rounded,
                            DateFormat('d MMM').format(scheme.updatedAt!),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(20),
                  ),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: scheme.status == SchemeStatus.approved
                      ? 1.0
                      : scheme.status == SchemeStatus.pending
                          ? 0.6
                          : 0.3,
                  child: Container(
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(20),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusChip(String status) {
    final color = SchemeStatus.colorOf(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            SchemeStatus.labelOf(status),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _metaChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey.shade700),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade800,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════
  // VIEW 2 — BY TOPIC (topical breakdown)
  // ═════════════════════════════════════════════════════════
  Widget _buildTopicsList(List<SchemeOfWork> schemes) {
    // Group schemes by subject+term+year so multiple subjects don't mix
    final grouped = <String, List<SchemeOfWork>>{};
    for (final s in schemes) {
      final key = '${s.subject} · ${s.term} ${s.year}';
      grouped.putIfAbsent(key, () => []).add(s);
    }

    // Default expand the first group for visibility
    if (_expandedSubjects.isEmpty && grouped.isNotEmpty) {
      _expandedSubjects.add(grouped.keys.first);
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, i) {
            final key = grouped.keys.elementAt(i);
            final groupSchemes = grouped[key]!;
            final isExpanded = _expandedSubjects.contains(key);
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _buildSubjectGroup(
                key: key,
                schemes: groupSchemes,
                isExpanded: isExpanded,
                onToggle: () => setState(() {
                  if (isExpanded) {
                    _expandedSubjects.remove(key);
                  } else {
                    _expandedSubjects.add(key);
                  }
                }),
              ),
            );
          },
          childCount: grouped.length,
        ),
      ),
    );
  }

  Widget _buildSubjectGroup({
    required String key,
    required List<SchemeOfWork> schemes,
    required bool isExpanded,
    required VoidCallback onToggle,
  }) {
    // Merge all weeks across all schemes in this group
    final allWeeks = <_TopicRow>[];
    int totalPeriods = 0;
    for (final s in schemes) {
      for (final w in s.weeks) {
        allWeeks.add(_TopicRow(week: w, scheme: s));
        totalPeriods += w.periods;
      }
    }
    allWeeks.sort((a, b) =>
        a.week.weekNumber.compareTo(b.week.weekNumber));

    final statuses = schemes.map((s) => s.status).toSet();
    final primaryStatus = statuses.contains(SchemeStatus.pending)
        ? SchemeStatus.pending
        : statuses.contains(SchemeStatus.approved)
            ? SchemeStatus.approved
            : SchemeStatus.draft;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Subject header
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          mainColor,
                          Color.lerp(mainColor, Colors.black, 0.25)!,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.menu_book_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          key,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A202C),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${allWeeks.length} topics · $totalPeriods periods',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _statusChip(primaryStatus),
                  const SizedBox(width: 6),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(Icons.keyboard_arrow_down_rounded,
                        color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ),
          // Expanded weeks
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity, height: 0),
            secondChild: Column(
              children: [
                const Divider(height: 1),
                ...allWeeks.asMap().entries.map((entry) {
                  final isLast = entry.key == allWeeks.length - 1;
                  return _buildTopicRow(entry.value, isLast);
                }),
              ],
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 220),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicRow(_TopicRow row, bool isLast) {
    final w = row.week;
    return GestureDetector(
      onTap: () => _openDetail(row.scheme),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(
                  bottom: BorderSide(color: Colors.grey.shade100),
                ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Week badge
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: mainColor.withOpacity(0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Wk',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                      color: mainColor.withOpacity(0.7),
                    ),
                  ),
                  Text(
                    '${w.weekNumber}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: mainColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Topic + sub-topics
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          w.topic.isEmpty ? 'Untitled' : w.topic,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A202C),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${w.periods} per.',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (w.subTopics.trim().isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.subdirectory_arrow_right_rounded,
                            size: 12, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            w.subTopics,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: Colors.grey.shade700,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (w.objectives.trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.check_circle_outline_rounded,
                            size: 12, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            w.objectives,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: Colors.grey.shade600,
                              height: 1.4,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Empty / loading ──────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: mainColor.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _viewMode == SchemeViewMode.schemes
                    ? Icons.description_outlined
                    : Icons.account_tree_rounded,
                size: 48,
                color: mainColor,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _viewMode == SchemeViewMode.schemes
                  ? 'No schemes yet'
                  : 'No topics yet',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A202C),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _viewMode == SchemeViewMode.schemes
                  ? 'Create your first scheme of work for\n${widget.className}'
                  : 'Topics will appear here once\na scheme is created',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: mainColor.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(mainColor),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Loading schemes...',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Filter pickers ──────────────────────────────────────
  void _pickTerm() {
    _showSheet<String>(
      title: 'Select term',
      options: const ['Term 1', 'Term 2', 'Term 3'],
      onSelected: (v) => setState(() => _selectedTerm = v),
    );
  }

  void _pickYear() {
    final current = DateTime.now().year;
    _showSheet<int>(
      title: 'Select year',
      options: [current - 1, current, current + 1],
      onSelected: (v) => setState(() => _selectedYear = v),
    );
  }

  void _pickStatus() {
    _showSheet<String>(
      title: 'Filter by status',
      options: const [
        SchemeStatus.draft,
        SchemeStatus.pending,
        SchemeStatus.approved,
        SchemeStatus.rejected,
      ],
      labelBuilder: SchemeStatus.labelOf,
      onSelected: (v) => setState(() => _selectedStatus = v),
    );
  }

  void _showSheet<T>({
    required String title,
    required List<T> options,
    required ValueChanged<T> onSelected,
    String Function(T)? labelBuilder,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A202C),
                ),
              ),
              const SizedBox(height: 12),
              ...options.map((o) => ListTile(
                    title: Text(labelBuilder != null ? labelBuilder(o) : '$o'),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded,
                        size: 14),
                    onTap: () {
                      Navigator.pop(context);
                      onSelected(o);
                    },
                  )),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Navigation ──────────────────────────────────────────
  void _openCreateForm() async {
    final result = await Navigator.push<SchemeOfWork>(
      context,
      MaterialPageRoute(
        builder: (_) => SchemeFormScreen(
          schoolId: widget.schoolId,
          classId: widget.classId,
          className: widget.className,
          teacherUid: widget.teacherUid,
          teacherName: widget.teacherName,
        ),
      ),
    );
    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Scheme ${result.status == SchemeStatus.draft ? "saved" : "submitted"}',
          ),
          backgroundColor: mainColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _openDetail(SchemeOfWork scheme) async {
    final result = await Navigator.push<SchemeOfWork>(
      context,
      MaterialPageRoute(
        builder: (_) => SchemeFormScreen(
          schoolId: widget.schoolId,
          classId: widget.classId,
          className: widget.className,
          teacherUid: widget.teacherUid,
          teacherName: widget.teacherName,
          existing: scheme,
        ),
      ),
    );
    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Scheme updated'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

// ─── Helper model for the breakdown view ──────────────────
class _TopicRow {
  final SchemeWeek week;
  final SchemeOfWork scheme;
  _TopicRow({required this.week, required this.scheme});
}