#!/bin/bash
#
# resize_screenshots.sh
# Resizes iPhone simulator screenshots to App Store requirements
#
# Usage: ./resize_screenshots.sh [input_directory]
#

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Input directory (default to current directory)
INPUT_DIR="${1:-.}"

# Output directory
OUTPUT_DIR="${INPUT_DIR}/AppStore_Screenshots"

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  App Store Screenshot Resizer${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Counter
count=0

# Find and process all PNG screenshots
echo -e "${BLUE}Searching for screenshots in:${NC} $INPUT_DIR"
echo ""

for file in "$INPUT_DIR"/Screenshot*.png; do
    # Check if file exists (handles case where no matches found)
    if [ ! -f "$file" ]; then
        continue
    fi
    
    filename=$(basename "$file")
    
    # Get current dimensions
    current_size=$(sips -g pixelWidth -g pixelHeight "$file" | grep -E "pixelWidth|pixelHeight" | awk '{print $2}' | tr '\n' 'x' | sed 's/x$//')
    
    echo -e "${BLUE}Processing:${NC} $filename"
    echo -e "  Current size: $current_size"
    
    # Check if it's a portrait iPhone 15 Pro Max screenshot
    if [[ "$current_size" == "1290x2796" ]]; then
        # Resize to App Store requirement
        output_file="$OUTPUT_DIR/${filename%.png}_1284x2778.png"
        sips -z 2778 1284 "$file" --out "$output_file" > /dev/null 2>&1
        
        if [ $? -eq 0 ]; then
            echo -e "  ${GREEN}✓ Resized to: 1284 × 2778${NC}"
            echo -e "  Saved as: $(basename "$output_file")"
            ((count++))
        else
            echo -e "  ${RED}✗ Failed to resize${NC}"
        fi
    elif [[ "$current_size" == "2796x1290" ]]; then
        # Landscape orientation
        output_file="$OUTPUT_DIR/${filename%.png}_2778x1284.png"
        sips -z 1284 2778 "$file" --out "$output_file" > /dev/null 2>&1
        
        if [ $? -eq 0 ]; then
            echo -e "  ${GREEN}✓ Resized to: 2778 × 1284${NC}"
            echo -e "  Saved as: $(basename "$output_file")"
            ((count++))
        else
            echo -e "  ${RED}✗ Failed to resize${NC}"
        fi
    elif [[ "$current_size" == "1284x2778" ]] || [[ "$current_size" == "2778x1284" ]]; then
        # Already correct size - just copy
        output_file="$OUTPUT_DIR/$filename"
        cp "$file" "$output_file"
        echo -e "  ${GREEN}✓ Already correct size - copied${NC}"
        ((count++))
    else
        echo -e "  ${RED}⚠ Unexpected size - skipped${NC}"
        echo -e "  Expected: 1290×2796 or 1284×2778"
    fi
    
    echo ""
done

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
if [ $count -eq 0 ]; then
    echo -e "${RED}No screenshots found or processed${NC}"
    echo -e "Make sure you have Screenshot*.png files in: $INPUT_DIR"
else
    echo -e "${GREEN}✓ Processed $count screenshot(s)${NC}"
    echo -e "${GREEN}✓ Output directory: $OUTPUT_DIR${NC}"
    echo ""
    echo -e "Next steps:"
    echo -e "1. Review screenshots in: $OUTPUT_DIR"
    echo -e "2. Upload to App Store Connect"
fi
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
