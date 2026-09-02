#!/usr/bin/env bash
# ===========================================================================
# Validate Rulebooks
# ===========================================================================
# Checks all rulebook YAML files for syntax errors.
#
# Usage:
#   ./scripts/validate-rulebooks.sh
#
# Prerequisites:
#   - python3 with pyyaml (pip install pyyaml)
#   - (optional) ansible-rulebook for deeper validation
# ===========================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "${SCRIPT_DIR}")"
RULEBOOK_DIR="${REPO_DIR}/rulebooks"

echo "============================================"
echo " Validating rulebooks in: ${RULEBOOK_DIR}"
echo "============================================"
echo ""

ERRORS=0
CHECKED=0

for rulebook in $(find "${RULEBOOK_DIR}" -name '*.yml' -type f | sort); do
    relative_path="${rulebook#${REPO_DIR}/}"
    CHECKED=$((CHECKED + 1))

    # Basic YAML syntax check
    if python3 -c "import yaml; yaml.safe_load(open('${rulebook}'))" 2>/dev/null; then
        echo "  [OK]   ${relative_path}"
    else
        echo "  [FAIL] ${relative_path}"
        python3 -c "import yaml; yaml.safe_load(open('${rulebook}'))" 2>&1 | sed 's/^/         /'
        ERRORS=$((ERRORS + 1))
    fi

    # If ansible-rulebook is available, do a deeper check
    # if command -v ansible-rulebook &>/dev/null; then
    #     if ansible-rulebook --rulebook "${rulebook}" --check 2>/dev/null; then
    #         echo "         [ansible-rulebook check: OK]"
    #     else
    #         echo "         [ansible-rulebook check: FAIL]"
    #         ERRORS=$((ERRORS + 1))
    #     fi
    # fi
done

echo ""
echo "============================================"
echo " Checked: ${CHECKED} rulebooks"
if [ ${ERRORS} -eq 0 ]; then
    echo " Result: All passed"
else
    echo " Result: ${ERRORS} error(s) found"
fi
echo "============================================"

exit ${ERRORS}
