module LegacyVariationTranslator
  GEOMETRY = /\A(\d+)x(\d+)([>^!])?\z/

  def self.call(transformations)
    return transformations unless transformations.is_a?(Hash)

    transformations.each_with_object({}) do |(key, value), out|
      if key.to_sym == :resize && value.is_a?(String) && (match = value.match(GEOMETRY))
        width = match[1].to_i
        height = match[2].to_i
        macro = case match[3]
                when "^" then :resize_to_fill
                when "!" then :resize_to_fit
                else          :resize_to_limit
                end
        out[macro] = [width, height]
      else
        out[key] = value
      end
    end
  end
end

module ActiveStorageRepresentationLegacyRescue
  private

  def set_representation
    super
  rescue TypeError => error
    raise error if params[:variation_key].blank?

    original = ActiveStorage::Variation.decode(params[:variation_key]).transformations
    translated = LegacyVariationTranslator.call(original)
    raise error if translated == original

    Rails.logger.warn("Translating legacy ActiveStorage variation #{original.inspect} -> #{translated.inspect}")
    @representation = @blob.representation(translated).processed
  end
end

Rails.application.config.to_prepare do
  ActiveStorage::Representations::BaseController.prepend(ActiveStorageRepresentationLegacyRescue)
end
