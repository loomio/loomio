import EventBus       from '@/shared/services/event_bus'
import AbilityService from '@/shared/services/ability_service'
import Session from '@/shared/services/session'
import Records from '@/shared/services/records'

user = -> Session.user()
export default new class AnnouncementService
  audiencesFor: (model) ->
    audiences = []

    if model.discussion && model.discussion().id && model.discussion().membersCount
      (model.adminsInclude(user()) ||
       model.group().membersCanAnnounce && model.membersInclude(user()))
      audiences.push 'discussion_group'

    if model.poll and model.poll().id && model.poll().votersCount
      (model.adminsInclude(user()) ||
       model.group().membersCanAnnounce && model.membersInclude(user()))
      audiences.push 'voters'

    if model.poll and model.poll().id && model.poll().decidedVotersCount && model.poll().undecidedVotersCount
      (model.adminsInclude(user()) ||
       model.group().membersCanAnnounce && model.membersInclude(user()))
      audiences.push 'decided_voters'

    if model.poll and model.poll().id && model.poll().decidedVotersCount && model.poll().undecidedVotersCount
      (model.adminsInclude(user()) ||
       model.group().membersCanAnnounce && model.membersInclude(user()))
      audiences.push 'undecided_voters'

    return audiences
