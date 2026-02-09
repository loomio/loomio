class HelpController < ApplicationController
  def markdown
    render layout: false
  end

  def api
    current_user.save if current_user.api_key_changed?
    render Views::Help::Api.new(
      api_key: current_user.api_key,
      group_id: params[:group_id] || 123,
      email: current_user.email,
      root_url: root_url
    )
  end

  def api2
    current_user.save if current_user.api_key_changed?
    render Views::Help::Api2.new(
      api_key: current_user.api_key,
      group_id: params[:group_id] || 123,
      email: current_user.email,
      root_url: root_url,
      user: current_user
    )
  end

  def api3
    render Views::Help::Api3.new(root_url: root_url)
  end
end
