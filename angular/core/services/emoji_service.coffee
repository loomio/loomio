angular.module('loomioApp').factory 'EmojiService', ($timeout, AppConfig, $translate) ->
  new class EmojiService
    source:   AppConfig.emojis.source
    render:   AppConfig.emojis.render
    defaults: AppConfig.emojis.defaults

    imgSrcFor: (shortname) ->
      ns = emojione
      unicode = ns.emojioneList[shortname].unicode[ns.emojioneList[shortname].unicode.length-1];
      ns.imagePathPNG+unicode+'.png'+ns.cacheBustParam

    translate: (shortname_with_colons) ->
      shortname = shortname_with_colons.replace(/:/g, '')
      str = $translate.instant("reactions.#{shortname}")
      if _.startsWith(str, "reactions.")
        shortname
      else
        str

    listen: (scope, model, field, elem) ->
      scope.$on 'emojiSelected', (_, emoji) ->
        return unless $textarea = elem.find('textarea')[0]
        caretPosition = $textarea.selectionEnd
        model[field] = "#{model[field].toString().substring(0, $textarea.selectionEnd)} #{emoji} #{model[field].substring($textarea.selectionEnd)}"
        $timeout ->
          $textarea.selectionEnd = $textarea.selectionStart = caretPosition + emoji.length + 2
          $textarea.focus()
