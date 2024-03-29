// swiftlint:disable all
import Amplify
import Foundation

extension Weather {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case aqIndex
    case latitude
    case longitude
    case temperature
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let weather = Weather.keys
    
    model.listPluralName = "Weathers"
    model.syncPluralName = "Weathers"
    
    model.fields(
      .field(weather.aqIndex, is: .required, ofType: .double),
      .field(weather.latitude, is: .required, ofType: .double),
      .field(weather.longitude, is: .required, ofType: .double),
      .field(weather.temperature, is: .required, ofType: .double)
    )
    }
}