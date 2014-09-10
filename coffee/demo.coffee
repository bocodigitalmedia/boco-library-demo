Express = require 'express'
Stream = require 'stream'
Async = require 'async'
BodyParser = require 'body-parser'
Path = require 'path'
SocketIO = require 'socket.io'
HTTP = require 'http'

Document = require './Document'
DocumentRepository = require './DocumentRepository'

expressApp = Express()
httpServer = HTTP.createServer expressApp
socketServer = SocketIO httpServer

publishEvent = (name, payload) ->
  socketServer.emit name, payload

resolveDataPath = (args...) ->
  allArgs = [__dirname, '..', 'data'].concat args
  Path.resolve.apply Path, allArgs

resolvePublicPath = (args...) ->
  allArgs = [__dirname, '..', 'public'].concat args
  Path.resolve.apply Path, allArgs

documentRepository = new DocumentRepository
  collection: require resolveDataPath('documents.json')

socketServer.on "connect", (socket) ->
  console.log "socket connected #{socket.id}"
  socket.on "disconnect", ->
    console.log "socket disconnected #{socket.id}"

expressApp.use BodyParser.json()

expressApp.get "/", (request, response) ->
  response.sendFile resolvePublicPath('index.html')

expressApp.get "/documents", (request, response) ->
  response.json documentRepository.collection

expressApp.post "/documents", (request, response) ->
  doc = new Document request.body
  documentRepository.create doc, (error, doc) ->
    throw error if error?
    publishEvent "library.document.created",
      document: doc
    response.json doc

expressApp.get "/documents/:id", (request, response) ->
  id = request.params.id
  console.log "finding document #{id}"
  documentRepository.find id, (error, doc) ->
    throw error if error?
    response.json doc

expressApp.put "/documents/:id", (request, response) ->
  doc = new Document request.body
  doc.id = request.params.id
  documentRepository.update doc, (error, doc) ->
    throw error if error?
    publishEvent "library.document.updated",
      document: doc
    response.json doc

expressApp.delete "/documents/:id", (request, response) ->
  id = request.params.id
  documentRepository.delete id, (error, doc) ->
    throw error if error?
    publishEvent "library.document.deleted",
      document: doc
    response.json doc

httpServer.listen process.env.PORT, ->
  console.log "Demo server started", httpServer.address()
