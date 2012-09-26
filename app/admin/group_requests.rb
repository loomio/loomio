ActiveAdmin.register GroupRequest do
  index do
    column :id
    column :name
    column :expected_size
    column :description
    column :admin_email
    column :created_at
    column "Approve" do |group_request|
      link_to "Approve", approve_admin_group_request_path(group_request.id),
        :method => :put, :id => "approve_group_request_#{group_request.id}"
    end
    default_actions
  end

  member_action :approve, :method => :put do
    group_request = GroupRequest.find(params[:id])
    group = group_request.approve!
    redirect_to admin_group_requests_path,
      :notice => "Group approved: #{link_to(group.name, admin_group_path(group))}"
  end
end
