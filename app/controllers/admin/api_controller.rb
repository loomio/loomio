# frozen_string_literal: true

class Admin::ApiController < Admin::BaseController
  def show
    markdown = Rails.root.join("docs", "api", "b3.md").read
    markdown = markdown.gsub("{{root_url}}", root_url)

    render Views::Admin::Api.new(markdown: markdown, status: api_status)
  end

  private

  def api_status
    return :disabled_missing unless ENV.key?("B3_API_KEY")
    return :disabled_invalid unless ENV.fetch("B3_API_KEY").length > 16

    :enabled
  end
end
