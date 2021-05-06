// swiftlint:disable all
import Amplify
import Foundation

public struct Place: Embeddable {
  var placeType: PlaceType
  var name: String
  var address: String
  var latitude: Double
  var longitude: Double
}