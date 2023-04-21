FROM ruby:3.0-bullseye
ARG RAILS_ENV=production
ENV RAILS_ENV $RAILS_ENV

ENV APP_HOME /app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

# RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash -
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -

RUN apt-get update && apt-get install -y \
	build-essential \
	mariadb-client \
	nodejs \
	# yarnpkg \
	--no-install-recommends && rm -rf /var/lib/apt/lists/*
# RUN ln -s /usr/bin/yarnpkg /usr/bin/yarn
RUN npm install --global yarn

RUN gem install bundler:2.3.7
ADD Gemfile* $APP_HOME/
ADD bin/bundle $APP_HOME/bin/bundle
RUN ./bin/bundle

ADD package.json* $APP_HOME
# RUN npm add @babel/runtime
# RUN npm add @babel/runtime-corejs2
# RUN NODE_PATH=/usr/lib/nodejs:/usr/share/nodejs yarn cache clean && yarn
# RUN npm install --loglevel verbose
RUN yarn cache clean && yarn install --verbose

EXPOSE 3000

ADD . $APP_HOME/

CMD ["./bin/dev"]
