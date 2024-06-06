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