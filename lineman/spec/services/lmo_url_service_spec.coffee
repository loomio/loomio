describe 'LmoUrlService', ->
  service = null
  group = null
  subgroup = null
  proposal = null
  comment = null
  thread = null

  describe 'group', ->

    beforeEach module 'loomioApp'
    beforeEach useFactory
    beforeEach inject (LmoUrlService) -> service = LmoUrlService
    beforeEach ->
      inject (Records) ->
        group = Records.groups.importJSON id: 1, name: 'Group Name', key: 'gkey'
        subgroup = Records.groups.importJSON id: 2, parent_id: group.id, name: 'Subgroup Name', key: 'sgkey'
        thread = Records.discussions.importJSON id: 1, title: 'Discussion Title', key: 'dkey'
        proposal = Records.proposals.importJSON id: 1, discussion_id: thread.id, name: 'Proposal Name', key: 'pkey'
        comment = Records.comments.importJSON id:1, discussion_id: thread.id, key: 'ckey'

    describe 'route', ->
      it 'can accept a model', ->
        expect(service.route({model: group})).toBe("/g/#{group.key}/group-name")
        expect(service.route({model: thread})).toBe("/d/#{thread.key}/discussion-title")

      it 'can accept a route', ->
        expect(service.route({action: '/dashboard'})).toBe("/dashboard")
        expect(service.route({action: 'dashboard'})).toBe("/dashboard")

      it 'can accept a model and a route', ->
        expect(service.route({model: group, action: 'memberships'})).toBe("/g/#{group.key}/memberships")
        expect(service.route({model: group, action: '/memberships'})).toBe("/g/#{group.key}/memberships")

    describe 'group', ->
      it 'gives a group path', ->
        expect(service.group(group)).toBe("/g/#{group.key}/group-name")

      it 'gives a subgroup path', ->
        expect(service.group(subgroup)).toBe("/g/#{subgroup.key}/group-name-subgroup-name")

      it 'can pass query parameters', ->
        expect(service.group(group, { utm_source: 'source'})).toBe("/g/#{group.key}/group-name?utm_source=source")

    describe 'discussion', ->
      it 'gives a discussion path', ->
        expect(service.discussion(thread)).toBe("/d/#{thread.key}/discussion-title")

      it 'can pass query parameters', ->
        expect(service.discussion(thread, { comment_id: '15'})).toBe("/d/#{thread.key}/discussion-title?comment_id=15")


    describe 'proposal', ->
      it 'gives a proposal path', ->
        expect(service.proposal(proposal)).toBe("/m/#{proposal.key}/proposal-name")

      it 'can pass query parameters', ->
        expect(service.proposal(proposal, { position: 'yes', utm_medium: 'medium'})).toBe("/m/#{proposal.key}/proposal-name?position=yes&utm_medium=medium")

    describe 'comment', ->
      it 'gives a comment path', ->
        expect(service.comment(comment)).toBe("/d/#{thread.key}/discussion-title?comment=#{comment.id}")
