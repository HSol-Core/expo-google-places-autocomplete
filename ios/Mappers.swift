import GooglePlaces

struct Mappers {

  // GMS declares many of these properties nonnull, but the Obj-C runtime can
  // still hand back nil at runtime. Reading a nonnull-that's-nil via the Swift
  // property accessor TRAPS — and in optimized Release builds it crashes hard
  // (this is the "Places search crashes on the 3rd character" bug). KVC
  // (`value(forKey:)`) returns an Optional safely, so a missing field degrades
  // to a default instead of crashing. These helpers funnel every potentially-nil
  // read through KVC.
  private static func string(_ obj: NSObject, _ key: String) -> String? {
    obj.value(forKey: key) as? String
  }
  private static func attrString(_ obj: NSObject, _ key: String) -> String? {
    (obj.value(forKey: key) as? NSAttributedString)?.string
  }

  static func mapFromPlace(place: GMSPlace) -> [String: Any?] {
    let components = (place.value(forKey: "addressComponents") as? [GMSAddressComponent]) ?? []
    return [
      "name": Mappers.string(place, "name"),
      "placeId": Mappers.string(place, "placeID"),
      "coordinate": Mappers.mapFromCoordinate(coordinate: place.coordinate),
      "formattedAddress": Mappers.string(place, "formattedAddress"),
      "addressComponents": components.compactMap { $0.value(forKey: "name") as? String },
      "businessStatus": Mappers.mapFromBusinessStatus(place.businessStatus),
      "websiteUri": (place.value(forKey: "website") as? URL)?.absoluteString,
      "nationalPhoneNumber": Mappers.string(place, "phoneNumber")
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
  // GMSAutocompletePlaceSuggestion. All reads are nil-safe (see note above).
  static func mapFromSuggestion(_ suggestion: GMSAutocompleteSuggestion) -> [String: Any]? {
    guard let p = suggestion.placeSuggestion else { return nil }
    guard let placeId = Mappers.string(p, "placeID"), !placeId.isEmpty else { return nil }
    return [
      "primaryText": Mappers.attrString(p, "attributedPrimaryText") ?? "",
      "secondaryText": Mappers.attrString(p, "attributedSecondaryText") ?? "",
      "fullText": Mappers.attrString(p, "attributedFullText") ?? "",
      "placeId": placeId,
      "distance": (p.value(forKey: "distanceMeters") as? NSNumber) ?? NSNull(),
      "types": (p.value(forKey: "types") as? [String]) ?? []
    ]
  }
}
