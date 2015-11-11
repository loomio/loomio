class E2eTestController < ApplicationController
  around_filter :ensure_testing_environment

  # supports setting up any group as defined in params[:group]
  # supports an extras array with things like [add_public_discussion, add_private_discussion]
  # supports login_as=patrick
  def setup_group

  end

  def ensure_testing_environment
    raise "Do not call me." if Rails.env.production?
    tmp, Rails.env = Rails.env, 'test'
    yield
    Rails.env = tmp
  end

  def cleanup_database
    User.delete_all
    Group.delete_all
    ActionMailer::Base.deliveries = []
  end
end
