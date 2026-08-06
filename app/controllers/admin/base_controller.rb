# frozen_string_literal: true

class Admin::BaseController < ApplicationController
  before_action :authenticate_admin_user!

  private

  def authenticate_admin_user!
    return unless authenticate_user!
    return if current_user.is_admin?

    redirect_to dashboard_path
  end

  def paginate(relation, per_page: 50)
    page = [params.fetch(:page, 1).to_i, 1].max
    count = relation.count
    count = count.length if count.is_a?(Hash)
    page_count = [(count.to_f / per_page).ceil, 1].max
    page = page_count if page > page_count

    [
      relation.limit(per_page).offset((page - 1) * per_page),
      { page: page, page_count: page_count, count: count }
    ]
  end
end
