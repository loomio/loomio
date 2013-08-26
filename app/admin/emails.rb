ActiveAdmin.register Email do
  scope :unsent, default: true
  scope :all
  actions :index, :show, :edit, :update, :destroy

  index do
    selectable_column
    column :to
    column :from
    column :subject
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
    def permitted_params
      params.permit!
    end
  end

end
