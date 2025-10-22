% Estados iniciais dos fluxos
lambds = 0;         % Fluxo de estator no eixo d
lambqs = 0;         % Fluxo de estator no eixo q
lambdr = 0;         % Fluxo de rotor no eixo d
lambqr = 0;         % Fluxo de rotor no eixo q
lambasf = 0;        % Fluxo da falha ITF

% Estados iniciais das correntes
ids = 0;            % Corrente de estator no eixo d
iqs = 0;            % Corrente de estator no eixo q
idr = 0;            % Corrente de rotor no eixo d
iqr = 0;            % Corrente de rotor no eixo q
i_f = 0;            % Corrente da falha em abc

% Estados iniciais das posições e velocidades angulares
% OBS.: wr != 0 para resolver inconsistência numérica
wr = 0.0001;        % Velocidade elétrica do rotor
wmec = (2/p)*wr;    % Velocidade mecânica do rotor
theta_r = 0;        % Posição elétrica do rotor
theta_mec = 0;      % Posição mecânica do rotor
theta_dq = 0;       % Ângulo de rotação do eixo coordenado dq

% Inicialização de outros parâmetros
k = 1;
decimador = nPontosDecimacao;
delta_d = 0;
delta_st = delta_st_ref;
entrouEd = false;