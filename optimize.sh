#!/bin/bash
# optimize.sh
# Modify index.html to use WebP thumbnails with fallback to original images

set -e

# Configuration
INDEX_FILE="index.html"
THUMB_DIR="thumbnails"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=== HTML Optimizer for WebP Thumbnails ==="
echo ""

# Check if index.html exists
if [ ! -f "$INDEX_FILE" ]; then
    echo "ERROR: File $INDEX_FILE not found!"
    exit 1
fi

# Check if thumbnails directory exists
if [ ! -d "$THUMB_DIR" ]; then
    echo "ERROR: Thumbnails directory $THUMB_DIR not found!"
    echo "Please run ./generate-thumbnails.sh first"
    exit 1
fi

# Extract all images from index.html that should use thumbnails
images=$(grep -oP 'src="\K[^"]*ressources/[^"]*\.(jpg|png|JPG|PNG)(?=")' "$INDEX_FILE" | sort -u)

if [ -z "$images" ]; then
    echo "WARNING: No images found in $INDEX_FILE"
    exit 0
fi

total_images=$(echo "$images" | wc -l)
echo "Images found: $total_images"
echo ""

# Function to convert img tag to picture tag with WebP
convert_to_picture() {
    local img_src
    local basename
    local filename
    local thumb_webp
    local img_src_escaped
    local thumb_webp_escaped

    img_src="$1"
    basename=$(basename "$img_src")
    filename="${basename%.*}"
    thumb_webp="$THUMB_DIR/${filename}_thumb.webp"

    # Check if thumbnail exists
    if [ ! -f "$thumb_webp" ]; then
        echo -e "${YELLOW}WARNING: Thumbnail not found: $thumb_webp${NC}"
        return 1
    fi

    # Check if this image is already wrapped in a <picture> tag
    # Look for pattern: <picture>...<img src="img_src"...>...</picture>
    if grep -q "<picture>.*<img src=\"${img_src}\"" "$INDEX_FILE"; then
        echo -e "SKIP: Already optimized: $img_src"
        return 2
    fi

    echo -e "${BLUE}Processing:${NC} $img_src -> $thumb_webp"

    # Escape special characters for sed
    img_src_escaped=$(echo "$img_src" | sed 's/[\/&]/\\&/g')
    thumb_webp_escaped=$(echo "$thumb_webp" | sed 's/[\/&]/\\&/g')

    # Replace <img src="ORIGINAL"> with <picture><source srcset="THUMB.webp" type="image/webp"><img src="ORIGINAL">
    # This preserves all img attributes (class, alt, etc.)
    sed -i "s/<img src=\"${img_src_escaped}\"/<picture><source srcset=\"${thumb_webp_escaped}\" type=\"image\/webp\"><img src=\"${img_src_escaped}\"/g" "$INDEX_FILE"

    # Close the picture tag after the img tag
    # Find lines with our converted img and add </picture> after them
    sed -i "s/\(<img src=\"${img_src_escaped}\"[^>]*>\)/\1<\/picture>/g" "$INDEX_FILE"

    return 0
}

# Process each image
converted=0
already_optimized=0
skipped=0

while IFS= read -r img; do
    result=0
    convert_to_picture "$img" || result=$?

    case $result in
        0)
            converted=$((converted + 1))
            ;;
        2)
            already_optimized=$((already_optimized + 1))
            ;;
        *)
            skipped=$((skipped + 1))
            ;;
    esac
done <<< "$images"

echo ""
echo "=================================="
echo -e "${GREEN}Optimization complete!${NC}"
echo ""
echo "Summary:"
echo "   Total images: $total_images"
echo "   Converted to picture tags: $converted"
echo "   Already optimized (skipped): $already_optimized"
echo "   Missing thumbnail (skipped): $skipped"
