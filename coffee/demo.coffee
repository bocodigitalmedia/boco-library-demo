Express = require 'express'
Stream = require 'stream'
Async = require 'async'
BodyParser = require 'body-parser'
Path = require 'path'
SocketIO = require 'socket.io'
HTTP = require 'http'

Document = require './Document'
DocumentRepository = require './DocumentRepository'

routers = require './routers'
config = require './config'
initializers = require './initializers'

initializers.initialize config, (error, depends) ->

  expressApp = Express()
  httpServer = HTTP.createServer expressApp
  socketServer = SocketIO httpServer

  publishEvent = (name, payload) ->
    exchange = config.amqp.eventsExchangeName
    routingKey = name
    event = name: name, payload: payload
    json = JSON.stringify event
    buffer = new Buffer json
    channel = depends.amqpPublisher
    options = persistent: true

    channel.publish exchange, routingKey, buffer, options, (error) ->
      throw error if error?

  constructDocument = (props) ->
    new Document props

  documentsPath = Path.join config.dataFolderPath, "documents.json"
  documents = require documentsPath
  documentRepository = new DocumentRepository collection: documents

  # Configure Express Routes....................................................

  # router: /
  rootRouter = routers.root
    staticFolderPath: config.staticFolderPath

  expressApp.use "/", rootRouter

  # router: /documents
  documentsRouter = routers.documents
    constructDocument: constructDocument
    publishEvent: publishEvent
    documentRepository: documentRepository

  expressApp.use "/documents", documentsRouter

  # Start the server ...........................................................
  httpServer.listen process.env.PORT, ->
    console.log "Demo server started", httpServer.address()

    # Process events from the events queue .....................................
    channel = depends.amqpConsumer
    queue = config.amqp.eventsQueueName
    options = noAck: false

    consumeFn = (message) ->
      json = message.content.toString()
      event = JSON.parse json
      socketServer.emit event.name, event.payload
      channel.ack message

    channel.consume queue, consumeFn, options
