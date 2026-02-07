# frozen_string_literal: true

class Views::Base < Components::Base
  include PrettyUrlHelper
  include PollHelper
  include FormattedDateHelper
  include Phlex::Rails::Helpers::T
  include Phlex::Rails::Helpers::LinkTo
  include Phlex::Rails::Helpers::ImageTag
  include Phlex::Rails::Helpers::ImagePath
  include Phlex::Rails::Helpers::Sanitize
  include Phlex::Rails::Helpers::StyleSheetLinkTag
  include Phlex::Rails::Helpers::NumberToHumanSize

  def cache_store = Rails.cache
end
