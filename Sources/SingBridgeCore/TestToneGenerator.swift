import Foundation

public enum TestToneGenerator {
  public static func float32SineWavePayload(
    frequency: Double = 440,
    duration: TimeInterval,
    sampleRate: Double = 48_000,
    amplitude: Float = 0.25
  ) -> Data {
    guard duration > 0, sampleRate > 0, frequency > 0 else {
      return Data()
    }

    let sampleCount = max(1, Int(duration * sampleRate))
    var samples = [Float](repeating: 0, count: sampleCount)

    for index in 0..<sampleCount {
      let phase = 2 * Double.pi * frequency * Double(index) / sampleRate
      samples[index] = sin(Float(phase)) * amplitude
    }

    return samples.withUnsafeBufferPointer { Data(buffer: $0) }
  }

  public static func packets(
    duration: TimeInterval = 1,
    packetDuration: TimeInterval = 0.02,
    sampleRate: Double = 48_000,
    frequency: Double = 440,
    startSequenceNumber: UInt64 = 0,
    startTimestampNanoseconds: UInt64 = 0
  ) -> [AudioPacket] {
    guard duration > 0, packetDuration > 0 else { return [] }

    let packetCount = max(1, Int((duration / packetDuration).rounded(.up)))
    return (0..<packetCount).map { index in
      let payload = float32SineWavePayload(
        frequency: frequency,
        duration: packetDuration,
        sampleRate: sampleRate
      )
      return AudioPacket(
        sequenceNumber: startSequenceNumber + UInt64(index),
        sentAtNanoseconds: startTimestampNanoseconds + UInt64(Double(index) * packetDuration * 1_000_000_000),
        payload: payload
      )
    }
  }
}
