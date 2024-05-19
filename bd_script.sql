DROP DATABASE IF EXISTS cwdb;

CREATE DATABASE cwdb;

USE cwdb;

CREATE TABLE endereco (
    id_endereco INT PRIMARY KEY AUTO_INCREMENT,
    logradouro VARCHAR(45),
    cep CHAR(8),
    numero VARCHAR(5),
    complemento VARCHAR(45),
    cidade VARCHAR(45) NOT NULL,
    uf CHAR(2)
);
 
CREATE TABLE empresa (
    id_empresa INT PRIMARY KEY AUTO_INCREMENT,
    nome_fantasia VARCHAR(45) NOT NULL,
    razao_social VARCHAR(45) NOT NULL,
    cnpj CHAR(14) NOT NULL,
    telefone VARCHAR(11),
    fk_matriz INT,
    CONSTRAINT fk_matriz_empresa FOREIGN KEY (fk_matriz) REFERENCES empresa(id_empresa),
    fk_endereco INT,
    CONSTRAINT fk_endereco_empresa FOREIGN KEY (fk_endereco) REFERENCES endereco(id_endereco)
) AUTO_INCREMENT = 1000;

CREATE TABLE config (
    id_config INT PRIMARY KEY,
    max_cpu DECIMAL(4, 1),
    max_ram DECIMAL(4, 1),
    max_volume DECIMAL(4, 1),
    sensibilidade_mouse INT,
    timer_mouse_ms INT,
    intervalo_registro_ms INT,
    intervalo_volume_ms INT,
    intervalo_quest_dias INT,
    CONSTRAINT fk_empresa_config FOREIGN KEY (id_config) REFERENCES empresa(id_empresa)
);

CREATE TABLE perm_processo (
    id_perm_processo INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(45) NOT NULL,
    permitido TINYINT DEFAULT 0,
    fk_config INT,
    CONSTRAINT fk_config_perm FOREIGN KEY (fk_config) REFERENCES config(id_config)
);

CREATE TABLE funcionario (
    id_funcionario INT PRIMARY KEY AUTO_INCREMENT,
    primeiro_nome VARCHAR(80),
    sobrenome VARCHAR(80) NOT NULL,
    celular CHAR(11),
    telefone VARCHAR(11),
    email VARCHAR(80) NOT NULL,
    dt_nasc DATE,
    cpf CHAR(14) NOT NULL,
    cargo VARCHAR(45),
    fk_gerente INT,
    fk_empresa INT,
    CONSTRAINT fk_gerente_funcionario FOREIGN KEY (fk_gerente) REFERENCES funcionario(id_funcionario),
    CONSTRAINT fk_empresa_funcionario FOREIGN KEY (fk_empresa) REFERENCES empresa(id_empresa)
);

CREATE TABLE questionario (
    id_apontamento INT PRIMARY KEY AUTO_INCREMENT,
    nota INT,
    detalhe VARCHAR(2000),
    dt_criacao DATE DEFAULT (CURRENT_DATE),
    respondido_em DATETIME,
    fk_funcionario INT NOT NULL,
    CONSTRAINT fk_apontamento_funcionario FOREIGN KEY (fk_funcionario) REFERENCES funcionario(id_funcionario)
);

CREATE TABLE tarefa (
    id_tarefa INT PRIMARY KEY AUTO_INCREMENT,
    descricao VARCHAR(255),
    dt_inicio DATE DEFAULT (CURRENT_DATE),
    dt_fim DATE,
    prioridade VARCHAR(45),
    concluida TINYINT DEFAULT 0,
    dt_hora_concluida DATETIME,
    fk_funcionario INT NOT NULL,
    fk_gerente INT NOT NULL,
    CONSTRAINT fk_funcionario_tarefa FOREIGN KEY (fk_funcionario) REFERENCES funcionario(id_funcionario),
    CONSTRAINT fk_gerente_tarefa FOREIGN KEY (fk_gerente) REFERENCES funcionario(id_funcionario)
);  

CREATE TABLE usuario (
    id_usuario INT PRIMARY KEY,
    username VARCHAR(80),
    senha VARCHAR(80) CHECK (LENGTH(senha) >= 8),
    dt_criado DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_funcionario_usuario FOREIGN KEY (id_usuario) REFERENCES funcionario(id_funcionario)
);

CREATE TABLE tempo_ociosidade (
    id_tempo_ociosidade INT PRIMARY KEY AUTO_INCREMENT,
    dt_hora_registro DATETIME DEFAULT CURRENT_TIMESTAMP,
    tempo_registro_ms INT,
    fk_usuario INT,
    CONSTRAINT fk_usuario_tempo_ociosidade FOREIGN KEY (fk_usuario) REFERENCES usuario(id_usuario)
);

CREATE TABLE artigo (
    id_artigo INT PRIMARY KEY AUTO_INCREMENT,
    titulo VARCHAR(45),
    descricao VARCHAR(2000),
    categoria VARCHAR(45),
    criado_em DATETIME DEFAULT CURRENT_TIMESTAMP,
    palavra_chave VARCHAR(45),
    fk_funcionario INT,
    CONSTRAINT fk_funcionario_artigo FOREIGN KEY (fk_funcionario) REFERENCES funcionario(id_funcionario)
);

CREATE TABLE tag (
    id_tag INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(45)
);

CREATE TABLE artigo_has_tag (
    fk_tag INT,
    fk_artigo INT,
    CONSTRAINT fk_tag_at FOREIGN KEY (fk_tag) REFERENCES tag(id_tag),
    CONSTRAINT fk_artigo_at FOREIGN KEY (fk_artigo) REFERENCES artigo(id_artigo),
    PRIMARY KEY (fk_tag, fk_artigo)
);

CREATE TABLE maquina (
    id_maquina INT PRIMARY KEY AUTO_INCREMENT,
    hostname VARCHAR(80),
    so VARCHAR(80),
    cpu_modelo VARCHAR(80),
    ram_total BIGINT,
    modificado_em DATETIME DEFAULT CURRENT_TIMESTAMP,  
    fk_empresa INT,
    CONSTRAINT fk_empresa_maquina FOREIGN KEY (fk_empresa) REFERENCES empresa(id_empresa)
);

CREATE TABLE volume (
    uuid CHAR(36) PRIMARY KEY,
    fk_maquina INT,
    nome VARCHAR(45),
    ponto_montagem VARCHAR(45),
    volume_total BIGINT,
    CONSTRAINT fk_maquina_volume FOREIGN KEY (fk_maquina) REFERENCES maquina(id_maquina)
);

CREATE TABLE sessao (
    id_sessao INT PRIMARY KEY AUTO_INCREMENT,
    fk_maquina INT,
    fk_usuario INT,
    dt_hora_sessao DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_maquina_sessao FOREIGN KEY (fk_maquina) REFERENCES maquina(id_maquina),
    CONSTRAINT fk_usuario_sessao FOREIGN KEY (fk_usuario) REFERENCES usuario(id_usuario)
);

CREATE TABLE ocorrencia (
    id_ocorrencia INT PRIMARY KEY AUTO_INCREMENT,
    titulo VARCHAR(45),
    descricao VARCHAR(255),
    tipo VARCHAR(45),
    resolvido TINYINT DEFAULT 0,
    criado_em DATETIME DEFAULT CURRENT_TIMESTAMP,
    resolvido_em DATETIME,
    fk_sessao INT,
    fk_atribuido INT,
    CONSTRAINT fk_sessao_ocorrencia FOREIGN KEY (fk_sessao) REFERENCES sessao(id_sessao),
    CONSTRAINT fk_atribuido_ocorrencia FOREIGN KEY (fk_atribuido) REFERENCES funcionario(id_funcionario)
);

CREATE TABLE registro (
    id_registro INT PRIMARY KEY AUTO_INCREMENT,
    dt_hora DATETIME DEFAULT CURRENT_TIMESTAMP,
    uso_cpu DECIMAL(4, 1),
    uso_ram BIGINT,
    disponivel_ram BIGINT,
    fk_sessao INT,
    CONSTRAINT fk_sessao_registro FOREIGN KEY (fk_sessao) REFERENCES sessao(id_sessao)
);

CREATE TABLE registro_volume (
    id_registro_volume INT PRIMARY KEY AUTO_INCREMENT,
    volume_disponivel BIGINT,
    dt_hora DATETIME DEFAULT CURRENT_TIMESTAMP,
    fk_sessao INT,
    fk_volume CHAR(36),
    CONSTRAINT fk_registro_sessao FOREIGN KEY (fk_sessao) REFERENCES sessao(id_sessao),
    CONSTRAINT fk_registro_volume FOREIGN KEY (fk_volume) REFERENCES volume(uuid)
);

CREATE TABLE processo (
    id_processo INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(45),
    caminho VARCHAR(255),
    uso_ram BIGINT,
    fk_registro INT,
    CONSTRAINT fk_registro_processo FOREIGN KEY (fk_registro) REFERENCES registro(id_registro)
);

CREATE TABLE alerta (
    id_alerta INT PRIMARY KEY AUTO_INCREMENT,
    tipo VARCHAR(45),
    descricao VARCHAR(45),
    fk_registro INT,
    fk_reg_volume INT,
    CONSTRAINT fk_registro_alerta FOREIGN KEY (fk_registro) REFERENCES registro(id_registro),
    CONSTRAINT fk_reg_vol_alerta FOREIGN KEY (fk_reg_volume) REFERENCES registro_volume(id_registro_volume)
);

-- ENDEREÇOS
INSERT INTO endereco (logradouro, cep, numero, complemento, cidade, uf)
VALUES ('Rua das Flores', '12345678', '101', 'Bloco A', 'São Paulo', 'SP');
    
INSERT INTO endereco (logradouro, cep, numero, complemento, cidade, uf)
VALUES ('Avenida Copacabana', '87654321', '202', 'Sala 10', 'Rio de Janeiro', 'RJ');
    
-- EMPRESAS
INSERT INTO empresa (nome_fantasia, razao_social, cnpj, fk_endereco)
VALUES ('Tech Solutions', 'Tech Solutions Ltda.', '12345678000100', 1);
    
INSERT INTO empresa (nome_fantasia, razao_social, cnpj, fk_endereco)
VALUES ('Global Tech', 'Global Tech S.A.', '98765432000199', 2);

INSERT INTO empresa (nome_fantasia, razao_social, cnpj, fk_matriz, fk_endereco)
VALUES ('Filial Centro', 'Centro Filial Ltda.', '11223344000188', 1000, 1);

-- PARÂMETROS DE CONFIGURAÇÃO
INSERT INTO config (id_config, max_cpu, max_ram, max_volume, sensibilidade_mouse, timer_mouse_ms, intervalo_registro_ms, intervalo_volume_ms, intervalo_quest_dias)
VALUES (1001, 85.0, 80.0, 95.0, 25, 15000, 3000, 40000, 10);

INSERT INTO config (id_config, max_cpu, max_ram, max_volume, sensibilidade_mouse, timer_mouse_ms, intervalo_registro_ms, intervalo_volume_ms, intervalo_quest_dias)
VALUES (1000, 80.0, 70.0, 90.0, 20, 10000, 2000, 30000, 15);

INSERT INTO config (id_config, max_cpu, max_ram, max_volume, sensibilidade_mouse, timer_mouse_ms, intervalo_registro_ms, intervalo_volume_ms, intervalo_quest_dias)
VALUES (1002, 75.0, 65.0, 85.0, 25, 25000, 2000, 35000, 10);

-- FUNCIONÁRIOS
-- Empresa 1
INSERT INTO funcionario (primeiro_nome, sobrenome, celular, telefone, email, dt_nasc, cpf, cargo, fk_empresa)
VALUES ('Alice', 'Silva', '11987654321', '1123456789', 'alice@techsolutions.com', '1980-05-15', '123.456.789-10', 'Diretor', 1000);
    
INSERT INTO funcionario (primeiro_nome, sobrenome, celular, telefone, email, dt_nasc, cpf, cargo, fk_empresa, fk_gerente)
VALUES ('Carlos', 'Santos', '11976543210', '1122334455', 'carlos@techsolutions.com', '1985-10-20', '987.654.321-01', 'Gerente', 1000, 1);
    
INSERT INTO funcionario (primeiro_nome, sobrenome, celular, telefone, email, dt_nasc, cpf, cargo, fk_empresa, fk_gerente)
VALUES ('Lucas', 'Oliveira', '11965432109', '1199887766', 'lucas@techsolutions.com', '1990-07-12', '456.789.123-02', 'Operador', 1000, 2);
    
-- Empresa 2
INSERT INTO funcionario (primeiro_nome, sobrenome, celular, telefone, email, dt_nasc, cpf, cargo, fk_empresa)
VALUES ('Ana', 'Rodrigues', '21876543210', '2133445566', 'ana@globaltech.com', '1975-03-25', '789.456.123-45', 'Diretor', 1001);
    
INSERT INTO funcionario (primeiro_nome, sobrenome, celular, telefone, email, dt_nasc, cpf, cargo, fk_empresa, fk_gerente)
VALUES ('Pedro', 'Ferreira', '21887654321', '2133556677', 'pedro@globaltech.com', '1992-12-08', '654.321.987-78', 'Suporte', 1001, 4);
    
-- Empresa 3
INSERT INTO funcionario (primeiro_nome, sobrenome, celular, telefone, email, dt_nasc, cpf, cargo, fk_empresa)
VALUES ('Mariana', 'Souza', '11998765432', '1122667788', 'mariana@filialcentro.com', '1993-08-20', '987.654.321-98', 'Suporte', 1002);
    
INSERT INTO funcionario (primeiro_nome, sobrenome, celular, telefone, email, dt_nasc, cpf, cargo, fk_empresa, fk_gerente)
VALUES ('Rafael', 'Lima', '11987654321', '1122334455', 'rafael@filialcentro.com', '1995-04-18', '123.456.789-45', 'Operador', 1002, 6);

-- USUÁRIOS
-- Empresa 1
INSERT INTO usuario (id_usuario, username, senha)
VALUES (1, 'alice@techsolutions.com', 'alice123');
    
INSERT INTO usuario (id_usuario, username, senha)
VALUES (2, 'carlos@techsolutions.com', 'carlos456');
    
INSERT INTO usuario (id_usuario, username, senha)
VALUES (3, 'lucas@techsolutions.com', 'lucas789');

-- Empresa 2
INSERT INTO usuario (id_usuario, username, senha)
VALUES (4, 'ana@globaltech.com', 'ana12987');
    
INSERT INTO usuario (id_usuario, username, senha)
VALUES (5, 'pedro@globaltech.com', 'pedro654');

-- Empresa 3
INSERT INTO usuario (id_usuario, username, senha)
VALUES (6, 'mariana@filialcentro.com', 'mariana321');
    
INSERT INTO usuario (id_usuario, username, senha)
VALUES (7, 'rafael@filialcentro.com', 'rafael123');