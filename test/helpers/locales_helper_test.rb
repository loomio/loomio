require 'test_helper'

class LocalesHelperTest < ActiveSupport::TestCase
  include LocalesHelper

  setup do
    @user = users(:user)
    @params = {}
    @request_env = { 'HTTP_ACCEPT_LANGUAGE' => '' }
  end

  # Provide methods that LocalesHelper calls
  def params
    @params
  end

  def current_user
    @user
  end

  def request
    OpenStruct.new(env: @request_env)
  end

  test "can set locale via query parameter" do
    @params = { locale: 'fr' }
    assert_equal :fr, preferred_locale.to_sym
  end

  test "does not set a bad locale via query param" do
    @params = { lang: 'notagoodone' }
    assert_equal I18n.default_locale, preferred_locale.to_sym
  end

  test "can set locale via user preference" do
    @user.update(selected_locale: 'fr')
    assert_equal :fr, preferred_locale.to_sym
  end

  test "has robust fallbacks from browser http headers" do
    @request_env = { 'HTTP_ACCEPT_LANGUAGE' => 'fr-fr;q=0.8' }
    assert_equal :fr, preferred_locale.to_sym
  end

  test "does not set a bad locale via http header" do
    @request_env = { 'HTTP_ACCEPT_LANGUAGE' => 'notagoodone' }
    assert_equal I18n.default_locale, preferred_locale.to_sym
  end

  test "uses default_locale by default" do
    assert_equal I18n.default_locale, preferred_locale.to_sym
  end
end
