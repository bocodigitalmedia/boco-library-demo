# Todo

* [ ] Move API to /library/api/v1
* [ ] Create HTML interface in /documents
* [ ] Implement view templates
* [ ] Move files/upload to documents/upload
* [ ] Implement WS command interface?
* [ ] Design simple HTML interface for Frank to implement


## REST API

Accessible via `/library/api/v1`

### GET /documents

Query for a list of documents

* Pagination
* Root element via JSON?

```
{ "documents": [...] }
```

### POST /documents/

Create a document

### DELETE /documents/:id

Delete a document

### PUT/POST /documents/:id

Update a document
