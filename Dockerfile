FROM ruby:3.2-slim

RUN apt-get update
RUN apt-get install -y git wget xz-utils build-essential libyaml-dev

# Install Firefox
RUN apt-get install -y firefox-esr

# Install Geckodriver
RUN wget "https://github.com/mozilla/geckodriver/releases/download/v0.36.0/geckodriver-v0.36.0-linux64.tar.gz" -O geckodriver.tar.gz
RUN tar -xzf geckodriver.tar.gz -C /usr/local/bin

COPY . /app
WORKDIR /app
RUN bundle install
CMD ["bundle", "exec", "rspec"]
