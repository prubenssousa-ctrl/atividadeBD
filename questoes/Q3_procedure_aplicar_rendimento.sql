-- =====================================================================
-- Atividade-04 · Questão 3 (2,0) – Procedure aplicar_rendimento (transação)
-- Aluno(s): ____________________________________________________________
-- =====================================================================
-- Crie a procedure
--   aplicar_rendimento(IN p_taxa DECIMAL(5,2), OUT p_qtd INT)
-- que paga o rendimento do mês (p_taxa %) para as contas 'ATIVA' com
-- saldo maior que zero.
--
--   * se p_taxa <= 0 -> SIGNAL 'Taxa inválida'
--   * para cada conta que recebe:
--       rendimento = ROUND(saldo * p_taxa / 100, 2)
--       - o saldo aumenta o valor do rendimento;
--       - registre em movimentacoes: (conta, 'credito', rendimento, 'Rendimento');
--   * p_qtd = quantas contas receberam rendimento;
--   * tudo numa TRANSAÇÃO: se der erro no meio, nenhuma conta recebe
--     (EXIT HANDLER FOR SQLEXCEPTION com ROLLBACK e RESIGNAL).
--
-- Dicas: pode usar um laço WHILE (de conta em conta) ou dois comandos
-- que tratam várias linhas: INSERT INTO ... SELECT ... e UPDATE.
-- Cuidado com a ORDEM: o rendimento é calculado sobre o saldo ANTIGO.
-- ROW_COUNT() devolve quantas linhas o último comando afetou.
-- =====================================================================
USE DBatividade4;

-- --------------------------- SUA RESPOSTA ----------------------------
DROP PROCEDURE IF EXISTS aplicar_rendimento;
DELIMITER $$
CREATE PROCEDURE aplicar_rendimento(IN p_taxa DECIMAL(5,2), OUT p_qtd INT)
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    RESIGNAL;
  END;

  IF p_taxa IS NULL OR p_taxa <= 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Taxa inválida';
  END IF;

  START TRANSACTION;

    -- 1º: registra o crédito, calculado sobre o saldo ANTIGO
    INSERT INTO movimentacoes (id_conta, tipo, valor, descricao)
    SELECT id_conta, 'credito', ROUND(saldo * p_taxa / 100, 2), 'Rendimento'
      FROM contas
     WHERE status = 'ATIVA' AND saldo > 0;

    SET p_qtd = ROW_COUNT();

    -- 2º: só depois atualiza os saldos
    UPDATE contas
       SET saldo = saldo + ROUND(saldo * p_taxa / 100, 2)
     WHERE status = 'ATIVA' AND saldo > 0;

  COMMIT;

END $$
DELIMITER ;

-- ------------------------------ TESTES -------------------------------
-- Antes, rode sql/02_voltar_dados_iniciais.sql. Depois:
--
-- CALL aplicar_rendimento(1.5, @q);  SELECT @q;       -- 3
-- SELECT id_conta, titular, saldo FROM contas;
--   -- Ana 1015.00 · Bruno 507.50 · Carla 203.00 · Diego 0.00 · Elisa 300.00
-- SELECT * FROM movimentacoes WHERE descricao = 'Rendimento';
--   -- 3 linhas: 15.00 (Ana) · 7.50 (Bruno) · 3.00 (Carla)
--
-- CALL aplicar_rendimento(0, @q);   -- ERROR 1644 (45000): Taxa inválida
--
-- Pergunta: por que Diego e Elisa não receberam nada?
-- Resposta: porque o rendimento só vale para contas 'ATIVA' com saldo > 0.
-- O Diego está ATIVA, mas tem saldo 0.00 (nada a render); a Elisa tem
-- saldo (300.00), mas a conta está BLOQUEADA. Os dois ficam fora do
-- WHERE status = 'ATIVA' AND saldo > 0.

-- ------------------------- RESULTADO OBTIDO --------------------------
-- Cole aqui (como comentário) o que o MySQL mostrou nos testes,
-- ou salve um print em evidencias/Q3.png
--
-- CALL aplicar_rendimento(1.5, @q);  SELECT @q;  -> 3
-- contas: Ana 1015.00 · Bruno 507.50 · Carla 203.00 · Diego 0.00 · Elisa 300.00
-- movimentacoes (descricao = 'Rendimento'):
--   id 7 | conta 1 | credito | 15.00
--   id 8 | conta 2 | credito |  7.50
--   id 9 | conta 3 | credito |  3.00
-- CALL aplicar_rendimento(0, @q);  -> ERROR 1644 (45000): Taxa inválida
