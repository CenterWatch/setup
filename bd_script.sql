DROP DATABASE IF EXISTS cwdb;

CREATE DATABASE cwdb;

USE cwdb;

CREATE TABLE endereco (
    id_endereco INT PRIMARY KEY AUTO_INCREMENT,
    logradouro VARCHAR(45),
    cep CHAR(8),
    numero VARCHAR(5),
    bairro VARCHAR(45),
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
    permitido TINYINT,
    path VARCHAR(250),
    dt_hora DATETIME DEFAULT CURRENT_TIMESTAMP,
    fk_config INT,
    CONSTRAINT fk_config_perm FOREIGN KEY (fk_config) REFERENCES config(id_config)
);

CREATE TABLE agendamento_quest (
    id_quest INT PRIMARY KEY AUTO_INCREMENT,
    inicio DATETIME,
    fim DATETIME,
    fk_config INT,
    CONSTRAINT fk_config_ag_quest FOREIGN KEY (fk_config) REFERENCES config(id_config)
);

CREATE TABLE funcionario (
    id_funcionario INT PRIMARY KEY AUTO_INCREMENT,
    primeiro_nome VARCHAR(80),
    sobrenome VARCHAR(80) NOT NULL,
    celular CHAR(15),
    telefone CHAR(14),
    email VARCHAR(80) NOT NULL,
    dt_nasc DATE,
    cpf CHAR(14) NOT NULL,
    cargo VARCHAR(45),
    fk_gerente INT,
    fk_endereco INT,
    fk_empresa INT,
    CONSTRAINT fk_gerente_funcionario FOREIGN KEY (fk_gerente) REFERENCES funcionario(id_funcionario),
    CONSTRAINT fk_endereco_funcionario FOREIGN KEY (fk_endereco) REFERENCES endereco(id_endereco),
    CONSTRAINT fk_empresa_funcionario FOREIGN KEY (fk_empresa) REFERENCES empresa(id_empresa)
);

CREATE TABLE questionario (
    id_quest INT PRIMARY KEY AUTO_INCREMENT,
    nota INT,
    detalhe VARCHAR(2000),
    respondido_em DATETIME DEFAULT CURRENT_TIMESTAMP,
    fk_quest INT NOT NULL,
    CONSTRAINT fk_quest_agendamento_quest FOREIGN KEY (fk_quest) REFERENCES agendamento_quest(id_quest),
    fk_funcionario INT NOT NULL,
    CONSTRAINT fk_quest_funcionario FOREIGN KEY (fk_funcionario) REFERENCES funcionario(id_funcionario)
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

CREATE TABLE historico_tarefa (
    id_historico_tarefa INT PRIMARY KEY AUTO_INCREMENT,
    status VARCHAR(45),
    dt_hora DATETIME DEFAULT CURRENT_TIMESTAMP,
    fk_tarefa INT,
    CONSTRAINT fk_historico_tarefa FOREIGN KEY (fk_tarefa) REFERENCES tarefa(id_tarefa)
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
    ip VARCHAR(15),
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
    fim_sessao DATETIME,
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
    uptime BIGINT,
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
VALUES ('Manuel', 'Nicolas Cardoso', '(14) 98865-4354', '(14) 3632-5560', 'manuel.cardoso@nexus.com', '1982-04-02', '038.676.648-70', 'Gerente', 1000, 2);

INSERT INTO funcionario (primeiro_nome, sobrenome, celular, telefone, email, dt_nasc, cpf, cargo, fk_empresa, fk_gerente, fk_endereco)
VALUES ('Valentina', 'Cláudia Assunção', '(11) 98798-9241', '(11) 2914-0034', 'valentina.assuncao@nexus.com', '1993-04-02', '060.925.518-53', 'Operador', 1000, 1, 3);

INSERT INTO funcionario (primeiro_nome, sobrenome, celular, telefone, email, dt_nasc, cpf, cargo, fk_empresa, fk_gerente, fk_endereco)
VALUES ('Isis', 'Valentina Farias', '(11) 98160-8515', '(35) 4407-49', 'isis.valentina@nexus.com', '1997-01-06', '931.144.188-05', 'Operador', 1000, 1, 4);

INSERT INTO funcionario (primeiro_nome, sobrenome, celular, telefone, email, dt_nasc, cpf, cargo, fk_empresa, fk_gerente, fk_endereco)
VALUES ('Ana', 'Vera Rezende', '(11) 98747-0434', '(11) 3676-4152', 'ana.rezende@nexus.com', '1991-01-15', '788.923.188-10', 'Operador', 1000, 1, 5);

INSERT INTO funcionario (primeiro_nome, sobrenome, celular, telefone, email, dt_nasc, cpf, cargo, fk_empresa, fk_gerente, fk_endereco)
VALUES ('Ryan', 'Costa', '(11) 98960-4140', '(11) 2515-6928', 'ryan.costa@nexus.com', '1992-12-08', '145.216.758-32', 'Operador', 1000, 1, 6);

INSERT INTO funcionario (primeiro_nome, sobrenome, celular, telefone, email, dt_nasc, cpf, cargo, fk_empresa, fk_endereco)
VALUES ('Lívia', 'Luciana Figueiredo', '(11) 98654-5684', '(11) 2931-9945', 'livia.figueiredo@nexus.com', '1993-04-02', '408.886.248-16', 'Gerente', 1000, 7);

INSERT INTO funcionario (primeiro_nome, sobrenome, celular, telefone, email, dt_nasc, cpf, cargo, fk_empresa, fk_gerente, fk_endereco)
VALUES ('Patrícia', 'Elisa Viana', '(11) 99226-1086', '(11) 3929-6287', 'patricia.viana@nexus.com', '1990-06-10', '547.403.208-00', 'Operador', 1000, 2, 8);

INSERT INTO funcionario (primeiro_nome, sobrenome, celular, telefone, email, dt_nasc, cpf, cargo, fk_empresa, fk_gerente, fk_endereco)
VALUES ('Lara', 'Isadora Aparício', '(11) 98737-6523', '(11) 2781-6818', 'lara.aparicio@nexus.com', '1985-04-09', '581.652.258-20', 'Operador', 1000, 2, 9);

INSERT INTO funcionario (primeiro_nome, sobrenome, celular, telefone, email, dt_nasc, cpf, cargo, fk_empresa, fk_gerente, fk_endereco)
VALUES ('Leandro', 'Monteiro Santos', '(11) 98816-9528', '(11) 3516-7017', 'ana.santos@nexus.com', '1975-03-25', '580.334.208-47', 'Operador', 1000, 2, 10);

INSERT INTO funcionario (primeiro_nome, sobrenome, celular, telefone, email, dt_nasc, cpf, cargo, fk_empresa, fk_gerente, fk_endereco)
VALUES ('Benedito', 'Anthony de Paula', '(11) 98684-3433', '(11) 2914-1766', 'benedito.anthony@nexus.com', '1992-12-08', '439.566.708-25', 'Operador', 1000, 2, 11);

INSERT INTO funcionario (primeiro_nome, sobrenome, celular, telefone, email, dt_nasc, cpf, cargo, fk_empresa, fk_endereco)
VALUES ('Mariana', 'Souza', '(11) 93684-521', '(11) 3706-6879', 'mariana.souza@nexus.com', '1993-08-20', '200.298.578-21', 'Suporte', 1000, 12);

INSERT INTO funcionario (primeiro_nome, sobrenome, celular, telefone, email, dt_nasc, cpf, cargo, fk_empresa, fk_endereco)
VALUES ('Catarina', 'Patrícia Fogaça', '(11) 91407-149', '(11) 2820-7119', 'catarina.fogaca@nexus.com', '1993-08-20', '773.481.638-07', 'Suporte', 1000, 13);

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

INSERT INTO endereco (id_endereco, logradouro, cep, numero, bairro, complemento, cidade, uf)
VALUES
(34, 'Rua Funchal', '04551060', '1329', 'Vila Olímpia', '', 'São Paulo', 'SP'),
(33, 'Avenida das Ameixeiras', '09940400', '123', 'Taboão', '(Jd Maravilha)', 'Diadema', 'SP'),
(32, 'Rua Olinda', '09770070', '99', 'Nova Petrópolis', '', 'São Bernardo do Campo', 'SP'),
(28, 'Rua F', '02859190', '49', 'Jardim Vitória Régia (Zona Norte)', '', 'São Paulo', 'SP'),
(27, 'Rua Cupiara', '03273020', '123', 'Vila Santa Clara', '', 'São Paulo', 'SP'),
(29, 'Praça da Sé', '01001000', '432', 'Sé', '', 'São Paulo', 'SP');

INSERT INTO funcionario (id_funcionario, primeiro_nome, sobrenome, celular, telefone, email, dt_nasc, cpf, cargo, fk_gerente, fk_endereco, fk_empresa)
VALUES
(19, 'Eduarda', 'Guardião', '(11) 95128-8322', '', 'maria.guardiao@sptech.school', '2005-03-29', '356.455.545-65', 'Operador', 1, 34, 1000),
(20, 'Vinícius', 'Zirondi', '(19) 99965-4584', '(19) 3534-1719', 'viniciuszirondi04@gmail.com', '2004-08-31', '123.123.123-12', 'Operador', 1, 33, 1000),
(21, 'Jean', 'Rocha Santos', '(11) 11635-8593', '(11) 8699-4859', 'jean@hotmail.com', '2000-03-10', '247.437.575-48', 'Operador', 1, 32, 1000),
(22, 'Samuel', 'de Oliveira', '(11) 93410-1869', '(11) 1234-1223', 'samuel@gmail.com', '2004-02-08', '534.733.998-50', 'Operador', 1, 28, 1000),
(23, 'Lucas', 'Faes', '(11) 91234-1234', '(11) 1234-1234', 'lucas.faes@techsolutions.com', '2004-10-20', '123.123.123-12', 'Operador', 1, 27, 1000),
(24, 'Pedro', 'Scortuzzi', '(11) 91234-1234', '(11) 1234-1234', 'pedro.scortuzzi@techsolutions.com', '2005-03-30', '123.123.123-12', 'Operador', 1, 29, 1000);

INSERT INTO usuario (id_usuario, username, senha)
VALUES
(19, 'maria.guardiao', 'mar123123'),
(20, 'vinicius.zirondi', 'vin123123'),
(21, 'jean.santos', 'jea123123'),
(22, 'samuel.batista', 'sam123123'),
(23, 'lucas.faes', 'luc123123'),
(24, 'pedro.scortuzzi', 'sco123123');

INSERT INTO tarefa (descricao, dt_inicio, dt_fim, prioridade, concluida, dt_hora_concluida, fk_funcionario, fk_gerente)
VALUES 
('Responder consultas de clientes', '2024-05-01', '2024-05-10', 'media', false, NULL, 2, 1),
('Resolver problemas técnicos dos clientes', '2024-05-03', '2024-05-15', 'media', false, NULL, 3, 1),
('Realizar follow-up de chamadas pendentes', '2024-05-05', '2024-05-08', 'media', true, '2024-05-08 12:00:00', 4, 1),
('Atualizar registros de clientes', '2024-05-06', '2024-05-12', 'media', false, NULL, 5, 1),
('Treinamento de novos operadores', '2024-05-07', '2024-05-11', 'media', true, '2024-05-11 15:30:00', 2, 1),
('Reunião com a equipe de supervisão', '2024-05-09', '2024-05-09', 'media', false, NULL, 3, 1),
('Planejamento de escalas de trabalho', '2024-05-10', '2024-05-12', 'media', false, NULL, 4, 1),
('Analisar métricas de desempenho de chamadas', '2024-05-11', '2024-05-13', 'media', false, NULL, 5, 1),
('Revisar gravações de chamadas', '2024-05-12', '2024-05-14', 'media', true, '2024-05-14 09:00:00', 2, 1),
('Coaching de operadores de call center', '2024-05-13', '2024-05-15', 'media', false, NULL, 3, 1);

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


INSERT INTO perm_processo (nome, fk_config)
VALUES
('azuredatastudio', 1000),
('smss', 1000),
('java', 1000),
('gamingservices', 1000),
('gamingservicesnet', 1000),
('Code', 1000),
('taskhostw', 1000),
('winlogon', 1000),
('OfficeClickToRun', 1000),
('dwm', 1000),
('StartMenuExperienceHost', 1000),
('csrss', 1000),
('audiodg', 1000),
('SqlToolsResourceProviderService', 1000),
('MpDefenderCoreService', 1000),
('svchost', 1000),
('AMDRSServ', 1000),
('mstsc', 1000),
('services', 1000),
('FileCoAuth', 1000),
('WidgetService', 1000),
('SecurityHealthService', 1000),
('TextInputHost', 1000),
('ShellExperienceHost', 1000),
('conhost', 1000),
('wininit', 1000),
('RtkAudUService64', 1000),
('vmcompute', 1000),
('steamwebhelper', 1000),
('LsaIso', 1000),
('WmiPrvSE', 1000),
('sihost', 1000),
('System', 1000),
('SystemSettingsBroker', 1000),
('dllhost', 1000),
('ApplicationFrameHost', 1000),
('mysqld', 1000),
('Registry', 1000),
('bash', 1000),
('Memory Compression', 1000),
('fsnotifier', 1000),
('CPUMetricsServer', 1000),
('powershell', 1000),
('steamservice', 1000),
('RuntimeBroker', 1000),
('idea64', 1000),
('atiesrxx', 1000),
('explorer', 1000),
('cmd', 1000),
('MicrosoftSqlToolsServiceLayer', 1000),
('WindowsTerminal', 1000),
('cncmd', 1000),
('ngrok', 1000),
('git-bash', 1000),
('DataExchangeHost', 1000),
('OneDrive', 1000),
('ctfmon', 1000),
('Notepad', 1000),
('spoolsv', 1000),
('UserOOBEBroker', 1000),
('MicrosoftSqlToolsCredentials', 1000),
('SecurityHealthSystray', 1000),
('MySQLWorkbench', 1000),
('wslservice', 1000),
('firefox', 1000),
('Widgets', 1000),
('PhoneExperienceHost', 1000),
('mintty', 1000),
('fontdrvhost', 1000),
('dasHost', 1000),
('atieclxx', 1000),
('RadeonSoftware', 1000),
('lsass', 1000),
('LockApp', 1000),
('wlanext', 1000),
('NisSrv', 1000),
('Secure System', 1000),
('Idle', 1000),
('steam', 1000),
('spacedeskService', 1000),
('spacedeskServiceTray', 1000),
('SearchHost', 1000),
('AMDRSSrcExt', 1000),
('OpenConsole', 1000),
('MsMpEng', 1000),
('amdfendrsr', 1000),
('SearchIndexer', 1000);