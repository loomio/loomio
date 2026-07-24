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

  test "inline does not expose another user's hidden anonymous stance reason" do
    poll, stance = anonymous_poll_and_stance
    Translation.create!(translatable: stance, language: 'fr', fields: {'reason' => 'Raison privée'})
    sign_in @user

    TranslationService.stub(:available?, false) do
      get :inline, params: {model: 'stance', stance_id: stance.id, to: 'fr'}
    end

    assert_response :forbidden
    refute_includes response.body, 'Raison privée'
  end

  test "inline uses an opaque id once an anonymous stance reason is visible" do
    poll, stance = anonymous_poll_and_stance
    poll.update!(closed_at: Time.current)
    Translation.create!(translatable: stance, language: 'fr', fields: {'reason' => 'Raison visible'})
    sign_in @user

    TranslationService.stub(:available?, false) do
      get :inline, params: {model: 'stance', stance_id: stance.id, to: 'fr'}
    end

    assert_response :success
    translation = JSON.parse(response.body).fetch('translations').first
    assert_equal Stance.anonymous_id_for(poll_id: poll.id, stance_id: stance.id), translation['translatable_id']
    refute_equal stance.id, translation['translatable_id']
  end

  private

  def anonymous_poll_and_stance
    voter = users(:member)
    groups(:group).add_member!(voter)
    poll = PollService.create(params: {
      title: 'Anonymous translated stance',
      poll_type: 'proposal',
      group_id: groups(:group).id,
      anonymous: true,
      hide_results: 'until_closed',
      poll_option_names: %w[Agree Disagree],
      closing_at: 1.day.from_now
    }, actor: users(:admin))
    stance = poll.stances.latest.find_by!(participant_id: voter.id)
    stance.update_columns(reason: 'Private source reason', cast_at: Time.current)
    [poll, stance]
  end
end
