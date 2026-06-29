import type { Coordinate } from "./Coordinate";
/**
 * Represents the details of a place after it has been selected from the list of results
 */
export interface PlaceDetails {
    name?: string;
    placeId?: string;
    coordinate: Coordinate;
    formattedAddress?: string;
    addressComponents: string[];
    /** OPERATIONAL | CLOSED_TEMPORARILY | CLOSED_PERMANENTLY (undefined if unknown). */
    businessStatus?: string;
    /** The place's website, if Google has one. */
    websiteUri?: string;
    /** Phone number in the place's national format, if available. */
    nationalPhoneNumber?: string;
}
//# sourceMappingURL=PlaceDetails.d.ts.map