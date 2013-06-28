class ContributionsController < BaseController
  def callback
    @contribution = Contribution.new
    @contribution.params = params.to_json
    @contribution.user = current_user
    @contribution.save!
    redirect_to thanks_contributions_url
  end

  def create
    amount = params[:amount]
    currency = params[:currency]
    if amount.present? && currency.present? and amount.to_i > 0
      wrapper = SwipeWrapper.new
      identifier = wrapper.create_tx_identifier_for(user: current_user, amount: amount, currency: currency)
      redirect_to "https://payment.swipehq.com/?identifier_id=#{identifier}"
    else
      flash[:error] = "Please enter an amount to contibute"
      redirect_to contributions_url
    end
  end

  def index
  end

  def thanks
  end
end
