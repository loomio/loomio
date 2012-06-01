describe 'linkify', ->
  $textWithUrl = $('<div>I like http://loom.io</div>')
  $textWithoutUrl = $('<div>I like loom.io</div>')

  it 'will apply an anchor tag to a jQuery object containing a URL', ->
    linkify = new Loomio.Views.Utils.Linkify
      el: $textWithUrl
    expect($textWithUrl.html())
      .toBe('I like <a href="http://loom.io">http://loom.io</a>')

  it 'will not apply an anchor tag to a jQuery object with no URL', ->
    linkify = new Loomio.Views.Utils.Linkify
      el: $textWithoutUrl
    expect($textWithoutUrl.html()).toBe('I like loom.io')