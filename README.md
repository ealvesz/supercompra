# SuperCompra — Banco de Dados

Projeto acadêmico de modelagem e implementação de banco de dados para um sistema de supermercado, desenvolvido com PostgreSQL.

## Sobre o projeto

O SuperCompra tem como objetivo organizar informações de produtos, categorias, clientes, fornecedores, estoque, pedidos, pagamentos e vendas. O banco também conta com recursos para registrar alterações e facilitar consultas gerenciais.

O projeto está em desenvolvimento e utiliza dados fictícios para testes.

## Tecnologias utilizadas

- PostgreSQL
- SQL
- pgAdmin 4

## Estrutura do banco

O banco utiliza o esquema `sc` e possui tabelas para organizar as principais operações do sistema, incluindo:

- **Produtos e categorias:** cadastro e organização dos produtos.
- **Clientes e endereços:** armazenamento dos dados de exemplo dos clientes.
- **Estoque:** controle de quantidades e movimentações.
- **Pedidos e itens:** registro dos pedidos e dos produtos associados.
- **Pagamentos e entregas:** organização das informações dessas operações.
- **Auditoria e histórico:** registro de alterações e acompanhamento de eventos.

O projeto também contém funções, gatilhos (*triggers*), índices e visualizações (*views*) para apoiar a integridade dos dados e as consultas.

## Arquivos do projeto

| Arquivo | Descrição |
|---|---|
| `README.md` | Documentação do projeto |
| `supercompra.sql` | Script SQL exportado do PostgreSQL |

## Como executar o banco de dados

### 1. Requisitos

- PostgreSQL instalado.
- Acesso ao terminal com o utilitário `psql`.
- Arquivo `supercompra.sql` baixado deste repositório.

### 2. Criar o banco de dados

No terminal, execute:

```bash
createdb -U postgres supercompra
```

Caso o usuário `postgres` não corresponda à sua instalação, substitua-o pelo usuário configurado no seu PostgreSQL.

### 3. Importar o arquivo SQL

Na pasta onde o arquivo foi salvo, execute:

```bash
psql -U postgres -d supercompra -v ON_ERROR_STOP=1 -f supercompra.sql
```

O comando interrompe a execução quando encontra um erro SQL. Confira o resultado no terminal antes de considerar a importação concluída.

> O arquivo foi exportado em formato textual do PostgreSQL. Para esse formato, utilize `psql`, que reconhece os comandos próprios do utilitário presentes no arquivo.

## Como verificar a importação

Depois da importação, conecte-se ao banco `supercompra` pelo pgAdmin 4 ou pelo terminal.

Execute as consultas abaixo para verificar se as tabelas e visualizações estão disponíveis.

### Consultar as tabelas do esquema

```sql
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'sc'
  AND table_type = 'BASE TABLE'
ORDER BY table_name;
```

### Consultar os produtos cadastrados

```sql
SELECT *
FROM sc.produtos;
```

### Consultar as visualizações disponíveis

```sql
SELECT table_name
FROM information_schema.views
WHERE table_schema = 'sc'
ORDER BY table_name;
```

### Consultar a visualização de estoque baixo

```sql
SELECT *
FROM sc.vw_estoque_baixo;
```

Essas consultas ajudam a conferir a estrutura importada e os dados disponíveis. O resultado depende dos registros existentes no banco.

## Testes e validação

Após importar o arquivo em um banco de testes, recomenda-se:

1. Confirmar a criação das tabelas e das visualizações.
2. Consultar os registros de exemplo.
3. Verificar os relacionamentos e as restrições entre as tabelas.
4. Testar as funções e os gatilhos com operações controladas.
5. Conferir os registros de auditoria após as alterações previstas.

Os testes devem ser executados antes de registrar que um recurso foi validado com sucesso. O arquivo SQL contém dados fictícios e não deve ser tratado como uma base de produção.

## Situação do projeto

O SuperCompra é um projeto acadêmico em desenvolvimento, voltado à prática de modelagem de dados, criação de estruturas relacionais e utilização de recursos do PostgreSQL.

## Autor

Kauã Kairon Alves de Melo

Projeto desenvolvido para fins acadêmicos.
