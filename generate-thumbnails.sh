#!/bin/bash
# generate-thumbnails.sh
# Parse index.html and generate missing WebP thumbnails

set -e

# Configuration
INDEX_FILE="index.html"
THUMB_DIR="ressources/thumbnails"
THUMB_WIDTH=800
WEBP_QUALITY=85
FORCE=false

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -f|--force)
            FORCE=true
            shift
            ;;
        *)
            shift
            ;;
    esac
done

echo "=== Smart WebP Thumbnail Generator ==="
echo ""

# Check ImageMagick
if ! command -v convert &> /dev/null; then
    echo "ERROR: ImageMagick is not installed!"
    echo "Installation: sudo apt install imagemagick"
    exit 1
fi

# Check index.html
if [ ! -f "$INDEX_FILE" ]; then
    echo "ERROR: File $INDEX_FILE not found!"
    exit 1
fi

echo "Analyzing $INDEX_FILE..."

# Create thumbnails directory if it doesn't exist
mkdir -p "$THUMB_DIR"
echo "Thumbnail directory: $THUMB_DIR/"
echo ""

# Extract all images referenced in index.html
# Look for src="ressources/..." with jpg, jpeg, png (case-insensitive)
images=$(grep -oP 'src="\K[^"]*ressources/[^"]*\.(?i:jpg|jpeg|png)(?=")' "$INDEX_FILE" | sort -u)

if [ -z "$images" ]; then
    echo "WARNING: No images found in $INDEX_FILE"
    exit 0
fi

# Count images
total_images=$(echo "$images" | wc -l)
echo "Images found: $total_images"
echo ""

# Thumbnail generation function
generate_thumb() {
    local input
    local basename
    local filename
    local output

    input="$1"
    basename=$(basename "$input")
    filename="${basename%.*}"
    output="$THUMB_DIR/${filename}_thumb.webp"

    # Check if source file exists
    if [ ! -f "$input" ]; then
        echo -e "${YELLOW}WARNING: Source file not found:${NC} $input"
        return 1
    fi

    # Check if thumbnail already exists
    if [ -f "$output" ] && [ "$FORCE" = false ]; then
        echo -e "SKIP: Already exists: $output"
        return 0
    fi

    echo -e "${BLUE}Generating:${NC} $input"

    # Get original size
    if command -v stat &> /dev/null; then
        orig_size=$(stat -c%s "$input" 2>/dev/null || stat -f%z "$input" 2>/dev/null || echo 0)
        [ "$orig_size" -gt 0 ] && echo "   Original: $((orig_size / 1024)) KB"
    fi

    # WebP conversion with ImageMagick
    convert "$input" \
            -resize "${THUMB_WIDTH}x${THUMB_WIDTH}>" \
            -strip \
            -quality "$WEBP_QUALITY" \
            "$output"

    # Get thumbnail size
    if command -v stat &> /dev/null; then
        thumb_size=$(stat -c%s "$output" 2>/dev/null || stat -f%z "$output" 2>/dev/null || echo 0)
        if [ "$thumb_size" -gt 0 ]; then
            echo "   Thumbnail: $((thumb_size / 1024)) KB"
            if [ "$orig_size" -gt 0 ]; then
                saved=$((100 - thumb_size * 100 / orig_size))
                echo "   Saved: ${saved}%"
            fi
        fi
    fi

    echo -e "${GREEN}SUCCESS: Created: $output${NC}"
    echo ""
}

# Counters
generated=0
skipped=0
errors=0

# Process each image
while IFS= read -r img; do
    basename=$(basename "$img")
    filename="${basename%.*}"
    thumb_path="$THUMB_DIR/${filename}_thumb.webp"

    # Check if thumbnail existed before processing
    existed_before=false
    [ -f "$thumb_path" ] && existed_before=true

    if generate_thumb "$img"; then
        # Check if it was skipped (existed before) or newly created
        if [ "$existed_before" = true ]; then
            skipped=$((skipped + 1))
        elif [ -f "$thumb_path" ]; then
            generated=$((generated + 1))
        fi
    else
        errors=$((errors + 1))
    fi
done <<< "$images"

# Summary
echo "=================================="
echo "Generation complete!"
echo ""
echo "Summary:"
echo "   Total images in index.html: $total_images"
echo "   Thumbnails generated: $generated"
echo "   Already existing (skipped): $skipped"
[ $errors -gt 0 ] && echo -e "${RED}   Errors: $errors${NC}"
echo ""
echo "Thumbnails available:"
find "$THUMB_DIR" -name "*_thumb.webp" -type f 2>/dev/null | while read -r f; do
    size=$(stat -c%s "$f" 2>/dev/null || stat -f%z "$f" 2>/dev/null || echo 0)
    echo "   - $f ($((size / 1024)) KB)"
done

echo ""
echo "Next step: use optimize.sh to modify index.html to use WebP thumbnails"
