# Contact List App

This project was created to learn offline-first and synchronization data with a server.
But I included to manipulate files (save locally, download and send to a server) and run integration tests in codemagic as bonus.
The system is simple, it is a CRUD of a contact list where the contact has name, avatar and document. The user can change any of these informations. Name must not be null, avatar is recovered by https url and document must download directly from the server. Usually documents has important information than avatar.

## TODO

- [x] offline-first (crud básico com persistência no sqlite)
- [x] adicionar verificador da internet
- [x] adicionar sincronização com o servidor
- [] adicionar avatar (fazer recuperação via https)
-     falta enviar cada avatar para o servidor e de lá gerar um link para retornar a url do arquivo e sincronizar na base local
- [] adicionar pdf (fazer recuperação via download)
- [] adicionar testes de integração (executar no codemagic)

## About

- flutter version: 3.10.1
- dart: 3.0.1
- android sdk version: 33
- ios version: - (not used but needs to configure if wants to use it)
- codemagic.io to run integration tests

## Architecture

The project was splitted in `screens`, `widgets`, `blocs`, `entities`, `repositories`, `datasources` and `services`.


The screens represent the page of the app. In this project have contact list page and add/edit/remove contact page.
Widgets represent reusable components.
Blocks is the chosen state management used in this project to control the state of the page. For components, ValueNotifier or similar is usually used.
The entities represent the project model, where the data is stored and there is some logic related to the internal data transformations.
Repositories represent the control of the refactored data passed to the state manager. It is where there is control over where the data comes from offline or online.
The datasources represent the adapters for retrieving data saved somewhere. For example Dio adapters or Sqflite adapters.
Finally, services are external services added to projects, such as Dio and Sqflite or any other internal package that can be reused in other projects. They serve more as a support and not as part of the business, thus being easy to replace with similar ones.

Os screens representam a página do app. Neste projeto tem a página da lista de contatos e a página de adição/edição/remoção do contato.
Os widgets representam componentes reutilizáveis.
Os blocs é o state management escolhido utilizado neste projeto para o controle do estado da página. Para os componentes, normalmente é utilizado o ValueNotifier ou semelhantes.
As entities representam o modelo do projeto, onde os dados estão armazenados e nele existem alguma lógica relacionado as transformações dos dados internos.
Os repositories representam o controle dos dados refatorados passados para o state managent. É nele em que há o controle de onde vem os dados offline ou online.
Os datasources representam os adapters para recuperação dos dados salvos em algum local. Por exemplo, adapters do Dio ou adapters do Sqflite.
Por último, os services são os serviços externos adicionados aos projetos, como o Dio e Sqflite ou qualquer outro package interno que pode ser reutilizado em outros projetos. Eles servem mais como um apoio e não como parte do negócio, sendo assim fácil a substituição por outros similares.

[#############] COLOCAR A IMAGEM AQUI


## Lista de contatos com persistencia offline e sincronização em um servidor

- os dados são prioritariamente armazenados na base local.
- os dados são salvos e sincronizados no servidor como se fosse um backup.
- os dados são sincronizados com o servidor toda vez q pede para sincronizar, quando entra no app pela primeira vez e quando muda de estado de offline para online.
- a tela de contatos mostra a lista de contatos, botão deletar todos, ícone se está online ou offline.
- a tela de contato permite adicionar/editar/deletar o contato, tanto online quanto offline.
- os erros devem ser mostrados via snackbar.
- a lista de contatos é lista infinita.
- as imagens e os pdfs devem ser armazenados no app e no servidor.

- extra: para o servidor portar vários devices, é necessário que para cada item faça o controle de quais devices foram sincronizados.

## Tem 2 tipos de sincronizações
- sincronização da lista
  - controla a diferença entre a lista da base local com a do servidor
  - se as listas estão iguais, então está sincronizada, caso contrário está desincronizada
- a sincronização do item
  - controla se um item foi adicionado/editado/removido no local mas não no servidor
  - quando pede para sincronizar a lista desincronizada, o item é sincronizado no servidor

## Support

https://www.figma.com/file/Hv1nRdNq4b082O2pVqfopw/Contact-List?type=whiteboard&node-id=0-1

## Links

para download de pdf/imagens de teste:

https://freetestdata.com/