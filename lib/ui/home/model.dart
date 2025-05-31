import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logging/logging.dart';

import '../../data/repository/feed.dart';
import '../../model/episode.dart';
import '../../model/settings.dart';
import '../../util/constants.dart';

class HomeViewModel extends ChangeNotifier {
  final FeedRepository _feedRepo;
  final AudioPlayer _player;
  HomeViewModel({required FeedRepository feedRepo, required AudioPlayer player})
    : _feedRepo = feedRepo,
      _player = player {
    _init();
  }

  // ignore: unused_field
  final _log = Logger('HomeModel');
  List<Episode> _episodes = [];
  Settings? _settings;
  IndexedAudioSource? _currentSource;

  List<Episode> get episodes => _episodes;
  Settings? get settings => _settings;
  List<Episode> get unplayed =>
      _episodes.where((e) => e.played != true).toList();
  List<Episode> get downloaded =>
      _episodes.where((e) => e.downloaded == true).toList();
  List<Episode> get liked => _episodes.where((e) => e.liked == true).toList();
  IndexedAudioSource? get currentSource => _currentSource;
  String? get currentId => _currentSource?.tag.id;

  void _init() {
    _player.playerStateStream.listen((event) async {
      // _log.fine('playerState: $event');
      //
      // playing: true / false
      // processingState: idle / loading / buffering /  ready/ completed
      //
      if (event.playing == false &&
          event.processingState == ProcessingState.ready) {
        // paused
        await _handlePlayerStateChange(event);
      }
      if (event.playing == true &&
          (event.processingState == ProcessingState.buffering ||
              event.processingState == ProcessingState.completed)) {
        // seek
        await _handlePlayerStateChange(event);
      }
    });
    _player.sequenceStateStream.listen((event) async {
      // _log.fine('sequenceState: $event');
      //
      // currentIndex
      // currentSource
      // sequence
      await _handleSequenceStateChange(event);
    });
    // _player.currentIndexStream.listen((event) async {
    //   _log.fine('currentIndex:$event');
    // });
  }

  Future _handleSequenceStateChange(SequenceState state) async {
    if (_currentSource != state.currentSource) {
      if (_currentSource?.tag.id != null) {
        await _feedRepo.setPlayed(_currentSource?.tag.id);
      }
      _currentSource = state.currentSource;
      await load();
    }
  }

  Future _handlePlayerStateChange(PlayerState state) async {
    _log.fine('handlePlayerStateChange');
    final index = _player.currentIndex;
    final sequence = _player.sequence;
    final position = _player.position;
    final duration = _player.duration;

    if (index != null &&
        sequence.isNotEmpty == true &&
        sequence.length > index &&
        position > Duration(seconds: 30)) {
      final source = sequence[index];
      if (duration != null && (position + Duration(seconds: 30) > duration)) {
        // end of the media
        _log.fine('set played: ${source.tag}');
        await _feedRepo.setPlayed(source.tag.id);
        await load();
      } else {
        // paused or seek
        _log.fine('update bookmark: ${source.tag}');
        await _feedRepo.updateBookmark(source.tag.id, position.inSeconds);
      }
    }
  }

  Future load() async {
    _log.fine('load');
    _settings = await _feedRepo.getSettings();
    _episodes = await _feedRepo.getEpisodes(
      period: _settings?.retentionPeriod ?? defaultRetentionDays,
    );
    notifyListeners();
  }

  Future<ImageProvider> getChannelImage(Episode episode) async {
    return _feedRepo.getChannelImage(episode);
  }

  Future playEpisode(Episode episode) async {
    await _feedRepo.playEpisode(episode);
  }

  Future addToPlayList(Episode episode) async {
    await _feedRepo.addToPlayList(episode);
    // notification done via player.sequenceStream
    // notifyListeners();
  }

  Future togglePlayed(Episode episode) async {
    if (episode.id != null) {
      if (episode.played == true) {
        // clear
        // _log.fine('clear played');
        await _feedRepo.clearPlayed(episode.guid);
      } else {
        // set
        // _log.fine('set played');
        await _feedRepo.setPlayed(episode.guid);
        // }
      }
      _episodes = await _feedRepo.getEpisodes(
        period: _settings?.retentionPeriod ?? defaultRetentionDays,
      );
      notifyListeners();
    }
  }

  Future toggleLiked(Episode episode) async {
    if (episode.id != null) {
      if (episode.liked == true) {
        await _feedRepo.clearLiked(episode.guid);
      } else {
        await _feedRepo.setLiked(episode.guid);
      }
      _episodes = await _feedRepo.getEpisodes(
        period: _settings?.retentionPeriod ?? defaultRetentionDays,
      );
      notifyListeners();
    }
  }

  Future downloadEpisode(Episode episode) async {
    await _feedRepo.downloadEpisode(episode);
    _episodes = await _feedRepo.getEpisodes(
      period: _settings?.retentionPeriod ?? defaultRetentionDays,
    );
    notifyListeners();
  }

  Future updateRetentionPeriod(int period) async {
    if (_settings?.id != null) {
      _settings!.retentionPeriod = period;
      await _feedRepo.updateSettings(_settings!.id!, {
        "retention_period": period,
      });
      await load();
    }
  }

  Future updateSearchEngine(String url) async {
    if (_settings?.id != null) {
      _settings!.searchEngineUrl = url;
      await _feedRepo.updateSettings(_settings!.id!, {
        "search_engine_url": url,
      });
      _settings = await _feedRepo.getSettings();
      notifyListeners();
    }
  }

  Future<String?> getChannelUrl(int? id) async {
    if (id != null) {
      final channel = await _feedRepo.getChannel(id);
      return channel?.url;
    }
    return null;
  }

  // Future updateSettings() async {
  //   if (_settings?.id != null) {
  //     await _feedRepo.updateSettings(_settings!);
  //   }
  // }

  Future refreshData() async {
    await _feedRepo.refreshData(force: true);
    await load();
  }

  Future stop() async {
    await _feedRepo.stop();
  }
}
