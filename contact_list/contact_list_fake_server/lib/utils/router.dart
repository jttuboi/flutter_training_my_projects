import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../database/database.dart';
import '../entities/entities.dart';
import 'utils.dart';

final router = Router()

      /// UPDATE ALL / SYNCHRONIZE
      ///
      /// request url = 'http://10.0.2.2:8080/v1/contacts'
      /// request method = PUT
      /// request body = {
      ///   "entities": [
      ///     {
      ///       "id": "1",
      ///       "name": "blablabla",
      ///       "avatar_url": "http://....",
      ///       "document_url": "http://...",
      ///       "created_at": "2023-...",     // can be null
      ///       "updated_at": null,           // can be null
      ///       "sync_status": "added"        // added, updated, removed, synced
      ///     },
      ///     ...
      ///   ]
      /// }
      ///
      /// TODO deixar com retorno, pois se precisar sincronizar mais de um device, é necessário recuperar os dados do servidor
      /// response status code = 200
      /// response body = {
      ///   "entities": [
      ///     {
      ///       "id": "1",
      ///       "name": "blablabla",
      ///       "avatar_url": "http://....",
      ///       "document_url": "http://...",
      ///       "created_at": "2023-...",     // can be null
      ///       "updated_at": null,           // can be null
      ///       "sync_status": "added"        // added, updated, removed, synced
      ///     },
      ///     ...
      ///   ]
      /// }
      ..put('/contacts', (request) async {
        await printRequest(request);

        final bodyString = await request.readAsString();
        if (bodyString.isEmpty) {
          return _responseNotFoundErrors([
            const Error(tag: 'no_data', message: 'Não foi enviado nenhuma lista para o servidor atualizar.'),
          ]);
        }

        final maps = jsonDecode(bodyString) as Map<String, dynamic>;
        if (maps.containsKey('entities')) {
          final contactsToSynchronize = ContactsExtension.fromEntitiesMap(maps);

          for (final contactToSynchronize in contactsToSynchronize) {
            if (contactToSynchronize.syncStatus.isAdded) {
              contactsDB.add(contactToSynchronize.copyWith(syncStatus: SyncStatus.synced));
            } else //
            if (contactToSynchronize.syncStatus.isUpdated) {
              final index = contactsDB.indexWhere((contact) => contact.id == contactToSynchronize.id);
              if (index == -1) {
                contactsDB.add(contactToSynchronize.copyWith(syncStatus: SyncStatus.synced));
              } else {
                contactsDB[index] = contactToSynchronize.copyWith(syncStatus: SyncStatus.synced);
              }
            } else //
            if (contactToSynchronize.syncStatus.isRemoved) {
              contactsDB.removeWhere((contact) => contact.id == contactToSynchronize.id);
            }
          }

          // por enquanto retorna os mesmos dados recebidos, no futuro deverá recuperar os dados da base do servidor e mandar todos alterados
          // pois pode haver dados alterados pelo outro device
          return _response(data: maps);
        }

        return _responseNotFoundErrors([
          const Error(tag: 'no_data', message: 'Não foi enviado contact para o servidor salvar.'),
        ]);
      })

      /// GET ALL
      ///
      /// request url = 'http://10.0.2.2:8080/v1/contacts'
      /// request method = GET
      /// request body = null
      ///
      /// response status code = 200
      /// response body = {
      ///   "entities": [
      ///     {
      ///       "id": "1",
      ///       "name": "blablabla",
      ///       "avatar_url": "http://....",
      ///       "document_url": "http://...",
      ///       "created_at": "2023-...",     // can be null
      ///       "updated_at": null,           // can be null
      ///       "sync_status": "added"        // added, updated, removed, synced
      ///     },
      ///     ...
      ///   ]
      /// }
      ..get('/contacts', (request) async {
        await printRequest(request);
        return _response(data: contactsDB.toEntitiesMap());
      })

      /// COUNT
      //
      /// request url = 'http://10.0.2.2:8080/v1/contacts/count'
      /// request method = GET
      /// request body = null
      ///
      /// response status code = 200
      /// response body = {
      ///   "count": 11
      /// }
      ..get('/contacts/count', (request) async {
        await printRequest(request);
        return _response(data: contactsDB.toCountMap());
      })

    // /// CREATE
    // ///
    // /// request url = 'http://10.0.2.2:8080/v1/contacts'
    // /// request method = POST
    // /// request body = {
    // ///   "entity": {
    // ///     "id": "1",
    // ///     "name": "blablabla",
    // ///     "avatar_url": "http://....",
    // ///     "document_url": "http://...",
    // ///     "created_at": "2023-...",     // can be null
    // ///     "updated_at": null,           // can be null
    // ///     "sync_status": "added"        // added, updated, removed, synced
    // ///   }
    // /// }
    // ///
    // /// response status code = 200
    // /// response body = {
    // ///   "entity": {
    // ///     "id": "1",
    // ///     "name": "blablabla",
    // ///     "avatar_url": "http://....",
    // ///     "document_url": "http://...",
    // ///     "created_at": "2023-...",     // can be null
    // ///     "updated_at": null,           // can be null
    // ///     "sync_status": "synced"       // added, updated, removed, synced
    // ///   },
    // /// }
    // ///
    // /// response status code = 404
    // ..post('/contacts', (request) async {
    //   await Future.delayed(const Duration(seconds: 2));
    //   print(request);

    //   final bodyString = await request.readAsString();
    //   if (bodyString.isEmpty) {
    //     return _responseNotFoundErrors([
    //       const Error(tag: 'no_data', message: 'Não foi enviado contact para o servidor salvar.'),
    //     ]);
    //   }

    //   final data = jsonDecode(bodyString) as Map<String, dynamic>;
    //   if (data.containsKey('entity')) {
    //     final name = data['name'] as String;
    //     final avatarUrl = data['avatar_url'] as String;
    //     final documentUrl = data['document_url'] as String;

    //     final newContact = Contact(id: const Uuid().v4(), name: name, avatarUrl: avatarUrl, documentUrl: documentUrl);
    //     contacts.add(newContact);

    //     return _response(responseTypeToShow: ResponseType.x201created, data: newContact.toEntityMap());
    //   }

    //   return _responseNotFoundErrors([
    //     const Error(tag: 'no_data', message: 'Não foi enviado contact para o servidor salvar.'),
    //   ]);
    // })

    // /// DELETE ALL
    // ///
    // /// request url = 'http://10.0.2.2:8080/v1/contacts'
    // /// request method = DELETE
    // /// request body = null
    // ///
    // /// response status code = 204
    // /// response body = null
    // ..delete('/contacts', (request) async {
    //   return ;
    // })

    // /// GET
    // ///
    // /// request url = 'http://10.0.2.2:8080/v1/contacts/<id>'
    // /// request method = GET
    // /// request body = null
    // ///
    // /// response status code = 200
    // /// response body = {
    // ///   "entity": {
    // ///     "id": "1",
    // ///     "name": "blablabla",
    // ///     "avatar_url": "http://....",
    // ///     "document_url": "http://...",
    // ///     "created_at": "2023-...",     // can be null
    // ///     "updated_at": null,           // can be null
    // ///     "sync_status": "synced"       // added, updated, removed, synced
    // ///   },
    // /// }
    // ///
    // /// response status code = 404
    // ..get('/contacts/<id>', (request, id) async {
    //   await Future.delayed(const Duration(seconds: 2));
    //   print(request);

    //   try {
    //     final contact = contacts.firstWhere((contact) => contact.id == id);

    //     return _response(data: contact.toEntityMap());
    //   } on StateError {
    //     return _responseNotFoundErrors([
    //       const Error(tag: 'no_data', message: 'Não foi encontrado o contact com o id específico.'),
    //     ]);
    //   }
    // })

    // /// UPDATE
    // ///
    // /// request url = 'http://10.0.2.2:8080/v1/contacts/<id>'
    // /// request method = PUT
    // /// request body = {
    // ///   "entity": {
    // ///     "id": "1",
    // ///     "name": "Jão",
    // ///     "avatar_url": "http://....",
    // ///     "document_url": "http://...",
    // ///     "created_at": "2023-...",     // can be null
    // ///     "updated_at": null,           // can be null
    // ///     "sync_status": "synced"       // added, updated, removed, synced
    // ///   }
    // /// }
    // ///
    // /// response status code = 200
    // /// response body = {
    // ///   "entity": {
    // ///     "id": "1",
    // ///     "name": "Jão",
    // ///     "avatar_url": "http://....",
    // ///     "document_url": "http://...",
    // ///     "created_at": "2023-...",     // can be null
    // ///     "updated_at": null,           // can be null
    // ///     "sync_status": "synced"       // added, updated, removed, synced
    // ///   },
    // /// }
    // ///
    // /// response status code = 404
    // ..put('/contacts/<id>', (request, id) async {
    //   await Future.delayed(const Duration(seconds: 2));
    //   print(request);

    //   final bodyString = await request.readAsString();
    //   if (bodyString.isEmpty) {
    //     return _responseNotFoundErrors([
    //       const Error(tag: 'no_data', message: 'Não foi enviado contact para o servidor alterar.'),
    //     ]);
    //   }

    //   final data = jsonDecode(bodyString) as Map<String, dynamic>;
    //   if (data.containsKey('entity')) {
    //     final name = data['name'] as String;
    //     final avatarUrl = data['avatar_url'] as String;
    //     final documentUrl = data['document_url'] as String;

    //     try {
    //       final index = contacts.indexWhere((contact) => contact.id == id);

    //       final updateContact = Contact(id: id, name: name, avatarUrl: avatarUrl, documentUrl: documentUrl);
    //       contacts[index] = updateContact;

    //       return _response(data: updateContact.toEntityMap());
    //     } on StateError {
    //       return _responseNotFoundErrors([
    //         const Error(tag: 'no_data', message: 'Não foi encontrado o contact com o id específico.'),
    //       ]);
    //     }
    //   }

    //   return _responseNotFoundErrors([
    //     const Error(tag: 'no_data', message: 'Não foi enviado contact para o servidor alterar.'),
    //   ]);
    // })

    // /// DELETE
    // ///
    // /// request url = 'http://10.0.2.2:8080/v1/contacts/<id>'
    // /// request method = DELETE
    // /// request body = null
    // ///
    // /// response status code = 204
    // /// response body = null
    // ..delete('/contacts/<id>', (request) async {
    //   return ;
    // })
    ;

Response _response({ResponseType responseTypeToShow = ResponseType.x200ok, Map<String, dynamic> data = const {}}) {
  assert(responseTypeToShow != ResponseType.xUseDefinedInMethod, 'responseTypeToShow must not be _useDefinedInMethod.');
  final responseType = (responseTypeToShow == ResponseType.xUseDefinedInMethod) ? responseTypeToShow : responseTypeToShow;

  var response = Response.internalServerError();
  var responseToPrint = Response.internalServerError();

  switch (responseType) {
    case ResponseType.x200ok:
      assert(data != const {}, 'data must not be empty.');
      response = Response.ok(jsonEncode(data), headers: defaultHeaders);
      responseToPrint = Response.ok(jsonEncode(data), headers: defaultHeaders);
      break;
    case ResponseType.x201created:
      assert(data != const {}, 'data must not be empty.');
      response = Response(ResponseType.x201created.code, body: jsonEncode(data), headers: defaultHeaders);
      responseToPrint = Response(ResponseType.x201created.code, body: jsonEncode(data), headers: defaultHeaders);
      break;
    case ResponseType.x202accepted:
      response = Response(ResponseType.x202accepted.code, body: jsonEncode(data), headers: defaultHeaders);
      responseToPrint = Response(ResponseType.x202accepted.code, body: jsonEncode(data), headers: defaultHeaders);
      break;
    case ResponseType.x401unautorized:
      response = Response.unauthorized(null);
      responseToPrint = Response.unauthorized(null);
      break;
    case ResponseType.x404notFound:
      response = Response.notFound(null);
      responseToPrint = Response.notFound(null);
      break;
    case ResponseType.xUseDefinedInMethod:
      response = Response.internalServerError();
      responseToPrint = Response.internalServerError();
      break;
  }

  printResponse(responseToPrint);
  printContacts();
  return response;
}

Response _responseNotFoundErrors(List<Error> errors) {
  final response = Response.notFound(jsonEncode(errors.toErrorsMap()), headers: defaultHeaders);
  final responseToPrint = Response.notFound(jsonEncode(errors.toErrorsMap()), headers: defaultHeaders);

  printResponse(responseToPrint);
  printContacts();
  return response;
}
