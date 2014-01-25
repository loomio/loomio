module ServiceHelpers

  def create_discussion( options={} )
    options[:private] = true unless options.has_key?(:private)
    discussion = FactoryGirl.build(:discussion, options)
    DiscussionService.start_discussion(discussion)
    discussion
  end

end

RSpec.configure do |config|
  config.include ServiceHelpers
end
