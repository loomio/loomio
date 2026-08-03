require 'test_helper'

class TranslationServiceTest < ActiveSupport::TestCase
  setup do
    @old_backend = I18n.backend
    @old_locale = I18n.locale
    @old_enforce = I18n.enforce_available_locales

    I18n.locale = :en
    I18n.backend = I18n::Backend::Simple.new
    I18n.enforce_available_locales = false

    @user = users(:user)
    @group = groups(:group)
  end

  teardown do
    I18n.backend = @old_backend
    I18n.locale = @old_locale
    I18n.enforce_available_locales = @old_enforce
  end

  test "uses Rails I18n translation for known labels and does not call Google Translate" do
    poll = PollService.create(params: {
      title: 'Test Poll',
      poll_type: 'proposal',
      closing_at: 3.days.from_now,
      group_id: @group.id,
      poll_option_names: ['agree', 'disagree']
    }, actor: @user)

    poll_option = poll.poll_options.find_by!(name: 'Agree')

    # Provide translations under a wildcard-able namespace
    I18n.backend.store_translations(:en, poll_proposal_options: { agree: 'Agree' })
    I18n.backend.store_translations(:fr, poll_proposal_options: { agree: "D'accord" })

    # Create a stub that will raise if Google Translate is called
    translate_called = false
    google_service = Object.new
    google_service.define_singleton_method(:translate) do |*args, **kwargs|
      translate_called = true
      raise "Google Translate should not be called for I18n-known labels"
    end

    Google::Cloud::Translate.stub :translation_v2_service, google_service do
      translation = TranslationService.create(model: poll_option, to: 'fr')

      assert translation.persisted?
      assert_equal 'fr', translation.language
      assert translation.fields['name'].include?('accord'), "Expected translation to include 'accord'"
    end

    assert_equal false, translate_called
  end

  test "falls back to Google Translate for custom field values" do
    poll = PollService.create(params: {
      title: 'Test Poll',
      poll_type: 'proposal',
      closing_at: 3.days.from_now,
      group_id: @group.id,
      poll_option_names: ['agree', 'disagree']
    }, actor: @user)

    poll_option = PollOption.create!(poll: poll, name: 'Plan X')

    # Create a stub that returns translated text and validates arguments
    test_context = self
    translate_text = nil
    translate_options = nil

    google_service = Object.new
    google_service.define_singleton_method(:translate) do |text, **options|
      translate_text = text
      translate_options = options
      'Plan X FR'
    end

    Google::Cloud::Translate.stub :translation_v2_service, google_service do
      translation = TranslationService.create(model: poll_option, to: 'fr')

      assert translation.persisted?
      assert_equal 'fr', translation.language
      assert_equal 'Plan X FR', translation.fields['name']
      assert_nil translation.fields['meaning']
      assert_nil translation.fields['prompt']
    end

    # Verify Google Translate was called with correct arguments
    assert_equal 'Plan X', translate_text
    assert_equal 'fr', translate_options[:to]
    assert_equal :text, translate_options[:format]
  end

  test "counts and logs characters before calling Google Translate" do
    throttle_args = nil
    log_args = nil
    translate_args = nil

    logger = Object.new
    logger.define_singleton_method(:info) do |message, **attributes|
      log_args = [message, attributes]
    end

    google_service = Object.new
    google_service.define_singleton_method(:translate) do |content, **options|
      translate_args = [content, options]
      'Kia ora'
    end

    ThrottleService.stub(:can?, ->(**args) { throttle_args = args; true }) do
      Sentry.stub(:logger, logger) do
        Google::Cloud::Translate.stub(:translation_v2_service, google_service) do
          result = TranslationService.translate_text(
            'Hello',
            to: 'mi',
            source_locale: 'en',
            source: 'test'
          )

          assert_equal 'Kia ora', result
        end
      end
    end

    assert_equal({
      key: 'TranslationCharacters',
      id: 'all',
      max: 10_000,
      inc: 5,
      per: 'day'
    }, throttle_args)
    assert_equal ['Hello', { to: 'mi', format: :text }], translate_args
    assert_equal 'google translation request', log_args[0]
    assert_equal 'translation_api', log_args[1][:audit_kind]
    assert_equal 5, log_args[1][:character_count]
    assert_equal 'test', log_args[1][:source]
  end

  test "does not call Google Translate after reaching the daily character limit" do
    error_log = nil
    logger = Object.new
    logger.define_singleton_method(:error) do |message, **attributes|
      error_log = [message, attributes]
    end

    ThrottleService.stub(:can?, false) do
      Sentry.stub(:logger, logger) do
        assert_raises TranslationService::CharacterLimitReached do
          TranslationService.translate_text('Hello', to: 'mi')
        end
      end
    end

    assert_equal 'google translation daily character limit reached', error_log[0]
    assert_equal 'translation_api', error_log[1][:audit_kind]
    assert_equal 10_000, error_log[1][:character_limit_day]
  end

  test "allows translation audit logs through the Sentry log filter" do
    log = Struct.new(:level, :attributes).new(:info, { 'audit_kind' => 'translation_api' })

    assert_same log, Sentry.configuration.before_send_log.call(log)
  end
end
