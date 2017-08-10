require 'yaml'
module Loomio
  class I18n
    config_yml = Rails.root.join('config', 'loomio_i18n.yml')
    config = Hash.new([]).merge(YAML.load_file(config_yml).fetch('loomio_i18n', {}))

    SELECTABLE_LOCALES = config['selectable_locales']
    DETECTABLE_LOCALES = config['additional_detectable_locales'] + config['selectable_locales']
    RTL_LOCALES        = config['rtl_locales']
    TEST_LOCALES       = config['test_locales']

    # return a fallback if it exists, but the default value is the key passed in.
    # So, the fallback for :pt is :pt-BR, but the 'fallback' for :en is :en
    FALLBACKS = Hash.new { |_,key| key }.merge(config['fallbacks']).with_indifferent_access

    TRANSLATION_COVERAGE = YAML.load_file(Rails.root.join('.translation_coverage.yml'))

    [
      SELECTABLE_LOCALES,
      DETECTABLE_LOCALES,
      RTL_LOCALES,
      TEST_LOCALES,
      FALLBACKS,
      TRANSLATION_COVERAGE
    ].map(&:freeze)

    js_unix_time_last_updated_at = (YAML.load_file Rails.root.join('.translation_updated_at.yml'))['updated_at']
    TRANSLATION_UPDATED_AT = Time.at( js_unix_time_last_updated_at/1000 ).to_datetime
  end
end
