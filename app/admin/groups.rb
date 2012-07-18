ActiveAdmin.register Group do
  scope :all, :default => true do |group|
    group.includes [:creator]
  end

  index do
    column :id
    column :name
    column "Members", :memberships_count
    column :creator, :sortable => 'users.name'
    column :created_at
    column :viewable_by
    column :description, :sortable => :description do |group|
      group.description
    end
    default_actions
  end
end
