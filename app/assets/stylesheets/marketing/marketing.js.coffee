#= require ahoy

ahoy.trackAll()

document.getElementsByClassName("header__resources-dropdown")[0].addEventListener "click", ->
  e = document.getElementsByClassName("header__resources-dropdown-menu")[0]
  if e.style.display == "block"
    e.parentElement.setAttribute('aria-expanded', 'false')
    e.style.display = "none"
  else
    e.parentElement.setAttribute('aria-expanded', 'true')
    e.style.display = "block"

if document.getElementsByClassName("header__menu-bars")[0]
  document.getElementsByClassName("header__menu-bars")[0].addEventListener "click", ->
    e = document.getElementsByClassName("header__menu")[0]
    if e.style.display == "flex"
      e.style.display = "none"
    else
      e.style.display = "flex"
