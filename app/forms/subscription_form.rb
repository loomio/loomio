class SubscriptionForm
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  validates :amount, numericality: { greater_than_or_equal_to: 0 }

  attr_accessor :preset_amount, :custom_amount

  def initialize(params=nil)
    set_params(params)
  end

  def persisted?
    false
  end

  def amounts
    { 
      :'$100 per month' => 100,
      :'$50 per month' => 50,
      :'$25 per month' => 25,
      :'$10 per month' => 10,
      :'$0 per month' => 0,
      "Choose another amount:
      <div class='input-prepend'>
        <span class='add-on'>$</span>
        <input class='input-mini' id='subscription_form_custom_amount' name='subscription_form[custom_amount]' type='text'></input>
      </div>".html_safe => 'custom'
    }
  end

  def amount
    if preset_amount.present?
      amount = preset_amount
      if preset_amount == 'custom'
        amount = custom_amount
      end
    elsif custom_amount.present?
      amount = custom_amount
    end
    amount
  end

  def amount_with_cents
    "%.2f" % amount
  end

  private

  def set_params(params)
    if params
      @custom_amount = params['custom_amount']
      @preset_amount = params['preset_amount']
    end
  end
end
