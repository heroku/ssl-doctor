module PGAsyncExecWithScornTowardsOpenSSL
  def async_exec *a, &b
    retried ||= false
    super(*a, &b)
  rescue PG::ConnectionBad => e
    raise e if retried
    OpenSSL.errors
    retried = true
    retry
  end
end

PG::Connection.prepend PGAsyncExecWithScornTowardsOpenSSL
