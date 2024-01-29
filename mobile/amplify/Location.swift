// swiftlint:disable all
import Amplify
import Foundation

public struct Location: Embeddable {
  var latitude: Double
  var longitude: Double
  var name: String
}