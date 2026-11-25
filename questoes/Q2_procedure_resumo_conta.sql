-- =====================================================================
-- Atividade-04 · Questão 2 (2,0) – Procedure resumo_conta (parâmetros OUT)
-- Aluno(s): ____________________________________________________________
-- =====================================================================
-- Crie a procedure
--   resumo_conta(IN  p_conta    INT,
--                OUT p_creditos DECIMAL(10,2),
--                OUT p_debitos  DECIMAL(10,2),
--                OUT p_qtd      INT)
-- que devolve, para a conta p_conta:
--   * p_creditos: a soma dos valores das movimentações do tipo 'credito';
--   * p_debitos:  a soma dos valores das movimentações do tipo 'debito';
--   * p_qtd:      quantas movimentações a conta tem.
-- Conta sem movimentação deve devolver 0 (e não NULL) nas duas somas.
--
-- Dicas: SELECT SUM(valor) INTO p_creditos FROM ... WHERE ...;
--        IFNULL(SUM(valor), 0) troca NULL por 0.
--        Para ler os parâmetros OUT, use variáveis de sessão (@):
--        CALL resumo_conta(2, @c, @d, @q);  SELECT @c, @d, @q;
-- =====================================================================
USE DBatividade4;

-- --------------------------- SUA RESPOSTA ----------------------------
DROP PROCEDURE IF EXISTS resumo_conta;
DELIMITER $$
CREATE PROCEDURE resumo_conta(IN  p_conta    INT,
                              OUT p_creditos DECIMAL(10,2),
                              OUT p_debitos  DECIMAL(10,2),
                              OUT p_qtd      INT)
BEGIN

  SELECT IFNULL(SUM(CASE WHEN tipo = 'credito' THEN valor END), 0),
         IFNULL(SUM(CASE WHEN tipo = 'debito'  THEN valor END), 0),
         COUNT(*)
    INTO p_creditos, p_debitos, p_qtd
    FROM movimentacoes
   WHERE id_conta = p_conta;

END $$
DELIMITER ;

-- ------------------------------ TESTES -------------------------------
-- Antes, rode sql/02_voltar_dados_iniciais.sql. Depois:
--
-- CALL resumo_conta(2, @c, @d, @q);  SELECT @c, @d, @q;   -- 600.00 | 100.00 | 2
-- CALL resumo_conta(1, @c, @d, @q);  SELECT @c, @d, @q;   -- 1000.00 | 0.00 | 1
-- CALL resumo_conta(4, @c, @d, @q);  SELECT @c, @d, @q;   -- 0.00 | 0.00 | 0
--
-- Pergunta: para o Bruno, quanto dá @c - @d? Bate com o saldo dele?
-- Resposta: @c - @d = 600.00 - 100.00 = 500.00, que é exatamente o saldo do
-- Bruno. Bate porque o saldo é o acumulado de todos os créditos menos todos
-- os débitos da conta (saldo = créditos - débitos).

-- ------------------------- RESULTADO OBTIDO --------------------------
-- Cole aqui (como comentário) o que o MySQL mostrou nos testes,
-- ou salve um print em evidencias/Q2.png
--
-- CALL resumo_conta(2, @c, @d, @q);  -> 600.00 | 100.00 | 2
-- CALL resumo_conta(1, @c, @d, @q);  -> 1000.00 | 0.00 | 1
-- CALL resumo_conta(4, @c, @d, @q);  -> 0.00 | 0.00 | 0
