ActiveAdmin.register Email do
  scope :unsent, default: true
  scope :all
  actions :index, :show, :edit, :update, :destroy
  before_filter :set_pagination

  index do
    selectable_column
    column :to
    column :from
    column('Template') {|e| e.email_template.name }
    column :created_at
    column :updated_at
    default_actions
  end

  show do |email|
    render template: 'admin/emails/show', locals: {email: email}
  end

  batch_action :send do |email_ids|
    Email.where(id: email_ids).each do |email|
      EmailTemplateMailer.delay.basic(email)
      email.update_attribute(:sent_at, Time.zone.now)
    end
    redirect_to admin_emails_path
  end

  controller do
    def set_pagination
      if params[:pagination].blank?
        @per_page = 40
      elsif params[:pagination] == 'false'
        @per_page = 999999999
      else
        @per_page = params[:pagination]
      end
    end
  end

  controller do
    def permitted_params
      params.permit!
    end
  end

end
