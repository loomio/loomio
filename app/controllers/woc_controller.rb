class WocController < ApplicationController
  layout 'frontpage'

  def index
    @title = "Loomio - Wellington Online Collaboration: Alcohol Management Strategy"
    @example_discussion_url = WocOptions.first.example_discussion_url
    assign_meta_data
  end

  def send_request
    @requested_email = params[:requested_email]
    WocMailer.delay.send_request(params[:requested_name], @requested_email, params[:robot_trap])
    flash[:success] = "<p>Success! You have registered '#{@requested_email}'
                       to participate in the Wellington Online Collaboration.</p>
                       <p>You should hear from us within 24hrs. Drop us a line if
                       you have any queries: contact@loomio.org</p>".html_safe
    redirect_to collaborate_url(:success => 'yes')
  end

  def success
  end

  private

  def assign_meta_data
    @meta_title = "Loomio - Wellington Online Collaboration: Alcohol Management Strategy"
    @meta_description = "People all over Wellington are getting together online to work with their " +
                        "City Council to collaborate on an Alcohol Management Strategy for the city. " +
                        "Click here to participate!"
  end
end
