_ = require('lodash')

describe 'Verify Stances', ->
  page = require './helpers/page_helper.coffee'

  create a public poll and vote as logged in user
  create a public poll and vote as logged out new user, then verify email or merge accounts
  create a public poll and vote as logged out existing user, then verify vote

  create a private poll and vote as logged in user
  create a private poll and vote as logged out new user, and verify email or merge accounts
  create a private poll and vote as logged out existing user, then verify vote

  describe 'logged out', ->
    describe 'vote on public poll', ->
      describe 'with email of verified user', ->
        it '
      it 'creates stance and logs in unverified user'
    describe 'vote on poll via invitation', ->
      it 'create stance and logs in unverified user'

  describe 'logged in', ->
    describe 'verify stance'
