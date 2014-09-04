Express = require 'express'
Stream = require 'stream'
Async = require 'async'
BodyParser = require 'body-parser'

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
    unless @collection.hasOwnProperty id?
      error = Error()
      error.name = "DocumentNotFound"
      error.message = "Document not found."
      error.payload = id: id
      return callback error

    doc = @collection[id]
    return callback null, doc

  insert: (doc, callback) ->
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

documentRepository = new DocumentRepository
  collection: require('./documents.json')

expressApp.use BodyParser.json()

expressApp.get "/documents", (request, response) ->
  # TODO: this is a workaround, do something for reals here
  response.send 200, documentRepository.collection

expressApp.post "/documents", (request, response) ->
  doc = new Document request.body
  documentRepository.insert doc, (error, doc) ->
    throw error if error?
    response.send 200, doc

expressApp.listen process.env.PORT, ->
  console.log "Demo server started"
