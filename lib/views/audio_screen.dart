import 'package:flutter/material.dart';

import 'app_top_bar.dart';

import '../presenters/audio_presenter.dart';

class AudioListScreen extends StatefulWidget {
  final AudioPresenter? presenter;

  const AudioListScreen({super.key, this.presenter});

  @override
  State<AudioListScreen> createState() => _AudioListScreenState();
}

class _AudioListScreenState extends State<AudioListScreen> {
  late final AudioPresenter _presenter = widget.presenter ?? AudioPresenter();

  @override
  void dispose() {
    if (widget.presenter == null) _presenter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _presenter,
      builder: (context, child) {
        final selected = _presenter.selectedAudio;
        return Scaffold(
          appBar: const AppTopBar(title: 'Sleep Audio'),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Choose a sound. Sounds loop until you pause or stop.',
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: _presenter.audios.length,
                  itemBuilder: (context, index) {
                    final audio = _presenter.audios[index];
                    final isSelected = selected == audio;
                    final isPlaying = isSelected && _presenter.isPlaying;
                    final isLoading = _presenter.loadingAudio == audio;
                    return Card(
                      child: ListTile(
                        selected: isSelected,
                        leading: const Icon(Icons.graphic_eq),
                        title: Text(audio.name),
                        subtitle: audio.description == null
                            ? null
                            : Text(audio.description!),
                        onTap: _presenter.isLoading || !audio.hasSource
                            ? null
                            : () => _presenter.toggleAudio(audio),
                        trailing: isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : IconButton(
                                tooltip:
                                    '${isPlaying ? 'Pause' : 'Play'} ${audio.name}',
                                icon: Icon(
                                  isPlaying ? Icons.pause : Icons.play_arrow,
                                ),
                                onPressed:
                                    _presenter.isLoading || !audio.hasSource
                                    ? null
                                    : () => _presenter.toggleAudio(audio),
                              ),
                      ),
                    );
                  },
                ),
              ),
              if (_presenter.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    _presenter.errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                    semanticsLabel: _presenter.errorMessage,
                  ),
                ),
              SafeArea(
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
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium,
                                ),
                                if (selected != null)
                                  Text(
                                    _presenter.isPlaying ? 'Playing' : 'Paused',
                                  ),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: _presenter.isPlaying
                                ? 'Pause audio'
                                : 'Resume audio',
                            icon: Icon(
                              _presenter.isPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow,
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
                            _presenter.volume == 0
                                ? Icons.volume_off
                                : Icons.volume_up,
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
                            child: Text(
                              '${(_presenter.volume * 100).round()}%',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
