ActiveAdmin.register EmailTemplate do
  index do
    column :name
    column :language
    column :updated_at
    default_actions
  end

  form partial: 'form'

  show do |template|
    recipient = User.loomio_helper_bot
    group = Group.find_by_name('Loomio Community')

    email = email_template.generate_email(
      headers: { to: "#{recipient.name} <#{recipient.email}>",
                 from: "#{current_user.name} via Loomio <#{current_user.email}>",
                 reply_to: "#{current_user.name} <#{current_user.email}>"},
      placeholders: { recipient: recipient,
                      author: current_user,
                      group: group } )

    render template: 'admin/emails/show', locals: {email: email}
  end

  controller do
    def permitted_params
      params.permit!
    end
  end

end
