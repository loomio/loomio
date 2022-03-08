class Chatbot < ApplicationRecord
  belongs_to :group
  belongs_to :author

  validates_inclusion_of :kind, in: ['matrix', 'slack', 'discord']

end
