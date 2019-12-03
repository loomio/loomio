export hardReload = (path) ->
  if path
    window.location.href = path
  else
    window.location.reload()

export print = -> window.print()
export is2x = -> window.devicePixelRatio >= 2
