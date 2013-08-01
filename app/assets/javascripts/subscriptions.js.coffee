$ ->
  payment_buttons = $('#payment-options a.subscription.btn')
  payment_buttons.on 'click', (e)->
    $('#please-wait').removeClass('hidden')
    $('#payment-options').addClass('hidden')
