class EnablePollsJob < ActiveJob::Base
  queue_as :low_priority

  def perform(group_id)
    group = Group.find(group_id)
    return if group.features['uses_polls']

    PollService.convert(motions: group.motions)
    group.features['uses_polls'] = true
    group.save
  end
end
