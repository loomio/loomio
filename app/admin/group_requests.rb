ActiveAdmin.register GroupRequest do
  scope :awaiting_approval, :default => true
  scope :approved
  scope :ignored

  index do
    column :id
    column :name
    column :expected_size
    column :description
    column :admin_email
    column "Can Contribute", :sortable => :cannot_contribute do |group_request|
      !group_request.cannot_contribute
    end
    column "Approve" do |group_request|
      link = ""
      if group_request.awaiting_approval? or group_request.ignored?
        link += link_to "Approve",
               approve_admin_group_request_path(group_request.id),
               :method => :put, :id => "approve_group_request_#{group_request.id}"
      end
      if group_request.awaiting_approval?
        link += " | "
        link += link_to "Ignore",
                ignore_admin_group_request_path(group_request.id),
                :method => :put, :id => "ignore_group_request_#{group_request.id}"
      end
      link.html_safe
    end
    column :created_at
    default_actions
  end

  member_action :approve, :method => :put do
    group_request = GroupRequest.find(params[:id])
    group_request.approve!
    group = group_request.group
    redirect_to admin_group_requests_path,
      :notice => ("Group approved: " +
      "<a href='#{admin_group_path(group)}'>#{group.name}</a>").html_safe
  end

  member_action :ignore, :method => :put do
    group_request = GroupRequest.find(params[:id])
    group_request.ignore!
    group = group_request.group
    redirect_to admin_group_requests_path, :notice => "Group request ignored."
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :admin_email
      f.input :expected_size
      f.input :description
    end
    f.buttons
  end
end
