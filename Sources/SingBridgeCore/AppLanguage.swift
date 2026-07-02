import Foundation

public enum AppLanguage: String, CaseIterable, Identifiable, Sendable {
  case english
  case simplifiedChinese

  public var id: String { rawValue }

  public var displayName: String {
    switch self {
    case .english:
      "English"
    case .simplifiedChinese:
      "简体中文"
    }
  }

  public static let storageKey = "SingBridge.selectedLanguage"

  public static func fromStorageValue(_ value: String) -> AppLanguage {
    AppLanguage(rawValue: value) ?? .english
  }
}

public struct AppStrings: Sendable {
  public var language: AppLanguage

  public init(language: AppLanguage) {
    self.language = language
  }

  public var languageLabel: String { text("Language", "语言") }
  public var receiver: String { text("Receiver", "接收器") }
  public var voice: String { text("Voice", "人声") }
  public var music: String { text("Music", "音乐") }
  public var settings: String { text("Settings", "设置") }
  public var karaokeReceiver: String { text("Karaoke Receiver", "卡拉 OK 接收器") }
  public var connection: String { text("Connection", "连接") }
  public var port: String { text("Port", "端口") }
  public var listen: String { text("Listen", "监听") }
  public var stop: String { text("Stop", "停止") }
  public var stopTest: String { text("Stop Test", "停止测试") }
  public var selfTest: String { text("Self Test", "自检") }
  public var diagnostics: String { text("Diagnostics", "诊断") }
  public var voiceMix: String { text("Voice Mix", "人声混音") }
  public var voiceGain: String { text("Voice Gain", "人声增益") }
  public var targetLatency: String { text("Target Latency", "目标延迟") }
  public var accompaniment: String { text("Accompaniment", "伴奏") }
  public var chooseLocalTrack: String { text("Choose Local Track", "选择本地曲目") }
  public var pause: String { text("Pause", "暂停") }
  public var play: String { text("Play", "播放") }
  public var appleMusic: String { text("Apple Music", "Apple Music") }
  public var trackProgress: String { text("Track Progress", "曲目进度") }
  public var accompanimentVolume: String { text("Accompaniment Volume", "伴奏音量") }
  public var lyrics: String { text("Lyrics", "歌词") }
  public var importLRC: String { text("Import LRC", "导入 LRC") }
  public var lyricsOffset: String { text("Lyrics Offset", "歌词偏移") }
  public var authorize: String { text("Authorize", "授权") }
  public var searchAppleMusic: String { text("Search Apple Music", "搜索 Apple Music") }
  public var searching: String { text("Searching", "搜索中") }
  public var search: String { text("Search", "搜索") }
  public var playing: String { text("Playing", "播放中") }
  public var singBridgeMic: String { text("SingBridge Mic", "SingBridge 麦克风") }
  public var voiceLevel: String { text("Voice Level", "人声音量") }
  public var nearbyMacs: String { text("Nearby Macs", "附近的 Mac") }
  public var stopScan: String { text("Stop Scan", "停止扫描") }
  public var scan: String { text("Scan", "扫描") }
  public var macHost: String { text("Mac host", "Mac 主机") }
  public var start: String { text("Start", "开始") }
  public var unmute: String { text("Unmute", "取消静音") }
  public var mute: String { text("Mute", "静音") }
  public var monitor: String { text("Monitor", "监听") }
  public var inputGain: String { text("Input Gain", "输入增益") }
  public var mix: String { text("Mix", "混合") }
  public var dry: String { text("Dry", "干声") }
  public var wet: String { text("Wet", "湿声") }

  public func packets(received: Int, dropped: Int) -> String {
    switch language {
    case .english:
      "Packets: \(received) received, \(dropped) dropped"
    case .simplifiedChinese:
      "数据包：已接收 \(received)，已丢弃 \(dropped)"
    }
  }

  public func buffer(packetCount: Int) -> String {
    switch language {
    case .english:
      "Buffer: \(packetCount) packets"
    case .simplifiedChinese:
      "缓冲区：\(packetCount) 个数据包"
    }
  }

  public func latency(milliseconds: Int) -> String {
    switch language {
    case .english:
      "Latency: \(milliseconds) ms"
    case .simplifiedChinese:
      "延迟：\(milliseconds) 毫秒"
    }
  }

  public func offset(seconds: Double) -> String {
    switch language {
    case .english:
      String(format: "Offset: %.1fs", seconds)
    case .simplifiedChinese:
      String(format: "偏移：%.1f 秒", seconds)
    }
  }

  public func status(_ statusDescription: String) -> String {
    switch language {
    case .english:
      "Status: \(statusDescription)"
    case .simplifiedChinese:
      "状态：\(appleMusicAuthorizationStatus(statusDescription))"
    }
  }

  public func connectionState(_ state: ConnectionState) -> String {
    switch state {
    case .idle:
      text("Ready", "就绪")
    case .searching:
      text("Searching", "搜索中")
    case .connecting(let deviceName):
      switch language {
      case .english:
        "Connecting to \(deviceName)"
      case .simplifiedChinese:
        "正在连接 \(deviceName)"
      }
    case .connected(let deviceName, let latencyMilliseconds):
      switch language {
      case .english:
        "\(deviceName) - \(latencyMilliseconds) ms"
      case .simplifiedChinese:
        "\(deviceName) - \(latencyMilliseconds) 毫秒"
      }
    case .failed(let message):
      message
    }
  }

  public func diagnostics(_ diagnostics: ConnectionDiagnostics) -> (message: String, recommendation: String) {
    switch language {
    case .english:
      (diagnostics.message, diagnostics.recommendation)
    case .simplifiedChinese:
      switch diagnostics.health {
      case .idle:
        ("接收器空闲", "在 Mac 上点击“监听”，然后从手机连接。")
      case .poor where diagnostics.latencyMilliseconds == nil:
        ("连接失败", diagnostics.recommendation)
      case .poor:
        ("连接需要注意", "靠近 Wi-Fi，停止占用网络的其他应用，或降低扬声器音量以避免啸叫。")
      case .watch where diagnostics.latencyMilliseconds == nil:
        ("正在等待连接", "请保持两台设备在同一个 Wi-Fi 网络，并允许本地网络访问。")
      case .watch:
        ("连接可用", "如果演唱时感觉延迟，请靠近路由器或重新开始会话。")
      case .good:
        ("连接健康", "可以开始卡拉 OK。")
      }
    }
  }

  public var localAccompanimentNotice: String {
    text(
      "Apple Music support will use MusicKit-authorized catalog and playback features only.",
      "Apple Music 支持仅使用经 MusicKit 授权的曲库和播放功能。"
    )
  }

  public var importLyricsHint: String {
    text(
      "Import an LRC file to sync lyrics with local accompaniment.",
      "导入 LRC 文件，将歌词与本地伴奏同步。"
    )
  }

  public var appleMusicSafetyNotice: String {
    text(
      "Search uses MusicKit catalog metadata. Protected Apple Music audio is not extracted, transformed, recorded, or exported.",
      "搜索仅使用 MusicKit 曲库元数据。受保护的 Apple Music 音频不会被提取、转换、录制或导出。"
    )
  }

  public var microphoneReadyHint: String {
    text(
      "Microphone is ready to stream to your Mac.",
      "麦克风已准备好推流到 Mac。"
    )
  }

  public var startHint: String {
    text(
      "Tap start when your Mac receiver is open.",
      "打开 Mac 接收器后，点击开始。"
    )
  }

  public var noReceiverHint: String {
    text(
      "No receiver found yet. You can still enter a Mac host manually.",
      "尚未找到接收器。你仍然可以手动输入 Mac 主机。"
    )
  }

  private func appleMusicAuthorizationStatus(_ statusDescription: String) -> String {
    switch statusDescription {
    case "Authorized":
      "已授权"
    case "Denied":
      "已拒绝"
    case "Not requested":
      "尚未请求"
    case "Restricted":
      "受限制"
    case "MusicKit unavailable":
      "MusicKit 不可用"
    case "Unknown":
      "未知"
    default:
      statusDescription
    }
  }

  private func text(_ english: String, _ simplifiedChinese: String) -> String {
    switch language {
    case .english:
      english
    case .simplifiedChinese:
      simplifiedChinese
    }
  }
}
