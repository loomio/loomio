module Loomio
  class I18n
    require 'yaml'
    config = YAML.load_file('config/loomio_i18n.yml')['loomio_i18n']

    SELECTABLE_LOCALES = Array(config['selectable_locales']).map(&:to_sym)
    DETECTABLE_LOCALES = Array(config['additional_detectable_locales']).map(&:to_sym) + SELECTABLE_LOCALES

    RTL_LOCALES  = Array(config['rtl_locales']).map(&:to_sym)
    TEST_LOCALES = Array(config['test_locales']).map(&:to_sym)

    FALLBACKS = Hash(config['fallbacks']).inject({}) do |new_hash, (k,v)| 
      new_hash[k.to_sym] = v.to_sym
      new_hash
    end

  end
end

