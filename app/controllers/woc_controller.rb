class WocController < ApplicationController
  layout 'frontpage'

  def index
    @example_discussion_url = WocOptions.first.example_discussion_url
  end

  def send_request
    @requested_email = params[:requested_email]
    WocMailer.delay.send_request(params[:requested_name], @requested_email, params[:robot_trap])
    flash[:success] = "<p>Success! You have registered '#{@requested_email}'
                       to participate in the Wellington Online Collaboration.</p>
                       <p>You should hear from us within 24hrs. Drop us a line if
                       you have any queries: contact@loomio.org</p>".html_safe
    redirect_to collaborate_url
  end

  def success
  end
end
