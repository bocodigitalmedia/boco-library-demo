Express = require 'express'
Stream = require 'stream'
Async = require 'async'
BodyParser = require 'body-parser'
Path = require 'path'
SocketIO = require 'socket.io'
HTTP = require 'http'

class Document
  constructor: (props = {}) ->
    @id = props.id
    @url = props.url
    @name = props.name
    @mimeType = props.mimeType
    @setDefaults()

  setDefaults: ->
    @id ?= require('uuid').v4()

class DocumentRepository
  constructor: (props = {}) ->
    @collection = props.collection
    @setDefaults()

  setDefaults: ->
    @collection ?= {}

  generateId: ->
    require('uuid').v4()

  find: (id, callback) ->
    unless @collection.hasOwnProperty id
      error = Error()
      error.name = "DocumentNotFound"
      error.message = "Document not found."
      error.payload = id: id
      return callback error

    doc = @collection[id]
    return callback null, doc

  create: (doc, callback) ->
    doc.id ?= @generateId

    if @collection.hasOwnProperty doc.id
      error = Error()
      error.name = "PrimaryKeyViolation"
      error.message = "A document already exists with this id."
      error.payload = id: doc.id
      return callback error

    @collection[doc.id] = doc
    return callback null, doc

  update: (doc, callback) ->
    unless doc.id?
      error = Error()
      error.name = "InvalidDocument"
      error.message = "This document has no identity"
      error.payload = document: doc
      return callback error

    unless @collection.hasOwnProperty doc.id
      error = Error()
      error.name = "DocumentNotFound"
      error.message = "Cannot update this document, not found."
      error.payload = id: doc.id
      return callback error

    @collection[doc.id] = doc
    return callback null, doc

  delete: (id, callback) ->
    unless @collection.hasOwnProperty(id)
      error = Error()
      error.name = "DocumentNotFound"
      error.message = "Document not found."
      error.payload = id: id
      return callback error

    doc = @collection[id]
    delete @collection[id]
    return callback null, doc

expressApp = Express()
httpServer = HTTP.createServer expressApp
socketServer = SocketIO httpServer

publishEvent = (name, payload) ->
  socketServer.emit name, payload

documentRepository = new DocumentRepository
  collection: require('./documents.json')

socketServer.on "connect", (socket) ->
  console.log "socket connected #{socket.id}"
  socket.on "disconnect", ->
    console.log "socket disconnected #{socket.id}"

expressApp.use BodyParser.json()

expressApp.get "/", (request, response) ->
  pathToIndex = Path.join __dirname, "public", "index.html"
  console.log pathToIndex
  response.sendFile pathToIndex

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
