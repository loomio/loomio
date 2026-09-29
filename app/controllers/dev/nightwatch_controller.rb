require_relative Rails.root.join('test/reset_database_helper')
class Dev::NightwatchController < Dev::BaseController
  include ResetDatabaseHelper
  include Dev::NintiesMoviesHelper
  include PrettyUrlHelper

  include Dev::Scenarios::Util
  include Dev::Scenarios::Auth
  include Dev::Scenarios::Dashboard
  include Dev::Scenarios::Discussion
  include Dev::Scenarios::EmailSettings
  include Dev::Scenarios::Group
  include Dev::Scenarios::Inbox
  include Dev::Scenarios::JoinGroup
  include Dev::Scenarios::MembershipRequest
  include Dev::Scenarios::Membership
  include Dev::Scenarios::Notification
  include Dev::Scenarios::OatmilkCooperative
  include Dev::Scenarios::Profile
  include Dev::Scenarios::Tags

  around_action :deliver_preview_emails_inline, if: -> { action_name.include?('_mailer_') }
  after_action :age_manual_scenario, if: -> { action_name.start_with?('setup_manual_') }

  before_action :reset_transient_state, except: [
    :last_email,
    :last_login_code,
    :use_last_login_token,
    :index,
    :accept_last_invitation,
    :revoke_secret_group_access,
    :view_email_catch_up_settings,
    :view_thread_email_settings,
  ]
  before_action :reset_database, except: [
    :last_email,
    :last_login_code,
    :use_last_login_token,
    :index,
    :accept_last_invitation,
    :revoke_secret_group_access,
    :view_email_catch_up_settings,
    :view_thread_email_settings,
  ]


  def reset_transient_state
    Rails.cache.clear
    ActionMailer::Base.deliveries.clear
    flash.clear
  end

  private

  # Manual screenshots show relative times such as "Opened 2 hours ago".
  # Scenarios are built at the real time, so a capture would otherwise read "1
  # second ago" one time and "3 seconds ago" the next. The database is reset
  # before each scenario, so every row belongs to it: move all timestamps back
  # by the same age. Sessions stay current so sign-in checks behave normally.
  def age_manual_scenario
    Rails.application.eager_load! unless Rails.application.config.eager_load
    age = Arel.sql("interval '2 hours'")
    models = ActiveRecord::Base.descendants.reject(&:abstract_class?).uniq(&:table_name)
    models.each do |model|
      next if model.table_name == 'sessions' || model.table_name.start_with?('solid_') || !model.table_exists?

      columns = model.columns.select { |column| column.type == :datetime }.map(&:name)
      next if columns.empty?

      model.unscoped.update_all(columns.to_h { |name| [name, Arel::Nodes::Subtraction.new(model.arel_table[name], age)] })
    end
  end

  # Mail previews read in-process deliveries, so their jobs must finish in the request.
  def deliver_preview_emails_inline
    previous_adapter = ActiveJob::Base.queue_adapter
    ActiveJob::Base.queue_adapter = :inline
    yield
  ensure
    ActiveJob::Base.queue_adapter = previous_adapter
  end
end
