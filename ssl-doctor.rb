#!/usr/bin/env ruby

require 'bundler/setup'
require 'sinatra'
require 'rack/ssl'
require 'puma'
require 'ssltool'
require 'sequel'
require 'yajl'
require 'rollbar'
require 'rollbar/middleware/sinatra'
require 'sucker_punch'
require 'rollbar/blanket'


Rollbar.configure do |config|
  config.access_token = ENV['ROLLBAR_ACCESS_TOKEN']
  config.disable_monkey_patch = true
  config.use_sucker_punch
  config.scrub_fields  |= Rollbar::Blanket.fields
  config.scrub_headers |= Rollbar::Blanket.headers
end
use Rollbar::Middleware::Sinatra if ENV['ROLLBAR_ACCESS_TOKEN']


use Rack::SSL if ENV['RACK_ENV'] == 'production'
set :show_exceptions, false
$stdout.sync = true


STORE = SSLTool::CertificateStore.new ENV['DATABASE_URL']
STORE.on_circular_chain_detection do |circular_chains|
  raise NotImplementedError
end

[ [SSLTool::KeyHelper::KeyNotPresentError,                     400, "No valid, non-passphrase-protected keys given."],
  [SSLTool::KeyHelper::KeyNotFoundError,                       422, "No key found that signs the certificate."],
  [SSLTool::KeyHelper::KeyMalformedError,                      422, "Key appears to be malformed, or is passphrase-protected."],
  [SSLTool::ChainResolution::ZeroCertsChainResolutionError,    400, "No certificate given."],
  [SSLTool::ChainResolution::ZeroHeadsChainResolutionError,    422, "No certificate given is a domain name certificate."],
  [SSLTool::ChainResolution::TooManyHeadsChainResolutionError, 422, "More than one domain name certificate given."],
].each { |err, code, msg| error(err) { error(code, msg) } }

def respond(data)
  case
  when data.respond_to?(:to_pem); content_type :text; data.to_pem
  when data.is_a?(Hash)         ; content_type :json; Yajl::Encoder.encode(data)
  else raise ArgumentError
  end
end

def respond_with_resolved_chain(component = nil)
  response = STORE.resolve_chain(request.body.read)
  response = response.send(component) if component
  respond response
end

def resolve_chain_and_key
  scan  = SSLTool::PEMScanner.scan(request.body.read)
  chain = STORE.resolve_chain(scan.certs)
  key   = SSLTool::KeyHelper.find_private_key_for_certificate!(chain.first, scan.keys)
  [chain, key]
end

post "/find-domain-certificate-from-set" do
  respond_with_resolved_chain(:first)
end

post "/order-chain" do
  respond_with_resolved_chain(:ordered_chain)
end

post "/resolve-chain" do
  respond_with_resolved_chain
end

post "/resolve-chain-and-key" do
  chain, key = resolve_chain_and_key
  respond pem:chain.to_pem, key:key.to_pem
end

post "/find-key-for-certificate" do
  chain, key = resolve_chain_and_key
  respond key
end

post "/info-for-certificate-bundle" do
  raise NotImplementedError
end

DOCS = DATA.read
get "/" do
  content_type :text
  DOCS
end

__END__
Always POST plain/text to the endpoints.

E.g.:
  curl -X POST --data-binary @pem-file https://hostname/resolve-chain


# Endpoints that respond with plaintext:

/order-chain                      -> one or more certificates
/resolve-chain                    -> one or more certificates
/find-domain-certificate-from-set -> a certificate
/find-key-for-certificate         -> one key

- order-chain only orders the posted certificates.
- resolve-chain will complete the chain with intermediates on file.

# Endpoints that respond with json:

/resolve-chain-and-key            -> { "pem":"...", "key":"..." }
