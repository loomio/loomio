class EmailTemplateSentToGroup < ActiveRecord::Base
  belongs_to :email_template
  belongs_to :group
  belongs_to :author, class_name: 'User'
end
