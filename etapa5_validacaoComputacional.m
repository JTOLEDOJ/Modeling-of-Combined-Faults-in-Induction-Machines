clear variables
close all
clc

% Carrega os dados necessários
load('dados/parametrosConstrutivos.mat');
load('dados/etapa4.mat',...
    'p','f','we','Inom','TeNom','deg120','dt_decimado','tempo',...
    'tEfetivoEntraEd_falhas','tEntraCurto','tSaiCarga',...
    'theta_mec_saud','nmec_saud','Te_saud','is_dq_saud',...
    'ias_saud','ibs_saud','ics_saud',...
    'iar_saud','ibr_saud','icr_saud',...
    'theta_mec_falhas','Te_falhas',...
    'if_falhas','xi_ref','er_falhas','delta_r_falhas',...
    'ias_falhas','ibs_falhas','ics_falhas',...
    'iar_falhas','ibr_falhas','icr_falhas');

% Inicia a medição de desempenho da simulação
tic

% Índices da primeira parte (exc. estática)
idx0 = round((tEfetivoEntraEd_falhas - 2/f)/dt_decimado);
idx1 = idx0 + round(1/f/dt_decimado);

% Índices da segunda parte (exc. mista)
idx2 = round((tEntraCurto - 2/f)/dt_decimado);
idx3 = idx2 + round(1/f/dt_decimado);

% Índices da terceira parte (exc. mista e falha entre espiras)
idx4 = round((tSaiCarga - 2/f)/dt_decimado);
idx5 = idx4 + round(1/f/dt_decimado);

% Verifica o torque calculado pelo FEMM para a máquina saudável usando o
% método da frequência de escorregamento e inserindo correntes complexas
torqueMITGaiolaSaudavel

% Verifica o torque calculado pelo FEMM para a máquina saudável usando o
% método instantâneo, ou seja, frequência nula e valores instantâneos para
% as correntes de estator e rotor
torqueMITBobinadaSaudavel

% Verifica o torque calculado pelo FEMM para a máquina com ambas as falhas
% (curto-circuito e excentricidade) usando o método instantâneo, ou seja,
% frequência nula e valores instantâneos para correntes de estator e rotor
torqueMITBobinadaFalhas

% Finaliza a medição de desempenho da simulação
tempoSimulacaoEtapa5 = toc;

% Salva todas as variáveis do espaço de trabalho
save dados/etapa5.mat