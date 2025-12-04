FROM debian:13-slim AS base

FROM pwn.red/jail
COPY --from=base / /srv
COPY run.sh /srv/app/run
COPY ld-linux-x86-64.so.2 libc.so.6 flag.txt calculator++ /srv/app/
