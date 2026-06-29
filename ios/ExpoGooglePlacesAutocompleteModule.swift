import ExpoModulesCore
import GooglePlaces

public class ExpoGooglePlacesAutocompleteModule: Module {
  public func definition() -> ModuleDefinition {
    Name("ExpoGooglePlacesAutocomplete")

    Function("initPlaces") { (apiKey: String) in
      // provideAPIKey touches main-thread-only state; calling it synchronously on
      // the JS thread (New Architecture) raised an Obj-C exception surfacing as
      // "Exception in HostFunction". Hop to main; the JS Function still returns
      // immediately.
      DispatchQueue.main.async {
        GMSPlacesClient.provideAPIKey(apiKey)
      }
    }

    // New Places API: fetchAutocompleteSuggestions(from:) replaces the deprecated
    // GMSAutocompleteFetcher.
    AsyncFunction("findPlaces") { (query: String, config: RequestConfig?, promise: Promise) in
      let filter = GMSAutocompleteFilter()
      if let countries = config?.countries, !countries.isEmpty {
        filter.countries = countries
      }
      let request = GMSAutocompleteRequest(query: query)
      request.filter = filter

      GMSPlacesClient.shared().fetchAutocompleteSuggestions(from: request) { suggestions, error in
        if let error {
          promise.reject(error)
          return
        }
        let places = (suggestions ?? []).compactMap { Mappers.mapFromSuggestion($0) }
        promise.resolve(["places": places])
      }
    }.runOnQueue(.main)

    // New Places API: fetchPlace(with:) + GMSFetchPlaceRequest replace the
    // deprecated fetchPlace(fromPlaceID:placeFields:sessionToken:callback:).
    AsyncFunction("placeDetails") { (id: String, promise: Promise) in
      let properties: [String] = [
        GMSPlacePropertyPlaceID,
        GMSPlacePropertyName,
        GMSPlacePropertyCoordinate,
        GMSPlacePropertyFormattedAddress,
        GMSPlacePropertyAddressComponents,
        GMSPlacePropertyBusinessStatus,
        GMSPlacePropertyWebsite,
        GMSPlacePropertyPhoneNumber,
      ]
      let request = GMSFetchPlaceRequest(placeID: id, placeProperties: properties)

      GMSPlacesClient.shared().fetchPlace(with: request) { place, error in
        if let error {
          promise.reject(error)
          return
        }
        if let place {
          promise.resolve(Mappers.mapFromPlace(place: place))
        } else {
          promise.resolve()
        }
      }
    }.runOnQueue(.main)
  }
}
