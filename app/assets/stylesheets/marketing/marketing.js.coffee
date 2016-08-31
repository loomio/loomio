#= require ahoy

ahoy.trackAll()

document.getElementsByClassName("header__resources-dropdown")[0].addEventListener "click", ->
  e = document.getElementsByClassName("header__resources-dropdown-menu")[0]
  if e.style.display == "block"
    e.style.display = "none"
  else
    e.style.display = "block"

document.getElementsByClassName("header__menu-bars")[0].addEventListener "click", ->
  e = document.getElementsByClassName("header__menu")[0]
  if e.style.display == "flex"
    e.style.display = "none"
  else
    e.style.display = "flex"
