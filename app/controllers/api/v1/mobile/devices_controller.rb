class Api::V1::Mobile::DevicesController < Api::V1::Mobile::BaseController
  before_action -> { require_mobile_scope!("device:revoke") }, only: :destroy

  def show
    render json: device_json
  end

  def destroy
    current_mobile_device.revoke!
    head :no_content
  end

  private

  def device_json
    {
      id: current_mobile_device.id,
      name: current_mobile_device.name,
      platform: current_mobile_device.platform,
      protocol_version: current_mobile_device.protocol_version,
      created_at: current_mobile_device.created_at,
      last_seen_at: current_mobile_device.last_seen_at
    }
  end
end
