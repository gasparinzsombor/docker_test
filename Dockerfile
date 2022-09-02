FROM elixir:latest AS builder

# The following are build arguments used to change variable parts of the image.
# The name of your application/release (required)
ARG APP_NAME
# The version of the application we are building (required)
ARG APP_VSN
# The environment to build with
ARG MIX_ENV=prod
# Set this to true if this release is not a Phoenix app
ARG SKIP_PHOENIX=false
# If you are using an umbrella project, you can change this
# argument to the directory the Phoenix app is in so that the assets
# can be built
ARG PHOENIX_SUBDIR=.

ENV SKIP_PHOENIX=${SKIP_PHOENIX} \
    APP_NAME=${APP_NAME} \
    APP_VSN=${APP_VSN} \
    MIX_ENV=${MIX_ENV}

# By convention, /opt is typically used for applications
WORKDIR /opt/app

# This step installs all the build tools we'll need
RUN mix local.rebar --force && \
  mix local.hex --force

# This copies our app source code into the build container
COPY . .

RUN mix do deps.get, deps.compile, compile

# This step builds assets for the Phoenix app (if there is one)
# If you aren't building a Phoenix app, pass `--build-arg SKIP_PHOENIX=true`
# This is mostly here for demonstration purposes
RUN if [ ! "$SKIP_PHOENIX" = "true" ]; then \
  mix phx.digest; \
fi

RUN \
  mkdir -p /opt/built && \
  mix release --overwrite && \
  cp -r _build/${MIX_ENV}/rel/${APP_NAME} /opt/built
  
# From this line onwards, we're in a new image, which will be the image used in production
FROM elixir:latest

# The name of your application/release (required)

ENV REPLACE_OS_VARS=true

WORKDIR /opt/app

COPY --from=builder /opt/built .

CMD trap 'exit' INT; /opt/app/rel/docker_test/bin/docker_test start
# CMD bash