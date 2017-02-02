module Development::BaseHelper
  private
  def ensure_testing_environment
    raise "Do not call me." if Rails.env.production?
  end

  def cleanup_database
    User.delete_all
    Group.delete_all
    Membership.delete_all

    ActionMailer::Base.deliveries = []
  end
end
