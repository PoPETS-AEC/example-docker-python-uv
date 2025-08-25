# Let's start from an official python docker image - feel free to update the tag
# as needed.
FROM python:3.13.6-trixie

# Copy the uv binary from the official image (pinned version, edit as needed)
COPY --from=ghcr.io/astral-sh/uv:0.8.13 /uv /uvx /bin/

# Configure uv
# ENV UV_COMPILE_BYTECODE=1
ENV UV_LINK_MODE=copy
ENV UV_TOOL_BIN_DIR=/usr/local/bin
# directory for virtual environment (separate than working dir, so that volume
# does not override it)
ENV UV_PROJECT_ENVIRONMENT=/opt/venv
# Install dependencies
RUN --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    uv sync --locked --no-install-project --no-dev

# Create group and user to avoid permissions issues with local user/group
# when editing files in and out of docker container.
# Note: GNU/Linux systems assign the default 1000 User Identifier (UID) and
# Group Identifier (GID) to the first account created during installation. It is
# possible that your local UID and GID on your machine may be different, in that
# case you should edit the values in the commands below.
# You can see your UID and GID(s) by executing: `id`
RUN addgroup --gid 1000 groupname
RUN adduser --disabled-password --gecos "" --uid 1000 --gid 1000 username
ENV HOME=/home/username
USER username