--- Schemas/Tabelas das Entidades do Projeto Integrador ---

SELECT * FROM cidadao;
SELECT * FROM gestor;
SELECT * FROM categoria;
SELECT * FROM bairro;
SELECT * FROM relato;
SELECT * FROM historico_relato;
SELECT * FROM relato_foto;

SELECT * FROM vw_relato_completo;
SELECT * FROM vw_historico_relato_completo;
SELECT * FROM vw_relatorios_por_categoria;
SELECT * FROM vw_relatorios_por_status;
SELECT * FROM vw_relatorios_por_bairro;
SELECT * FROM vw_cidadaos;
SELECT * FROM vw_gestores;

CREATE TABLE cidadao (
	id SERIAL PRIMARY KEY NOT NULL,
	nome VARCHAR(100) NOT NULL,
	username VARCHAR(50) NOT NULL UNIQUE,
	email VARCHAR(100) NOT NULL UNIQUE,
	senha VARCHAR(50) NOT NULL,
	telefone VARCHAR(11) NOT NULL
);

CREATE TABLE gestor (
	id SERIAL PRIMARY KEY NOT NULL,
	nome VARCHAR(100) NOT NULL,
	username VARCHAR(50) NOT NULL UNIQUE,
	email VARCHAR(100) NOT NULL UNIQUE,
	senha VARCHAR(50) NOT NULL
);

CREATE TABLE categoria (
	id SERIAL PRIMARY KEY NOT NULL,
	nome VARCHAR(100) NOT NULL,
	descricao TEXT NOT NULL,
	ativo BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE bairro (
	id SERIAL PRIMARY KEY NOT NULL,
	nome VARCHAR(100) NOT NULL UNIQUE,
	ativo BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TYPE status_relato AS ENUM (
    'AGUARDANDO_ANALISE',
    'EM_ANALISE',
    'EM_ANDAMENTO',
    'RESOLVIDO'
);

CREATE TABLE relato (
	id SERIAL PRIMARY KEY NOT NULL,
	foto_url VARCHAR(255) NOT NULL,
	endereco VARCHAR(100) NOT NULL,
	titulo VARCHAR(100) NOT NULL,
	descricao TEXT NOT NULL,
	status status_relato NOT NULL DEFAULT 'AGUARDANDO_ANALISE',
	criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	atualizado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	
	cidadao_id INT NOT NULL,
	bairro_id INT NOT NULL,
	categoria_id INT NOT NULL,

    CONSTRAINT fk_relato_cidadao
        FOREIGN KEY (cidadao_id)
        REFERENCES cidadao(id),

    CONSTRAINT fk_relato_bairro
        FOREIGN KEY (bairro_id)
        REFERENCES bairro(id),

    CONSTRAINT fk_relato_categoria
        FOREIGN KEY (categoria_id)
        REFERENCES categoria(id)
);

CREATE TABLE historico_relato(
	id SERIAL PRIMARY KEY NOT NULL,
	status_anterior status_relato NOT NULL,
	status_novo status_relato NOT NULL,
	comentario TEXT,
	alterado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

	relato_id INT NOT NULL,
	gestor_id INT NOT NULL,

    CONSTRAINT fk_historico_relato
        FOREIGN KEY (relato_id)
        REFERENCES relato(id)
		ON DELETE CASCADE,

    CONSTRAINT fk_historico_gestor
        FOREIGN KEY (gestor_id)
        REFERENCES gestor(id)
);

CREATE TABLE relato_foto(
	id SERIAL PRIMARY KEY NOT NULL,
	imagem_url VARCHAR(255) NOT NULL,
	public_id VARCHAR(255),
	ordem SMALLINT NOT NULL DEFAULT 1,
	criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

	relato_id INT NOT NULL,

	CONSTRAINT fk_relato_foto
		FOREIGN KEY(relato_id)
		REFERENCES relato(id)
		ON DELETE CASCADE
);

----- INSERT PARA TESTES E APRESENTAÇÃO -----
-- Cidadãos
INSERT INTO cidadao (nome, username, email, senha, telefone) VALUES
('Jadson Teixeira', 'jadson', 'jadson@email.com', 'senha123', '84999990001'),
('Davi Silva', 'davi', 'davi@email.com', 'senha123', '84999990002');

-- Gestor
INSERT INTO gestor (nome, username, email, senha) VALUES
('Luana Gomes', 'luana', 'luana@email.com', 'senha123');

-- Categorias
INSERT INTO categoria (nome, descricao) VALUES
('Buracos', 'Problemas relacionados a buracos nas ruas e vias públicas'),
('Energia', 'Problemas relacionados à falta de energia elétrica'),
('Água', 'Problemas relacionados a vazamentos ou falta de água');

-- Bairros
INSERT INTO bairro (nome) VALUES
('Centro'),
('Santa Luzia'),
('Frei Damião');

-- Relatos
INSERT INTO relato (foto_url, endereco, titulo, descricao, cidadao_id, bairro_id, categoria_id) VALUES
(
    'https://exemplo.com/fotos/buraco1.jpg',
    'Rua Principal, próximo à padaria',
    'Buraco grande na rua',
    'Buraco enorme causando risco a pedestres e veículos.',
    (SELECT id FROM cidadao WHERE username = 'jadson'),
    (SELECT id FROM bairro WHERE nome = 'Centro'),
    (SELECT id FROM categoria WHERE nome = 'Buracos')
),
(
    'https://exemplo.com/fotos/energia1.jpg',
    'Rua das Flores, em frente ao mercado',
    'Falta de energia há 3 dias',
    'Bairro inteiro sem energia elétrica desde segunda-feira.',
    (SELECT id FROM cidadao WHERE username = 'davi'),
    (SELECT id FROM bairro WHERE nome = 'Santa Luzia'),
    (SELECT id FROM categoria WHERE nome = 'Energia')
);

-- Fotos dos relatos
INSERT INTO relato_foto (imagem_url, public_id, ordem, relato_id) VALUES
(
    'https://exemplo.com/fotos/buraco1.jpg',
    'buraco1_public_id',
    1,
    (SELECT id FROM relato WHERE titulo = 'Buraco grande na rua')
),
(
    'https://exemplo.com/fotos/buraco1_detalhe.jpg',
    'buraco1_detalhe_public_id',
    2,
    (SELECT id FROM relato WHERE titulo = 'Buraco grande na rua')
),
(
    'https://exemplo.com/fotos/energia1.jpg',
    'energia1_public_id',
    1,
    (SELECT id FROM relato WHERE titulo = 'Falta de energia há 3 dias')
);

-- ================================================== -- VIEWS-- ==================================================

-- ========================================== -- VIEW: RELATO COMPLETO -- ==========================================
CREATE OR REPLACE VIEW vw_relato_completo AS 
	SELECT 

	cidadao.username AS username_cidadao,

	categoria.nome as nome_categoria,

	relato.status,
	relato.id AS relato_id,
	relato.foto_url as foto_relato,
	relato.titulo, 
	relato.descricao,
	relato.endereco,
	
	bairro.nome AS nome_bairro,
	
	relato.criado_em,
	relato.atualizado_em
	
	FROM relato 
	JOIN cidadao ON relato.cidadao_id = cidadao.id 
	JOIN bairro ON relato.bairro_id = bairro.id 
	JOIN categoria ON relato.categoria_id = categoria.id;


-- ========================================== -- VIEW: HISTÓRICO COMPLETO DO RELATO -- ==========================================

CREATE OR REPLACE VIEW vw_historico_relato_completo AS
SELECT

	historico_relato.id AS historico_id, 
	historico_relato.status_anterior, 
	historico_relato.status_novo, 
	
	gestor.nome AS nome_gestor, 
	gestor.username AS username_gestor,
	
	historico_relato.comentario, 

	relato.id AS relato_id, 
	relato.titulo AS titulo_relato,

	historico_relato.alterado_em

	FROM historico_relato 
	JOIN relato ON historico_relato.relato_id = relato.id 
	JOIN gestor ON historico_relato.gestor_id = gestor.id;


-- ========================================== -- VIEW: QUANTIDADE DE RELATOS POR STATUS -- ========================================== 
CREATE OR REPLACE VIEW vw_relatorios_por_status AS 
	SELECT relato.status, COUNT(relato.id) AS quantidade_relato 
	FROM relato GROUP BY relato.status;

-- ========================================== -- VIEW: QUANTIDADE DE RELATOS POR CATEGORIA -- ========================================== 
CREATE OR REPLACE VIEW vw_relatorios_por_categoria AS 
	SELECT categoria.id AS categoria_id, categoria.nome AS nome_categoria, COUNT(relato.id) AS quantidade_relato 
	FROM categoria LEFT JOIN relato 
	ON relato.categoria_id = categoria.id GROUP BY categoria.id, categoria.nome;

-- ========================================== -- VIEW: QUANTIDADE DE RELATOS POR BAIRROS -- ========================================== 
CREATE OR REPLACE VIEW vw_relatorios_por_bairro AS
SELECT 
	bairro.nome AS nome_bairro, 
	COUNT(relato.id) AS quantidade_relato 
	FROM bairro LEFT JOIN relato 
	ON relato.bairro_id = bairro.id 
	GROUP BY bairro.id, bairro.nome;
-- ========================================== -- VIEW: QUANTIDADE DE CIDADAOS -- ========================================== 

CREATE OR REPLACE VIEW vw_cidadaos AS
SELECT
    cidadao.nome,
    cidadao.username,
    cidadao.email,
    cidadao.telefone
FROM cidadao;

-- ========================================== -- VIEW: QUANTIDADE DE GESTORES -- ========================================== 

CREATE OR REPLACE VIEW vw_gestores AS
SELECT
    gestor.nome,
    gestor.username,
    gestor.email
FROM gestor;