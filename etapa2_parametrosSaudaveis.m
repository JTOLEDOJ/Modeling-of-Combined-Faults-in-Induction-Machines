clear variables
clear metodoMeeker
close all
clc

% Carrega os dados necessários
load('dados/etapa1.mat');

% Inicia a medição de desempenho da simulação
tic

% Utilizando da metodologia do exemplo do FEMM, encontra-se as indutâncias
% e a constante de tempo da máquina
encontraIndutanciasMeeker

% Verifica, em regime permanente, os parâmetros da MIT que foram calculados
% na simulação anterior. Além disso, mostra os valores estimados em p.u.
circuitoEquivalenteOriginal

% Compara, em regime permanente, as curvas características do motor para os
% dois circuitos: original do autor (sem indutância de dispersão no rotor)
% e tradicional (mais comum na comunidade científica)
circuitoEquivalenteTradicional

% Verifica o torque induzido em várias frequências de operação da máquina,
% criando a curva de torque em regime permanente
verificaCurvaTorque

% Renomeia algumas variáveis para serem salvas posteriormente
Pnom = pNom;
Vnom = vNom;
Vmax = vs;
Inom = iNom;
Nnom = nNom;
FPnom = fpNom;
RendNom = rendNom;
TeMax = max(TeVetor_Tradicional);
Ip_In = max(abs(isVetor_Tradicional)*sqrt(3)/sqrt(2))/iNom;
TeVetor = TeVetor_Tradicional;
PmecVetor = pMecVetor_Tradicional;
IsVetor = isVetor_Tradicional;
IrVetor = irVetor_Tradicional;
PeleVetor = pEleVetor_Tradicional;
RendVetor = rendVetor_Tradicional;
FPVetor = fpVetor_Tradicional;
nVetor = nVetor_Tradicional;

% Finaliza a medição de desempenho da simulação
tempoSimulacaoEtapa2 = toc;

% Salva todas as variáveis do espaço de trabalho
save dados/etapa2.mat

% Salva algumas variáveis específicas
save dados/parametrosSaudaveis_Meeker.mat ...
    f we Ns Nr p rs rr Ls Lr Lm Lms Lmr Lls Llr Lsr ...
    rr_linha Lr_linha Lmr_linha Llr_linha ...
    TeNom Pnom Vnom Vmax Inom Nnom FPnom RendNom TeMax Ip_In ...
    TeVetor PmecVetor IsVetor IrVetor PeleVetor RendVetor FPVetor nVetor;