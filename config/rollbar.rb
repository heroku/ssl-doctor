if ENV["ROLLBAR_ACCESS_TOKEN"]
  
  require "rollbar"
  require "rollbar/middleware/sinatra"
  require "rollbar/blanket"

  Rollbar.configure do |config|
    config.access_token = ENV["ROLLBAR_ACCESS_TOKEN"]
    config.disable_monkey_patch = true
    config.environment = Sinatra::Base.environment
    config.use_thread
    config.scrub_fields  |= Rollbar::Blanket.fields
    config.scrub_headers |= Rollbar::Blanket.headers
  
    [ "SSLTool::KeyHelper::KeyNotPresentError",
      "SSLTool::KeyHelper::KeyNotFoundError",
      "SSLTool::KeyHelper::KeyMalformedError",
      "SSLTool::ChainResolution::ZeroCertsChainResolutionError",
      "SSLTool::ChainResolution::ZeroHeadsChainResolutionError",
      "SSLTool::ChainResolution::TooManyHeadsChainResolutionError",
    ].each do |e|
      config.exception_level_filters[e] = "ignore"
    end
  
  end

  use Rollbar::Middleware::Sinatra 

end
