FROM ruby:3.2

ARG APP_USER=appuser
ARG APP_GROUP=appgroup
ARG APP_USER_UID=900
ARG APP_GROUP_GID=900

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        postgresql-client \
    && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    #for troubleshooting
    && apt-get install -y nano \
    && apt-get install -y htop \
    && addgroup --gid $APP_GROUP_GID $APP_GROUP \
    && adduser --system --disabled-login --uid $APP_USER_UID --ingroup $APP_GROUP $APP_USER \
    && mkdir /usr/src/app \
    && chown $APP_USER:$APP_GROUP /usr/src/app \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src/app
COPY --chown=$APP_USER:$APP_GROUP Gemfile* ./
COPY Gemfile* ./
ENV ENV_RAILS=production
RUN bundle install
COPY --chown=$APP_USER_UID:$APP_GROUP_UID . .
COPY . .
RUN chmod -R 777 /usr/src/app/tmp && chmod +x /usr/src/app/lib/docker-entrypoint.sh && bundle exec rake app:update:bin && rails generate delayed_job
ENTRYPOINT ["sh","/usr/src/app/lib/docker-entrypoint.sh"]
#CMD sh -c "bin/delayed_job start && bin/rails server -e production -b 0.0.0.0"

EXPOSE 3000

