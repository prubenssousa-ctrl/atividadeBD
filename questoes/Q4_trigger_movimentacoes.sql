-- =====================================================================
-- Atividade-04 · Questão 4 (2,0) – Trigger trg_mov_bi (BEFORE INSERT)
-- Aluno(s): ____________________________________________________________
-- =====================================================================
-- Crie o trigger trg_mov_bi, que dispara ANTES de cada INSERT em
-- movimentacoes e arruma/valida a linha que vai entrar (NEW):
--
--   1. tipo em minúsculo e sem espaços nas pontas: LOWER(TRIM(NEW.tipo));
--   2. o tipo só pode ser 'credito' ou 'debito'  -> senão SIGNAL 'Tipo inválido';
--   3. o valor precisa ser maior que zero         -> senão SIGNAL 'Valor inválido';
--   4. se a descrição vier vazia ou NULL, grave 'Sem descrição'.
--
-- Lembre: no BEFORE INSERT dá para mudar a linha com SET NEW.coluna = ...
-- =====================================================================
USE DBatividade4;

-- --------------------------- SUA RESPOSTA ----------------------------
DROP TRIGGER IF EXISTS trg_mov_bi;
DELIMITER $$
CREATE TRIGGER trg_mov_bi
BEFORE INSERT ON movimentacoes
FOR EACH ROW
BEGIN

  SET NEW.tipo = LOWER(TRIM(NEW.tipo));

  IF NEW.tipo NOT IN ('credito', 'debito') THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Tipo inválido';
  END IF;

  IF NEW.valor IS NULL OR NEW.valor <= 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Valor inválido';
  END IF;

  IF NEW.descricao IS NULL OR TRIM(NEW.descricao) = '' THEN
    SET NEW.descricao = 'Sem descrição';
  END IF;

END $$
DELIMITER ;

-- ------------------------------ TESTES -------------------------------
-- Antes, rode sql/02_voltar_dados_iniciais.sql. Depois, um por vez:
--
-- INSERT INTO movimentacoes (id_conta, tipo, valor, descricao) VALUES (1, ' CREDITO ', 50, 'Bônus');
--   -- gravou com tipo 'credito'
-- INSERT INTO movimentacoes (id_conta, tipo, valor, descricao) VALUES (1, 'debito', 20, '');
--   -- gravou com descricao 'Sem descrição'
-- INSERT INTO movimentacoes (id_conta, tipo, valor, descricao) VALUES (1, 'pix', 10, 'Teste');
--   -- ERROR 1644 (45000): Tipo inválido
-- INSERT INTO movimentacoes (id_conta, tipo, valor, descricao) VALUES (1, 'debito', 0, 'Teste');
--   -- ERROR 1644 (45000): Valor inválido
-- SELECT * FROM movimentacoes WHERE id_mov > 6;   -- só as 2 primeiras entraram
--
-- Pergunta: este trigger também vale quando a procedure sacar (Q1)
-- grava uma movimentação? Por quê?
-- Resposta: Sim. O trigger dispara em qualquer INSERT na tabela
-- movimentacoes, venha de onde vier (INSERT manual, procedure, aplicação).
-- Quando a sacar faz o INSERT do 'debito', o BEFORE INSERT roda do mesmo jeito
-- (testado: CALL sacar(1, 10) gravou debito 10.00 'Saque' passando pelo trigger).

-- ------------------------- RESULTADO OBTIDO --------------------------
-- Cole aqui (como comentário) o que o MySQL mostrou nos testes,
-- ou salve um print em evidencias/Q4.png
--
-- INSERT tipo ' CREDITO '  -> gravou: id 7 | conta 1 | credito | 50.00 | Bônus
-- INSERT descricao ''      -> gravou: id 8 | conta 1 | debito  | 20.00 | Sem descrição
-- INSERT tipo 'pix'        -> ERROR 1644 (45000): Tipo inválido
-- INSERT valor 0           -> ERROR 1644 (45000): Valor inválido
-- SELECT * FROM movimentacoes WHERE id_mov > 6;  -> só as ids 7 e 8
