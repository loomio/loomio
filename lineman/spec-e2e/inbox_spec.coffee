describe 'Inbox Page', ->

  inboxHelper = require './helpers/inbox_helper.coffee'

  beforeEach ->
    inboxHelper.load()

  describe 'inbox', ->
    it 'does not display read threads', ->

    it 'does not display muted threads', ->

    it 'does not display old threads', ->

    it 'displays threads by group', ->
