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
  throw error if error?

  # Dependencies
  #-----------------------------------------------------------------------------

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
  data = require documentsPath
  documents = {}
  documents[id] = constructDocument props for own id, props of data
  documentRepository = new DocumentRepository collection: documents

  # Configure Express
  #-----------------------------------------------------------------------------
  expressApp = Express()

  # Views
  expressApp.set 'views', config.viewsFolderPath
  expressApp.set 'view engine', 'hbs'

  # Static
  staticMiddleware = Express.static config.staticFolderPath
  expressApp.use staticMiddleware

  # Root Router
  rootRouter = routers.root
    staticFolderPath: config.staticFolderPath

  # Files Router
  filesRouter = routers.files
    constructDocument: constructDocument
    publishEvent: publishEvent
    documentRepository: documentRepository
    uploadsFolderPath: config.uploadsFolderPath

  # Documents Router
  documentsRouter = routers.documents
    constructDocument: constructDocument
    publishEvent: publishEvent
    documentRepository: documentRepository

  expressApp.use "/", rootRouter
  expressApp.use "/files/", filesRouter
  expressApp.use "/documents", documentsRouter

  #-----------------------------------------------------------------------------

  httpServer = HTTP.createServer expressApp
  socketServer = SocketIO httpServer

  #-----------------------------------------------------------------------------

  # Start the server
  httpServer.listen process.env.LISTEN, ->
    console.log "Demo server started", httpServer.address()

    channel = depends.amqpConsumer
    queue = config.amqp.eventsQueueName
    options = noAck: false

    consumeFn = (message) ->
      json = message.content.toString()
      event = JSON.parse json
      socketServer.emit event.name, event.payload
      channel.ack message

    channel.consume queue, consumeFn, options
