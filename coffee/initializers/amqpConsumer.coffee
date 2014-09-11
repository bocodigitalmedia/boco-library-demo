module.exports = (config, depends, callback) ->
  depends.amqpConnection.createChannel (error, channel) ->
    depends.amqpConsumer = channel
    callback error, depends
