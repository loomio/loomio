require 'test_helper'

class TranslationServiceTest < ActiveSupport::TestCase
  setup do
    @old_backend = I18n.backend
    @old_locale = I18n.locale
    @old_enforce = I18n.enforce_available_locales

    I18n.locale = :en
    I18n.backend = I18n::Backend::Simple.new
    I18n.enforce_available_locales = false

    @user = users(:normal_user)
    @group = groups(:test_group)

    @old_provider = TranslationService.instance_variable_get(:@provider)
  end

  teardown do
    I18n.backend = @old_backend
    I18n.locale = @old_locale
    I18n.enforce_available_locales = @old_enforce
    TranslationService.instance_variable_set(:@provider, @old_provider)
  end

  test "uses Rails I18n translation for known labels and does not call provider" do
    poll = Poll.new(
      title: 'Test Poll',
      author: @user,
      poll_type: 'proposal',
      closing_at: 3.days.from_now,
      poll_option_names: []
    )
    PollService.create(poll: poll, actor: @user)

    poll_option = PollOption.create!(poll: poll, name: 'Agree')

    I18n.backend.store_translations(:en, poll_proposal_options: { agree: 'Agree' })
    I18n.backend.store_translations(:fr, poll_proposal_options: { agree: "D'accord" })

    translate_called = false
    fake_provider = Object.new
    fake_provider.define_singleton_method(:translate) do |*args, **kwargs|
      translate_called = true
      raise "Provider should not be called for I18n-known labels"
    end
    fake_provider.define_singleton_method(:normalize_locale) { |locale| locale.to_s }

    TranslationService.instance_variable_set(:@provider, fake_provider)

    translation = TranslationService.create(model: poll_option, to: 'fr')

    assert translation.persisted?
    assert_equal 'fr', translation.language
    assert translation.fields['name'].include?('accord'), "Expected translation to include 'accord'"
    assert_nil translation.fields['meaning']
    assert_nil translation.fields['prompt']

    assert_equal false, translate_called
  end

  test "falls back to provider for custom field values" do
    poll = Poll.new(
      title: 'Test Poll',
      author: @user,
      poll_type: 'proposal',
      closing_at: 3.days.from_now,
      poll_option_names: []
    )
    PollService.create(poll: poll, actor: @user)

    poll_option = PollOption.create!(poll: poll, name: 'Plan X')

    translate_text = nil
    translate_options = nil

    fake_provider = Object.new
    fake_provider.define_singleton_method(:translate) do |text, **options|
      translate_text = text
      translate_options = options
      'Plan X FR'
    end
    fake_provider.define_singleton_method(:normalize_locale) { |locale| locale.to_s }

    TranslationService.instance_variable_set(:@provider, fake_provider)

    translation = TranslationService.create(model: poll_option, to: 'fr')

    assert translation.persisted?
    assert_equal 'fr', translation.language
    assert_equal 'Plan X FR', translation.fields['name']
    assert_nil translation.fields['meaning']
    assert_nil translation.fields['prompt']

    assert_equal 'Plan X', translate_text
    assert_equal 'fr', translate_options[:to]
    assert_equal :text, translate_options[:format]
  end
end
