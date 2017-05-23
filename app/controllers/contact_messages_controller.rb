class ContactMessagesController < ApplicationController

	def new
    @contact_message = ContactMessage.new(destination: params[:destination])
    if current_user.is_logged_in?
      @contact_message.name = current_user.name
      @contact_message.email = current_user.email
    end
	end

	def create
  	@contact_message = ContactMessage.new(permitted_params.contact_message)
    @contact_message.user = current_user if current_user.is_logged_in?
  	if @contact_message.save
      ContactMessageService.deliver(email: @contact_message.email, message: @contact_message.message )
      flash[:success] = "Thanks! Someone from our team will get back to you shortly!"
      redirect_to dashboard_or_root_path
    else
      render :new
    end
  end

end
