#!/bin/bash
# Batch convert all Groovy pipeline configs to JSON format
#
# This script converts all jdkNN_pipeline_config.groovy files from
# ci-jenkins-pipelines to JSON format for the new ci-temurin-config repository

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="/Users/anleonar/workspace/ci-jenkins-pipelines/pipelines/jobs/configurations"
OUTPUT_DIR="${SCRIPT_DIR}/configurations"
CONVERTER="/Users/anleonar/workspace/ci-adoptium-pipelines/tools/convert-groovy-config-to-json.sh"

echo "=== Batch Converting Pipeline Configurations ==="
echo ""
echo "Source: ${SOURCE_DIR}"
echo "Output: ${OUTPUT_DIR}"
echo "Converter: ${CONVERTER}"
echo ""

# Check if converter exists
if [[ ! -f "${CONVERTER}" ]]; then
    echo "Error: Converter script not found: ${CONVERTER}"
    exit 1
fi

# Make converter executable
chmod +x "${CONVERTER}"

# Create output directory
mkdir -p "${OUTPUT_DIR}"

# Find all pipeline config files
CONFIG_FILES=$(find "${SOURCE_DIR}" -name "*_pipeline_config.groovy" | sort)

if [[ -z "${CONFIG_FILES}" ]]; then
    echo "Error: No pipeline config files found in ${SOURCE_DIR}"
    exit 1
fi

# Count files
TOTAL=$(echo "${CONFIG_FILES}" | wc -l | tr -d ' ')
CURRENT=0
SUCCESS=0
FAILED=0

echo "Found ${TOTAL} configuration files to convert"
echo ""

# Convert each file
for GROOVY_FILE in ${CONFIG_FILES}; do
    CURRENT=$((CURRENT + 1))
    BASENAME=$(basename "${GROOVY_FILE}" .groovy)
    JSON_FILE="${OUTPUT_DIR}/${BASENAME}.json"
    
    echo "[${CURRENT}/${TOTAL}] Converting ${BASENAME}..."
    
    if "${CONVERTER}" "${GROOVY_FILE}" "${JSON_FILE}" > /dev/null 2>&1; then
        SUCCESS=$((SUCCESS + 1))
        echo "  ✅ Success: ${JSON_FILE}"
    else
        FAILED=$((FAILED + 1))
        echo "  ❌ Failed: ${BASENAME}"
    fi
    echo ""
done

echo "=== Conversion Summary ==="
echo "Total:   ${TOTAL}"
echo "Success: ${SUCCESS}"
echo "Failed:  ${FAILED}"
echo ""

if [[ ${FAILED} -eq 0 ]]; then
    echo "✅ All configurations converted successfully!"
else
    echo "⚠️  Some configurations failed to convert. Please review manually."
fi

echo ""
echo "Output directory: ${OUTPUT_DIR}"
echo ""
echo "Next steps:"
echo "1. Review the generated JSON files"
echo "2. Manually adjust any complex configurations"
echo "3. Add version and scmReference fields to each file"
echo "4. Commit to ci-temurin-config repository"

# Made with Bob
