class HostInfoSerializer < ActiveModel::Serializer
  root false

  attributes :port, :default_subdomain, :host, :ssl

  def object
    @info ||= HostInfo.new super
  end

end
