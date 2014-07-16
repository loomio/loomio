class Users::ContactsController < BaseController
  def import

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
    redirect_to :import_contacts, notice: t(:'notice.new_contacts_imported', count: @contacts.size)
  end

  def autocomplete
    contacts = current_user.contacts.where('name ilike :term or email ilike :term', {term: "%#{params[:q]}%"})
    render json: contacts.map{|c| {name: c.name, email: c.email, name_and_email: "#{c.name} <#{c.email}>" } }
  end
end
