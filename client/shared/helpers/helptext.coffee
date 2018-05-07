Records = require 'shared/services/records'

# a series of helpers related to getting a translation string to translate, such
# as the headline of an event or the helptext strings on the discussion or group forms
module.exports =
  eventHeadline: (event, useNesting = false) ->
    key = switch event.kind
      when 'new_comment'       then newCommentKey(event, useNesting)
      when 'stance_created'    then stanceCreatedKey(event, useNesting)
      when 'discussion_edited' then discussionEditedKey(event)
      else event.kind
    "thread_item.#{key}"

  eventTitle: (event) ->
    switch event.eventable.type
      when 'comment'             then event.model().parentAuthorName
      when 'poll', 'outcome'     then event.model().poll().title
      when 'group', 'membership' then event.model().group().name
      when 'stance'              then event.model().poll().title
      when 'discussion'
        if event.kind == 'discussion_moved'
          Records.groups.find(event.sourceGroupId).fullName
        else
          event.model().title

  eventPollType: (event) ->
    return "" unless _.contains ['poll', 'stance', 'outcome'], event.eventable.type
    "poll_types.#{event.model().poll().pollType}"

  emojiTitle: (shortname) ->
    "reactions.#{shortname.replace(/:/g, '')}"

  groupPrivacy: (group, privacy) ->
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

  groupPrivacyStatement: (group) ->
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

  groupPrivacyConfirm: (group) ->
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

  discussionPrivacy: (discussion, is_private = null) ->
    if is_private == false
      'discussion_form.privacy_public'
    else if discussion.group().parentMembersCanSeeDiscussions
      'discussion_form.privacy_organisation'
    else
      'discussion_form.privacy_private'

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
  if _.contains(changes, 'title')
    'discussion_title_edited'
  else if _.contains(changes, 'private')
    'discussion_privacy_edited'
  else if _.contains(changes, 'description')
    'discussion_context_edited'
  else if _.contains(changes, 'document_ids')
    'discussion_attachments_edited'
  else
    'discussion_edited'
