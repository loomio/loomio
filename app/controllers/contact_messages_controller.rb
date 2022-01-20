class ContactMessagesController < ApplicationController
  def new
    response.set_header("X-FRAME-OPTIONS", "ALLOWALL")
  end

  def create
    response.set_header("X-FRAME-OPTIONS", "ALLOWALL")
    BaseMailer.delay.contact_message(
      params[:name],
      params[:email],
      params[:subject],
      params[:body]
    )
    redirect_to contact_messages_path(params: {name: params[:name]})
  end

  def show
    response.set_header("X-FRAME-OPTIONS", "ALLOWALL")
  end
end
