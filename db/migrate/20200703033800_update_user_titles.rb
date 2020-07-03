class UpdateUserTitles < ActiveRecord::Migration[5.2]
  def change
    Membership.where("title is not null").pluck(:id).each do |id|
      MembershipService.delay.update_user_titles_and_broadcast(id)
    end
  end
end
