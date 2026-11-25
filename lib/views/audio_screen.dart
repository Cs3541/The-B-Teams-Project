import 'dart:async';

import 'package:flutter/material.dart';

import 'app_top_bar.dart';

import '../models/audio_model.dart';
import '../presenters/audio_presenter.dart';

class AudioListScreen extends StatefulWidget {
  final AudioPresenter? presenter;

  const AudioListScreen({super.key, this.presenter});

  @override
  State<AudioListScreen> createState() => _AudioListScreenState();
}

class _AudioListScreenState extends State<AudioListScreen>
    with WidgetsBindingObserver {
  late final AudioPresenter _presenter = widget.presenter ?? AudioPresenter();
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_presenter.initialize());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    unawaited(_presenter.flush());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _search.dispose();
    if (widget.presenter == null) _presenter.dispose();
    super.dispose();
  }

  Future<void> _importAudio() async {
    if (await _presenter.importAudio() && mounted) {
      _search.clear();
      _presenter.setQuery('');
      _presenter.setSection(AudioLibrarySection.imports);
    }
  }

  Future<void> _removeAudio(Audio audio) async {
    final remove = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove imported audio?'),
        content: Text(
          'Remove "${audio.name}" from this app? Your original file and listening history will remain.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (remove == true && mounted) await _presenter.removeImportedAudio(audio);
  }

  Widget _soundCard(Audio audio) {
    final isSelected = _presenter.selectedAudio == audio;
    final isPlaying = isSelected && _presenter.isPlaying;
    final isLoading = _presenter.loadingAudio == audio;
    final play = _presenter.isLoading || !audio.hasSource
        ? null
        : () => _presenter.toggleAudio(audio);
    return Card(
      child: ListTile(
        selected: isSelected,
        isThreeLine: true,
        leading: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : IconButton(
                tooltip: '${isPlaying ? 'Pause' : 'Play'} ${audio.name}',
                icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                onPressed: play,
              ),
        title: Text(audio.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              audio.description ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'Listened ${AudioPresenter.formatListening(_presenter.listeningFor(audio))}',
            ),
          ],
        ),
        onTap: play,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip:
                  '${_presenter.isFavorite(audio) ? 'Unfavorite' : 'Favorite'} ${audio.name}',
              icon: Icon(
                _presenter.isFavorite(audio)
                    ? Icons.favorite
                    : Icons.favorite_border,
              ),
              color: _presenter.isFavorite(audio)
                  ? Theme.of(context).colorScheme.primary
                  : null,
              onPressed: !_presenter.libraryReady || _presenter.isLibraryBusy
                  ? null
                  : () => _presenter.toggleFavorite(audio),
            ),
            if (audio.sourceType == AudioSourceType.file)
              PopupMenuButton<String>(
                tooltip: 'Manage ${audio.name}',
                enabled: !_presenter.isLibraryBusy && !_presenter.isLoading,
                onSelected: (_) => _removeAudio(audio),
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'remove',
                    child: Text('Remove from library'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _libraryContent() {
    final history = _presenter.section == AudioLibrarySection.history;
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      children: [
        Row(
          children: [
            const Expanded(child: Text('Sounds for sleep')),
            TextButton.icon(
              onPressed: !_presenter.libraryReady || _presenter.isLibraryBusy
                  ? null
                  : _importAudio,
              icon: _presenter.isLibraryBusy
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.file_upload_outlined),
              label: const Text('Import MP3'),
            ),
          ],
        ),
        const Text('Choose a sound. Sounds loop until you pause or stop.'),
        const SizedBox(height: 12),
        TextField(
          controller: _search,
          decoration: InputDecoration(
            labelText: history ? 'Search listening history' : 'Search audios',
            prefixIcon: const Icon(Icons.search),
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              tooltip: 'Clear search',
              icon: const Icon(Icons.clear),
              onPressed: () {
                _search.clear();
                _presenter.setQuery('');
              },
            ),
          ),
          onChanged: _presenter.setQuery,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (final section in AudioLibrarySection.values)
              ChoiceChip(
                label: Text(switch (section) {
                  AudioLibrarySection.catalog => 'All audios',
                  AudioLibrarySection.favorites => 'Favorite audios',
                  AudioLibrarySection.imports => 'My imports',
                  AudioLibrarySection.history => 'Listening history',
                }),
                selected: _presenter.section == section,
                onSelected: (_) => _presenter.setSection(section),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (_presenter.isLibraryLoading)
          const Center(child: CircularProgressIndicator())
        else if (history) ...[
          Text(
            'Today: ${AudioPresenter.formatListening(_presenter.todayListening)}  •  Total: ${AudioPresenter.formatListening(_presenter.totalListening)}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          const Text(
            'Time counts while audio is playing, excluding pauses and buffering.',
          ),
          if (_presenter.listeningHistory.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text('No listening history matches your search.'),
            ),
          for (final record in _presenter.listeningHistory)
            ListTile(
              leading: const Icon(Icons.headphones),
              title: Text(record.audioName),
              subtitle: Text(
                MaterialLocalizations.of(context).formatMediumDate(record.day),
              ),
              trailing: Text(
                AudioPresenter.formatListening(
                  Duration(milliseconds: record.milliseconds),
                ),
              ),
            ),
        ] else if (_presenter.visibleAudios.isEmpty)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              _search.text.trim().isNotEmpty
                  ? 'No audios match your search.'
                  : switch (_presenter.section) {
                      AudioLibrarySection.favorites =>
                        'No favorite audios yet. Tap a heart to save a sound.',
                      AudioLibrarySection.imports => 'No imported audios yet. Choose Import MP3 to add your own.',
                      _ => 'No audios available.',
                    },
            ),
          )
        else
          for (final audio in _presenter.visibleAudios) _soundCard(audio),
        if (_presenter.libraryMessage != null)
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _presenter.libraryMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                TextButton(
                  onPressed: _presenter.retryLibrary,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _player() {
    final selected = _presenter.selectedAudio;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selected?.name ?? 'Choose a sound to begin',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (selected != null)
                        Text(_presenter.isPlaying ? 'Playing' : 'Paused'),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: _presenter.isPlaying
                      ? 'Pause audio'
                      : 'Resume audio',
                  icon: Icon(
                    _presenter.isPlaying ? Icons.pause : Icons.play_arrow,
                  ),
                  onPressed: selected == null || _presenter.isLoading
                      ? null
                      : () => _presenter.toggleAudio(selected),
                ),
                IconButton(
                  tooltip: 'Stop audio',
                  icon: const Icon(Icons.stop),
                  onPressed: selected == null || _presenter.isLoading
                      ? null
                      : _presenter.stopAudio,
                ),
              ],
            ),
            Row(
              children: [
                Icon(
                  _presenter.volume == 0 ? Icons.volume_off : Icons.volume_up,
                ),
                const SizedBox(width: 8),
                const Text('Volume'),
                Expanded(
                  child: Slider(
                    value: _presenter.volume,
                    divisions: 20,
                    label: '${(_presenter.volume * 100).round()}%',
                    semanticFormatterCallback: (value) =>
                        '${(value * 100).round()} percent',
                    onChanged: _presenter.setVolume,
                  ),
                ),
                SizedBox(
                  width: 42,
                  child: Text('${(_presenter.volume * 100).round()}%'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _presenter,
      builder: (context, child) => Scaffold(
        appBar: const AppTopBar(title: 'Sleep Audio'),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: _libraryContent()),
            if (_presenter.errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  _presenter.errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            if (MediaQuery.viewInsetsOf(context).bottom == 0) _player(),
          ],
        ),
      ),
    );
  }
}
