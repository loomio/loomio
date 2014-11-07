class API::BaseController < ActionController::Base
  include CurrentUserHelper
  include ::ProtectedFromForgery
  skip_after_filter :intercom_rails_auto_include
  after_filter :increment_measurement
  respond_to :json

  before_filter :authorize_group, :authorize_discussion, :authorize_motion

  protected

  def increment_measurement
    Measurement.increment(measurement_name)
  end

  def measurement_name
    "#{controller_name}.#{action_name}"
  end

  def permitted_params
    @permitted_params ||= PermittedParams.new(params, current_user)
  end

  def require_authenticated_user
    head 401 unless current_user
  end

  def authenticate_user_by_email_api_key
    user_id = request.headers['Loomio-User-Id']
    key = request.headers['Loomio-Email-API-Key']
    @current_user = User.where(id: user_id, email_api_key: key).first
  end

  def authorize_group
    if params[:group_id].present?
      @group = Group.find(params[:group_id])
      authorize! :show, @group
    end
  end

  def authorize_discussion
    if params[:discussion_id].present?
      @discussion = Discussion.find(params[:discussion_id])
      authorize! :show, @discussion
    end
  end

  def authorize_motion
    if params[:motion_id].present?
      @motion = Motion.find(params[:motion_id])
      authorize! :show, @motion
    end
  end
end
