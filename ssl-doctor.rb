#!/usr/bin/env ruby
# encoding: UTF-8

require 'sinatra'
require 'rack/ssl'
require 'ssltool'
require 'sequel'
require 'json'

use Rack::SSL if ENV['RACK_ENV'] == 'production'

$store = SSLTool::CertificateStore.new ENV['DATABASE_URL']
def resolve_chain(chain_string = request.body.read)
  $store.resolve_chain_from_pem_string(chain_string)
rescue SSLTool::ChainResolution::ChainResolutionError => e
  raise NotImplementedError
end

def send_pem(data)
  content_type :text
  data.to_pem
end

$store.register_for_circular_chain_detection_notification do |circular_chains|
  raise NotImplementedError
end

post "/order-chain" do
  send_pem resolve_chain.ordered_chain
end

post "/resolve-chain" do
  send_pem resolve_chain
end

post "/find-domain-certificate-from-set" do
  send_pem resolve_chain.first
end

post "/find-key-for-certificate" do
  data  = request.body.read
  chain = resolve_chain(data)
  keys  = SSLTool::KeyHelper.scan(data)
  key   = SSLTool::KeyHelper.find_private_key_for_certificate(chain.first, keys)
  send_pem key if key
end

post "/info-for-certificate-bundle" do
  raise NotImplementedError
end

get "/" do
  "OH HAI"
end
