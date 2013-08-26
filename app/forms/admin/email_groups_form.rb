class Admin::EmailGroupsForm
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  RECIPIENTS_OPTIONS = %w[contact_person coordinators members]

  attr_accessor :recipients
  attr_accessor :group_ids
  attr_accessor :email_template_id
  attr_accessor :from
  attr_accessor :reply_to
  attr_accessor :author_id

  validates_inclusion_of :recipients, in: RECIPIENTS_OPTIONS
  validates_presence_of :group_ids, :email_template_id, :from, :reply_to, :author_id


  def initialize(params = {})
    params.each_pair do |key, value|
      self.send("#{key}=", value)
    end
  end

  def persisted?
    false
  end

  def group_ids=(group_ids)
    if group_ids.is_a? String
      @group_ids = group_ids.gsub('"', '').gsub(/[\[\]]/, '').split(',').map(&:to_i) 
    else
      @group_ids = group_ids
    end
  end
end
