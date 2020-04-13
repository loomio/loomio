import Session from '@/shared/services/session'
import { compact } from 'lodash'

export audiencesFor = (model) ->
  compact [
    ('parent_group'     if model.isA('group') && model.parent()),
    ('formal_group'     if model.isA('discussion', 'poll', 'outcome') && audienceSize(model, 'formal_group')),
    ('discussion_group' if model.isA('poll', 'outcome') && audienceSize(model, 'discussion_group')),
    ('voters'           if model.isA('poll', 'outcome') && audienceSize(model, 'voters')),
    ('undecided'        if model.isA('poll') && audienceSize(model, 'undecided')),
    ('non_voters'       if model.isA('poll') && audienceSize(model, 'non_voters') && model.stancesCount > 1)
  ]

export audienceSize = (model, audience) ->
  youParticipated = 0
  youUndecided = 0

  if model.isA('poll')
    stance = model.poll().stanceFor(Session.user())
    youParticipated = 1 if stance && stance.castAt
    youUndecided = 1 if stance && !stance.castAt

  switch audience
    when 'parent_group' then model.group().parent().activeMembershipsCount
    when 'formal_group' then model.group().activeMembershipsCount - 1
    when 'discussion_group' then model.discussion().seenByCount - 1
    when 'voters' then model.poll().participantsCount - youParticipated
    when 'undecided' then model.poll().undecidedCount - youUndecided
    when 'non_voters' then model.group().activeMembershipsCount - model.stancesCount

export audienceValuesFor = (model) ->
  if model.isA('group') && model.parent()
    name: model.parent().name
  else if model.isA('discussion', 'poll', 'outcome') && model.group()
    name: model.group().name
