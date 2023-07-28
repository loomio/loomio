class Tag < ApplicationRecord
  COLORS = %w[#f44336
              #e91e63
              #9c27b0
              #673ab7
              #3f51b5
              #2196f3
              #03a9f4
              #00bcd4
              #009688
              #4caf50
              #8bc34a
              #ffeb3b
              #ffc107
              #ff9800
              #ff5722
              #795548
              #607d8b
              #9e9e9e]

  include Translatable
  is_translatable on: :name
  belongs_to :group

  validates :name, presence: true, uniqueness: { scope: :group }
  validates :color, presence: true, format: /\A#([A-F0-9]{3}){1,2}\z/i
end
