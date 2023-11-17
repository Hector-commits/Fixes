codeunit 50850 "Return color code"
{
    local procedure getHexCode(colourCode: Enum "Color Codes") hexCode: Code[7]
    var

    begin
        case colourCode of
            colourCode::"Alice Blue":
                hexCode := '#F0F8FF';
            colourCode::"Antique White":
                hexCode := '#FAEBD7';
            colourCode::"Aqua":
                hexCode := '#00FFFF';
            colourCode::"Aquamarine":
                hexCode := '#7FFFD4';
            colourCode::"Azure":
                hexCode := '#F0FFFF';
            colourCode::"Beige":
                hexCode := '#F5F5DC';
            colourCode::"Bisque":
                hexCode := '#FFE4C4';
            colourCode::"Black":
                hexCode := '#000000';
            colourCode::"Blanched Almond":
                hexCode := '#FFEBCD';
            colourCode::"Blue":
                hexCode := '#0000FF';
            colourCode::"Blue Violet":
                hexCode := '#8A2BE2';
            colourCode::"Brown":
                hexCode := '#A52A2A';
            colourCode::"Burlywood":
                hexCode := '#DEB887';
            colourCode::"Cadet Blue":
                hexCode := '#5F9EA0';
            colourCode::"Chartreuse":
                hexCode := '#7FFF00';
            colourCode::"Chocolate":
                hexCode := '#D2691E';
            colourCode::"Coral":
                hexCode := '#FF7F50';
            colourCode::"Cornflower Blue":
                hexCode := '#6495ED';
            colourCode::"Cornsilk":
                hexCode := '#FFF8DC';
            colourCode::"Crimson":
                hexCode := '#DC143C';
            colourCode::"Cyan":
                hexCode := '#00FFFF';
            colourCode::"Dark Blue":
                hexCode := '#00008B';
            colourCode::"Dark Cyan":
                hexCode := '#008B8B';
            colourCode::"Dark Goldenrod":
                hexCode := '#B8860B';
            colourCode::"Dark Gray":
                hexCode := '#A9A9A9';
            colourCode::"Dark Green":
                hexCode := '#006400';
            colourCode::"Dark Khaki":
                hexCode := '#BDB76B';
            colourCode::"Dark Magenta":
                hexCode := '#8B008B';
            colourCode::"Dark Olive Green":
                hexCode := '#556B2F';
            colourCode::"Dark Orange":
                hexCode := '#FF8C00';
            colourCode::"Dark Orchid":
                hexCode := '#9932CC';
            colourCode::"Dark Red":
                hexCode := '#8B0000';
            colourCode::"Dark Salmon":
                hexCode := '#E9967A';
            colourCode::"Dark Sea Green":
                hexCode := '#8FBC8F';
            colourCode::"Dark Slate Blue":
                hexCode := '#483D8B';
            colourCode::"Dark Slate Gray":
                hexCode := '#2F4F4F';
            colourCode::"Dark Turquoise":
                hexCode := '#00CED1';
            colourCode::"Dark Violet":
                hexCode := '#9400D3';
            colourCode::"Deep Pink":
                hexCode := '#FF1493';
            colourCode::"Deep Sky Blue":
                hexCode := '#00BFFF';
            colourCode::"Dim Gray":
                hexCode := '#696969';
            colourCode::"Dodger Blue":
                hexCode := '#1E90FF';
            colourCode::"Firebrick":
                hexCode := '#B22222';
            colourCode::"Floral White":
                hexCode := '#FFFAF0';
            colourCode::"Forest Green":
                hexCode := '#228B22';
            colourCode::"Fuchsia":
                hexCode := '#FF00FF';
            colourCode::"Gainsboro":
                hexCode := '#DCDCDC';
            colourCode::"Ghost White":
                hexCode := '#F8F8FF';
            colourCode::"Gold":
                hexCode := '#FFD700';
            colourCode::"Goldenrod":
                hexCode := '#DAA520';
            colourCode::"Gray":
                hexCode := '#808080';
            colourCode::"Green":
                hexCode := '#008000';
            colourCode::"Green Yellow":
                hexCode := '#ADFF2F';
            colourCode::"Honeydew":
                hexCode := '#F0FFF0';
            colourCode::"Hot Pink":
                hexCode := '#FF69B4';
            colourCode::"Indian Red":
                hexCode := '#CD5C5C';
            colourCode::"Indigo":
                hexCode := '#4B0082';
            colourCode::"Ivory":
                hexCode := '#FFFFF0';
            colourCode::"Khaki":
                hexCode := '#F0E68C';
            colourCode::"Lavender":
                hexCode := '#E6E6FA';
            colourCode::"Lavender Blush":
                hexCode := '#FFF0F5';
            colourCode::"Lawn Green":
                hexCode := '#7CFC00';
            colourCode::"Lemon Chiffon":
                hexCode := '#FFFACD';
            colourCode::"Light Blue":
                hexCode := '#ADD8E6';
            colourCode::"Light Coral":
                hexCode := '#F08080';
            colourCode::"Light Cyan":
                hexCode := '#E0FFFF';
            colourCode::"Light Goldenrod Yellow":
                hexCode := '#FAFAD2';
            colourCode::"Light Green":
                hexCode := '#90EE90';
            colourCode::"Light Grey":
                hexCode := '#D3D3D3';
            colourCode::"Light Pink":
                hexCode := '#FFB6C1';
            colourCode::"Light Salmon":
                hexCode := '#FFA07A';
            colourCode::"Light Sea Green":
                hexCode := '#20B2AA';
            colourCode::"Light Sky Blue":
                hexCode := '#87CEFA';
            colourCode::"Light Slate Gray":
                hexCode := '#778899';
            colourCode::"Light Steel Blue":
                hexCode := '#B0C4DE';
            colourCode::"Light Yellow":
                hexCode := '#FFFFE0';
            colourCode::"Lime":
                hexCode := '#00FF00';
            colourCode::"Lime Green":
                hexCode := '#32CD32';
            colourCode::"Linen":
                hexCode := '#FAF0E6';
            colourCode::"Magenta":
                hexCode := '#FF00FF';
            colourCode::"Maroon":
                hexCode := '#800000';
            colourCode::"Medium Aquamarine":
                hexCode := '#66CDAA';
            colourCode::"Medium Blue":
                hexCode := '#0000CD';
            colourCode::"Medium Orchid":
                hexCode := '#BA55D3';
            colourCode::"Medium Purple":
                hexCode := '#9370DB';
            colourCode::"Medium Sea Green":
                hexCode := '#3CB371';
            colourCode::"Medium Slate Blue":
                hexCode := '#7B68EE';
            colourCode::"Medium Spring Green":
                hexCode := '#00FA9A';
            colourCode::"Medium Turquoise":
                hexCode := '#48D1CC';
            colourCode::"Medium Violet Red":
                hexCode := '#C71585';
            colourCode::"Midnight Blue":
                hexCode := '#191970';
            colourCode::"Mint Cream":
                hexCode := '#F5FFFA';
            colourCode::"Misty Rose":
                hexCode := '#FFE4E1';
            colourCode::"Moccasin":
                hexCode := '#FFE4B5';
            colourCode::"Navajo White":
                hexCode := '#FFDEAD';
            colourCode::"Navy":
                hexCode := '#000080';
            colourCode::"Old Lace":
                hexCode := '#FDF5E6';
            colourCode::"Olive Drab":
                hexCode := '#6B8E23';
            colourCode::"Orange":
                hexCode := '#FFA500';
            colourCode::"Orange Red":
                hexCode := '#FF4500';
            colourCode::"Orchid":
                hexCode := '#DA70D6';
            colourCode::"Pale Goldenrod":
                hexCode := '#EEE8AA';
            colourCode::"Pale Green":
                hexCode := '#98FB98';
            colourCode::"Pale Turquoise":
                hexCode := '#AFEEEE';
            colourCode::"Pale Violet Red":
                hexCode := '#DB7093';
            colourCode::"Papaya Whip":
                hexCode := '#FFEFD5';
            colourCode::"Peach Puff":
                hexCode := '#FFDAB9';
            colourCode::"Peru":
                hexCode := '#CD853F';
            colourCode::"Pink":
                hexCode := '#FFC0CB';
            colourCode::"Plum":
                hexCode := '#DDA0DD';
            colourCode::"Powder Blue":
                hexCode := '#B0E0E6';
            colourCode::"Purple":
                hexCode := '#800080';
            colourCode::"Red":
                hexCode := '#FF0000';
            colourCode::"Rosy Brown":
                hexCode := '#BC8F8F';
            colourCode::"Royal Blue":
                hexCode := '#4169E1';
            colourCode::"Saddle Brown":
                hexCode := '#8B4513';
            colourCode::"Salmon":
                hexCode := '#FA8072';
            colourCode::"Sandy Brown":
                hexCode := '#F4A460';
            colourCode::"Sea Green":
                hexCode := '#2E8B57';
            colourCode::"Sea Shell":
                hexCode := '#FFF5EE';
            colourCode::"Sienna":
                hexCode := '#A0522D';
            colourCode::"Silver":
                hexCode := '#C0C0C0';
            colourCode::"Sky Blue":
                hexCode := '#87CEEB';
            colourCode::"Slate Blue":
                hexCode := '#6A5ACD';
            colourCode::"Snow":
                hexCode := '#FFFAFA';
            colourCode::"Spring Green":
                hexCode := '#00FF7F';
            colourCode::"Steel Blue":
                hexCode := '#4682B4';
            colourCode::"Tan":
                hexCode := '#D2B48C';
            colourCode::"Thistle":
                hexCode := '#D8BFD8';
            colourCode::"Teal":
                hexCode := '#008080';
            colourCode::"Tomato":
                hexCode := '#FF6347';
            colourCode::"Turquoise":
                hexCode := '#40E0D0';
            colourCode::"Violet":
                hexCode := '#EE82EE';
            colourCode::"Wheat":
                hexCode := '#F5DEB3';
            colourCode::"White":
                hexCode := '#FFFFFF';
            colourCode::"White Smoke":
                hexCode := '#F5F5F5';
            colourCode::"Yellow":
                hexCode := '#FFFF00';
            colourCode::"Yellow Green":
                hexCode := '#9ACD32';
        end;
    end;
}