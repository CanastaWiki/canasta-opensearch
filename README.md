# canasta-opensearch

The OpenSearch image [Canasta](https://canasta.wiki) runs for
[CirrusSearch](https://www.mediawiki.org/wiki/Extension:CirrusSearch). It is the
official `opensearchproject/opensearch` image with the plugins CirrusSearch uses:

| Plugin | Source | What CirrusSearch uses it for |
|---|---|---|
| `analysis-icu` | OpenSearch | Unicode folding and normalization, ICU tokenizing |
| `opensearch-extra` | Wikimedia | Regular-expression search (`insource:/…/`), and skipping updates that change nothing |
| `opensearch-extra-analysis-textify` | Wikimedia | More text analysis filters, such as ICU token repair |
| `cirrus-highlighter` | Wikimedia | The experimental highlighter |

Images are published as `ghcr.io/canastawiki/canasta-opensearch:<OpenSearch version>-<build>`,
for example `3.8.0-1`, for amd64 and arm64.

## Versions

A plugin must be built for the exact OpenSearch version it is installed in.
Wikimedia publishes its plugins to
[Maven Central](https://repo1.maven.org/maven2/org/wikimedia/search/opensearch-extra/)
for a few OpenSearch versions only, so this image moves to a new OpenSearch
version only once Wikimedia has published the plugins for it.

To move to a new version, change `OPENSEARCH_VERSION` and
`WIKIMEDIA_PLUGIN_VERSION` in the `Dockerfile`, and replace each zip's SHA-256
with the new file's.

## Adding a plugin

To run another plugin, build on this image, with a plugin built for the same
OpenSearch version:

```dockerfile
FROM ghcr.io/canastawiki/canasta-opensearch:3.8.0-1
RUN /usr/share/opensearch/bin/opensearch-plugin install --batch analysis-kuromoji
```

## Releasing

1. Merge the change to `main`.
2. Tag `main` as `<OpenSearch version>-<build>`, using the next build number for
   that OpenSearch version, and push the tag. The workflow checks the tag
   against the `Dockerfile`, refuses a tag that is already published, builds
   and checks the image, and pushes it.

`check-plugins.sh IMAGE` checks an image for the required plugins.
