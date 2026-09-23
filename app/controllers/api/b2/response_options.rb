module Api::B2::ResponseOptions
  extend ActiveSupport::Concern

  COMPACT_EXCLUDE_TYPES = %w[topic group parent membership reaction tag translation].freeze

  private

  def exclude_types
    types = super
    return types unless params[:compact].to_s == "1"

    (types + COMPACT_EXCLUDE_TYPES).uniq
  end

  def response_meta(root)
    super.tap { |response_meta| response_meta.delete(:total) if collection_count.nil? }
  end
end
