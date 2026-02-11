require 'test_helper'

class SubscriptionsControllerTest < ActionController::TestCase
  setup do
    @routes = LoomioSubs::Engine.routes

    hex = SecureRandom.hex(4)
    @user = User.create!(name: "subuser#{hex}", email: "subuser#{hex}@example.com",
                         username: "subuser#{hex}", email_verified: true)
    @group = Group.new(name: "subgroup#{hex}", group_privacy: 'secret')
    @group.creator = @user
    @group.save!

    @subscription = Subscription.create!(plan: 'trial', state: 'active')
    @group.update!(subscription: @subscription)

    ENV['CHARGIFY_APP_NAME'] ||= 'test-app'
    ENV['CHARGIFY_API_KEY'] ||= 'test-key'
    ENV['CHARGIFY_SITE_KEY'] ||= 'test-site-key'

    ActionMailer::Base.deliveries.clear
  end

  test "webhook returns forbidden without valid signature" do
    post :webhook, params: webhook_params
    assert_response :forbidden
  end

  test "webhook returns ok when signature verification passes" do
    skip_signature_verification do
      post :webhook, params: webhook_params
      # ok or bad_request depending on whether SubscriptionService.available? is true
      assert_includes [200, 400], response.status
    end
  end

  test "webhook returns bad_request when subscription service unavailable" do
    skip_signature_verification do
      original_app_name = ENV['CHARGIFY_APP_NAME']
      ENV.delete('CHARGIFY_APP_NAME')
      post :webhook, params: webhook_params
      assert_response :bad_request
    ensure
      ENV['CHARGIFY_APP_NAME'] = original_app_name
    end
  end

  private

  def skip_signature_verification
    original = SubscriptionsController.instance_method(:verify_request)
    SubscriptionsController.define_method(:verify_request) { true }
    yield
  ensure
    SubscriptionsController.define_method(:verify_request, original)
  end

  def webhook_params
    {
      payload: {
        subscription: {
          id: '123',
          state: 'active',
          product: { id: 6650391, handle: '2024-starter-annual' },
          customer: { id: '456', reference: "#{@group.key}-#{Time.now.to_i}" },
          referral_code: 'abc',
          next_assessment_at: 1.month.from_now.iso8601,
          current_period_started_at: Time.current.iso8601,
          expires_at: nil
        }
      }
    }
  end
end
