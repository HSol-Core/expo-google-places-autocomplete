package expo.community.modules.googleplacesautocomplete

import android.content.Context
import com.google.android.libraries.places.api.Places
import com.google.android.libraries.places.api.model.AutocompleteSessionToken
import com.google.android.libraries.places.api.model.Place
import com.google.android.libraries.places.api.net.FetchPlaceRequest
import com.google.android.libraries.places.api.net.FindAutocompletePredictionsRequest
import com.google.android.libraries.places.api.net.PlacesClient
import expo.modules.kotlin.Promise
import expo.modules.kotlin.exception.Exceptions
import expo.modules.kotlin.modules.Module
import expo.modules.kotlin.modules.ModuleDefinition

class ExpoGooglePlacesAutocompleteModule : Module() {
    private val context: Context
        get() = appContext.reactContext ?: throw Exceptions.ReactContextLost()
    private lateinit var placesClient: PlacesClient
    private val token = AutocompleteSessionToken.newInstance()
    private val request =
        FindAutocompletePredictionsRequest.builder()
            .setSessionToken(token)

    override fun definition() = ModuleDefinition {
        Name("ExpoGooglePlacesAutocomplete")

        Function("initPlaces") { apiKey: String ->
            Places.initialize(context, apiKey)
            placesClient = Places.createClient(context)
        }

        AsyncFunction("findPlaces") { query: String, config: RequestConfig?, promise: Promise ->
            findPlaces(query, config, promise)
        }

        AsyncFunction("placeDetails") { placeId: String, promise: Promise ->
            placeDetails(placeId, promise)
        }
    }

    private fun findPlaces(query: String, config: RequestConfig?, promise: Promise) {
        request.query = query
        request.countries = config?.countries ?: emptyList()

        placesClient.findAutocompletePredictions(request.build())
            .addOnSuccessListener { response ->
                val places =
                    response.autocompletePredictions.map { mapFromPrediction(it) }
                val result = PredictionResult(places = places)
                promise.resolve(result)
            }
            .addOnFailureListener {
                promise.reject(
                    FailedToFetchPlace(it.message)
                )
            }
    }

    private fun placeDetails(placeId: String, promise: Promise) {
        // New Places API field enums (legacy NAME/LAT_LNG/ADDRESS/PHONE_NUMBER are
        // deprecated and removed in v6.0).
        val placeFields = listOf(
            Place.Field.ID,
            Place.Field.DISPLAY_NAME,
            Place.Field.LOCATION,
            Place.Field.FORMATTED_ADDRESS,
            Place.Field.ADDRESS_COMPONENTS,
            Place.Field.BUSINESS_STATUS,
            Place.Field.WEBSITE_URI,
            Place.Field.NATIONAL_PHONE_NUMBER
        )

        val request = FetchPlaceRequest.newInstance(placeId, placeFields)

        placesClient.fetchPlace(request)
            .addOnSuccessListener { response ->
                val place = mapFromPlace(response.place)
                promise.resolve(place)
            }
            .addOnFailureListener {
                promise.reject(
                    FailedToFetchDetails(it.message)
                )
            }
    }
}
