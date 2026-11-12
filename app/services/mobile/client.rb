# Registered public native clients of the mobile authentication protocol.
#
# Each client has one device platform and one redirect rule. The iOS app receives
# its callback on a private-use URI scheme. Desktop apps use an RFC 8252 loopback
# redirect: the app listens on whichever unprivileged port is free, so any port is
# accepted, but the host, scheme, and path are fixed. The authorization code stores
# the exact redirect URI it was issued for, and the token exchange must repeat it.
# Each client's tokens carry only the scopes that client uses; desktop apps have no
# push relay, so they cannot register for push notifications.
class Mobile::Client
  IOS_REDIRECT_URI = "org.loomio.mobile:/oauth/callback"
  LOOPBACK_REDIRECT_URI = %r{\Ahttp://127\.0\.0\.1:(?<port>[1-9][0-9]{3,4})/oauth/callback\z}
  LOOPBACK_PORT_RANGE = 1024..65535

  Definition = Data.define(:id, :platform, :device_name_default, :scopes, :redirect_rule) do
    def redirect_uri_valid?(uri)
      uri.is_a?(String) && redirect_rule.call(uri)
    end
  end

  IOS = Definition.new(
    id: "org.loomio.mobile.ios",
    platform: "ios",
    device_name_default: "iPhone",
    scopes: "activity:read activity:write notifications:manage relay:register web_session:create device:revoke",
    redirect_rule: ->(uri) { uri == IOS_REDIRECT_URI }
  )

  DESKTOP = Definition.new(
    id: "org.loomio.desktop",
    platform: "desktop",
    device_name_default: "Desktop",
    scopes: "activity:read activity:write web_session:create device:revoke",
    redirect_rule: lambda do |uri|
      match = LOOPBACK_REDIRECT_URI.match(uri)
      match.present? && LOOPBACK_PORT_RANGE.cover?(match[:port].to_i)
    end
  )

  ALL = [ IOS, DESKTOP ].freeze
  PLATFORMS = ALL.map(&:platform).freeze

  def self.find(id)
    ALL.find { |client| client.id == id }
  end

  def self.for_platform(platform)
    ALL.find { |client| client.platform == platform } || raise(KeyError, "no client for platform #{platform.inspect}")
  end
end
