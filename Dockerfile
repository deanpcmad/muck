FROM ruby:3.0.2-bullseye

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
  build-essential \
  && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /root/.bundle \
  && mkdir -p /opt/muck

WORKDIR /opt/muck

RUN gem install bundler --no-doc

COPY Gemfile Gemfile.lock ./

RUN bundle install

COPY . .

CMD ["bin/muck", "start"]
