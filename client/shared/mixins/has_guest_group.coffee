module.exports = new class HasGuestGroup
  apply: (model) ->
    model.guestGroup = ->
      @recordStore.groups.find(@guestGroupId)

    model.memberIds = ->
      model.formalMemberIds().concat model.guestIds()

    model.formalMemberIds = ->
      if model.group() then model.group().memberIds() else []

    model.guestIds = ->
      if model.guestGroup() then model.guestGroup().memberIds() else []

    model.members = model.members or ->
      model.recordStore.users.find(model.memberIds())

    model.memberships = model.memberships or ->
      model.guestGroup().memberships().concat((model.group() or @recordStore.groups.build()).memberships())

    model.adminMemberships = ->
      model.guestGroup().adminMemberships().concat((model.group() or @recordStore.groups.build()).adminMemberships())

    model.adminMembers = ->
      _.invoke model.adminMemberships(), 'user'
