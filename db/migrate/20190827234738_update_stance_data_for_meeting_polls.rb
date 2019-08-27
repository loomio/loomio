class UpdateStanceDataForMeetingPolls < ActiveRecord::Migration[5.2]
  def change
    Poll.where(poll_type: 'meeting').order('id desc').each(&:update_stance_data)
  end
end
