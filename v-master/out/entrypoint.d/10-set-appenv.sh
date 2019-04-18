#!/bin/bash

# Constructs the app's runtime environment.
# Besides app consumed env variables, it also creates
# the environment for entrypoint and startup scripts (eg. ODOO_ADDONS_PATH)

set -Eeuo pipefail

export ODOO_ADMINPASSWORD_FILE="${ODOO_ADMINPASSWORD_FILE:=/run/secrets/adminpwd}"  # Odoo Passfile (Patch tools/0002)

addonspath=""
# Sort reverse alfanumerically first, then do realpath
# so we can freely reorder loading by symlinking for
# exemple in a CI environment directly from a git clone.

for dir in $(find "${ODOO_SRC}" -maxdepth 3 -exec test -e {}/__manifest__.py -o -e {}/__openerp__.py \; -exec dirname {} \; | uniq | sort | xargs realpath --no-symlinks); do
    echo "==>  Adding $dir to addons path"
    if [ -z "$addonspath" ]; then
        addonspath=$dir
    else
        addonspath=$addonspath,$dir
    fi;
done;

for dir in $(find "${ODOO_VENDOR}" -maxdepth 5 -exec test -e {}/__manifest__.py -o -e {}/__openerp__.py \; -exec dirname {} \; | uniq | sort | xargs realpath --no-symlinks); do

    echo "==>  Adding $dir to addons path"
    if [ -z "$addonspath" ]; then
        addonspath=$dir
    else
        addonspath=$addonspath,$dir
    fi;
done;
export ODOO_ADDONS_PATH=$addonspath
