// swiftlint:disable all
import Amplify
import Foundation

public struct Place: Embeddable {
  var address: String
  var latitude: Double
  var longitude: Double
  var name: String
  var placeType: PlaceType
}