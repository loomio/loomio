require 'test_helper'

class Api::V1::TranslationsControllerTest < ActionController::TestCase
  setup do
    @user = users(:user)
    @discussion = discussions(:discussion)
  end

  test "inline requires a signed in user" do
    TranslationService.stub(:available?, true) do
      get :inline, params: { model: 'discussion', id: @discussion.id, to: 'fr' }
    end

    assert_response :unauthorized
  end

  test "inline rejects unsupported locales before translating" do
    sign_in @user

    TranslationService.stub(:available?, true) do
      get :inline, params: { model: 'discussion', id: @discussion.id, to: 'not-a-locale' }
    end

    assert_response :unprocessable_entity
  end

  test "inline returns unavailable when translation service is disabled" do
    sign_in @user

    TranslationService.stub(:available?, false) do
      get :inline, params: { model: 'discussion', id: @discussion.id, to: 'fr' }
    end

    assert_response :service_unavailable
  end

  test "inline does not throttle cached translations" do
    sign_in @user

    Translation.create!(
      translatable: @discussion,
      language: 'fr',
      fields: { 'title' => 'Cached title' }
    )

    TranslationService.stub(:available?, false) do
      ThrottleService.stub(:can?, ->(**) { raise "Throttle should not be checked for cached translations" }) do
        get :inline, params: { model: 'discussion', id: @discussion.id, to: 'fr' }
      end
    end

    assert_response :success
  end

  test "inline throttles uncached translations" do
    sign_in @user

    TranslationService.stub(:available?, true) do
      ThrottleService.stub(:can?, false) do
        get :inline, params: { model: 'discussion', id: @discussion.id, to: 'fr' }
      end
    end

    assert_response :too_many_requests
  end
end
