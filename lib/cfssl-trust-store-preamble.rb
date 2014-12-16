require "redis"

CFSSL_TRUST_URL = "https://github.com/cloudflare/cfssl_trust"
CFSSL_TRUST_DIR = File.expand_path(File.dirname(__FILE__) + "/../vendor/cfssl_trust.git")
TRUST_FILENAMES = %w[ ca-bundle.crt
                      ca-bundle.crt.metadata
                      int-bundle.crt ]

TRUST_STORE = Redis.connect url:ENV["REDISCLOUD_URL"]
