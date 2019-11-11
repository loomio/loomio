import Records from '@/shared/services/records'

# a series of helpers related to getting a translation string to translate, such
# as the headline of an event or the helptext strings on the discussion or group forms

export eventHeadline = (event, useNesting = false) ->
  key = switch event.kind
    when 'new_comment'       then newCommentKey(event, useNesting)
    when 'stance_created'    then stanceCreatedKey(event, useNesting)
    when 'discussion_edited' then discussionEditedKey(event)
    when 'poll_created' then 'poll_created_no_title'
    else event.kind
  "thread_item.#{key}"

export eventTitle = (event) ->
  switch event.eventableType
    when 'Comment'             then event.model().parentAuthorName
    when 'Poll', 'Outcome'     then event.model().poll().title
    when 'Group', 'Membership' then event.model().group().name
    when 'Stance'              then event.model().poll().title
    when 'Discussion'
      if event.kind == 'discussion_moved'
        Records.groups.find(event.sourceGroupId).fullName
      else
        event.model().title

export eventPollType = (event) ->
  return "" unless _.includes ['Poll', 'Stance', 'Outcome'], event.eventableType
  "poll_types.#{event.model().poll().pollType}"

export emojiTitle = (shortname) ->
  "reactions.#{shortname.replace(/:/g, '')}"

export groupPrivacy = (group, privacy) ->
  privacy = privacy || group.groupPrivacy

  if group.isParent()
    switch privacy
      when 'open'   then 'group_form.group_privacy_is_open_description'
      when 'secret' then 'group_form.group_privacy_is_secret_description'
      when 'closed'
        if group.allowPublicThreads
          'group_form.group_privacy_is_closed_public_threads_description'
        else
          'group_form.group_privacy_is_closed_description'
  else
    switch privacy
      when 'open'   then 'group_form.subgroup_privacy_is_open_description'
      when 'secret' then 'group_form.subgroup_privacy_is_secret_description'
      when 'closed'
        if group.isSubgroupOfSecretParent()
          'group_form.subgroup_privacy_is_closed_secret_parent_description'
        else if group.allowPublicThreads
          'group_form.subgroup_privacy_is_closed_public_threads_description'
        else
          'group_form.subgroup_privacy_is_closed_description'

export groupPrivacyStatement = (group) ->
  if group.isSubgroup() && group.parent().privacyIsSecret()
    if group.privacyIsClosed()
      'group_form.privacy_statement.private_to_parent_members'
    else
      'group_form.privacy_statement.private_to_group'
  else
    switch group.groupPrivacy
      when 'open'   then 'group_form.privacy_statement.public_on_web'
      when 'closed' then 'group_form.privacy_statement.public_on_web'
      when 'secret' then 'group_form.privacy_statement.private_to_group'

export groupPrivacyConfirm = (group) ->
  return "" if group.isNew()

  if group.attributeIsModified('groupPrivacy')
    if group.privacyIsSecret()
      if group.isParent()
        'group_form.confirm_change_to_secret'
      else
        'group_form.confirm_change_to_secret_subgroup'
    else if group.privacyIsOpen()
      'group_form.confirm_change_to_public'
  else if group.attributeIsModified('discussionPrivacyOptions')
    if group.discussionPrivacyOptions == 'private_only'
      'group_form.confirm_change_to_private_discussions_only'

newCommentKey = (event, useNesting) ->
  if event.isNested() && !useNesting
    'comment_replied_to'
  else
    'new_comment'

stanceCreatedKey = (event, useNesting) ->
  if event.isNested() && useNesting
    'new_comment'
  else
    'stance_created'

discussionEditedKey = (event) ->
  changes = event.customFields.changed_keys
  if _.includes(changes, 'title')
    'discussion_title_edited'
  else if _.includes(changes, 'private')
    'discussion_privacy_edited'
  else if _.includes(changes, 'description')
    'discussion_context_edited'
  else if _.includes(changes, 'document_ids')
    'discussion_attachments_edited'
  else
    'discussion_edited'
