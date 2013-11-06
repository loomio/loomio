module ServiceHelpers

  def create_discussion( options={} )
    discussion = FactoryGirl.build(:discussion, options)
    DiscussionService.start_discussion(discussion)
    discussion
  end

end

RSpec.configure do |config|
  config.include ServiceHelpers
end
