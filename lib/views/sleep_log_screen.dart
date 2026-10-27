
import 'package:flutter/material.dart';

import '../models/sleep_log_model.dart';
import '../presenters/sleep_log_presenter.dart';

class SleepLogScreen extends StatefulWidget {
  const SleepLogScreen({super.key});

  @override
  State<SleepLogScreen> createState() => _SleepLogScreenState();
}

class _SleepLogScreenState extends State<SleepLogScreen> {
  final SleepLogPresenter _presenter = SleepLogPresenter();

  TimeOfDay? _bedtime;
  TimeOfDay? _wakeUpTime;

  List<SleepLog> _logs = [];
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    try {
      final logs = await _presenter.loadLogs();

      if (!mounted) return;

      setState(() {
        _logs = logs;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() => _loading = false);
      _showMessage(error.toString());
    }
  }

  DateTime _combineDateAndTime(DateTime date, TimeOfDay time) {
    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }

  DateTime _formatBedtime(TimeOfDay time) {
    final now = DateTime.now();
    var result = _combineDateAndTime(now, time);

    if (result.isAfter(now)) {
      result = result.subtract(const Duration(days: 1));
    }

    return result;
  }

  DateTime _formatWakeUp(TimeOfDay time, DateTime bedtime) {
    var result = _combineDateAndTime(bedtime, time);

    if (!result.isAfter(bedtime)) {
      result = result.add(const Duration(days: 1));
    }

    return result;
  }

  Future<void> _pickTime({required bool isBedtime}) async {
    final selected = await showTimePicker(
      context: context,
      initialTime: isBedtime
          ? (_bedtime ?? const TimeOfDay(hour: 23, minute: 0))
          : (_wakeUpTime ?? const TimeOfDay(hour: 7, minute: 0)),
    );

    if (selected == null || !mounted) return;

    setState(() {
      if (isBedtime) {
        _bedtime = selected;
      } else {
        _wakeUpTime = selected;
      }
    });
  }

  Duration? get _previewDuration {
    if (_bedtime == null || _wakeUpTime == null) return null;

    final bedtime = _formatBedtime(_bedtime!);
    final wakeUp = _formatWakeUp(_wakeUpTime!, bedtime);
    final duration = wakeUp.difference(bedtime);

    if (duration <= Duration.zero ||
        duration > const Duration(hours: 24)) {
      return null;
    }

    return duration;
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return '$hours hr $minutes min';
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return 'Select time';
    return time.format(context);
  }

  String _formatDateTime(DateTime dateTime) {
    final date = MaterialLocalizations.of(context)
        .formatMediumDate(dateTime);
    final time = TimeOfDay.fromDateTime(dateTime).format(context);
    return '$date at $time';
  }

  Future<void> _saveLog() async {
    if (_bedtime == null || _wakeUpTime == null) {
      _showMessage('Please select both bedtime and wake-up time.');
      return;
    }

    final bedtime = _formatBedtime(_bedtime!);
    final wakeUp = _formatWakeUp(_wakeUpTime!, bedtime);
    final duration = wakeUp.difference(bedtime);

    if (duration <= Duration.zero ||
        duration > const Duration(hours: 24)) {
      _showMessage(
        'Please choose a valid sleep period of 24 hours or less.',
      );
      return;
    }

    setState(() => _saving = true);

    final log = SleepLog(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      bedtime: bedtime,
      wakeUpTime: wakeUp,
    );

    try {
      await _presenter.saveLog(log);

      if (!mounted) return;

      final updatedLogs = await _presenter.loadLogs();

      if (!mounted) return;

      setState(() {
        _logs = updatedLogs;
        _bedtime = null;
        _wakeUpTime = null;
        _saving = false;
      });

      _showMessage('Sleep log saved successfully!');
    } catch (error) {
      if (!mounted) return;

      setState(() => _saving = false);
      _showMessage(error.toString());
    }
  }

  Future<void> _deleteLog(SleepLog log) async {
    try {
      await _presenter.deleteLog(log.id);

      if (!mounted) return;

      setState(() {
        _logs.removeWhere((item) => item.id == log.id);
      });

      _showMessage('Sleep log deleted.');
    } catch (error) {
      if (!mounted) return;
      _showMessage(error.toString());
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final preview = _previewDuration;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sleep Log'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Record Your Sleep',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Choose when you went to bed and when you woke up.',
                        ),
                        const SizedBox(height: 20),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.bedtime),
                          title: const Text('Bedtime'),
                          subtitle: Text(_formatTime(_bedtime)),
                          trailing: const Icon(Icons.access_time),
                          onTap: () => _pickTime(isBedtime: true),
                        ),
                        const Divider(),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.wb_sunny_outlined),
                          title: const Text('Wake-up time'),
                          subtitle: Text(_formatTime(_wakeUpTime)),
                          trailing: const Icon(Icons.access_time),
                          onTap: () => _pickTime(isBedtime: false),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .secondaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Total sleep duration'),
                              const SizedBox(height: 6),
                              Text(
                                preview == null
                                    ? '--'
                                    : _formatDuration(preview),
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _saving ? null : _saveLog,
                            icon: const Icon(Icons.save),
                            label: Text(
                              _saving ? 'Saving...' : 'Save Sleep Log',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Sleep History',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                if (_logs.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(
                        child: Text('No sleep logs yet. Add your first one!'),
                      ),
                    ),
                  )
                else
                  ..._logs.map(
                    (log) => Card(
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.bedtime),
                        ),
                        title: Text(log.formattedDuration),
                        subtitle: Text(
                          'Bed: ${_formatDateTime(log.bedtime)}\n'
                          'Wake: ${_formatDateTime(log.wakeUpTime)}',
                        ),
                        isThreeLine: true,
                        trailing: IconButton(
                          tooltip: 'Delete sleep log',
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _deleteLog(log),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
