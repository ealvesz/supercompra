# SuperCompra

Projeto acadêmico de banco de dados para um sistema de compras, desenvolvido utilizando PostgreSQL.

## Objetivo

Organizar as informações de clientes, produtos, estoque, pedidos, pagamentos, entregas e vendas, aplicando conceitos de modelagem e integridade de dados.

## Tecnologias utilizadas

- PostgreSQL
- SQL
- pgAdmin 4

## Estrutura do banco de dados

O projeto utiliza o schema `sc`, com tabelas relacionadas às operações do sistema, chaves primárias e estrangeiras, restrições de integridade e validação.

Também foram desenvolvidas funções e gatilhos para registrar auditorias e atualizar datas de modificação de registros.

## Testes realizados

Foram realizados testes com registros de produtos, estoque, clientes, pedidos, itens de pedido e pagamentos. Também foi verificado o funcionamento de um gatilho responsável por atualizar a data de modificação de pagamentos.

## Situação atual

O projeto está em desenvolvimento. Algumas operações ainda precisam de testes e validações adicionais, incluindo os fluxos de pagamentos, vendas e entregas.

## Observação

Este projeto tem finalidade acadêmica. Os registros utilizados nos testes são dados de demonstração e não representam transações financeiras reais.
