source "https://rubygems.org"

ruby '2.6.6'

gem 'puma'
gem 'rack-ssl'
gem 'sinatra'
gem "sinatra-cross_origin", "~> 0.3.1"
gem 'rollbar'

source "https://packagecloud.io/heroku/gemgate/" do
  gem 'rollbar-blanket', '~> 1.0.0'
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
