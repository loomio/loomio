angular.module('loomioApp').factory 'LmoUrlService', ->
  new class LmoUrlService

    stub: (name) ->
      name.replace(/[^a-z0-9\-_]+/gi, '-').replace(/-+/g, '-').toLowerCase()

    group: (g) ->
      "/g/#{g.key}/#{@stub(g.fullName())}"

    discussion: (d) ->
      "/d/#{d.key}/#{@stub(d.title)}"

    proposal: (p) ->
      "/m/#{p.key}/#{@stub(p.name)}"

    comment: (c) ->
      @discussion(c.discussion()) + "#comment-#{c.id}"
