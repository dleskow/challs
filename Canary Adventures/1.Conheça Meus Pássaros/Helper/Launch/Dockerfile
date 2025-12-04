FROM debian:13-slim AS base

FROM pwn.red/jail
COPY --from=base / /srv
COPY run.sh /srv/app/run
COPY flag.txt birds /srv/app/
