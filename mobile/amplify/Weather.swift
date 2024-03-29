// swiftlint:disable all
import Amplify
import Foundation

public struct Weather: Embeddable {
  var aqIndex: Double
  var latitude: Double
  var longitude: Double
  var temperature: Double
}