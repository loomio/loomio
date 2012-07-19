ActiveAdmin.register Group do
  actions :index, :show

  scope :all, :default => true do |group|
    group.includes [:creator]
  end

  index do
    column :id
    column :name
    column "Members", :memberships_count
    column "Discussions" do |group|
      group.discussions.count
    end
    column "Motions" do |group|
      group.motions.count
    end
    column :creator, :sortable => 'users.name'
    column :created_at
    column :viewable_by
    column :description, :sortable => :description do |group|
      group.description
    end
    default_actions
  end
end
