module Ability::PollOption
  def initialize(user)
    super(user)

    can([:show], ::PollOption) do |poll_option|
    	can? :show, poll_option.poll
    end
  end
end
