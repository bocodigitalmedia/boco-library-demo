Async = require 'async'

module.exports = (config, depends, callback) ->
  channel = depends.amqpChannel

  assertEventsExchange = (done) ->
    name = config.amqp.eventsExchangeName
    type = "fanout"
    options = durable: true
    channel.assertExchange name, type, options, done

  assertEventsQueue = (done) ->
    name = config.amqp.eventsQueueName
    options = durable: true
    channel.assertQueue name, options, done

  bindEventsQueue = (done) ->
    exchange = config.amqp.eventsExchangeName
    queue = config.amqp.eventsQueueName
    pattern = "#"
    channel.bindQueue queue, exchange, pattern, null, done

  steps = [
    assertEventsExchange
    assertEventsQueue
    bindEventsQueue
  ]

  Async.series steps, (error) ->
    callback error, depends
