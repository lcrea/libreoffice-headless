#!/bin/bash

# Terminate the script if a command exits non-zero
set -e

# If none of these variables are set, uses default values.
: ${HOST_IN:=0}
: ${PORT_IN:=8100}
: ${LANG:='C.UTF-8'}

SOFFICE_ARGS=(
    "--accept=socket,host=${HOST_IN},port=${PORT_IN},tcpNoDelay=1;urp"
    "--headless"
    "--invisible"
    "--nodefault"
    "--nofirststartwizard"
    "--nolockcheck"
    "--nologo"
    "--norestore"
)

case "$1" in
    -- | soffice-headless)
        shift

        # Force the update of the fonts list eventually provided by an external volume.
        fc-cache -f

        exec gosu libreoffice soffice "${SOFFICE_ARGS[@]}" "$@"
        ;;
    -*)
        # Force the update of the fonts list eventually provided by an external volume.
        fc-cache -f

        exec gosu libreoffice soffice "$@"
        ;;
    debug)
        echo "LibreOffice parameters:" ${SOFFICE_ARGS[@]}
        exit 1
        ;;
    *)
        exec "$@"
esac

exit 1
