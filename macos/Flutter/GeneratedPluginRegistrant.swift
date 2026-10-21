//
//  Generated file. Do not edit.
//

import FlutterMacOS
import Foundation

import audio_service
import audio_session
import desktop_window
import just_audio
import media_kit_libs_macos_audio
import shared_preferences_foundation
import sqflite_darwin

func RegisterGeneratedPlugins(registry: FlutterPluginRegistry) {
  AudioServicePlugin.register(with: registry.registrar(forPlugin: "AudioServicePlugin"))
  AudioSessionPlugin.register(with: registry.registrar(forPlugin: "AudioSessionPlugin"))
  DesktopWindowPlugin.register(with: registry.registrar(forPlugin: "DesktopWindowPlugin"))
  JustAudioPlugin.register(with: registry.registrar(forPlugin: "JustAudioPlugin"))
  MediaKitLibsMacosAudioPlugin.register(with: registry.registrar(forPlugin: "MediaKitLibsMacosAudioPlugin"))
  SharedPreferencesPlugin.register(with: registry.registrar(forPlugin: "SharedPreferencesPlugin"))
  SqflitePlugin.register(with: registry.registrar(forPlugin: "SqflitePlugin"))
}
