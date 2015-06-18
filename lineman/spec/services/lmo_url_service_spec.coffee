describe 'LmoUrlService', ->
  describe 'group', ->

    beforeEach module 'loomioApp'
    beforeEach useFactory
    beforeEach inject (LmoUrlService) -> @subject = LmoUrlService
    beforeEach ->
      @group = @factory.create 'groups', name: 'Group Name', key: 'gkey'
      @subgroup = @factory.create 'groups', parent_id: @group.id, name: 'Subgroup Name', key: 'sgkey'
      @thread = @factory.create 'discussions', title: 'Discussion Title', key: 'dkey'
      @proposal = @factory.create 'proposals', discussion_id: @thread.id, name: 'Proposal Name', key: 'pkey'
      @comment = @factory.create 'comments', discussion_id: @thread.id, key: 'ckey'

    describe 'group', ->
      it 'gives a group path', ->
        expect(@subject.group(@group)).toBe("/g/#{@group.key}/group-name")

      it 'gives a subgroup path', ->
        expect(@subject.group(@subgroup)).toBe("/g/#{@subgroup.key}/group-name-subgroup-name")

      it 'can pass query parameters', ->
        expect(@subject.group(@group, { utm_source: 'source'})).toBe("/g/#{@group.key}/group-name?utm_source=source")

    describe 'discussion', ->
      it 'gives a discussion path', ->
        expect(@subject.discussion(@thread)).toBe("/d/#{@thread.key}/discussion-title")

      it 'can pass query parameters', ->
        expect(@subject.discussion(@thread, { comment_id: '15'})).toBe("/d/#{@thread.key}/discussion-title?comment_id=15")


    describe 'proposal', ->
      it 'gives a proposal path', ->
        expect(@subject.proposal(@proposal)).toBe("/m/#{@proposal.key}/proposal-name")

      it 'can pass query parameters', ->
        expect(@subject.proposal(@proposal, { position: 'yes', utm_medium: 'medium'})).toBe("/m/#{@proposal.key}/proposal-name?position=yes&utm_medium=medium")

    describe 'comment', ->
      it 'gives a comment path', ->
        expect(@subject.comment(@comment)).toBe("/d/#{@thread.key}/discussion-title?comment_id=#{@comment.id}")
