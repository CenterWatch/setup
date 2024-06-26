CREATE TABLE endereco (
    id_endereco INT IDENTITY(1,1) PRIMARY KEY,
    logradouro NVARCHAR(45),
    cep CHAR(8),
    numero NVARCHAR(5),
    bairro NVARCHAR(45),
    complemento NVARCHAR(45),
    cidade NVARCHAR(45) NOT NULL,
    uf CHAR(2)
);

CREATE TABLE empresa (
    id_empresa INT IDENTITY(1000,1) PRIMARY KEY,
    nome_fantasia NVARCHAR(45) NOT NULL,
    razao_social NVARCHAR(45) NOT NULL,
    cnpj CHAR(14) NOT NULL,
    telefone NVARCHAR(11),
    fk_matriz INT,
    CONSTRAINT fk_matriz_empresa FOREIGN KEY (fk_matriz) REFERENCES empresa(id_empresa),
    fk_endereco INT,
    CONSTRAINT fk_endereco_empresa FOREIGN KEY (fk_endereco) REFERENCES endereco(id_endereco)
);

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
    id_perm_processo INT IDENTITY(1,1) PRIMARY KEY,
    nome NVARCHAR(45) NOT NULL,
    permitido BIT,
    path NVARCHAR(250),
    dt_hora DATETIME DEFAULT GETDATE(),
    fk_config INT,
    CONSTRAINT fk_config_perm FOREIGN KEY (fk_config) REFERENCES config(id_config)
);

CREATE TABLE agendamento_quest (
    id_quest INT IDENTITY(1,1) PRIMARY KEY,
    inicio DATETIME,
    fim DATETIME,
    fk_config INT,
    CONSTRAINT fk_config_ag_quest FOREIGN KEY (fk_config) REFERENCES config(id_config)
);

CREATE TABLE funcionario (
    id_funcionario INT IDENTITY(1,1) PRIMARY KEY,
    primeiro_nome NVARCHAR(80),
    sobrenome NVARCHAR(80) NOT NULL,
    celular NVARCHAR(15),
    telefone NVARCHAR(14),
    email NVARCHAR(80) NOT NULL,
    dt_nasc DATE,
    cpf CHAR(14) NOT NULL,
    cargo NVARCHAR(45),
    fk_gerente INT,
    fk_endereco INT,
    fk_empresa INT,
    CONSTRAINT fk_gerente_funcionario FOREIGN KEY (fk_gerente) REFERENCES funcionario(id_funcionario),
    CONSTRAINT fk_endereco_funcionario FOREIGN KEY (fk_endereco) REFERENCES endereco(id_endereco),
    CONSTRAINT fk_empresa_funcionario FOREIGN KEY (fk_empresa) REFERENCES empresa(id_empresa)
);

CREATE TABLE questionario (
    id_quest INT IDENTITY(1,1) PRIMARY KEY,
    nota INT,
    detalhe NVARCHAR(2000),
    respondido_em DATETIME DEFAULT GETDATE(),
    fk_quest INT NOT NULL,
    CONSTRAINT fk_quest_agendamento_quest FOREIGN KEY (fk_quest) REFERENCES agendamento_quest(id_quest),
    fk_funcionario INT NOT NULL,
    CONSTRAINT fk_quest_funcionario FOREIGN KEY (fk_funcionario) REFERENCES funcionario(id_funcionario)
);

CREATE TABLE tarefa (
    id_tarefa INT IDENTITY(1,1) PRIMARY KEY,
    descricao NVARCHAR(255),
    dt_inicio DATE DEFAULT CAST(GETDATE() AS DATE),
    dt_fim DATE,
    prioridade NVARCHAR(45),
    concluida BIT DEFAULT 0,
    dt_hora_concluida DATETIME,
    fk_funcionario INT NOT NULL,
    fk_gerente INT NOT NULL,
    CONSTRAINT fk_funcionario_tarefa FOREIGN KEY (fk_funcionario) REFERENCES funcionario(id_funcionario),
    CONSTRAINT fk_gerente_tarefa FOREIGN KEY (fk_gerente) REFERENCES funcionario(id_funcionario)
);

CREATE TABLE historico_tarefa (
    id_historico_tarefa INT IDENTITY(1,1) PRIMARY KEY,
    status NVARCHAR(45),
    dt_hora DATETIME DEFAULT GETDATE(),
    fk_tarefa INT,
    CONSTRAINT fk_historico_tarefa FOREIGN KEY (fk_tarefa) REFERENCES tarefa(id_tarefa)
);

CREATE TABLE usuario (
    id_usuario INT PRIMARY KEY,
    username NVARCHAR(80),
    senha NVARCHAR(80) CHECK (LEN(senha) >= 8),
    dt_criado DATETIME DEFAULT GETDATE(),
    CONSTRAINT fk_funcionario_usuario FOREIGN KEY (id_usuario) REFERENCES funcionario(id_funcionario)
);

CREATE TABLE tempo_ociosidade (
    id_tempo_ociosidade INT IDENTITY(1,1) PRIMARY KEY,
    dt_hora_registro DATETIME DEFAULT GETDATE(),
    tempo_registro_ms INT,
    fk_usuario INT,
    CONSTRAINT fk_usuario_tempo_ociosidade FOREIGN KEY (fk_usuario) REFERENCES usuario(id_usuario)
);

CREATE TABLE artigo (
    id_artigo INT IDENTITY(1,1) PRIMARY KEY,
    titulo NVARCHAR(45),
    descricao NVARCHAR(2000),
    categoria NVARCHAR(45),
    criado_em DATETIME DEFAULT GETDATE(),
    palavra_chave NVARCHAR(45),
    fk_funcionario INT,
    CONSTRAINT fk_funcionario_artigo FOREIGN KEY (fk_funcionario) REFERENCES funcionario(id_funcionario)
);

CREATE TABLE tag (
    id_tag INT IDENTITY(1,1) PRIMARY KEY,
    nome NVARCHAR(45)
);

CREATE TABLE artigo_has_tag (
    fk_tag INT,
    fk_artigo INT,
    CONSTRAINT fk_tag_at FOREIGN KEY (fk_tag) REFERENCES tag(id_tag),
    CONSTRAINT fk_artigo_at FOREIGN KEY (fk_artigo) REFERENCES artigo(id_artigo),
    PRIMARY KEY (fk_tag, fk_artigo)
);

CREATE TABLE maquina (
    id_maquina INT IDENTITY(1,1) PRIMARY KEY,
    hostname NVARCHAR(80),
    ip NVARCHAR(15),
    so NVARCHAR(80),
    cpu_modelo NVARCHAR(80),
    ram_total BIGINT,
    modificado_em DATETIME DEFAULT GETDATE(),  
    fk_empresa INT,
    CONSTRAINT fk_empresa_maquina FOREIGN KEY (fk_empresa) REFERENCES empresa(id_empresa)
);

CREATE TABLE volume (
    uuid CHAR(36) PRIMARY KEY,
    fk_maquina INT,
    nome NVARCHAR(45),
    ponto_montagem NVARCHAR(45),
    volume_total BIGINT,
    CONSTRAINT fk_maquina_volume FOREIGN KEY (fk_maquina) REFERENCES maquina(id_maquina)
);

CREATE TABLE sessao (
    id_sessao INT IDENTITY(1,1) PRIMARY KEY,
    fk_maquina INT,
    fk_usuario INT,
    fim_sessao DATETIME,
    dt_hora_sessao DATETIME DEFAULT GETDATE(),
    CONSTRAINT fk_maquina_sessao FOREIGN KEY (fk_maquina) REFERENCES maquina(id_maquina),
    CONSTRAINT fk_usuario_sessao FOREIGN KEY (fk_usuario) REFERENCES usuario(id_usuario)
);

CREATE TABLE ocorrencia (
    id_ocorrencia INT IDENTITY(1,1) PRIMARY KEY,
    titulo NVARCHAR(45),
    descricao NVARCHAR(255),
    tipo NVARCHAR(45),
    resolvido BIT DEFAULT 0,
    criado_em DATETIME DEFAULT GETDATE(),
    resolvido_em DATETIME,
    fk_sessao INT,
    fk_atribuido INT,
    CONSTRAINT fk_sessao_ocorrencia FOREIGN KEY (fk_sessao) REFERENCES sessao(id_sessao),
    CONSTRAINT fk_atribuido_ocorrencia FOREIGN KEY (fk_atribuido) REFERENCES funcionario(id_funcionario)
);

CREATE TABLE registro (
    id_registro INT IDENTITY(1,1) PRIMARY KEY,
    dt_hora DATETIME DEFAULT GETDATE(),
    uso_cpu DECIMAL(4, 1),
    uso_ram BIGINT,
    disponivel_ram BIGINT,
    uptime BIGINT,
    fk_sessao INT,
    CONSTRAINT fk_sessao_registro FOREIGN KEY (fk_sessao) REFERENCES sessao(id_sessao)
);

CREATE TABLE registro_volume (
    id_registro_volume INT IDENTITY(1,1) PRIMARY KEY,
    volume_disponivel BIGINT,
    dt_hora DATETIME DEFAULT GETDATE(),
    fk_sessao INT,
    fk_volume CHAR(36),
    CONSTRAINT fk_registro_sessao FOREIGN KEY (fk_sessao) REFERENCES sessao(id_sessao),
    CONSTRAINT fk_registro_volume FOREIGN KEY (fk_volume) REFERENCES volume(uuid)
);

CREATE TABLE processo (
    id_processo INT IDENTITY(1,1) PRIMARY KEY,
    nome NVARCHAR(45),
    caminho NVARCHAR(255),
    uso_ram BIGINT,
    fk_registro INT,
    CONSTRAINT fk_registro_processo FOREIGN KEY (fk_registro) REFERENCES registro(id_registro)
);

CREATE TABLE alerta (
    id_alerta INT IDENTITY(1,1) PRIMARY KEY,
    tipo NVARCHAR(45),
    descricao NVARCHAR(45),
    fk_registro INT,
    fk_reg_volume INT,
    CONSTRAINT fk_registro_alerta FOREIGN KEY (fk_registro) REFERENCES registro(id_registro),
    CONSTRAINT fk_reg_vol_alerta FOREIGN KEY (fk_reg_volume) REFERENCES registro_volume(id_registro_volume)
);

-- ENDEREÇOS
INSERT INTO endereco (logradouro, cep, numero, bairro, complemento, cidade, uf)
VALUES ('Rua A', '07124403', '673', 'Jardim Diogo', 'N/A', 'São Paulo', 'SP');

INSERT INTO endereco (logradouro, cep, numero, bairro, complemento, cidade, uf)
VALUES ('Rua Guapeva', '03333010', 896, 'Vila Regente Feijó', 'Apto 28', 'São Paulo', 'SP');

INSERT INTO endereco (logradouro, cep, numero, bairro, complemento, cidade, uf)
VALUES ('Rua Loefgren 2527', '04040901', 752, 'Vila Clementino', 'Casa', 'São Paulo', 'SP');

INSERT INTO endereco (logradouro, cep, numero, bairro, complemento, cidade, uf)
VALUES ('Via de Pedestre Tabularium', '02223350', 488, 'Jardim Brasil (Zona Norte)', 'Fundos', 'São Paulo', 'SP');

INSERT INTO endereco (logradouro, cep, numero, bairro, complemento, cidade, uf)
VALUES ('Rua Fernando de Albuquerque', '01309030', 303, 'Consolação', 'N/A', 'São Paulo', 'SP');

INSERT INTO endereco (logradouro, cep, numero, bairro, complemento, cidade, uf)
VALUES ('Rua Diomar Ackel', '03380080', 260, 'Chácara Belenzinho', 'Bloco A', 'São Paulo', 'SP');

INSERT INTO endereco (logradouro, cep, numero, bairro, complemento, cidade, uf)
VALUES ('Rua Osvaldo Nevola', '03946000', 295, 'Jardim Tietê', 'Casa', 'São Paulo', 'SP');

INSERT INTO endereco (logradouro, cep, numero, bairro, complemento, cidade, uf)
VALUES ('Avenida Cardeal Motta 335', '05101909', 496, 'Vila Fiat Lux', 'Apto 198', 'São Paulo', 'SP');

INSERT INTO endereco (logradouro, cep, numero, bairro, complemento, cidade, uf)
VALUES ('Rua Primavera', '04176250', 765, 'Jardim Vergueiro (Sacomã)', 'N/A', 'São Paulo', 'SP');

INSERT INTO endereco (logradouro, cep, numero, bairro, complemento, cidade, uf)
VALUES ('Rua Pelágio Lobo', '05009020', 506, 'Perdizes', 'Apto 2', 'São Paulo', 'SP');

INSERT INTO endereco (logradouro, cep, numero, bairro, complemento, cidade, uf)
VALUES ('Travessa Nardo do Monte', '03560180', 597, 'Vila Nhocune', 'Casa', 'São Paulo', 'SP');

INSERT INTO endereco (logradouro, cep, numero, bairro, complemento, cidade, uf)
VALUES ('Rua Evocação das Montanhas', '08381690', 807, 'Jardim Alto Alegre (São Rafael)', 'Fundos', 'São Paulo', 'SP');

INSERT INTO endereco (logradouro, cep, numero, bairro, complemento, cidade, uf)
VALUES ('Rua Ilha das Palmas', '05164001', 327, 'Conjunto Habitacional Turística', 'Bloco B', 'São Paulo', 'SP');


-- EMPRESAS
INSERT INTO empresa (nome_fantasia, razao_social, cnpj, fk_endereco)
VALUES ('Nexus', 'NEXUS ASSISTENCIA LTDA', '64845308000110', 1);

-- PARÂMETROS DE CONFIGURAÇÃO
INSERT INTO config (id_config, max_cpu, max_ram, max_volume, sensibilidade_mouse, timer_mouse_ms, intervalo_registro_ms, intervalo_volume_ms, intervalo_quest_dias)
VALUES (1000, 85.0, 80.0, 95.0, 25, 15000, 3000, 40000, 10);
    
-- FUNCIONÁRIOS

INSERT INTO funcionario (primeiro_nome, sobrenome, celular, telefone, email, dt_nasc, cpf, cargo, fk_empresa, fk_endereco)
VALUES ('Manuel', 'Nicolas Cardoso', '14988654354', '1436325560', 'manuel.cardoso@nexus.com', '1982-04-02', '03867664870', 'Gerente', 1000, 2);
    
INSERT INTO funcionario (primeiro_nome, sobrenome, celular, telefone, email, dt_nasc, cpf, cargo, fk_empresa, fk_gerente, fk_endereco)
VALUES ('Valentina', 'Cláudia Assunção', '11987989241', '1129140034', 'valentina.assuncao@nexus.com', '1993-04-02', '06092551853', 'Operador', 1000, 1, 3);
    
INSERT INTO funcionario (primeiro_nome, sobrenome, celular, telefone, email, dt_nasc, cpf, cargo, fk_empresa, fk_gerente, fk_endereco)
VALUES ('Isis', 'Valentina Farias', '11981608515', '35440749', 'isis.valentina@nexus.com', '1997-01-06', '93114418805', 'Operador', 1000, 1, 4);
    
INSERT INTO funcionario (primeiro_nome, sobrenome, celular, telefone, email, dt_nasc, cpf, cargo, fk_empresa, fk_gerente, fk_endereco)
VALUES ('Ana', 'Vera Rezende', '11987470434', '1136764152', 'ana.rezende@nexus.com', '1991-01-15', '78892318810', 'Operador', 1000, 1, 5);
    
INSERT INTO funcionario (primeiro_nome, sobrenome, celular, telefone, email, dt_nasc, cpf, cargo, fk_empresa, fk_gerente, fk_endereco)
VALUES ('Ryan', 'Costa', '11989604140', '1125156928', 'ryan.costa@nexus.com', '1992-12-08', '14521675832', 'Operador', 1000, 1, 6);

INSERT INTO funcionario (primeiro_nome, sobrenome, celular, telefone, email, dt_nasc, cpf, cargo, fk_empresa, fk_endereco)
VALUES ('Lívia', 'Luciana Figueiredo', '11986545684', '1129319945', 'livia.figueiredo@nexus.com', '1993-04-02', '40888624816', 'Gerente', 1000, 7);
    
INSERT INTO funcionario (primeiro_nome, sobrenome, celular, telefone, email, dt_nasc, cpf, cargo, fk_empresa, fk_gerente, fk_endereco)
VALUES ('Patrícia', 'Elisa Viana', '11992261086', '1139296287', 'patricia.viana@nexus.com', '1990-06-10', '54740320800', 'Operador', 1000, 2, 8);
    
INSERT INTO funcionario (primeiro_nome, sobrenome, celular, telefone, email, dt_nasc, cpf, cargo, fk_empresa, fk_gerente, fk_endereco)
VALUES ('Lara', 'Isadora Aparício', '11987376523', '1127816818', 'lara.aparicio@nexus.com', '1985-04-09', '58165225820', 'Operador', 1000, 2, 9);
    
INSERT INTO funcionario (primeiro_nome, sobrenome, celular, telefone, email, dt_nasc, cpf, cargo, fk_empresa, fk_gerente, fk_endereco)
VALUES ('Leandro', 'Monteiro Santos', '11988169528', '1135167017', 'ana.santos@nexus.com', '1975-03-25', '58033420847', 'Operador', 1000, 2, 10);

INSERT INTO funcionario (primeiro_nome, sobrenome, celular, telefone, email, dt_nasc, cpf, cargo, fk_empresa, fk_gerente, fk_endereco)
VALUES ('Benedito', 'Anthony de Paula', '11986843433', '1129141766', 'benedito.anthony@nexus.com', '1992-12-08', '43956670825', 'Operador', 1000, 2, 11);

INSERT INTO funcionario (primeiro_nome, sobrenome, celular, telefone, email, dt_nasc, cpf, cargo, fk_empresa, fk_endereco)
VALUES ('Mariana', 'Souza', '11993684521', '1137066879', 'mariana.souza@nexus.com', '1993-08-20', '20029857821', 'Suporte', 1000, 12);
    
INSERT INTO funcionario (primeiro_nome, sobrenome, celular, telefone, email, dt_nasc, cpf, cargo, fk_empresa, fk_endereco)
VALUES ('Catarina', 'Patrícia Fogaça', '11991407149', '1128207119', 'catarina.fogaca@nexus.com', '1993-08-20', '77348163807', 'Suporte', 1000, 13);

-- USUÁRIOS

INSERT INTO usuario (id_usuario, username, senha)
VALUES (1, 'manuel.cardoso', 'man123123');

INSERT INTO usuario (id_usuario, username, senha)
VALUES (2, 'valentina.assuncao', 'val123123');

INSERT INTO usuario (id_usuario, username, senha)
VALUES (3, 'isis.valentina', 'isi123123');

INSERT INTO usuario (id_usuario, username, senha)
VALUES (4, 'ana.rezende', 'ana123123');

INSERT INTO usuario (id_usuario, username, senha)
VALUES (5, 'ryan.costa', 'rya123123');

INSERT INTO usuario (id_usuario, username, senha)
VALUES (6, 'livia.figueiredo', 'liv123123');

INSERT INTO usuario (id_usuario, username, senha)
VALUES (7, 'patricia.viana', 'pat123123');

INSERT INTO usuario (id_usuario, username, senha)
VALUES (8, 'lara.aparicio', 'lar123123');

INSERT INTO usuario (id_usuario, username, senha)
VALUES (9, 'ana.santos', 'ana123123');

INSERT INTO usuario (id_usuario, username, senha)
VALUES (10, 'benedito.anthony', 'ben123123');

INSERT INTO usuario (id_usuario, username, senha)
VALUES (11, 'mariana.souza', 'mar123123');

INSERT INTO usuario (id_usuario, username, senha)
VALUES (12, 'catarina.fogaca', 'cat123123');

INSERT INTO endereco (logradouro, cep, numero, bairro, complemento, cidade, uf)
VALUES
('Rua Funchal', '04551060', '1329', 'Vila Olímpia', '', 'São Paulo', 'SP'),
('Avenida das Ameixeiras', '09940400', '123', 'Taboão', '(Jd Maravilha)', 'Diadema', 'SP'),
('Rua Olinda', '09770070', '99', 'Nova Petrópolis', '', 'São Bernardo do Campo', 'SP'),
('Rua F', '02859190', '49', 'Jardim Vitória Régia (Zona Norte)', '', 'São Paulo', 'SP'),
('Rua Cupiara', '03273020', '123', 'Vila Santa Clara', '', 'São Paulo', 'SP'),
('Praça da Sé', '01001000', '432', 'Sé', '', 'São Paulo', 'SP');

INSERT INTO funcionario (primeiro_nome, sobrenome, celular, telefone, email, dt_nasc, cpf, cargo, fk_gerente, fk_endereco, fk_empresa)
VALUES
('Eduarda', 'Guardião', '(11) 95128-8322', '', 'maria.guardiao@sptech.school', '2005-03-29', '356.455.545-65', 'Operador', 1, 14, 1000),
('Vinícius', 'Zirondi', '(19) 99965-4584', '(19) 3534-1719', 'viniciuszirondi04@gmail.com', '2004-08-31', '123.123.123-12', 'Operador', 1, 15, 1000),
('Jean', 'Rocha Santos', '(11) 11635-8593', '(11) 8699-4859', 'jean@hotmail.com', '2000-03-10', '247.437.575-48', 'Operador', 1, 16, 1000),
('Samuel', 'de Oliveira', '(11) 93410-1869', '(11) 1234-1223', 'samuel@gmail.com', '2004-02-08', '534.733.998-50', 'Operador', 1, 17, 1000),
('Lucas', 'Faes', '(11) 91234-1234', '(11) 1234-1234', 'lucas.faes@techsolutions.com', '2004-10-20', '123.123.123-12', 'Operador', 1, 18, 1000),
('Pedro', 'Scortuzzi', '(11) 91234-1234', '(11) 1234-1234', 'pedro.scortuzzi@techsolutions.com', '2005-03-30', '123.123.123-12', 'Operador', 1, 19, 1000);

INSERT INTO usuario (id_usuario, username, senha)
VALUES
(13, 'maria.guardiao', 'mar123123'),
(14, 'vinicius.zirondi', 'vin123123'),
(15, 'jean.santos', 'jea123123'),
(16, 'samuel.batista', 'sam123123'),
(17, 'lucas.faes', 'luc123123'),
(18, 'pedro.scortuzzi', 'sco123123');

INSERT INTO tarefa (descricao, dt_inicio, dt_fim, prioridade, concluida, dt_hora_concluida, fk_funcionario, fk_gerente)
VALUES 
('Responder consultas de clientes', '2024-05-01', '2024-05-10', 'media', 'false', NULL, 2, 1),
('Resolver problemas técnicos dos clientes', '2024-05-03', '2024-05-15', 'media', 'false', NULL, 3, 1),
('Realizar follow-up de chamadas pendentes', '2024-05-05', '2024-05-08', 'media', 'true', '2024-05-08 12:00:00', 4, 1),
('Atualizar registros de clientes', '2024-05-06', '2024-05-12', 'media', 'false', NULL, 5, 1),
('Treinamento de novos operadores', '2024-05-07', '2024-05-11', 'media', 'true', '2024-05-11 15:30:00', 2, 1),
('Reunião com a equipe de supervisão', '2024-05-09', '2024-05-09', 'media', 'false', NULL, 3, 1),
('Planejamento de escalas de trabalho', '2024-05-10', '2024-05-12', 'media', 'false', NULL, 4, 1),
('Analisar métricas de desempenho de chamadas', '2024-05-11', '2024-05-13', 'media', 'false', NULL, 5, 1),
('Revisar gravações de chamadas', '2024-05-12', '2024-05-14', 'media', 'true', '2024-05-14 09:00:00', 2, 1),
('Coaching de operadores de call center', '2024-05-13', '2024-05-15', 'media', 'false', NULL, 3, 1);

INSERT INTO historico_tarefa (status, dt_hora, fk_tarefa)
VALUES 
('CONCLUIDO', '2024-05-08 12:00:00', 3),
('CONCLUIDO', '2024-05-11 15:30:00', 5),
('CONCLUIDO', '2024-05-14 09:00:00', 9),
('ATRASO', '2024-05-16 10:00:00', 1),
('ATRASO', '2024-05-16 10:00:00', 2),
('ATRASO', '2024-05-16 10:00:00', 4),
('ATRASO', '2024-05-16 10:00:00', 6),
('ATRASO', '2024-05-16 10:00:00', 7),
('ATRASO', '2024-05-16 10:00:00', 8),
('ATRASO', '2024-05-16 10:00:00', 10);

