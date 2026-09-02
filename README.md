# nextcloud-cli

A minimal container image bundling a **current `nextcloudcmd`** (the Nextcloud
desktop sync client's headless CLI).

## Why

Debian stable ships an old `nextcloud-desktop-cmd` — bookworm is frozen at
3.7.3, whose sync engine re-reads the entire local tree on every run and can
peg a core or two on a large folder. Debian trixie tracks the 3.16.x line with
the rewritten discovery/propagation engine (a steady-state sync of a large tree
drops from tens of minutes to seconds).

This image pulls `nextcloud-desktop-cmd` from trixie so a host on an older
distro can run a modern sync from `docker run` without a dist-upgrade.

## Image

Published to GHCR and Docker Hub with identical tags each release:

```
ghcr.io/m13tlabs/nextcloudcmd-cli:<version>   # e.g. 0.1.0
ghcr.io/m13tlabs/nextcloudcmd-cli:<major.minor>
ghcr.io/m13tlabs/nextcloudcmd-cli:latest

m13t/nextcloudcmd-cli:<version>
m13t/nextcloudcmd-cli:<major.minor>
m13t/nextcloudcmd-cli:latest
```

`linux/amd64` and `linux/arm64`. The `<version>` here is this repo's release
number, not the bundled `nextcloudcmd` version — check the image label
`org.opencontainers.image.version` or run `--version` for that.

## Usage

`ENTRYPOINT` is `nextcloudcmd`; pass its arguments straight through. Mount the
local sync folder and run as the user that should own the files:

```sh
docker run --rm \
  -u "$(id -u):$(id -g)" \
  -v /srv/nextcloud:/data \
  ghcr.io/m13tlabs/nextcloudcmd-cli:latest \
  --silent \
  --user "$NC_USER" --password "$NC_PASS" \
  /data https://cloud.example.com
```

Run it under `flock -n` from cron so a long run never stacks:

```cron
*/15 * * * * /usr/bin/flock -n /run/nextcloud-sync.lock -c 'docker run --rm -u 1000:1000 -v /srv/nextcloud:/data ghcr.io/m13tlabs/nextcloudcmd-cli:latest --silent --user "$NC_USER" --password "$NC_PASS" /data https://cloud.example.com'
```

### Notes

- The container needs a writable `HOME` for a transient config/keychain; the
  image sets `HOME=/tmp`, which `--rm` discards each run.
- App password recommended over the account password.
- First run after switching from an old client rebuilds the sync journal
  (`.sync_*.db`) — one slower pass, no data loss; back the file up first if you
  want a fallback.

## Releasing

`config.json` holds the current release version. Run the **Release** workflow
(`workflow_dispatch`, `patch` / `minor` / `major` / `custom`): it bumps
`config.json`, updates `CHANGELOG.md` from Conventional Commits via git-cliff,
builds and pushes the multi-arch image to GHCR and Docker Hub with provenance
and SBOM, and opens a draft GitHub release.

## License

MIT — see [LICENSE](LICENSE).
