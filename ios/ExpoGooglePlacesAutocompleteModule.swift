import ExpoModulesCore
import GooglePlaces

public class ExpoGooglePlacesAutocompleteModule: Module {
  // The API key is STORED on initPlaces and the GMS client is provisioned lazily,
  // on the main queue, immediately before the first sharedClient use. This fixes
  // two crashes:
  //   1. New Architecture: calling GMSPlacesClient.provideAPIKey synchronously on
  //      the JS thread from initPlaces threw "Exception in HostFunction". initPlaces
  //      now only stores a String (no GMS call), so it's safe to call synchronously.
  //   2. Init race: previously provideAPIKey was dispatched to main async from
  //      initPlaces, and findPlaces could reach +[GMSPlacesClient sharedClient]
  //      before that block ran → GMSPlacesException "must be initialized via
  //      provideAPIKey prior to use" (crash on the 3rd typed character). Providing
  //      the key on the same main-queue hop right before sharedClient removes the
  //      race; a missing key now rejects gracefully instead of crashing.
  private var apiKey: String?
  private var keyProvided = false

  /// Provision GMS with the stored key exactly once. MUST run on the main queue
  /// (callers below are `.runOnQueue(.main)`). Returns false if no key was set.
  private func provideKeyIfNeeded() -> Bool {
    if keyProvided { return true }
    guard let key = apiKey, !key.isEmpty else { return false }
    GMSPlacesClient.provideAPIKey(key)
    keyProvided = true
    return true
  }

  public func definition() -> ModuleDefinition {
    Name("ExpoGooglePlacesAutocomplete")

    // Store the key only — no GMS call here (avoids the New-Arch synchronous-call
    // crash). Idempotent; safe to call on every screen mount.
    Function("initPlaces") { (apiKey: String) in
      self.apiKey = apiKey
    }

    AsyncFunction("findPlaces") { (query: String, config: RequestConfig?, promise: Promise) in
      guard self.provideKeyIfNeeded() else {
        promise.reject("ERR_PLACES_NOT_INITIALIZED",
                       "Google Places is not initialized — call initPlaces with a valid API key first.")
        return
      }
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

    AsyncFunction("placeDetails") { (id: String, promise: Promise) in
      guard self.provideKeyIfNeeded() else {
        promise.reject("ERR_PLACES_NOT_INITIALIZED",
                       "Google Places is not initialized — call initPlaces with a valid API key first.")
        return
      }
      let properties: [GMSPlaceProperty] = [
        .placeID,
        .name,
        .coordinate,
        .formattedAddress,
        .addressComponents,
        .businessStatus,
        .website,
        .phoneNumber,
      ]
      // GMSFetchPlaceRequest's designated init takes the property keys as their
      // underlying String rawValues and a (nullable) billing session token.
      let request = GMSFetchPlaceRequest(
        placeID: id,
        placeProperties: properties.map { $0.rawValue },
        sessionToken: nil
      )

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
