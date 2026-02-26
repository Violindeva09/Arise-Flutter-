import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class SystemAudioService {
  static final SystemAudioService _instance = SystemAudioService._internal();

  factory SystemAudioService() {
    return _instance;
  }

  SystemAudioService._internal();

  final AudioPlayer _uiPlayer = AudioPlayer();
  final AudioPlayer _alertPlayer = AudioPlayer();

  bool _isMuted = false;

  bool get isMuted => _isMuted;

  void toggleMute() {
    _isMuted = !_isMuted;
  }

  Future<void> init() async {
    _uiPlayer.setReleaseMode(ReleaseMode.stop);
    _alertPlayer.setReleaseMode(ReleaseMode.stop);
  }

  Future<void> playClick() async {
    if (_isMuted) return;
    try {
      if (_uiPlayer.state == PlayerState.playing) {
        await _uiPlayer.stop();
      }
      await _uiPlayer.play(AssetSource('audio/solo_leveling_counter.mp3'));
    } catch (e) {
      if (kDebugMode) print('Error playing click sound: $e');
    }
  }

  Future<void> playSwish() async {
    if (_isMuted) return;
    try {
      if (_uiPlayer.state == PlayerState.playing) {
        await _uiPlayer.stop();
      }
      await _uiPlayer.play(AssetSource('audio/solo_leveling_menu_pop.mp3'));
    } catch (e) {
      if (kDebugMode) print('Error playing swish sound: $e');
    }
  }

  Future<void> playAlert() async {
    if (_isMuted) return;
    try {
      if (_alertPlayer.state == PlayerState.playing) {
        await _alertPlayer.stop();
      }
      await _alertPlayer.play(AssetSource('audio/solo_leveling_system.mp3'));
    } catch (e) {
      if (kDebugMode) print('Error playing alert sound: $e');
    }
  }

  Future<void> playLevelUp() async {
    if (_isMuted) return;
    try {
      await _alertPlayer.play(AssetSource(
          'audio/Solo Leveling Arise Notification Sound Download.mp3'));
    } catch (e) {
      if (kDebugMode) print('Error playing level up sound: $e');
    }
  }
}
