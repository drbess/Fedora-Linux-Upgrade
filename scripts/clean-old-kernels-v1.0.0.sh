#!/usr/bin/env sh
#
# Clean old Fedora kernels, keeping only the current and one previous
#

set -e

OLD_KERNELS=$(dnf repoquery --installonly --latest-limit=-1 -q)

if [ -z "$OLD_KERNELS" ]; then
    echo "No old kernels found to remove."
    exit 0
fi

echo "The following old kernels will be removed:"
echo "$OLD_KERNELS"
echo ""
read -p "Continue? (yes/no): " CONFIRM

if [ "$CONFIRM" = "yes" ]; then
    if dnf remove $OLD_KERNELS; then
        echo "Old kernels removed successfully."
    else
        echo "Error removing old kernels."
        exit 1
    fi
else
    echo "Operation cancelled."
fi
