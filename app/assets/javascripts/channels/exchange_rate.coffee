App.exchange_rate = App.cable.subscriptions.create "ExchangeRateChannel",
  connected: ->
    console.log 'connected'

  disconnected: ->
    console.log 'diconnected'

  received: (data) ->
    $('.js-dollar').html data['rate_value']

