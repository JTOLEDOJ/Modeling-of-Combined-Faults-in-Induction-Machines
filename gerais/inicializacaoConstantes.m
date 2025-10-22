%% Definição de variáveis diversas

% Figuras
fonteSize = 24;
lineWidth = 1.5;

% Loop
tInicial = 0;                           % Tempo inicial de simulação [s]
tFinal = 3.5;                           % Tempo final de simulação [s]
dt = 10e-6;                             % Passo de cálculo [s]
nPontosDecimacao = 1;                   % Número de pontos decimação
dt_decimado = nPontosDecimacao*dt;      % Passo de cálculo decimado [s]
tempo = tInicial:dt_decimado:tFinal;    % Vetor de tempo da simulação [s]
tamVetor = length(tempo);               % Tamanho do vetor de tempo

% Desempenho
dt_2 = dt/2;
dt_6 = dt/6;
deg120 = deg2rad(120);

% Parâmetros do acionamento e da carga
J = 0.03;                           % Momento de inércia [Kg.m2]
TL_ref = TeNom;                     % Referência de torque [N.m]
tEntraCarga = 1.5;                  % Referência de tempo de entrada [s]
tSaiCarga = tFinal - 0.5;           % Referência de tempo de saída [s]

%% Curto-circuito entre espiras

xi_ref = [1/Ns 2/Ns 3/Ns];          % Referência de porcentagem de curto
rf_ref = [0.9 0.7 0.4];             % Referência de resistência [Ohm]
tDuracaoCurto = [2/f 1/f];          % Tempo entre os curtos [s]

% Termos em comum aos conjuntos de dados:
rf_inf = 10^6;                      % Resistência para caso saudável [Ohm]
tEntraCurto = 2.6;                  % Referência de tempo de entrada [s]
tSaiCurto = tFinal + 1;             % Referência de tempo de saída [s]
tAcumulativoCurto = ...             % Tempos para cada etapa de curto [s]
    [tEntraCurto, tEntraCurto + cumsum(tDuracaoCurto), tSaiCurto];

%% Excentricidade mecânica (estática)
% Obs.: dentro da função deg2rad() na inicialização de delta_st_ref, entre
% com valores de 0º a +-180º!

est_ref = 0.20*g;                   % Referência de amplitude [mm]
delta_st_ref = deg2rad(-90);        % Referência de ângulo [rad]
tEntraEst = 2;                      % Referência de tempo de entrada [s]
tSaiEst = tFinal + 1;               % Referência de tempo de saída [s]

%% Excentricidade mecânica (dinâmica)
% Obs.: delta_d não é definido aqui, pois ele é síncrono com o ímã girante

ed_ref = 0.10*g;                    % Referência de amplitude [mm]
tEntraEd = 2.3;                     % Referência de tempo de entrada [s]
tSaiEd = tFinal + 1;                % Referência de tempo de saída [s]
% Obs.: garante que a excentricidade dinâmica entre na posição angular da
% excentricidade estática, sincronize com o ímã girante e não tenha posição
% mecânica variada abruptamente
erroMaxSincEd = 15e-4;
tDeslocEd = 5/f;
taxaCrescEd = dt*ed_ref/tDeslocEd;

%% Para a máquina saudável

L_saud_original = [Ls 0 Lm 0; 0 Ls 0 Lm; Lm 0 Lr 0; 0 Lm 0 Lr];
L_saud_modificada = L_saud_original;
L_saud_modificada(:,5) = 0;
L_saud_modificada(5,:) = 0;
L_saud_modificada(5,5) = 1;
Linv_saud_original = (1/(Ls*Lr - Lm^2))*...
    [Lr 0 -Lm 0; 0 Lr 0 -Lm; -Lm 0 Ls 0; 0 -Lm 0 Ls];
Linv_saud_modificada = Linv_saud_original;
Linv_saud_modificada(:,5) = 0;
Linv_saud_modificada(5,:) = 0;
Linv_saud_modificada(5,5) = 1;

%% Interpolação das matrizes de indutância

% Cálculos da matriz Lss
Lss_mutua_saud = ...
    mean([Lss12_saud_vetor,Lss13_saud_vetor,Lss21_saud_vetor,...
    Lss23_saud_vetor,Lss31_saud_vetor,Lss32_saud_vetor]);
Lss_mag_saud = -2*Lss_mutua_saud;
Lss_prop_saud = mean([Lss11_saud_vetor,Lss22_saud_vetor,Lss33_saud_vetor]);
Lss_disp_saud = Lss_prop_saud - Lss_mag_saud;

% Cálculos da matriz Lrr
Lrr_mutua_saud = ...
    mean([Lrr12_saud_vetor,Lrr13_saud_vetor,Lrr21_saud_vetor,...
    Lrr23_saud_vetor,Lrr31_saud_vetor,Lrr32_saud_vetor]);
Lrr_mag_saud = -2*Lrr_mutua_saud;
Lrr_prop_saud = mean([Lrr11_saud_vetor,Lrr22_saud_vetor,Lrr33_saud_vetor]);
Lrr_disp_saud = Lrr_prop_saud - Lrr_mag_saud;

% Cálculos dos erros entre os métodos de obtenção das indutâncias
erroLms = Lms - Lss_mag_saud;
erroLls = Lls - Lss_disp_saud;
erroLmr = Lmr_linha - Lrr_mag_saud;
erroLlr = Llr_linha - Lrr_disp_saud;

% Se precisar usar apenas Lss e Lrr (matriz 4D com 18 indutâncias)
V = zeros(ampExc_tam,angExc_tam,angRot_tam,18);
% Se precisar usar Lss, Lrr, Lsr e Lrs (matriz 4D com 36 indutâncias)
% V = zeros(ampExc_tam,angExc_tam,angRot_tam,36);

% Inserção das matrizes Lss
V(:,:,:,1) = Lss11_er_matriz + (erroLms + erroLls);
V(:,:,:,2) = Lss12_er_matriz + (-0.5*erroLms);
V(:,:,:,3) = Lss13_er_matriz + (-0.5*erroLms);
V(:,:,:,4) = Lss21_er_matriz + (-0.5*erroLms);
V(:,:,:,5) = Lss22_er_matriz + (erroLms + erroLls);
V(:,:,:,6) = Lss23_er_matriz + (-0.5*erroLms);
V(:,:,:,7) = Lss31_er_matriz + (-0.5*erroLms);
V(:,:,:,8) = Lss32_er_matriz + (-0.5*erroLms);
V(:,:,:,9) = Lss33_er_matriz + (erroLms + erroLls);

% Inserção das matrizes Lrr
V(:,:,:,10) = Lrr11_er_matriz + (erroLmr + erroLlr);
V(:,:,:,11) = Lrr12_er_matriz + (-0.5*erroLmr);
V(:,:,:,12) = Lrr13_er_matriz + (-0.5*erroLmr);
V(:,:,:,13) = Lrr21_er_matriz + (-0.5*erroLmr);
V(:,:,:,14) = Lrr22_er_matriz + (erroLmr + erroLlr);
V(:,:,:,15) = Lrr23_er_matriz + (-0.5*erroLmr);
V(:,:,:,16) = Lrr31_er_matriz + (-0.5*erroLmr);
V(:,:,:,17) = Lrr32_er_matriz + (-0.5*erroLmr);
V(:,:,:,18) = Lrr33_er_matriz + (erroLmr + erroLlr);

% % Inserção das matrizes Lsr
% V(:,:,:,19) = Lsr11_er_matriz;
% V(:,:,:,20) = Lsr12_er_matriz;
% V(:,:,:,21) = Lsr13_er_matriz;
% V(:,:,:,22) = Lsr21_er_matriz;
% V(:,:,:,23) = Lsr22_er_matriz;
% V(:,:,:,24) = Lsr23_er_matriz;
% V(:,:,:,25) = Lsr31_er_matriz;
% V(:,:,:,26) = Lsr32_er_matriz;
% V(:,:,:,27) = Lsr33_er_matriz;
% 
% % Inserção das matrizes Lrs
% V(:,:,:,28) = Lrs11_er_matriz;
% V(:,:,:,29) = Lrs12_er_matriz;
% V(:,:,:,30) = Lrs13_er_matriz;
% V(:,:,:,31) = Lrs21_er_matriz;
% V(:,:,:,32) = Lrs22_er_matriz;
% V(:,:,:,33) = Lrs23_er_matriz;
% V(:,:,:,34) = Lrs31_er_matriz;
% V(:,:,:,35) = Lrs32_er_matriz;
% V(:,:,:,36) = Lrs33_er_matriz;

% Objeto interpolado
F = griddedInterpolant(...
    {ampExc_vetor_mm,angExc_vetor_deg,angRot_vetor_deg},V);

%% Criação da struct 'constantes'

constantes.ampExc_vetor_mm = ampExc_vetor_mm;
constantes.angExc_vetor_deg = angExc_vetor_deg;
constantes.angRot_vetor_deg = angRot_vetor_deg;
constantes.ampExc_tam = ampExc_tam;
constantes.angExc_tam = angExc_tam;
constantes.angRot_tam = angRot_tam;
constantes.we = we;
constantes.p = p;
constantes.J = J;
constantes.Ns = Ns;
constantes.Nr = Nr;
constantes.rs = rs;
constantes.rr = rr;
constantes.Ls = Ls;
constantes.Lr = Lr;
constantes.Lm = Lm;
constantes.Lms = Lms;
constantes.Lmr = Lmr;
constantes.Lmr_linha = Lmr_linha;
constantes.Lls = Lls;
constantes.Llr = Llr;
constantes.Llr_linha = Llr_linha;
constantes.Lsr = Lsr;
constantes.F = F;
constantes.L_saud_modificada = L_saud_modificada;
constantes.Linv_saud_modificada = Linv_saud_modificada;
constantes.deg120 = deg120;
constantes.dt = dt;
constantes.dt_2 = dt_2;
constantes.dt_6 = dt_6;