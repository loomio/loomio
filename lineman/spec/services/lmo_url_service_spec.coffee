describe 'LmoUrlService', ->
  describe 'group', ->

    beforeEach module 'loomioApp'
    beforeEach useFactory
    beforeEach inject (LmoUrlService) -> @subject = LmoUrlService
    beforeEach ->
      @group = @factory.create 'groups', name: 'name', key: 'key'

    describe 'on localhost', ->
      beforeEach ->
        @subject.hostInfo = ->
          port: 3000
          default_subdomain: null
          host: 'localhost'

      it "handles a group without subdomain on localhost", ->
        expect(@subject.group(@group)).toBe "http://localhost:3000/g/#{@group.key}/name"

      it "handles a group with subdomain on localhost", ->
        @group.updateFromJSON subdomain: 'subdomain'
        expect(@subject.group(@group)).toBe "http://subdomain.localhost:3000/"

      it "handles a subgroup with subdomain on localhost", ->
        @group.updateFromJSON subdomain: 'subdomain'
        subgroup = @factory.create 'groups', parent_id: @group.id, key: 'subkey', name: 'subname'
        expect(@subject.group(subgroup)).toBe "http://subdomain.localhost:3000/g/#{subgroup.key}/name-subname"

    describe 'on loom.io', ->
      beforeEach ->
        @subject.hostInfo = ->
          host: 'loom.io'
          default_subdomain: null
          ssl: true

      it 'handles a group without subdomain on loom.io', ->
        expect(@subject.group(@group)).toBe "https://loom.io/g/#{@group.key}/name"

      it 'handles a group with subdomain on loom.io', ->
        @group.updateFromJSON subdomain: 'subdomain'
        expect(@subject.group(@group)).toBe 'https://subdomain.loom.io/'

      it 'handles a subgroup with subdomain on loom.io', ->
        @group.updateFromJSON subdomain: 'subdomain'
        subgroup = @factory.create 'groups', parent_id: @group.id, key: 'subkey', name: 'subname'
        expect(@subject.group(subgroup)).toBe "https://subdomain.loom.io/g/#{subgroup.key}/name-subname"

    describe 'on loomio.org', ->
      beforeEach ->
        @subject.hostInfo = ->
          host: 'loomio.org'
          default_subdomain: 'www'

      it 'handles a group without subdomain on loomio.org', ->
        expect(@subject.group(@group)).toBe "http://www.loomio.org/g/#{@group.key}/name"

      it 'handles a group with subdomain on loomio.org', ->
        @group.updateFromJSON subdomain: 'subdomain'
        expect(@subject.group(@group)).toBe "http://subdomain.loomio.org/"

      it 'handles a subgroup with subdomain on loomio.org', ->
        @group.updateFromJSON subdomain: 'subdomain'
        subgroup = @factory.create 'groups', parent_id: @group.id, key: 'subkey', name: 'subname'
        expect(@subject.group(subgroup)).toBe "http://subdomain.loomio.org/g/#{subgroup.key}/name-subname"

    describe 'on loomio.anotherdomain.com', ->
      beforeEach ->
        @subject.hostInfo = ->
          host: 'loomio.anotherdomain.com'
          default_subdomain: null

      it 'handles a group without subdomain on loomio.anotherdomain.com', ->
        expect(@subject.group(@group)).toBe "http://loomio.anotherdomain.com/g/#{@group.key}/name"

      it 'handles a group with subdomain on loomio.anotherdomain.com', ->
        @group.updateFromJSON subdomain: 'subdomain'
        expect(@subject.group(@group)).toBe "http://subdomain.loomio.anotherdomain.com/"

      it 'handles a subgroup with subdomain on loomio.anotherdomain.com', ->
        @group.updateFromJSON subdomain: 'subdomain'
        subgroup = @factory.create 'groups', parent_id: @group.id, key: 'subkey', name: 'subname'
        expect(@subject.group(subgroup)).toBe "http://subdomain.loomio.anotherdomain.com/g/#{subgroup.key}/name-subname"
