clear variables
close all
clc

% Inicia a medição de desempenho da simulação
tic

% Prepara a máquina saudável (exceto os condutores do rotor), definindo
% fronteiras, grupos, circuitos e materiais
preparaModelo

% Prepara o material dos condutores do rotor de gaiola da máquina saudável
preparaRotorGaiolaSaudavel

% Prepara o material dos condutores do rotor bobinado da máquina saudável
preparaRotorBobinadoSaudavel

% Finaliza a medição de desempenho da simulação
tempoSimulacaoEtapa1 = toc;

% Salva todas as variáveis do espaço de trabalho
save dados/etapa1.mat

% Salva algumas variáveis específicas
save dados/parametrosConstrutivos.mat ...
    g r_int_rotor r_ext_rotor r_int_estator r_ext_estator ...
    r_ranhura_estator r_ranhura_rotor ...
    mesh_coroa mesh_eixo mesh_gap mesh_ranhura ...
    Ns_ranhuras Nr_ranhuras Ns_efetivo Nr_efetivo l_axial x0 y0 ...
    funcao_espiras_as funcao_espiras_bs funcao_espiras_cs ...
    funcao_espiras_ar funcao_espiras_br funcao_espiras_cr;