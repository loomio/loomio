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

if document.getElementsByClassName("header__menu-collapsed-button")[0]
  triggerElement = document.getElementsByClassName("header__menu-collapsed-button")[0]
  triggerElement.addEventListener "click", ->
    menu = document.getElementsByClassName("header__menu")[0]
    if menu.style.display == "flex"
      triggerElement.setAttribute('aria-expanded', 'false')
      menu.style.display = "none"
    else
      triggerElement.setAttribute('aria-expanded', 'true')
      menu.style.display = "flex"
