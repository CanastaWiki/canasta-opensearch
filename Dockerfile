# OpenSearch with the plugins CirrusSearch uses.
#
# A plugin must be built for the exact OpenSearch version it is installed in,
# so OPENSEARCH_VERSION and WIKIMEDIA_PLUGIN_VERSION move together, and only
# to a version Wikimedia has published the plugins for:
# https://repo1.maven.org/maven2/org/wikimedia/search/opensearch-extra/
ARG OPENSEARCH_VERSION=3.8.0
FROM opensearchproject/opensearch:${OPENSEARCH_VERSION}

ARG WIKIMEDIA_PLUGIN_VERSION=3.8.0-wmf2
ARG MAVEN=https://repo1.maven.org/maven2/org/wikimedia/search

# The Wikimedia plugins come from Maven Central, which publishes no signatures
# opensearch-plugin can check, so each zip is pinned by its SHA-256.
# analysis-icu is OpenSearch's own plugin, installed by name for the base
# image's version.
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
WORKDIR /tmp
RUN set -e; \
    fetch() { \
        curl -fsSL -o "$2" "$MAVEN/$1/$WIKIMEDIA_PLUGIN_VERSION/$2" && \
        echo "$3  $2" | sha256sum -c -; \
    }; \
    fetch opensearch-extra \
        "opensearch-extra-$WIKIMEDIA_PLUGIN_VERSION.zip" \
        bf14eda888f400188df76ac1146ac4d4252b526c1e25b0550a21fe6418f68196; \
    fetch opensearch-extra-analysis-textify \
        "opensearch-extra-analysis-textify-$WIKIMEDIA_PLUGIN_VERSION.zip" \
        71d3f6b1c626ef3786ecb8662af6d7174f82ed4b3d32532ce6389d4c24b033fe; \
    fetch highlighter/cirrus-highlighter-opensearch-plugin \
        "cirrus-highlighter-opensearch-plugin-$WIKIMEDIA_PLUGIN_VERSION.zip" \
        dec4c5a5c1dc998e649e365c0ca9c6e4becfbe9f35ca14ddb979b45a25dec7da; \
    /usr/share/opensearch/bin/opensearch-plugin install --batch \
        analysis-icu \
        "file:///tmp/opensearch-extra-$WIKIMEDIA_PLUGIN_VERSION.zip" \
        "file:///tmp/opensearch-extra-analysis-textify-$WIKIMEDIA_PLUGIN_VERSION.zip" \
        "file:///tmp/cirrus-highlighter-opensearch-plugin-$WIKIMEDIA_PLUGIN_VERSION.zip"; \
    rm -f /tmp/*.zip
WORKDIR /usr/share/opensearch

LABEL org.opencontainers.image.source="https://github.com/CanastaWiki/canasta-opensearch" \
      org.opencontainers.image.description="OpenSearch with the plugins CirrusSearch uses"
