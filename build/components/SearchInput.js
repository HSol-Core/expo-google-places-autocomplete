import * as React from "react";
import { View, TextInput, StyleSheet } from "react-native";
export const SearchInput = React.forwardRef(function Input({ inputValue, onChangeText, inputContainerStyle, style, ...props }, ref) {
    return (<View style={[styles.container, inputContainerStyle]}>
        <TextInput ref={ref} defaultValue={inputValue} onChangeText={onChangeText} style={[styles.textField, style]} {...props}/>
      </View>);
});
const styles = StyleSheet.create({
    container: {
        padding: 10,
        width: "100%",
        flexDirection: "row",
        alignItems: "center",
    },
    textField: {
        backgroundColor: "gainsboro",
        borderRadius: 5,
        flex: 1,
        padding: 10,
        fontSize: 18,
    },
});
//# sourceMappingURL=SearchInput.js.map