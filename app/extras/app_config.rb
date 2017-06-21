class AppConfig
  CONFIG_FILES = %w(
    colors
    durations
    emojis
    plugins
    poll_templates
    providers
    timezones
  )

  CONFIG_FILES.each do |config|
    define_singleton_method(config) do
      instance_variable_get(:"@#{config}") ||
      instance_variable_set(:"@#{config}", YAML.load_file(Rails.root.join("config", "#{config}.yml")))
    end
  end
end
