BASE_DIR      = File.expand_path(File.dirname(__FILE__) + "/..")
SLEEP_SECONDS = 60 * 60 * 4 # every 4 hours

Thread.new do
  loop do
    load(File.join(BASE_DIR, "bin/cfssl-trust-store-get"), true)
    sleep SLEEP_SECONDS
  end
end
