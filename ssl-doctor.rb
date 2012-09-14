#!/usr/bin/env ruby
# encoding: UTF-8

require 'sinatra'
require 'rack/ssl'
require 'thin'
require 'ssltool'
require 'sequel'
require 'json'

use Rack::SSL if ENV['RACK_ENV'] == 'production'

# Thin doesn't know about HTTP 422, but Rack does, so let's patch thin's list.
# Revisit this for future removal when https://github.com/macournoyer/thin/pull/135 gets merged in
Thin::HTTP_STATUS_CODES.replace(Rack::Utils::HTTP_STATUS_CODES)

STORE = SSLTool::CertificateStore.new ENV['DATABASE_URL']
STORE.register_for_circular_chain_detection_notification do |circular_chains|
  raise NotImplementedError
end

[ [SSLTool::KeyHelper::KeyNotPresentError,                     400, "No keys given."],
  [SSLTool::KeyHelper::KeyNotFoundError,                       422, "No key found that signs the certificate."],
  [SSLTool::ChainResolution::ZeroCertsChainResolutionError,    400, "No certificate given."],
  [SSLTool::ChainResolution::ZeroHeadsChainResolutionError,    422, "No certificate given is a domain name certificate."],
  [SSLTool::ChainResolution::TooManyHeadsChainResolutionError, 422, "More than one domain name certificate given."],
].each { |err, code, msg| error(err) { error(code, msg) } }

def respond(data)
  case
  when data.respond_to?(:to_pem); content_type :text; data.to_pem
  when data.is_a?(Hash)         ; content_type :json; data.to_json
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

get "/" do
  "OH HAI"
end
