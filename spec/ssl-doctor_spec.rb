ENV['RACK_ENV'] = 'test'

require 'ssl-doctor'
require 'rspec'
require 'rack/test'

describe 'SSL-Doctor' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  it "return usage info" do
    get '/'
    expect(last_response).to be_ok
    expect(last_response.body).to include('Always POST plain/text to the endpoints.')
  end
end