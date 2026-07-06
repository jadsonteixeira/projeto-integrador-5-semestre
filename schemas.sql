--- Schemas/Tabelas das Entidades do Projeto Integrador ---

SELECT * FROM cidadao;
SELECT * FROM gestor;
SELECT * FROM categoria;
SELECT * FROM bairro;

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