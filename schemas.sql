--- Schemas/Tabelas das Entidades do Projeto Integrador ---

SELECT * FROM cidadao;

CREATE TABLE cidadao (
	id SERIAL PRIMARY KEY NOT NULL,
	nome VARCHAR(100) NOT NULL,
	username VARCHAR(50) NOT NULL UNIQUE,
	email VARCHAR(100) NOT NULL UNIQUE,
	senha VARCHAR(50) NOT NULL,
	telefone VARCHAR(11) NOT NULL
);