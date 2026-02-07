# frozen_string_literal: true

class Views::Base < Components::Base
  def cache_store = Rails.cache
end
