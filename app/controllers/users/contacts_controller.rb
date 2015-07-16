class Users::ContactsController < BaseController
  def import

    if params[:from]
      session[:return_to_after_import_contacts] = request.referer
      redirect_to "/contacts/#{params[:from]}"
    end
  end

  def callback
    @contacts = request.env['omnicontacts.contacts'].select do |contact|
      contact[:email].present? and
        current_user.contacts.where(email: contact[:email]).empty?
    end

    @user = request.env['omnicontacts.user']

    @contacts.each do |contact|
      current_user.contacts.create(name: contact[:name],
                                   email: contact[:email],
                                   source: params[:importer])

    end

    if session[:return_to_after_import_contacts]
      return_url = session[:return_to_after_import_contacts]
      session.delete(:return_to_after_import_contacts)
    else
      return_url = import_contacts_path
    end

    redirect_to return_url,
                notice: t(:'notice.new_contacts_imported')
  end

  def autocomplete
    contacts = current_user.contacts.where('name ilike :term or email ilike :term', {term: "%#{params[:q]}%"})
    render json: contacts.map{|c| {name: c.name, email: c.email, name_and_email: "#{c.name} <#{c.email}>" } }, root: false
  end
end
