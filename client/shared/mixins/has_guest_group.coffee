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
