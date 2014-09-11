AMQPLib = require 'amqplib/callback_api'

module.exports = (config, depends, callback) ->
  AMQPLib.connect config.amqp.connectionUri, (error, connection) ->
    depends.amqpConnection = connection
    callback error, depends
