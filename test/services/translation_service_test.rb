require 'test_helper'
require 'minitest/mock'

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
end
