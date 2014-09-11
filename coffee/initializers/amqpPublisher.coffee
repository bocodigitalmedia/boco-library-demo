module.exports = (config, depends, callback) ->
  depends.amqpConnection.createConfirmChannel (error, channel) ->
    depends.amqpPublisher = channel
    callback error, depends
