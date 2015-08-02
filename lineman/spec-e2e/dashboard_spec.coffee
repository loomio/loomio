describe 'Dashboard Page', ->

  dashboardHelper = require './helpers/dashboard_helper.coffee'

  beforeEach ->
    dashboardHelper.load()

  describe 'recent view', ->
    it 'displays threads with active proposals', ->

    it 'does not display muted threads', ->

    it 'displays threads with stars', ->

    it 'displays threads by recent activity', ->

    it 'sorts threads with active proposals by starred', ->

  describe 'participating view', ->
    it 'does not display non-participating threads', ->

    it 'does not display muted threads', ->

  describe 'muted view', ->
    it 'displays muted threads', ->

    it 'displays threads by group', ->

    it 'does not display old threads', ->
