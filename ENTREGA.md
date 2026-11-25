# Atividade-04 – Entrega

| Pedro Rubem de Sousa Oliveira | 20181S.25.19 |
|---|---|
|  |  |
|  |  |

**Turma:** 20262.3.14TADS.1T

## Checklist

Marque com `x` o que foi feito (ex.: `[x]`).

| Questão | Criei e funcionou | Colei o resultado / print | Respondi a pergunta | Mostrei ao professor |
|---|:-:|:-:|:-:|:-:|
| Q1 – `sacar` | [x] | [x] | – | [ ] |
| Q2 – `resumo_conta` | [x] | [x] | [x] | [ ] |
| Q3 – `aplicar_rendimento` | [x] | [x] | [x] | [ ] |
| Q4 – `trg_mov_bi` | [x] | [x] | [x] | [ ] |
| Q5 – `trg_contas_au` | [x] | [x] | [x] | [ ] |

## Resultados dos testes

Testado no MySQL 8.4 (banco `DBatividade4`), sempre partindo dos dados
iniciais. Prints em [`evidencias/`](evidencias/); o texto completo está na
seção *RESULTADO OBTIDO* de cada arquivo em `questoes/`.

| Questão | Teste | Resultado obtido | Print |
|---|---|---|---|
| Q1 | `CALL sacar(2, 150)` | Bruno com saldo 350.00 e nova movimentação `debito 150.00 Saque` | [Q1.png](evidencias/Q1.png) |
| Q1 | `sacar(1, 0)` · `(9, 10)` · `(5, 10)` · `(3, 500)` | `Valor inválido` · `Conta não encontrada` · `Conta bloqueada` · `Saldo insuficiente` | |
| Q2 | `resumo_conta(2, ...)` | 600.00 · 100.00 · 2 | [Q2.png](evidencias/Q2.png) |
| Q2 | `resumo_conta(1, ...)` · `(4, ...)` | 1000.00 · 0.00 · 1 e 0.00 · 0.00 · 0 (sem `NULL`) | |
| Q3 | `aplicar_rendimento(1.5, @q)` | `@q = 3`; Ana 1015.00 · Bruno 507.50 · Carla 203.00 · Diego 0.00 · Elisa 300.00 | [Q3.png](evidencias/Q3.png) |
| Q3 | `aplicar_rendimento(0, @q)` | `Taxa inválida` | |
| Q4 | `INSERT ' CREDITO '` e descrição `''` | Gravou `credito` e `Sem descrição` | [Q4.png](evidencias/Q4.png) |
| Q4 | `INSERT 'pix'` · valor `0` | `Tipo inválido` · `Valor inválido` (só 2 linhas entraram) | |
| Q5 | `UPDATE` de saldo (Diego) | 1 linha na auditoria: conta 4, 0.00 → 100.00 | [Q5.png](evidencias/Q5.png) |
| Q5 | `UPDATE` só do titular · `CALL sacar(2, 50)` | continua 1 linha · 2 linhas, a nova: conta 2, 500.00 → 450.00 | |

## Respostas às perguntas

- **Q2:** `@c - @d` do Bruno = 600.00 − 100.00 = **500.00**, igual ao saldo
  dele (saldo = créditos − débitos).
- **Q3:** o Diego tem saldo 0.00 e a Elisa está BLOQUEADA; só entram contas
  `ATIVA` com saldo > 0.
- **Q4:** sim, o trigger vale também para a `sacar`, porque dispara em
  qualquer `INSERT` em `movimentacoes`, venha de onde vier.
- **Q5:** o trigger é automático: o `UPDATE` de saldo dentro da `sacar`
  dispara o `trg_contas_au` sozinho, e como o saldo mudou ele grava na
  auditoria.

## Observações (opcional)

- No `aplicar_rendimento` o `INSERT` dos créditos roda **antes** do `UPDATE`
  dos saldos, para o rendimento ser calculado sobre o saldo antigo; tudo fica
  dentro de uma transação, com `ROLLBACK` + `RESIGNAL` em caso de erro.
- Os prints foram gerados a partir da saída real do MySQL, renderizada como
  terminal.
