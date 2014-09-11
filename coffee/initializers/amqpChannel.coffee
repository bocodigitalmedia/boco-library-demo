module.exports = (config, depends, callback) ->
  depends.amqpConnection.createChannel (error, channel) ->
    depends.amqpChannel = channel
    callback error, depends
