module LegacyVariationTranslator
  GEOMETRY = /\A(\d+)x(\d+)([>^!])?\z/
  SAVER_KEYS = %i[quality strip format colorspace interlace].freeze

  def self.call(transformations)
    return transformations unless transformations.is_a?(Hash)

    out = {}
    saver = {}

    transformations.each do |key, value|
      sym_key = key.to_sym

      if sym_key == :resize && value.is_a?(String) && (match = value.match(GEOMETRY))
        macro = case match[3]
                when "^" then :resize_to_fill
                when "!" then :resize_to_fit
                else          :resize_to_limit
                end
        out[macro] = [match[1].to_i, match[2].to_i]
      elsif sym_key == :saver && value.is_a?(Hash)
        saver.merge!(value.transform_keys(&:to_sym))
      elsif SAVER_KEYS.include?(sym_key)
        saver[sym_key] = coerce_saver_value(sym_key, value)
      else
        out[key] = value
      end
    end

    out[:saver] = saver unless saver.empty?
    out
  end

  def self.coerce_saver_value(key, value)
    case key
    when :quality then Integer(value) rescue value
    when :strip, :interlace
      case value
      when "true", "1", 1 then true
      when "false", "0", 0 then false
      else value
      end
    else value
    end
  end
end

module ActiveStorageRepresentationLegacyRescue
  private

  LEGACY_ERRORS = [TypeError, defined?(Vips::Error) ? Vips::Error : nil].compact.freeze

  def set_representation
    super
  rescue *LEGACY_ERRORS => error
    raise error if params[:variation_key].blank?

    original = ActiveStorage::Variation.decode(params[:variation_key]).transformations
    translated = LegacyVariationTranslator.call(original)
    raise error if translated == original

    Rails.logger.warn("Translating legacy ActiveStorage variation #{original.inspect} -> #{translated.inspect}")

    begin
      @representation = @blob.representation(translated).processed
    rescue *LEGACY_ERRORS => retry_error
      Rails.logger.warn("Legacy variation retry failed: #{retry_error.class}: #{retry_error.message}")
      head :not_acceptable
    end
  end
end

Rails.application.config.to_prepare do
  ActiveStorage::Representations::BaseController.prepend(ActiveStorageRepresentationLegacyRescue)
end
