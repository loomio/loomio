class CampaignsController < ApplicationController
  layout 'pages'

  def index
    @campaign = get_campaign
    assign_meta_data
  end

  def send_request
    @email = params[:requested_email]
    @name = params[:requested_name]
    is_spam = params[:robot_trap].present?
    campaign = get_campaign
    CampaignSignup.create!(campaign: campaign, name: @name, email: @email, spam: is_spam)
    CampaignMailer.delay.send_request(campaign, @name, @email, is_spam)
    flash[:success] = success_message.html_safe
    redirect_to success_url
  end
end
