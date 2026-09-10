: "${THEME_FILE:?}" "${FONT_TTF:?}" "${WIKI_URL:?}" "${out:?}"

get() { sed -n "s/^[[:space:]]*$1:[[:space:]]*\"\\(#[0-9a-fA-F]\\{6\\}\\)\".*/\\1/p" "$THEME_FILE"; }
b00=$(get base00)
b03=$(get base03)
b05=$(get base05)
b07=$(get base07)
b08=$(get base08)
b0A=$(get base0A)
b0B=$(get base0B)
b0C=$(get base0C)
b0D=$(get base0D)
b0E=$(get base0E)

mkdir -p "$out"

# termux
cat >"$out/colors.properties" <<EOF
background=${b00}
foreground=${b05}
cursor=${b05}
color0=${b00}
color1=${b08}
color2=${b0B}
color3=${b0A}
color4=${b0D}
color5=${b0E}
color6=${b0C}
color7=${b05}
color8=${b03}
color9=${b08}
color10=${b0B}
color11=${b0A}
color12=${b0D}
color13=${b0E}
color14=${b0C}
color15=${b07}
EOF

# blink
cat >"$out/carbonfox.js" <<EOF
t.prefs_.set('color-palette-overrides', [
  '${b00}', '${b08}', '${b0B}', '${b0A}', '${b0D}', '${b0E}', '${b0C}', '${b05}',
  '${b03}', '${b08}', '${b0B}', '${b0A}', '${b0D}', '${b0E}', '${b0C}', '${b07}'
]);
t.prefs_.set('foreground-color', '${b05}');
t.prefs_.set('background-color', '${b00}');
t.prefs_.set('cursor-color', '${b05}');
t.prefs_.set('cursor-blink', false);
EOF

cat >"$out/font.css" <<EOF
@font-face {
  font-family: "Hack Nerd Font Mono";
  font-style: normal;
  font-weight: 400;
  src: url(${WIKI_URL}/phone/font.ttf) format("truetype");
}
EOF

cp "$FONT_TTF" "$out/font.ttf"
