clear variables
clear atualizacaoEstados
clear interpolacaoIndutancias
close all
clc

% Este código só funciona no MATLAB R2021a e posteriores, devido à função
% griddedInterpolant() para interpolação das matrizes de indutância. Esta
% função existe desde a versão R2011b, porém é feita aqui interpolações de
% vários conjuntos de dados simultaneamente (adicionada na versão R2021a).
if exist('OCTAVE_VERSION','builtin') ~= 0 || ...
        isMATLABReleaseOlderThan('R2021a')
    error('Código só funciona no MATLAB R2021a e posteriores!');
end

% Carrega os dados necessários
load('dados/indutancias.mat');
load('dados/parametrosConstrutivos.mat');
load('dados/parametrosSaudaveis_Meeker.mat');
%load('dados/parametrosSaudaveis_Outro.mat');

% Inicia a medição de desempenho da simulação
tic

% Executa o arquivo de inicialização das variáveis de valor constante
inicializacaoConstantes

%% MIT saudável

% Executa o arquivo de inicialização das variáveis de estado
inicializacaoEstados

% Executa o arquivo de simulação em regime dinâmico da máquina saudável
simulacaoMITSaudavel

% Executa o arquivo de geração de figuras
figurasMITSaudavel

%% MIT aplicada a um estudo de caso

% Executa o arquivo de inicialização das variáveis de estado
inicializacaoEstados

% Executa o arquivo de simulação em regime dinâmico da máquina aplicada a
% um estudo de caso em que falhas são adicionadas gradualmente à simulação
simulacaoMITFalhas

% Executa o arquivo de geração de figuras
figurasMITFalhas

%% Fim da simulação

% Finaliza a medição de desempenho da simulação
tempoSimulacaoEtapa4 = toc;

% Salva todas as variáveis do espaço de trabalho
save dados/etapa4.mat