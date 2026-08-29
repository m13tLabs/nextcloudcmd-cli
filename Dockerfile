# A current `nextcloudcmd` in a throwaway container.
#
# Debian stable's `nextcloud-desktop-cmd` lags years behind (bookworm is frozen
# at 3.7.3, whose sync engine re-scans the whole tree on every run). Debian
# testing/trixie tracks the 3.16.x line with the faster discovery/propagation
# engine. This image pulls that package so hosts on an older distro can run a
# modern sync via `docker run` instead of a dist-upgrade.
#
# renovate: datasource=docker depName=debian versioning=loose
FROM debian:trixie-slim

# hadolint ignore=DL3008
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      nextcloud-desktop-cmd \
      ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# Qt aborts without a UTF-8 locale; HOME must be writable for the transient
# config/keychain nextcloudcmd creates on each run.
ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    HOME=/tmp

ENTRYPOINT ["nextcloudcmd"]
CMD ["--help"]
