HostInfo = Struct.new(:request) do
  alias :read_attribute_for_serialization :send

  def host
    request.domain || request.host
  end

  def port
    request.port
  end

  def ssl
    request.ssl?
  end

  def default_subdomain
    ENV["DEFAULT_SUBDOMAIN"]
  end

end