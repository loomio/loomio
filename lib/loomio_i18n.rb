require 'yaml'
module Loomio
  class I18n
    config = YAML.load_file(Rails.root.join('config', 'loomio_i18n.yml'))['loomio_i18n']

    SELECTABLE_LOCALES = Array(config['selectable_locales']).map(&:to_sym)
    DETECTABLE_LOCALES = Array(config['additional_detectable_locales']).map(&:to_sym) + SELECTABLE_LOCALES

    RTL_LOCALES  = Array(config['rtl_locales']).map(&:to_sym)
    TEST_LOCALES = Array(config['test_locales']).map(&:to_sym)

    FALLBACKS = Hash(config['fallbacks']).inject({}) do |new_hash, (k,v)|
      new_hash[k.to_sym] = v.to_sym
      new_hash
    end

    TRANSLATION_COVERAGE = (YAML.load_file Rails.root.join('.translation_coverage.yml')).with_indifferent_access

    js_unix_time_last_updated_at = (YAML.load_file Rails.root.join('.translation_updated_at.yml'))['updated_at']
    TRANSLATION_UPDATED_AT = Time.at( js_unix_time_last_updated_at/1000 ).to_datetime

    SELECTABLE_LOCALES.freeze
    DETECTABLE_LOCALES.freeze
    RTL_LOCALES.freeze
    TEST_LOCALES.freeze
    FALLBACKS.freeze
  end
end
