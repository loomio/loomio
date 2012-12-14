ActiveAdmin.register Group do
  actions :index, :show
  filter :name
  filter :creator
  filter :parent

  scope :all, :default => true do |group|
    group.includes [:creator]
  end

  index :download_links => false do
    column :id
    column :name
    column :max_size
    column "Members", :memberships_count
    column "Discussions", :discussions_count
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
