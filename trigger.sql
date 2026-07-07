----- GATILHOS -----

SELECT * FROM historico_relato;

----- 1. GATILHO PARA REGISTRAR O HISTÓRICO DE ALTERAÇÃO DE STATUS DO RELATO
CREATE OR REPLACE FUNCTION fun_registrar_historico_status()
RETURNS TRIGGER AS
$$
BEGIN
	IF NEW.status <> OLD.status THEN
		INSERT INTO historico_relato (status_anterior, status_novo, comentario, relato_id, gestor_id)
		VALUES (OLD.status, NEW.status, 'Estamos analisando o seu relato', NEW.id, 1);
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tgr_historico_status
AFTER UPDATE ON relato
FOR EACH ROW
EXECUTE FUNCTION fun_registrar_historico_status();

UPDATE relato
SET status = 'EM_ANALISE'
WHERE id = 1;

----- 2. GATILHO PARA REGISTAR A MUDANÇA DO ATRIBUTO alterado_em NO RELATO SEMPRE QUE OCORRER UMA ATUALIZAÇÃO NO STATUS
CREATE OR REPLACE FUNCTION fun_atualiza_data_relato()
RETURNS TRIGGER AS
$$
BEGIN
	NEW.atualizado_em := CURRENT_TIMESTAMP;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tgr_atualiza_data_relato
BEFORE UPDATE ON relato
FOR EACH ROW
EXECUTE FUNCTION fun_atualiza_data_relato();

----- 3. GATILHO PARA BLOQUEAR CRIAÇÃO DE RELATOS COM CATEGORIAS QUE ESTEJAM DESATIVADAS -----
CREATE OR REPLACE FUNCTION fun_verifica_categoria_ativa()
RETURNS TRIGGER AS
$$
DECLARE
	categoria_ativa BOOLEAN;
BEGIN
	SELECT ativo INTO categoria_ativa
	FROM categoria
	WHERE id = NEW.categoria_id;

	IF categoria_ativa = FALSE THEN
		RAISE EXCEPTION 'Não é possível criar relato com uma categoria desativada';
	END IF;

	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tgr_verifica_categoria_ativa
BEFORE INSERT ON relato
FOR EACH ROW
EXECUTE FUNCTION fun_verifica_categoria_ativa();

-- Desativa a categoria "Buracos"
UPDATE categoria SET ativo = FALSE WHERE nome = 'Buracos';

-- Tenta criar um relato novo com essa categoria (deve falhar)
INSERT INTO relato (foto_url, endereco, titulo, descricao, cidadao_id, bairro_id, categoria_id)
VALUES (
	'https://exemplo.com/fotos/teste.jpg',
	'Rua Teste, 123',
	'Teste categoria desativada',
	'Relato de teste para validar o gatilho',
	(SELECT id FROM cidadao WHERE username = 'jadson'),
	(SELECT id FROM bairro WHERE nome = 'Centro'),
	(SELECT id FROM categoria WHERE nome = 'Buracos')
);

----- 4. GATILHO PARA BLOQUEAR CRIAÇÃO DE RELATOS COM BAIRROS QUE ESTEJAM DESATIVADAS -----
CREATE OR REPLACE FUNCTION fun_verifica_bairro_ativo()
RETURNS TRIGGER AS
$$
DECLARE
	bairro_ativo BOOLEAN;
BEGIN
	SELECT ativo INTO bairro_ativo
	FROM bairro
	WHERE id = NEW.bairro_id;

	IF bairro_ativo = FALSE THEN
		RAISE EXCEPTION 'Não é possível criar relato com um bairro desativado';
	END IF;

	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tgr_verifica_bairro_ativo
BEFORE INSERT ON relato
FOR EACH ROW
EXECUTE FUNCTION fun_verifica_bairro_ativo();

-- Desativa o bairro "Centro"
UPDATE bairro SET ativo = TRUE WHERE nome = 'Centro';

-- Tenta criar um relato novo com esse bairro (deve falhar)
INSERT INTO relato (foto_url, endereco, titulo, descricao, cidadao_id, bairro_id, categoria_id)
VALUES (
	'https://exemplo.com/fotos/teste2.jpg',
	'Rua Teste, 456',
	'Teste bairro desativado',
	'Relato de teste para validar o gatilho',
	(SELECT id FROM cidadao WHERE username = 'davi'),
	(SELECT id FROM bairro WHERE nome = 'Centro'),
	(SELECT id FROM categoria WHERE nome = 'Água')
);