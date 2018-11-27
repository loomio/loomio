class Subscription < ApplicationRecord
  validates :kind, presence: true

  GOLD_NAMES =      %w(standard-loomio-plan standard-plan-yearly)
  PRO_NAMES =       %w(pro-loomio-plan pro-plan-yearly)
  PLUS_NAMES =      %w(plus-plan plus-plan-yearly)
  PLAN_NAMES =      GOLD_NAMES + PRO_NAMES + PLUS_NAMES
  PAYMENT_METHODS = ['chargify', 'manual', 'paypal', 'barter']
  KINDS =           ['gift', 'paid']

  # gift means free
  validates_inclusion_of :kind, in: KINDS
  validates_inclusion_of :payment_method, in: PAYMENT_METHODS, allow_nil: true

  has_many :groups

  belongs_to :owner, class_name: 'User'

  # plan is a text field to detail the subscription type further
  # plan could be manual
  #
  # current it indicates standard or plus plan

  def is_paid?
    self.kind.to_s == 'paid'
  end

  def level
    if kind == 'paid'
      if PRO_NAMES.include?(plan)
        'pro'
      elsif PLUS_NAMES.include?(plan)
        'plus'
      else
        'gold'
      end
    else
      'free'
    end
  end
end
