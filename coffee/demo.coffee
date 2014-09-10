Express = require 'express'
Stream = require 'stream'
Async = require 'async'
BodyParser = require 'body-parser'
Path = require 'path'
SocketIO = require 'socket.io'
HTTP = require 'http'

Document = require './Document'
DocumentRepository = require './DocumentRepository'

router = require './router'
expressApp = Express()
httpServer = HTTP.createServer expressApp
socketServer = SocketIO httpServer

publishEvent = (name, payload) ->
  socketServer.emit name, payload

constructDocument = (props) ->
  new Document props

resolveDataPath = (args...) ->
  allArgs = [__dirname, '..', 'data'].concat args
  Path.resolve.apply Path, allArgs

resolveStaticPath = (args...) ->
  allArgs = [__dirname, '..', 'public'].concat args
  Path.resolve.apply Path, allArgs

documentRepository = new DocumentRepository
  collection: require resolveDataPath('documents.json')

# router: /
rootRouter = router.root
  resolveStaticPath: resolveStaticPath

expressApp.use "/", rootRouter

# router: /documents
documentsRouter = router.documents
  constructDocument: constructDocument
  publishEvent: publishEvent
  documentRepository: documentRepository

expressApp.use "/documents", documentsRouter

httpServer.listen process.env.PORT, ->
  console.log "Demo server started", httpServer.address()
