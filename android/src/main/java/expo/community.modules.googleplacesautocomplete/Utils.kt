package expo.community.modules.googleplacesautocomplete

import com.google.android.gms.maps.model.LatLng
import com.google.android.libraries.places.api.model.AutocompletePrediction
import com.google.android.libraries.places.api.model.Place

internal fun mapFromPlace(place: Place) = DiscoveredPlace(
    // New Places API getters (legacy name/latLng/address/phoneNumber are deprecated).
    name = place.displayName,
    placeId = place.id,
    coordinate = mapFromCoordinate(place.location),
    formattedAddress = place.formattedAddress,
    addressComponents = place.addressComponents?.asList()?.map { it.name } ?: emptyList(),
    // BusinessStatus enum name matches the Web API strings (OPERATIONAL / CLOSED_TEMPORARILY / CLOSED_PERMANENTLY)
    businessStatus = place.businessStatus?.name,
    websiteUri = place.websiteUri?.toString(),
    nationalPhoneNumber = place.nationalPhoneNumber
)

internal fun mapFromCoordinate(coordinate: LatLng?) = Coordinate(
    latitude = coordinate?.latitude ?: 0.0,
    longitude = coordinate?.longitude ?: 0.0
)

internal fun mapFromPrediction(prediction: AutocompletePrediction) = PlaceDetails(
    primaryText = prediction.getPrimaryText(null).toString(),
    secondaryText = prediction.getSecondaryText(null).toString(),
    fullText = prediction.getFullText(null).toString(),
    placeId = prediction.placeId,
    distance = prediction.distanceMeters,
    types = prediction.placeTypes.map { it.name }
)







