export audiencesFor = (model) ->
  _.compact [
    ('parent_group'     if model.isA('group')                         && model.parent()),
    ('formal_group'     if model.isA('discussion', 'poll', 'outcome') && model.group() && model.group().activeMembershipsCount() > 1),
    ('discussion_group' if model.isA('poll', 'outcome')               && model.discussion()),
    ('voters'           if model.isA('poll', 'outcome')               && model.poll().stancesCount > 0),
    ('non_voters'       if model.isA('poll')                          && model.stancesCount > 0 && model.undecidedCount > 1)
  ]

export audienceValuesFor = (model) ->
  if model.isA('group') && model.parent()
    name: model.parent().name
  else if model.isA('discussion', 'poll', 'outcome') && model.group()
    name: model.group().name
