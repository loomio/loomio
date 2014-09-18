$ ->
  $('#select-locale').on 'change', ->
    window.location = this.value
