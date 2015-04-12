angular.module('loomioApp').factory 'LmoUrlService', ->
  new class LmoUrlService
    stub: (name) ->
      name.replace(/[^a-z0-9\-_]+/gi, '-').toLowerCase()

    discussion: (d) ->
      "/d/"+d.key+"/"+@stub(d.title)

    proposal: (p) ->
      "/m/"+p.key+"/"+@stub(p.name)

    comment: (c) ->
      d = c.discussion()
      "/d/"+d.key+"/"+@stub(d.title)+"#commment-#{c.id}"

    group: (g) ->
      "/g/"+g.key+"/"+@stub(g.fullName())
