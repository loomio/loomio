# The cell's image. Hot Cell installed this file once; it is yours to customize, and nothing inherits
# from a published base image — this is the whole recipe.
#
# A cell carries a Ruby runtime and every gem in its loaded graph, all inside the blast radius, so treat
# this file as a budget rather than an inventory. Which tools it holds is what decides its blast radius.

# The base image. This tag is mutable: `ruby:3.4-slim` moves as Debian and Ruby publish patches, so a
# clean build is only as reproducible and as patched as the tag on the day it runs. Build with
# `docker build --pull` to always take the newest patched base. If you also need to name the exact image
# you shipped, pin a digest (`FROM ruby:${RUBY_VERSION}-slim@sha256:…`) and refresh it on a schedule; the
# image scan in CI is what catches a base that has drifted into known-vulnerable either way.
ARG RUBY_VERSION=4.0
FROM ruby:${RUBY_VERSION}-slim

# Apply Debian's pending security patches. `--pull` takes the newest base tag, and the tag can still be
# behind an advisory that is already in `trixie-security`, because only a rebuild by docker-library/ruby
# moves it. Upgrading here makes the image's patch level its own rather than upstream's release cadence,
# and it is what keeps the image scan in CI passing on a fixable vulnerability the base has not picked up
# yet. It costs a layer and a little build time on every build.
RUN apt-get update && apt-get upgrade -y --no-install-recommends && rm -rf /var/lib/apt/lists/*

# Install only the media tools that Loomio's Active Storage operations invoke.
RUN apt-get update && \
    apt-get install -y --no-install-recommends libvips42 poppler-utils ffmpeg && \
    rm -rf /var/lib/apt/lists/*

# The cell's user: no home directory and no shell. Pick a uid your host does not also use for a person —
# without user namespace remapping this uid is the host's uid, and Debian's own range runs to 60000, so
# 10001 is not outside it. What isolates the cell is the container, not the number.
RUN groupadd --gid 10001 hotcell && \
    useradd --uid 10001 --gid 10001 --no-create-home --shell /usr/sbin/nologin hotcell

# The socket volume's mount point must exist here, owned by the cell's user, because a new named volume
# takes its ownership from the directory it covers. /hotcell is not: see the chown back to root below.
RUN mkdir -p /run/hotcell/cell /hotcell/operations && chown -R hotcell:hotcell /run/hotcell /hotcell

# HOME is /tmp because the cell's user has no home directory, and bundler wants one. A worker replaces
# it with its slot's home before it serves anything.
#
# OpenMP sizes its thread pool from the host's core count, and a `cpus:` quota does not lower it, so an
# unbounded libvips or ImageMagick asks a 98-core host for 98 threads, each with an 8MB stack.
# `RLIMIT_DATA` charges those stacks, and libgomp calls `exit(1)` on the first `pthread_create` it cannot satisfy. Match
# OMP_NUM_THREADS to the container's `cpus:`: the number follows the allocation rather than being 2.
# OMP_THREAD_LIMIT bounds a library that raises the count itself, which is what ImageMagick does.
ENV HOME=/tmp \
    BUNDLE_PATH=/hotcell/bundle \
    BUNDLE_WITHOUT=development \
    OMP_NUM_THREADS=2 \
    OMP_THREAD_LIMIT=8 \
    HOTCELL_OPERATIONS=/hotcell/operations \
    HOTCELL_DIR=/run/hotcell/cell

WORKDIR /hotcell

# For a reproducible dependency graph, commit a Gemfile.lock next to the Gemfile so a clean build resolves
# the exact gems the lockfile names rather than whatever the sources offer that day. Generate it for the
# platform you deploy on — e.g. from a macOS checkout, `bundle lock --add-platform x86_64-linux` so the
# Linux image accepts it — and build frozen (`bundle install --frozen`, or set `BUNDLE_FROZEN=true`) to
# refuse a Gemfile that has drifted from the lockfile. Left off by default so a freshly installed scaffold
# builds before you have generated a lockfile.
COPY --chown=hotcell:hotcell Gemfile* ./
USER hotcell
RUN bundle install

COPY config.rb /hotcell/config.rb
COPY operations/ /hotcell/operations/

# The cell reads its own code and must not be able to write it. `HotCell.load!` requires config.rb and
# every operation file at boot, so a worker that could write here would choose what the next supervisor
# runs. Bundler needed to write during the build and nothing needs to afterwards, so hand the tree back to
# root once the build is done. `read-only: true` covers this as well, and this holds without it.
USER root
RUN chown -R root:root /hotcell && chmod -R go-w /hotcell

# Strip the setuid and setgid bits off every binary the image carries (mount, umount, su, … from the base,
# plus anything a RUN above installed). The cell runs as an unprivileged user under `--cap-drop ALL` and
# `--security-opt no-new-privileges`, which already make these gadgets inert; removing the bits keeps a
# security image from shipping escalation tools it never uses. As the last root step it covers everything
# built above it. `-xdev` stays on the image's own filesystem; `chmod a-s` clears both bits.
RUN find / -xdev -type f -perm /06000 -exec chmod a-s {} +
USER hotcell

# Probes the supervisor's control socket from inside the container, where network: none does not apply.
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD ["bundle", "exec", "hotcell-health"]

CMD ["bundle", "exec", "hotcell"]
