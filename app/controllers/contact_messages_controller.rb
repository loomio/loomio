class ContactMessagesController < ApplicationController
  def new
    response.set_header("X-FRAME-OPTIONS", "ALLOWALL")
  end

  def create
    response.set_header("X-FRAME-OPTIONS", "ALLOWALL")
    BaseMailer.contact_message(
      params[:name],
      params[:email],
      params[:subject],
      params[:body],
      {
        site: ENV['CANONICAL_HOST'],
        form_type: 'Sales'
      }
    ).deliver_later
    redirect_to contact_messages_path(params: {name: params[:name]})
  end

  def show
    response.set_header("X-FRAME-OPTIONS", "ALLOWALL")
  end
end
