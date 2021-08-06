class UpdatePollStanceData < ActiveRecord::Migration[6.0]
  def change
    Poll.order('id desc').find_each do |poll|
      ResetPollStanceDataWorker.perform_async(poll.id)
    end
  end
end
