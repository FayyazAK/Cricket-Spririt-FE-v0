import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/app_state.dart';
import '../../app/themes/themes.dart';
import '../../services/api/api_service.dart';

class CreateMatchView extends StatefulWidget {
  const CreateMatchView({super.key});

  @override
  State<CreateMatchView> createState() => _CreateMatchViewState();
}

class _CreateMatchViewState extends State<CreateMatchView> {
  final _formKey = GlobalKey<FormState>();

  final _team1IdController = TextEditingController();
  final _team2IdController = TextEditingController();
  final _oversController = TextEditingController(text: '20');
  final _customOversController = TextEditingController();
  final _scorerSearchController = TextEditingController();

  final List<_TeamOption> _teams = [];
  final List<_UserOption> _scorerOptions = [];

  String? _team1Id;
  String? _team2Id;
  String _ballType = 'LEATHER';
  String _format = 'T20';
  bool _useSelfAsScorer = true;
  String? _scorerId;
  _UserOption? _selectedScorer;
  DateTime? _scheduledDate;

  bool _isLoadingTeams = false;
  bool _isSearchingScorer = false;
  bool _isCreating = false;
  String? _teamsError;
  String? _scorerSearchError;
  Timer? _scorerSearchDebounce;

  @override
  void initState() {
    super.initState();
    _loadTeams();
    _scorerSearchController.addListener(_onScorerSearchChanged);
  }

  @override
  void dispose() {
    _team1IdController.dispose();
    _team2IdController.dispose();
    _oversController.dispose();
    _customOversController.dispose();
    _scorerSearchController.dispose();
    _scorerSearchDebounce?.cancel();
    super.dispose();
  }

  Future<void> _loadTeams() async {
    setState(() {
      _isLoadingTeams = true;
      _teamsError = null;
    });

    try {
      final joinedTeams = appState.currentUser?.player?.joinedTeams ?? const [];
      for (final team in joinedTeams) {
        _teams.add(
          _TeamOption(id: team.id, name: team.name, clubId: team.clubId),
        );
      }

      final response = await apiService.getAllTeams(limit: 200);
      final data = (response['data'] as List?) ?? const [];
      for (final raw in data) {
        if (raw is! Map<String, dynamic>) continue;
        final id = raw['id']?.toString();
        final name = raw['name']?.toString();
        if (id == null || name == null) continue;
        if (_teams.any((t) => t.id == id)) continue;
        _teams.add(
          _TeamOption(
            id: id,
            name: name,
            clubId: raw['clubId']?.toString(),
          ),
        );
      }

      _teams.sort((a, b) => a.name.compareTo(b.name));
    } catch (e) {
      _teamsError = e.toString().replaceAll('Exception: ', '');
    } finally {
      if (!mounted) return;
      setState(() => _isLoadingTeams = false);
    }
  }

  void _onScorerSearchChanged() {
    if (_useSelfAsScorer) return;
    _scorerSearchDebounce?.cancel();
    final query = _scorerSearchController.text.trim();

    if (query.isEmpty) {
      setState(() {
        _scorerOptions.clear();
        _scorerSearchError = null;
        _scorerId = null;
        _selectedScorer = null;
      });
      return;
    }

    if (_selectedScorer != null && _selectedScorer!.email != query) {
      setState(() {
        _scorerId = null;
        _selectedScorer = null;
      });
    }

    _scorerSearchDebounce = Timer(const Duration(seconds: 1), () {
      _searchScorers(query);
    });
  }

  Future<void> _searchScorers(String query) async {
    if (!mounted) return;
    if (query.isEmpty) return;
    setState(() {
      _isSearchingScorer = true;
      _scorerSearchError = null;
    });

    try {
      final response = await apiService.searchUsersByEmail(query);
      final data = (response['data'] as List?) ?? const [];
      final results = data
          .whereType<Map<String, dynamic>>()
          .map(_UserOption.fromJson)
          .toList();
      if (!mounted) return;
      setState(() {
        _scorerOptions
          ..clear()
          ..addAll(results);
        _isSearchingScorer = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _scorerOptions.clear();
        _isSearchingScorer = false;
        _scorerSearchError = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  int? _parseOvers(String value) {
    final parsed = int.tryParse(value.trim());
    if (parsed == null) return null;
    if (parsed < 2 || parsed > 50) return null;
    return parsed;
  }

  String? _validateTeamId(String? value, {required String label}) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return '$label is required';
    }
    return null;
  }

  String? _validateTeam1(String? value) {
    final base = _validateTeamId(value, label: 'Team 1');
    if (base != null) return base;
    if (value != null && value == _team2Id) {
      return 'Team 1 and Team 2 must be different';
    }
    if (_teams.isEmpty &&
        _team2IdController.text.trim().isNotEmpty &&
        value?.trim() == _team2IdController.text.trim()) {
      return 'Team 1 and Team 2 must be different';
    }
    return null;
  }

  String? _validateTeam2(String? value) {
    final base = _validateTeamId(value, label: 'Team 2');
    if (base != null) return base;
    if (value != null && value == _team1Id) {
      return 'Team 1 and Team 2 must be different';
    }
    if (_teams.isEmpty &&
        _team1IdController.text.trim().isNotEmpty &&
        value?.trim() == _team1IdController.text.trim()) {
      return 'Team 1 and Team 2 must be different';
    }
    return null;
  }

  String _formatDateTime(DateTime value) {
    final date =
        '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
    final time =
        '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
    return '$date $time';
  }

  Future<void> _pickScheduledDate() async {
    final now = DateTime.now();
    final initialDate = _scheduledDate ?? now;
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365)),
      helpText: 'Select match date',
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
      helpText: 'Select match time',
    );
    if (time == null || !mounted) return;

    setState(() {
      _scheduledDate = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _createMatch() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_team1Id != null && _team2Id != null && _team1Id == _team2Id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Team 1 and Team 2 must be different'),
          backgroundColor: CricketSpiritColors.error,
        ),
      );
      return;
    }

    if (_team1Id == null && _team1IdController.text.trim().isNotEmpty) {
      _team1Id = _team1IdController.text.trim();
    }
    if (_team2Id == null && _team2IdController.text.trim().isNotEmpty) {
      _team2Id = _team2IdController.text.trim();
    }

    if (_team1Id != null && _team2Id != null && _team1Id == _team2Id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Team 1 and Team 2 must be different'),
          backgroundColor: CricketSpiritColors.error,
        ),
      );
      return;
    }

    if (_team1Id == null || _team2Id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both teams'),
          backgroundColor: CricketSpiritColors.error,
        ),
      );
      return;
    }

    final overs = _parseOvers(_oversController.text);
    if (overs == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Overs must be between 2 and 50'),
          backgroundColor: CricketSpiritColors.error,
        ),
      );
      return;
    }

    int? customOvers;
    if (_format == 'CUSTOM') {
      customOvers = _parseOvers(_customOversController.text);
      if (customOvers == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Custom overs must be between 2 and 50'),
            backgroundColor: CricketSpiritColors.error,
          ),
        );
        return;
      }
    }

    final scorerId = _useSelfAsScorer ? null : _scorerId;

    if (!_useSelfAsScorer && (scorerId == null || scorerId.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select a scorer from search results'),
          backgroundColor: CricketSpiritColors.error,
        ),
      );
      return;
    }

    setState(() => _isCreating = true);

    try {
      final response = await apiService.createMatch(
        tournamentId: null,
        scorerId: scorerId,
        team1Id: _team1Id!,
        team2Id: _team2Id!,
        overs: _format == 'CUSTOM' ? customOvers ?? overs : overs,
        ballType: _ballType,
        format: _format,
        customOvers: _format == 'CUSTOM' ? customOvers : null,
        scheduledDate: _scheduledDate,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response['message'] ?? 'Match created successfully',
          ),
          backgroundColor: CricketSpiritColors.primary,
        ),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isCreating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: CricketSpiritColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: CricketSpiritColors.background,
      appBar: AppBar(
        title: const Text('Create Match'),
        backgroundColor: CricketSpiritColors.background,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCard(
                      title: 'Teams',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_isLoadingTeams)
                            const LinearProgressIndicator(
                              color: CricketSpiritColors.primary,
                            ),
                          if (_teamsError != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              _teamsError!,
                              style: textTheme.bodySmall?.copyWith(
                                color: CricketSpiritColors.error,
                              ),
                            ),
                          ],
                          const SizedBox(height: 12),
                          _teams.isNotEmpty
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Team 1',
                                      style: textTheme.bodyMedium?.copyWith(
                                        color:
                                            CricketSpiritColors.mutedForeground,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                                      value: _team1Id,
                                      hint: const Text('Select team 1'),
                                      items: _teams
                                          .map(
                                            (team) => DropdownMenuItem(
                                              value: team.id,
                                              child: Text(team.name),
                                            ),
                                          )
                                          .toList(),
                              onChanged: (value) {
                                if (value != null && value == _team2Id) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Team 1 and Team 2 must be different',
                                      ),
                                      backgroundColor: CricketSpiritColors.error,
                                    ),
                                  );
                                  setState(() => _team1Id = null);
                                  return;
                                }
                                setState(() => _team1Id = value);
                              },
                              validator: _validateTeam1,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Team 2',
                                      style: textTheme.bodyMedium?.copyWith(
                                        color:
                                            CricketSpiritColors.mutedForeground,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                                      value: _team2Id,
                                      hint: const Text('Select team 2'),
                                      items: _teams
                                          .map(
                                            (team) => DropdownMenuItem(
                                              value: team.id,
                                              child: Text(team.name),
                                            ),
                                          )
                                          .toList(),
                              onChanged: (value) {
                                if (value != null && value == _team1Id) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Team 1 and Team 2 must be different',
                                      ),
                                      backgroundColor: CricketSpiritColors.error,
                                    ),
                                  );
                                  setState(() => _team2Id = null);
                                  return;
                                }
                                setState(() => _team2Id = value);
                              },
                              validator: _validateTeam2,
                                    ),
                                  ],
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'No teams available. Enter team IDs.',
                                      style: textTheme.bodySmall?.copyWith(
                                        color:
                                            CricketSpiritColors.mutedForeground,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    TextFormField(
                                      controller: _team1IdController,
                                      decoration: const InputDecoration(
                                        labelText: 'Team 1 ID *',
                                        hintText: 'Enter team 1 ID',
                                      ),
                                      validator: _validateTeam1,
                                    ),
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      controller: _team2IdController,
                                      decoration: const InputDecoration(
                                        labelText: 'Team 2 ID *',
                                        hintText: 'Enter team 2 ID',
                                      ),
                                      validator: _validateTeam2,
                                    ),
                                  ],
                                ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildCard(
                      title: 'Match format',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DropdownButtonFormField<String>(
                            value: _format,
                            items: const [
                              DropdownMenuItem(value: 'T20', child: Text('T20')),
                              DropdownMenuItem(value: 'ODI', child: Text('ODI')),
                              DropdownMenuItem(value: 'TEST', child: Text('Test')),
                              DropdownMenuItem(
                                value: 'CUSTOM',
                                child: Text('Custom'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() => _format = value);
                            },
                            decoration: const InputDecoration(
                              labelText: 'Format *',
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _oversController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Overs *',
                              hintText: '2 - 50',
                            ),
                            validator: (value) {
                              final parsed = _parseOvers(value ?? '');
                              if (parsed == null) {
                                return 'Overs must be between 2 and 50';
                              }
                              return null;
                            },
                          ),
                          if (_format == 'CUSTOM') ...[
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _customOversController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Custom overs *',
                                hintText: '2 - 50',
                              ),
                              validator: (value) {
                                final parsed = _parseOvers(value ?? '');
                                if (parsed == null) {
                                  return 'Custom overs must be between 2 and 50';
                                }
                                return null;
                              },
                            ),
                          ],
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _ballType,
                            items: const [
                              DropdownMenuItem(
                                value: 'LEATHER',
                                child: Text('Leather'),
                              ),
                              DropdownMenuItem(
                                value: 'TENNIS_TAPE',
                                child: Text('Tennis Tape'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() => _ballType = value);
                            },
                            decoration: const InputDecoration(
                              labelText: 'Ball type *',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildCard(
                      title: 'Scheduling',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Scheduled date (optional)',
                            style: textTheme.bodySmall?.copyWith(
                              color: CricketSpiritColors.mutedForeground,
                            ),
                          ),
                          const SizedBox(height: 12),
                          InkWell(
                            onTap: _pickScheduledDate,
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Match date & time',
                                suffixIcon: Icon(Icons.calendar_today_outlined),
                              ),
                              child: Text(
                                _scheduledDate == null
                                    ? 'Select date & time'
                                    : _formatDateTime(_scheduledDate!),
                                style: textTheme.bodyMedium?.copyWith(
                                  color: _scheduledDate == null
                                      ? CricketSpiritColors.mutedForeground
                                      : CricketSpiritColors.foreground,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildCard(
                      title: 'Scoring',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('I will score this match'),
                            value: _useSelfAsScorer,
                            onChanged: (value) {
                              setState(() {
                                _useSelfAsScorer = value;
                                _scorerId = null;
                                _selectedScorer = null;
                                _scorerSearchController.clear();
                                _scorerOptions.clear();
                                _scorerSearchError = null;
                              });
                            },
                          ),
                          if (!_useSelfAsScorer) ...[
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _scorerSearchController,
                              decoration: const InputDecoration(
                                labelText: 'Search scorer by email',
                                hintText: 'Type email to search',
                                prefixIcon: Icon(Icons.search),
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (_isSearchingScorer)
                              const LinearProgressIndicator(
                                color: CricketSpiritColors.primary,
                              ),
                            const SizedBox(height: 12),
                            if (_scorerSearchError != null)
                              Text(
                                _scorerSearchError!,
                                style: textTheme.bodySmall?.copyWith(
                                  color: CricketSpiritColors.error,
                                ),
                              ),
                            if (_selectedScorer != null) ...[
                              const SizedBox(height: 8),
                              _buildSelectedScorerCard(_selectedScorer!),
                            ],
                            Builder(
                              builder: (context) {
                                final visibleOptions = _scorerOptions
                                    .where((user) => user.id != _scorerId)
                                    .toList();
                                if (visibleOptions.isEmpty ||
                                    _selectedScorer != null) {
                                  return const SizedBox.shrink();
                                }
                                return Column(
                                  children: [
                                    const SizedBox(height: 8),
                                    ListView.separated(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: visibleOptions.length,
                                      separatorBuilder: (_, __) =>
                                          const SizedBox(height: 8),
                                      itemBuilder: (context, index) {
                                        final user = visibleOptions[index];
                                        final isSelected =
                                            _scorerId == user.id;
                                        return InkWell(
                                          onTap: () {
                                            setState(() {
                                              _scorerId = user.id;
                                              _selectedScorer = user;
                                              _scorerSearchController.text =
                                                  user.email;
                                              _scorerOptions.clear();
                                            });
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? CricketSpiritColors.primary
                                                      .withOpacity(0.12)
                                                  : CricketSpiritColors.white10,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                CricketSpiritRadius.button,
                                              ),
                                              border: Border.all(
                                                color: isSelected
                                                    ? CricketSpiritColors.primary
                                                    : CricketSpiritColors.border,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.person_outline,
                                                  color: isSelected
                                                      ? CricketSpiritColors
                                                          .primary
                                                      : CricketSpiritColors
                                                          .mutedForeground,
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        user.name,
                                                        style: textTheme
                                                            .bodyMedium
                                                            ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 2),
                                                      Text(
                                                        user.email,
                                                        style: textTheme
                                                            .bodySmall
                                                            ?.copyWith(
                                                          color:
                                                              CricketSpiritColors
                                                                  .mutedForeground,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isCreating ? null : _createMatch,
                        child: _isCreating
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: CricketSpiritColors.primaryForeground,
                                ),
                              )
                            : const Text('Create Match'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: CricketSpiritColors.card,
        borderRadius: BorderRadius.circular(CricketSpiritRadius.card),
        border: Border.all(color: CricketSpiritColors.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildSelectedScorerCard(_UserOption user) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CricketSpiritColors.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(CricketSpiritRadius.button),
        border: Border.all(color: CricketSpiritColors.primary),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: CricketSpiritColors.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.email,
                  style: textTheme.bodySmall?.copyWith(
                    color: CricketSpiritColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            color: CricketSpiritColors.mutedForeground,
            onPressed: () {
              setState(() {
                _scorerId = null;
                _selectedScorer = null;
                _scorerSearchController.clear();
              });
            },
          ),
        ],
      ),
    );
  }
}

class _TeamOption {
  final String id;
  final String name;
  final String? clubId;

  _TeamOption({
    required this.id,
    required this.name,
    this.clubId,
  });
}

class _UserOption {
  final String id;
  final String email;
  final String name;

  _UserOption({
    required this.id,
    required this.email,
    required this.name,
  });

  factory _UserOption.fromJson(Map<String, dynamic> json) {
    return _UserOption(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      name: json['name']?.toString() ?? 'User',
    );
  }
}
