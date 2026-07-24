require 'test_helper'

class ReceivedEmailTest < ActiveSupport::TestCase
  def email_with(auth_results)
    headers = { 'From' => 'alice@partner.example' }
    headers['Authentication-Results'] = auth_results if auth_results
    ReceivedEmail.new(headers: headers)
  end

  test "sender_authentication_failed? is true when DMARC fails" do
    assert email_with('mx.loomio.com; spf=pass smtp.mailfrom=x; dkim=pass; dmarc=fail header.from=partner.example').sender_authentication_failed?
  end

  test "sender_authentication_failed? is true when both DKIM and SPF fail" do
    assert email_with('mx.loomio.com; spf=fail smtp.mailfrom=x; dkim=fail header.d=partner.example').sender_authentication_failed?
  end

  test "sender_authentication_failed? is false when DMARC passes" do
    assert_not email_with('mx.loomio.com; spf=pass; dkim=pass; dmarc=pass header.from=partner.example').sender_authentication_failed?
  end

  test "sender_authentication_failed? is false when only SPF fails but DKIM passes" do
    assert_not email_with('mx.loomio.com; spf=fail; dkim=pass; dmarc=pass').sender_authentication_failed?
  end

  test "sender_authentication_failed? is false when the header is absent (cannot prove failure)" do
    assert_not email_with(nil).sender_authentication_failed?
  end
end
