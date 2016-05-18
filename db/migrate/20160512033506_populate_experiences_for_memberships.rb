class PopulateExperiencesForMemberships < ActiveRecord::Migration
  def up
    Membership.update_all experiences: { welcomeModal: true }
  end

  def down
    Membership.update_all experiences: {}
  end
end
