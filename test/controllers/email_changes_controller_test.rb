require 'test_helper'

class EmailChangesControllerTest < ActionController::TestCase
  setup do
    @disable_edit_user_profile_previous = ENV.delete('LOOMIO_DISABLE_EDIT_USER_PROFILE')
    @force_user_attrs_previous = ENV.delete('LOOMIO_SSO_FORCE_USER_ATTRS')
    @user = users(:user)
    @old_email = @user.email
    @new_email = 'confirmed-address@example.com'
    ActionMailer::Base.deliveries.clear
    perform_enqueued_jobs do
      EmailChangeService.request(user: @user, actor: @user, email: @new_email)
    end
    confirmation_mail = ActionMailer::Base.deliveries.find { |mail| mail.to == [@new_email] }
    link = Nokogiri::HTML(confirmation_mail.html_part.body.decoded).at_css('a.email-button')['href']
    @token = Rack::Utils.parse_query(URI.parse(link).query).fetch('token')
  end

  teardown do
    @disable_edit_user_profile_previous.nil? ? ENV.delete('LOOMIO_DISABLE_EDIT_USER_PROFILE') : ENV['LOOMIO_DISABLE_EDIT_USER_PROFILE'] = @disable_edit_user_profile_previous
    @force_user_attrs_previous.nil? ? ENV.delete('LOOMIO_SSO_FORCE_USER_ATTRS') : ENV['LOOMIO_SSO_FORCE_USER_ATTRS'] = @force_user_attrs_previous
  end

  test 'a signed-out visitor can view the confirmation page without changing the email' do
    get :confirm, params: {user_id: @user.id, token: @token}

    assert_response :success
    assert_equal @old_email, @user.reload.email
    assert_includes response.body, @new_email
    assert_equal 'no-store', response.headers['Cache-Control']
    assert_equal 'no-referrer', response.headers['Referrer-Policy']
  end

  test 'a signed-out visitor can confirm with the link' do
    post :apply, params: {user_id: @user.id, token: @token}

    assert_response :success
    assert_equal @new_email, @user.reload.email
    assert_nil @user.email_change_pending
  end

  test 'changing the account ID invalidates the link' do
    post :apply, params: {user_id: users(:alien).id, token: @token}

    assert_response :unprocessable_entity
    assert_equal @old_email, @user.reload.email
  end

  test 'a forged confirmation link cannot change the email' do
    post :apply, params: {user_id: @user.id, token: 'invalid'}

    assert_response :unprocessable_entity
    assert_equal @old_email, @user.reload.email
  end

  test 'a pending link cannot be used after SSO-managed profile editing is enabled' do
    ENV['LOOMIO_SSO_FORCE_USER_ATTRS'] = '1'

    get :confirm, params: {user_id: @user.id, token: @token}
    assert_response :forbidden

    post :apply, params: {user_id: @user.id, token: @token}
    assert_response :forbidden
    assert_equal @old_email, @user.reload.email
  end
end
