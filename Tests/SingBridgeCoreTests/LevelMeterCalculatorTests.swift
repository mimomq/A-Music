import Foundation
import XCTest
@testable import SingBridgeCore

final class LevelMeterCalculatorTests: XCTestCase {
  func testComputesPeakAndAverageFromFloat32Payload() {
    var samples: [Float] = [0, -0.5, 1, 0.5]
    let data = Data(bytes: &samples, count: samples.count * MemoryLayout<Float>.size)

    let level = LevelMeterCalculator.float32LevelMeter(for: data)

    XCTAssertEqual(level.peak, 1, accuracy: 0.0001)
    XCTAssertEqual(level.average, sqrt(0.375), accuracy: 0.0001)
  }
}
