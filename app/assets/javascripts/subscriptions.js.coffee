$ ->
  payment_buttons = $('#payment-options a.subscription.btn')
  payment_buttons.on 'click', (e)->
    $('#replace-on-click').html('Redirecting you to PayPal, please wait a little bit')
