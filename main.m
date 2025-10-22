%% Inicialização do MATLAB

% Adiciona o caminho dos arquivos .m para manipular o FEMM
if ispc
    % Se for Windows
    addpath('C:/femm42/mfiles');
else
    % Se for Linux
    addpath('~/.wine/drive_c/femm42/mfiles');
end

% Adiciona outros caminhos necessários
addpath('desenhos');
addpath('gerais');
addpath('indutancias');
addpath('mitFalhas');
addpath('mitSaudavel');
addpath('parametrosSaudaveis');

%% Executa as etapas em sequência
% Comente e descomente os arquivos que deseja executar

% Executa o arquivo da Etapa 1
%etapa1_desenhosSaudaveis

% Executa o arquivo da Etapa 2
%etapa2_parametrosSaudaveis

% Executa o arquivo da Etapa 3
%etapa3_caracterizacaoIndutancias

% Executa o arquivo da Etapa 4
%etapa4_simulacaoDinamica

% Executa o arquivo da Etapa 5
%etapa5_validacaoComputacional