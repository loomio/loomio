unless Rails.env.test?
  vars = YAML.load_file("#{Rails.root}/config/loomio.yml")

  missing = ->(array) { array.select { |key| !ENV.has_key? key.to_s } if array.present? }
  missing_required = missing.call vars['required']
  missing_optional = missing.call vars['optional']

  raise "You are missing the following required environment variables: #{missing_required}\n" +
        "Please set them to continue." if missing_required.present?
  Rails.logger.info "You are missing the following optional environment variables: #{missing_optional.keys}\n" +
                    "They have been set to defaults automatically."

  missing_optional.keys.each do |key|
    ENV[key] ||= missing_optional[key]
  end
end