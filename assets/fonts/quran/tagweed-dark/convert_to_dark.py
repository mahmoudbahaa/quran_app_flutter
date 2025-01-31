from fontTools import ttLib
import time

# Load the font file (replace 'your_font.otf' with the path to your font)
cur = round(time.time())
for i in range(1,605):
    ms = round(time.time()) - cur
    print(f'elpased: {ms} converting page {i}')
    font = ttLib.TTFont(f'org/p{i}.woff2')
    cpal = font['CPAL']
    defaultPalette = cpal.palettes[0]
    newDefaultPalette = cpal.palettes[1]
    cpal.palettes[0] = newDefaultPalette
    cpal.palettes[1] = defaultPalette
    font.save(f'converted_woff2/4_{i}.woff2')
    ttLib.woff2.decompress(f'converted_woff2/4_{i}.woff2', f'converted_ttf/4_{i}_dark.ttf')