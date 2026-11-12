require "test_helper"

class Mobile::ClientTest < ActiveSupport::TestCase
  test "finds only registered clients" do
    assert_equal Mobile::Client::IOS, Mobile::Client.find("org.loomio.mobile.ios")
    assert_equal Mobile::Client::DESKTOP, Mobile::Client.find("org.loomio.desktop")
    assert_nil Mobile::Client.find("org.loomio.desktop ")
    assert_nil Mobile::Client.find(nil)
  end

  test "the iOS client accepts only its private-use callback" do
    assert Mobile::Client::IOS.redirect_uri_valid?("org.loomio.mobile:/oauth/callback")
    assert_not Mobile::Client::IOS.redirect_uri_valid?("http://127.0.0.1:53682/oauth/callback")
  end

  test "the desktop client accepts only an IPv4 loopback callback on an unprivileged port" do
    %w[
      http://127.0.0.1:1024/oauth/callback
      http://127.0.0.1:53682/oauth/callback
      http://127.0.0.1:65535/oauth/callback
    ].each { |uri| assert Mobile::Client::DESKTOP.redirect_uri_valid?(uri), uri }

    [
      "org.loomio.mobile:/oauth/callback",
      "http://127.0.0.1/oauth/callback",
      "http://127.0.0.1:80/oauth/callback",
      "http://127.0.0.1:1023/oauth/callback",
      "http://127.0.0.1:65536/oauth/callback",
      "http://127.0.0.1:099999/oauth/callback",
      "http://localhost:53682/oauth/callback",
      "http://[::1]:53682/oauth/callback",
      "https://127.0.0.1:53682/oauth/callback",
      "http://127.0.0.2:53682/oauth/callback",
      "http://127.0.0.1:53682/oauth/callback/",
      "http://127.0.0.1:53682/oauth/callback?next=x",
      "http://127.0.0.1:53682/oauth/callback#x",
      "http://user@127.0.0.1:53682/oauth/callback",
      "http://127.0.0.1:53682@evil.example/oauth/callback",
      "http://127.0.0.1:53682/oauth/callback\nx",
      nil
    ].each { |uri| assert_not Mobile::Client::DESKTOP.redirect_uri_valid?(uri), uri.inspect }
  end
end
