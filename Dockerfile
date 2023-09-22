FROM ruby:3.1.2-alpine

RUN apk update && \
  apk add --no-cache build-base curl git nodejs bash gpg

WORKDIR /opt/muck

COPY Gemfile Gemfile.lock ./

RUN bundle install

COPY . .

CMD ["bin/muck", "start"]
