angular.module('loomioApp').factory 'LmoUrlService', ->
  new class LmoUrlService

    hostInfo: ->
      window.Loomio.hostInfo

    stub: (name) ->
      name.replace(/[^a-z0-9\-_]+/gi, '-').replace(/-+/g, '-').toLowerCase()

    group: (g) ->
      @groupHost(g) + @groupPath(g)

    discussion: (d) ->
      @groupHost(d.group()) + @discussionPath(d)

    proposal: (p) ->
      @groupHost(p.discussion().group()) + @proposalPath(p)

    comment: (c) ->
      d = c.discussion()
      @discussion(d) + "#comment-#{c.id}"

    discussionPath: (d) ->
      "/d/#{d.key}/#{@stub(d.title)}"

    proposalPath: (p) ->
      "/m/#{p.key}/#{@stub(p.name)}"

    groupPath: (g) ->
      if "#{g.subdomain}." == @subdomainFor(g)
        "/"
      else
        "/g/#{g.key}/#{@stub(g.fullName())}"

    groupHost: (g) ->
      #"#{@protocol()}#{@subdomainFor(g)}#{@host()}#{@port()}"
      ''

    protocol: ->
      if @hostInfo().ssl then 'https://' else 'http://'

    subdomainFor: (g) ->
      if subdomain = g.organisationSubdomain() or @hostInfo().default_subdomain
        "#{subdomain}."
      else
        ""

    host: ->
      @hostInfo().host

    port: ->
      if @hostInfo().port && !@portIsDefault()
        ":#{@hostInfo().port}"
      else
        ""

    portIsDefault: ->
      @hostInfo().port == if @hostInfo().ssl then 443 else 80
