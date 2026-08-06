# frozen_string_literal: true

class Admin::UsersController < Admin::BaseController
  before_action :load_user, only: %i[show edit update login_as merge redact deactivate reactivate delete_spam delete_identity]

  def index
    users, pagination = paginate(filtered_users)
    render Views::Admin::Users::Index.new(users: users, pagination: pagination, filters: filter_params)
  end

  def show
    render Views::Admin::Users::Show.new(user: @user)
  end

  def edit
    render Views::Admin::Users::Edit.new(user: @user)
  end

  def update
    @user.update!(user_params)
    redirect_to admin_user_path(@user), notice: "User updated"
  end

  def login_as
    token = @user.login_tokens.create!
    render Views::Admin::Users::LoginAs.new(user: @user, token: token)
  end

  def merge
    destination = User.find_by!(email: params.require(:destination_email).strip)
    MigrateUserWorker.perform_later(@user.id, destination.id)
    redirect_to admin_user_path(destination), notice: "Account merge started"
  end

  def redact
    RedactUserWorker.perform_later(@user.id, current_user.id)
    redirect_to admin_users_path, notice: "User scheduled for redaction"
  end

  def deactivate
    DeactivateUserWorker.perform_later(@user.id, current_user.id)
    redirect_to admin_users_path, notice: "User scheduled for deactivation"
  end

  def reactivate
    ReactivateUserWorker.perform_later(@user.id)
    redirect_to admin_users_path, notice: "User scheduled for reactivation"
  end

  def delete_spam
    DestroyUserWorker.perform_later(@user.id)
    redirect_to admin_users_path, notice: "User scheduled for spam deletion"
  end

  def delete_identity
    @user.identities.find(params.require(:identity_id)).destroy!
    redirect_to admin_user_path(@user), notice: "Identity deleted"
  end

  private

  def load_user
    @user = User.friendly.find(params[:id])
  end

  def filtered_users
    relation = User.order(created_at: :desc)
    filters = filter_params
    if filters[:search].present?
      search = "%#{ActiveRecord::Base.sanitize_sql_like(filters[:search])}%"
      relation = relation.where("users.name ILIKE :search OR users.username ILIKE :search OR users.email ILIKE :search", search: search)
    end
    relation = relation.coordinators if filters[:coordinators] == "1"
    relation = relation.where(email_verified: filters[:email_verified] == "true") if filters[:email_verified].present?
    relation = relation.where.not(deactivated_at: nil) if filters[:deactivated] == "1"
    relation = relation.where(detected_locale: filters[:locale]) if filters[:locale].present?
    relation = relation.where(created_at: Date.parse(filters[:created_from])..) if filters[:created_from].present?
    relation = relation.where(created_at: ..Date.parse(filters[:created_to]).end_of_day) if filters[:created_to].present?
    relation.distinct
  rescue Date::Error
    relation.distinct
  end

  def filter_params
    params.permit(:search, :coordinators, :email_verified, :deactivated, :locale, :created_from, :created_to, :page, :commit).except(:page, :commit)
  end

  def user_params
    params.require(:user).permit(:name, :email, :username, :complaints_count, :bounces_count, :is_admin, :bot)
  end
end
