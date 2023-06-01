# contact_list_app


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

## Lins

para download de pdf/imagens de teste:

https://freetestdata.com/