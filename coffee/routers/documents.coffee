Express = require 'express'
BodyParser = require 'body-parser'

documentsRouter = (config = {}) ->
  repository = config.documentRepository
  constructDocument = config.constructDocument
  publishEvent = config.publishEvent
  jsonBodyParser = BodyParser.json()
  router = new Express.Router()

  listDocuments = (request, response) ->
    documents = repository.collection.sort (doc1, doc2) ->
      d1 = new Date(doc1.createdAt).getTime()
      d2 = new Date(doc2.createdAt).getTime()
      return d2 - d1

    response.json
      count: documents.length
      documents: documents

  createDocument = (request, response) ->
    document = constructDocument request.body
    repository.create document, (error, document) ->
      throw error if error?
      publishEvent "library.document.created", document: document
      response.json document

  getDocument = (request, response) ->
    documentId = request.params.id
    repository.find documentId, (error, document) ->
      throw error if error?
      response.json document

  updateDocument = (request, response) ->
    documentId = request.params.id
    document = constructDocument request.body
    document.id = documentId

    repository.update document, (error, document) ->
      throw error if error?
      publishEvent "library.document.updated", document: document
      response.json document

  deleteDocument = (request, response) ->
    documentId = request.params.id
    repository.delete documentId, (error, document) ->
      throw error if error?
      publishEvent "library.document.deleted", document: document
      response.json document

  router.get "/", listDocuments
  router.post "/", jsonBodyParser, createDocument
  router.get "/:id", getDocument
  router.put "/:id", jsonBodyParser, updateDocument
  router.delete "/:id", jsonBodyParser, deleteDocument

  return router

module.exports = documentsRouter
