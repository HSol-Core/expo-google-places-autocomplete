import { Place, PlaceDetails } from "./types";
import { RequestConfig } from "./types/RequestConfig";
interface ExpoGooglePlacesAutocompleteModule {
    initPlaces: (apikey: string) => void;
    findPlaces: (query: string, config?: RequestConfig) => Promise<{
        places: Place[];
    }>;
    placeDetails: (placeId: String) => Promise<PlaceDetails>;
}
declare const _default: ExpoGooglePlacesAutocompleteModule;
export default _default;
//# sourceMappingURL=ExpoGooglePlacesAutocompleteModule.d.ts.map