source "https://rubygems.org"

ruby '2.3.3'

gem 'puma'
gem 'rack-ssl'
gem 'sinatra'
gem "sinatra-cross_origin", "~> 0.3.1"
gem 'rollbar'

source "https://packagecloud.io/heroku/gemgate/" do
  gem 'rollbar-blanket', '0.1.8'
end

gem 'ssltool' #, path:"#{ENV['HOME']}/src/ssltool"
gem 'sequel'
gem 'pg'
gem 'yajl-ruby'
gem 'redis'

group :test do
    gem 'rack-test'
    gem 'rspec'
end
