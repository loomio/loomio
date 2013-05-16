ActiveAdmin.register CampaignSignup do
  index do
    column "Campaign" do |signup|
      signup.campaign.name.titlecase if signup.campaign
    end
    column :email
    column :name
    column :created_at
    column :spam
  end
end
