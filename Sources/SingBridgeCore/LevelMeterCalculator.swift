import Foundation

public enum LevelMeterCalculator {
  public static func float32LevelMeter(for payload: Data) -> LevelMeter {
    guard payload.count >= MemoryLayout<Float>.size else {
      return .silent
    }

    return payload.withUnsafeBytes { rawBuffer in
      let samples = rawBuffer.bindMemory(to: Float.self)
      guard !samples.isEmpty else { return .silent }

      var peak: Double = 0
      var sumOfSquares: Double = 0

      for sample in samples {
        let amplitude = Double(abs(sample))
        peak = max(peak, amplitude)
        sumOfSquares += amplitude * amplitude
      }

      let rms = sqrt(sumOfSquares / Double(samples.count))
      return LevelMeter(peak: peak, average: rms)
    }
  }
}
