var DemoApp = (function(window) {

  var DemoApp = {};
  var socket = window.io();
  var viewId = "allDocumentsView";
  var viewEl = window.document.getElementById(viewId);

  var ReadyState = {
    UNSENT: 0,
    OPENED: 1,
    HEADERS_RECEIVED: 2,
    LOADING: 3,
    DONE: 4
  };

  socket.on("library.document.deleted", onDocumentDeleted);
  socket.on("library.document.created", onDocumentCreated);
  socket.on("library.document.updated", onDocumentUpdated);

  window.addEventListener("load", onWindowLoad);

  return DemoApp;

  function createDocumentViewElement(doc) {
    var linkEl = window.document.createElement("a");
    linkEl.setAttribute("href", doc.url);
    linkEl.innerText = doc.name;

    var divEl = window.document.createElement("div");
    divEl.appendChild(linkEl);

    var listEl = window.document.createElement("li");
    listEl.setAttribute("id", "document-" + doc.id);
    listEl.appendChild(divEl);

    return listEl;
  }

  function requestDocumentList(callback) {
    var xhr = new XMLHttpRequest();
    xhr.responseType = "text";

    xhr.onreadystatechange = function() {
      var error, json, list;

      if(ReadyState.DONE !== xhr.readyState) {
        return; // Nothing to do until ready
      }

      if(200 !== xhr.status) {
        error = new Error();
        error.name = "DocumentListRequestFailed";
        error.message = "Document list request failed.";
        error.payload = { xhr: xhr };
        return callback(error);
      }

      json = xhr.response;
      response = JSON.parse(json);
      return callback(null, response);
    };

    xhr.open("get", "/documents", true);
    xhr.send();
  }

  function updateAllDocumentsView(docs) {
    viewEl.innerHTML = "";
    docs.forEach(function(doc) {
      var docViewEl = createDocumentViewElement(doc);
      viewEl.appendChild(docViewEl);
    });
  }

  function onDocumentDeleted(payload) {
    var doc = payload.document;
    var docElId = "document-" + doc.id;
    var docEl = window.document.getElementById(docElId);
    viewEl.removeChild(docEl);
  }

  function onDocumentCreated(payload) {
    var doc = payload.document;
    var docEl = createDocumentViewElement(doc);
    viewEl.appendChild(docEl);
  }

  function onDocumentUpdated(payload) {
    var doc = payload.document;
    var docElId = "document-" + doc.id;
    var oldEl = window.document.getElementById(docElId);
    var newEl = createDocumentViewElement(doc);
    viewEl.replaceChild(newEl, oldEl);
  }

  function refreshAllDocumentsView() {
    requestDocumentList(function(error, response) {

      if(error != null) {
        console.error(error);
        throw error;
      }

      return updateAllDocumentsView(response.documents);
    });
  }

  function onWindowLoad() {
    refreshAllDocumentsView();
  }

}(this));
