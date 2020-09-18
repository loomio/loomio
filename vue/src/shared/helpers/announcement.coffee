import Session from '@/shared/services/session'
import { compact } from 'lodash'

export audiencesFor = (model) ->
  compact [
    ('parent_group'     if model.isA('group') && model.parent()),
    ('group'            if model.isA('discussion', 'poll', 'outcome') && audienceSize(model, 'group')),
    ('discussion_group' if model.isA('poll', 'outcome') && model.discussion() && audienceSize(model, 'discussion_group')),
    ('voters'           if model.isA('poll', 'outcome') && audienceSize(model, 'voters')),
    ('undecided'        if model.isA('poll') && audienceSize(model, 'undecided')),
    ('non_voters'       if model.isA('poll') && audienceSize(model, 'non_voters') && model.stancesCount > 1)
  ]

export audienceSize = (model, audience) ->
  switch audience
    when 'parent_group' then model.group().parent().announceableMembersCount
    when 'group' then model.group().announceableMembersCount
    when 'discussion_group' then model.discussion().announceableMembersCount
    when 'voters' then model.poll().participantsCount
    when 'undecided' then model.poll().undecidedCount
    when 'non_voters' then model.group().announceableMembersCount - model.stancesCount

export audienceValuesFor = (model) ->
  if model.isA('group') && model.parent()
    name: model.parent().name
  else if model.isA('discussion', 'poll', 'outcome') && model.group()
    name: model.group().name
