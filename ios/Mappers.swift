import GooglePlaces

struct Mappers {

  static func mapFromPlace(place: GMSPlace) -> [String: Any?] {
    [
      "name": place.name,
      "placeId": place.placeID,
      "coordinate": Mappers.mapFromCoordinate(coordinate: place.coordinate),
      "formattedAddress": place.formattedAddress,
      "addressComponents": place.addressComponents.map({ comp in
        comp.map {
          $0.name
        }
      }) ?? [],
      "businessStatus": Mappers.mapFromBusinessStatus(place.businessStatus),
      "websiteUri": place.website?.absoluteString,
      "nationalPhoneNumber": place.phoneNumber
    ]
  }

  static func mapFromBusinessStatus(_ status: GMSPlacesBusinessStatus) -> String? {
    switch status {
    case .operational: return "OPERATIONAL"
    case .closedTemporarily: return "CLOSED_TEMPORARILY"
    case .closedPermanently: return "CLOSED_PERMANENTLY"
    default: return nil
    }
  }

  static func mapFromCoordinate(coordinate: CLLocationCoordinate2D) -> [String: Any] {
    [
      "latitude": coordinate.latitude,
      "longitude": coordinate.longitude
    ]
  }

  // New Places API autocomplete: each GMSAutocompleteSuggestion wraps a
  // GMSPlaceSuggestion. Shapes the same dict the JS PlaceDetails/Place expects.
  static func mapFromSuggestion(_ suggestion: GMSAutocompleteSuggestion) -> [String: Any]? {
    guard let p = suggestion.placeSuggestion else { return nil }
    return [
      // attributedPrimaryText / attributedFullText are non-optional NSAttributedString
      // in the New Places API; only attributedSecondaryText is nullable.
      "primaryText": p.attributedPrimaryText.string,
      "secondaryText": p.attributedSecondaryText?.string ?? "",
      "fullText": p.attributedFullText.string,
      "placeId": p.placeID,
      "distance": p.distanceMeters ?? NSNull(),
      "types": p.types
    ]
  }
}
