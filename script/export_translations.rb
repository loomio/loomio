require 'yaml'
require 'json'

# currently this is not used, but some time in the future we'll want to export these during build
require_relative '../lib/version'
require_relative '../lib/version/major'
require_relative '../lib/version/minor'
require_relative '../lib/version/patch'
require_relative '../lib/version/pre'

class ::Hash
  def deep_merge(second)
      merger = proc { |key, v1, v2| Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) : v2 }
      self.merge(second, &merger)
  end
end

Dir.glob('config/locales/client.*.yml').each do |filename|
  source = YAML.load_file(filename)
  locale = source.keys.first
  source = source[locale]

  fallback = YAML.load_file('config/locales/client.en.yml')['en']
  dest = fallback.deep_merge(source)

  File.open("public/i18n/#{locale}-#{Loomio::Version.current}.json", 'w') do |file|
    file.write(dest.to_json)
  end
end
