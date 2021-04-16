#!/usr/bin/env ruby

require "yajl"
require "shellwords"

module CFSSL
  ROOT = File.expand_path(File.dirname(__FILE__) + "/..")
  CFSSL = "#{ROOT}/vendor/cfssl/bin"
  TRUST = "#{ROOT}/vendor/cfssl_trust"
  CA = "#{TRUST}/ca-bundle.crt"
  INT = "#{TRUST}/int-bundle.crt"
  META = "#{TRUST}/ca-bundle.crt.metadata"
  OS = `uname -s`.chomp.downcase
  ARCH = `uname -m`.chomp.downcase.sub(/^x86_64$/, "amd64")
  BIN = "#{CFSSL}/cfssl.#{OS}_#{ARCH}"

  def self.bundle(x509_cert_str)
    cmd = [BIN,
      "bundle",
      "-ca-bundle", CA,
      "-int-bundle", INT,
      "-metadata", META,
      "-cert", "/dev/stdin"].shelljoin << " 2>/dev/null"
    result = Yajl::Parser.parse IO.popen(cmd, "r+") { |io|
                                  io.write(x509_cert_str)
                                  io.close_write
                                  io.read
                                }
    result && result["bundle"] || ""
  end
end

puts CFSSL.bundle(ARGF.read) if __FILE__ == $0
