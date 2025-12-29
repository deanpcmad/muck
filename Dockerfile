FROM ruby:3.3.4-alpine

RUN apk update && \
  apk add --no-cache build-base curl git nodejs bash gpg gpg-agent ca-certificates

WORKDIR /opt/muck

COPY Gemfile Gemfile.lock ./

RUN bundle install

COPY . .

CMD ["bin/muck", "start"]
