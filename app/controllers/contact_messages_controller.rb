class ContactMessagesController < BaseController
  skip_before_filter :authenticate_user!
  layout 'pages'

	def new
    @contact_message = ContactMessage.new
    if current_user
      @contact_message.name = current_user.name
      @contact_message.email = current_user.email
    end
	end

	def create
  	@contact_message = ContactMessage.new(permitted_params.contact_message)
    @contact_message.user = current_user
  	if @contact_message.save
      ContactMessageMailer.delay.contact_message_email(@contact_message)
      flash[:success] = "Thanks! Someone from our team will get back to you shortly!"

      redirect_to dashboard_or_root_path
    else
      render 'new'
    end
  end

end
