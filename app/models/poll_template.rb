class PollTemplate < ActiveRecord::Base
  has_many :poll_options
  has_many :polls

  validates :name, presence: true

  def self.motion_template
    find_by(name: :consensus) || create_motion_template
  end

  def self.create_motion_template
    create(name: :consensus).tap do |template|
      %w(agree abstain disagree block).each do |option|
        template.poll_options.create(name: option, icon_url: "/img/#{option}.svg")
      end
    end
  end

end
