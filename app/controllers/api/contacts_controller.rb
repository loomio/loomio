class API::ContactsController < API::RestfulController
  
  def import
    redirect_to "/contacts/#{params[:from]}" if params[:from]
  end

  def callback
    @contacts = importable_contacts.each do |contact|
      current_user.contacts.build name: contact[:name], email: contact[:email], source: params[:importer]
    end
    current_user.save

    respond_with_collection
  end

  private

  def importable_contacts
    current_contact_emails = current_user.contacts.pluck(:email)
    request.env['omnicontacts.contacts'].select do |contact|
      !current_contact_emails.include? contact[:email]
    end.reject(&:blank?)
  end

end
