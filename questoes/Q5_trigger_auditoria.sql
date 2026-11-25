-- =====================================================================
-- Atividade-04 · Questão 5 (2,0) – Trigger trg_contas_au (AFTER UPDATE)
-- Aluno(s): ____________________________________________________________
-- =====================================================================
-- O banco precisa guardar o histórico de todas as mudanças de saldo.
-- Crie o trigger trg_contas_au, que dispara DEPOIS de cada UPDATE em
-- contas e, SÓ QUANDO O SALDO MUDOU (OLD.saldo <> NEW.saldo), grava
-- uma linha na tabela auditoria com:
--   id_conta, saldo_antigo (OLD.saldo), saldo_novo (NEW.saldo),
--   usuario (CURRENT_USER()) e data_hora (NOW()).
-- Se o UPDATE mudou só o titular ou o status, não grava nada.
-- =====================================================================
USE DBatividade4;

-- --------------------------- SUA RESPOSTA ----------------------------
DROP TRIGGER IF EXISTS trg_contas_au;
DELIMITER $$
CREATE TRIGGER trg_contas_au
AFTER UPDATE ON contas
FOR EACH ROW
BEGIN

  IF OLD.saldo <> NEW.saldo THEN
    INSERT INTO auditoria (id_conta, saldo_antigo, saldo_novo, usuario, data_hora)
    VALUES (OLD.id_conta, OLD.saldo, NEW.saldo, CURRENT_USER(), NOW());
  END IF;

END $$
DELIMITER ;

-- ------------------------------ TESTES -------------------------------
-- Antes, rode sql/02_voltar_dados_iniciais.sql. Depois, em sequência:
--
-- UPDATE contas SET saldo = saldo + 100 WHERE id_conta = 4;
-- SELECT * FROM auditoria;          -- 1 linha: conta 4, 0.00 -> 100.00
--
-- UPDATE contas SET titular = 'Diego S.' WHERE id_conta = 4;
-- SELECT * FROM auditoria;          -- continua 1 linha
--
-- CALL sacar(2, 50);                -- precisa da Questão 1
-- SELECT * FROM auditoria;          -- 2 linhas: a nova é conta 2, 500.00 -> 450.00
--
-- Pergunta: ninguém chamou o trigger no CALL sacar. Como a linha
-- apareceu na auditoria?
-- Resposta: porque o trigger é automático: ele está ligado à tabela contas e
-- o MySQL o executa sozinho depois de qualquer UPDATE nela, inclusive o
-- UPDATE contas SET saldo = saldo - p_valor que está dentro da procedure
-- sacar. Como o saldo mudou (500.00 -> 450.00), o IF OLD.saldo <> NEW.saldo
-- foi verdadeiro e a linha foi gravada na auditoria.

-- ------------------------- RESULTADO OBTIDO --------------------------
-- Cole aqui (como comentário) o que o MySQL mostrou nos testes,
-- ou salve um print em evidencias/Q5.png
--
-- UPDATE contas SET saldo = saldo + 100 WHERE id_conta = 4;
--   auditoria: 1 | conta 4 | 0.00 -> 100.00 | root@localhost
-- UPDATE contas SET titular = 'Diego S.' WHERE id_conta = 4;
--   auditoria: continua 1 linha
-- CALL sacar(2, 50);
--   auditoria: 2 linhas; a nova é 2 | conta 2 | 500.00 -> 450.00 | root@localhost
