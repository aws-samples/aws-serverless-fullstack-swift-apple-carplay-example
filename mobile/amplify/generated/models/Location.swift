// swiftlint:disable all
import Amplify
import Foundation

public struct Location: Embeddable {
  var name: String
  var latitude: Double
  var longitude: Double
}