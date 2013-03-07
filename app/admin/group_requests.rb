ActiveAdmin.register GroupRequest do
  scope :awaiting_approval, :default => true
  scope :approved
  scope :accepted
  scope :ignored
  scope :marked_as_spam
  scope :all

  index do
    column :id
    column :name
    column :description
    column "Can Contribute", :sortable => :cannot_contribute do |group_request|
      !group_request.cannot_contribute
    end
    column :expected_size
    column :max_size
    column :admin_email
    column "Approve" do |group_request|
      link = ""
      unless group_request.approved? or group_request.accepted?
        link += link_to "Approve",
               approve_admin_group_request_path(group_request.id),
               :method => :put, :id => "approve_group_request_#{group_request.id}"
      end
      if group_request.awaiting_approval? or group_request.marked_as_spam?
        link += " | "
        link += link_to "Ignore",
                ignore_admin_group_request_path(group_request.id),
                :method => :put, :id => "ignore_group_request_#{group_request.id}"
      end
      if group_request.awaiting_approval? or group_request.ignored?
        link += " | "
        link += link_to "Already Approved",
               mark_as_manually_approved_admin_group_request_path(group_request.id),
               :method => :put, :id => "approve_group_request_#{group_request.id}"
        link += " | "
        link += link_to "Mark as Spam",
               mark_as_spam_admin_group_request_path(group_request.id),
               :method => :put, :id => "mark_as_spam_group_request_#{group_request.id}"
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

  member_action :mark_as_manually_approved, :method => :put do
    group_request = GroupRequest.find(params[:id])
    group_request.mark_as_manually_approved!
    redirect_to admin_group_requests_path,
      :notice => "Group marked as 'already approved': " +
      group_request.name
  end

  member_action :mark_as_spam, :method => :put do
    group_request = GroupRequest.find(params[:id])
    group_request.mark_as_spam!
    redirect_to admin_group_requests_path,
      :notice => "Group marked as 'spam': " +
      group_request.name
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :admin_email
      f.input :expected_size
      f.input :max_size
      f.input :description
    end
    f.buttons
  end
end
