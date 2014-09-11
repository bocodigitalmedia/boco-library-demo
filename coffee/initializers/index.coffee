Async = require 'async'

exports.initialize = (config, callback) ->

  initializers = [
    require './amqpConnection'
    require './amqpChannel'
    require './amqpConsumer'
    require './amqpPublisher'
    require './amqpSchema'
  ]

  reduceFn = (depends, initializer, done) ->
    initializer.call null, config, depends, done

  Async.reduce initializers, {}, reduceFn, callback
