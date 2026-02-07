# frozen_string_literal: true

class Views::Chatbot::Base < Views::Base
  include EmailHelper
  include FormattedDateHelper
  include Phlex::Rails::Helpers::T
  include Phlex::Rails::Helpers::LinkTo
  include Phlex::Rails::Helpers::ImageTag
end
