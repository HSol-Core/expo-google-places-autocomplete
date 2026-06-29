import * as React from "react";
import type { TextInputProps, ViewStyle } from "react-native";
import { TextInput } from "react-native";
interface SearchInputProps extends TextInputProps {
    inputValue: string;
    inputContainerStyle?: ViewStyle;
    onChangeText: (text: string) => void;
}
export declare const SearchInput: React.ForwardRefExoticComponent<SearchInputProps & React.RefAttributes<TextInput>>;
export {};
//# sourceMappingURL=SearchInput.d.ts.map