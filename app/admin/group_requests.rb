ActiveAdmin.register GroupRequest do
  actions :all, :except => [:new]
  scope :not_setup
  scope :setup_completed
  scope :zero_members
  scope :starred
  scope :all

  filter :name
  filter :description
  filter :admin_email
  filter :admin_name
  filter :high_touch

  index do
    column :id
    column :name_and_contact do |gr|
      name = ERB::Util.h(gr.name)
      admin_name = ERB::Util.h(gr.admin_name)
      admin_email = ERB::Util.h(gr.admin_email)
      (link_to(name, edit_admin_group_request_path(gr)) +
       "<br><br>#{admin_name}".html_safe +
       " &lt;#{admin_email}&gt;".html_safe)
    end
    column :description
    column :admin_notes
    column 'Size', :expected_size
    column :status
    column :created_at, sortable: :created_at do |gr|
      gr.created_at.to_date
    end
    column :actions do |gr|
      span do
        links = []
        links << link_to('Star', set_high_touch_admin_group_request_path(gr), :method => :put) unless gr.high_touch?
        links << link_to('Un-star', unset_high_touch_admin_group_request_path(gr), :method => :put) if gr.high_touch?
        links.join(' ').html_safe
      end
    end
  end

  form partial: 'form'

  member_action :set_high_touch, :method => :put do
    @group_request = GroupRequest.find(params[:id])
    @group_request.update_attribute(:high_touch, true)
    redirect_to admin_group_requests_path
  end

  member_action :unset_high_touch, :method => :put do
    @group_request = GroupRequest.find(params[:id])
    @group_request.update_attribute(:high_touch, false)
    redirect_to admin_group_requests_path
  end

  member_action :resend_invitation_to_start_group, :method => :get do
    group_request = GroupRequest.find(params[:id])
    group_request.send_invitation_to_start_group
    redirect_to admin_group_requests_path,
      :notice => "Invitation to start group email sent for " +
      group_request.name
  end

  controller do
    def permitted_params
      params.permit!
    end
  end
end
