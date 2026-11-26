#!/usr/bin/env bash
# Fail unless IMAGE has every plugin CirrusSearch uses.
set -euo pipefail

image=${1:?usage: check-plugins.sh IMAGE}
required=(analysis-icu opensearch-extra opensearch-extra-analysis-textify cirrus-highlighter)

installed=$(docker run --rm --entrypoint /usr/share/opensearch/bin/opensearch-plugin "$image" list)
missing=0
for plugin in "${required[@]}"; do
    if grep -qx "$plugin" <<<"$installed"; then
        echo "ok: $plugin"
    else
        echo "missing: $plugin" >&2
        missing=1
    fi
done
exit "$missing"
