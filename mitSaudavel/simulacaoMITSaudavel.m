% Informações: O código está configurado para dar partida na MIT saudável e
% variar carga em degrau

%% Inicialização das variáveis

% Vetores de dados
vas_saud = zeros(1,tamVetor);
vbs_saud = zeros(1,tamVetor);
vcs_saud = zeros(1,tamVetor);
vasf_saud = zeros(1,tamVetor);
vds_saud = zeros(1,tamVetor);
vqs_saud = zeros(1,tamVetor);
vdr_saud = zeros(1,tamVetor);
vqr_saud = zeros(1,tamVetor);
lambds_saud = zeros(1,tamVetor);
lambqs_saud = zeros(1,tamVetor);
lambdr_saud = zeros(1,tamVetor);
lambqr_saud = zeros(1,tamVetor);
lambasf_saud = zeros(1,tamVetor);
lambs_alpha_saud = zeros(1,tamVetor);
lambs_beta_saud = zeros(1,tamVetor);
lambs_alpha_beta_mod_saud = zeros(1,tamVetor);
lambs_alpha_beta_ang_saud = zeros(1,tamVetor);
lambr_alpha_saud = zeros(1,tamVetor);
lambr_beta_saud = zeros(1,tamVetor);
lambr_alpha_beta_mod_saud = zeros(1,tamVetor);
lambr_alpha_beta_ang_saud = zeros(1,tamVetor);
lambgap_alpha_saud = zeros(1,tamVetor);
lambgap_beta_saud = zeros(1,tamVetor);
lambgap_alpha_beta_mod_saud = zeros(1,tamVetor);
lambgap_alpha_beta_ang_saud = zeros(1,tamVetor);
is_dq_saud = zeros(1,tamVetor);
ids_saud = zeros(1,tamVetor);
iqs_saud = zeros(1,tamVetor);
idr_saud = zeros(1,tamVetor);
iqr_saud = zeros(1,tamVetor);
if_saud = zeros(1,tamVetor);
idf_saud = zeros(1,tamVetor);
iqf_saud = zeros(1,tamVetor);
ias_saud = zeros(1,tamVetor);
ibs_saud = zeros(1,tamVetor);
ics_saud = zeros(1,tamVetor);
iar_saud = zeros(1,tamVetor);
ibr_saud = zeros(1,tamVetor);
icr_saud = zeros(1,tamVetor);
Pmec_saud = zeros(1,tamVetor);
Te_saud = zeros(1,tamVetor);
TL_saud = zeros(1,tamVetor);
wmec_saud = zeros(1,tamVetor);
nmec_saud = zeros(1,tamVetor);
theta_mec_saud = zeros(1,tamVetor);
wr_saud = zeros(1,tamVetor);
theta_r_saud = zeros(1,tamVetor);
theta_dq_saud = zeros(1,tamVetor);

% Não há falhas
xi = 0;
rf = rf_inf;
est = 0;
ed = 0;
er = sqrt(est^2 + ed^2 - 2*est*ed*cos(pi + delta_st - delta_d));
delta_r = atan2(est*sin(delta_st)+ed*sin(delta_d), ...
    est*cos(delta_st)+ed*cos(delta_d));

%% Loop de simulação

for t = tInicial:dt:tFinal
    
    %% Tensões de estator
    
    vas = Vmax*cos(we*t);
    vbs = Vmax*cos(we*t-deg120);
    vcs = Vmax*cos(we*t+deg120);

    %% Carga mecânica

    if t >= tEntraCarga && t < tSaiCarga
        TL = TL_ref;
    else
        TL = 0;
    end

    %% Atualização dos estados

    % Inicialização da struct "estadosAnterior"
    estadosAnterior.lambds = lambds;
    estadosAnterior.lambqs = lambqs;
    estadosAnterior.lambdr = lambdr;
    estadosAnterior.lambqr = lambqr;
    estadosAnterior.lambasf = lambasf;
    estadosAnterior.ids = ids;
    estadosAnterior.iqs = iqs;
    estadosAnterior.idr = idr;
    estadosAnterior.iqr = iqr;
    estadosAnterior.i_f = i_f;
    estadosAnterior.wr = wr;
    estadosAnterior.wmec = wmec;
    estadosAnterior.theta_r = theta_r;
    estadosAnterior.theta_mec = theta_mec;
    estadosAnterior.theta_dq = theta_dq;

    % Faz efetivamente a simulação dimânica da máquina
    estadosAtual = atualizacaoEstados(constantes, estadosAnterior, ...
        vas, vbs, vcs, er, delta_r, xi, rf, TL);

    % Desmembramento das variáveis da struct "estadosAtual"
    vds = estadosAtual.vds;
    vqs = estadosAtual.vqs;
    vdr = estadosAtual.vdr;
    vqr = estadosAtual.vqr;
    lambds = estadosAtual.lambds;
    lambqs = estadosAtual.lambqs;
    lambdr = estadosAtual.lambdr;
    lambqr = estadosAtual.lambqr;
    lambasf = estadosAtual.lambasf;
    lambs_alpha = estadosAtual.lambs_alpha;
    lambs_beta = estadosAtual.lambs_beta;
    lambs_alpha_beta_mod = estadosAtual.lambs_alpha_beta_mod;
    lambs_alpha_beta_ang = estadosAtual.lambs_alpha_beta_ang;
    lambr_alpha = estadosAtual.lambr_alpha;
    lambr_beta = estadosAtual.lambr_beta;
    lambr_alpha_beta_mod = estadosAtual.lambr_alpha_beta_mod;
    lambr_alpha_beta_ang = estadosAtual.lambr_alpha_beta_ang;
    lambgap_alpha = estadosAtual.lambgap_alpha;
    lambgap_beta = estadosAtual.lambgap_beta;
    lambgap_alpha_beta_mod = estadosAtual.lambgap_alpha_beta_mod;
    lambgap_alpha_beta_ang = estadosAtual.lambgap_alpha_beta_ang;
    ids = estadosAtual.ids;
    iqs = estadosAtual.iqs;
    idr = estadosAtual.idr;
    iqr = estadosAtual.iqr;
    i_f = estadosAtual.i_f;
    idf = estadosAtual.idf;
    iqf = estadosAtual.iqf;
    ias = estadosAtual.ias;
    ibs = estadosAtual.ibs;
    ics = estadosAtual.ics;
    iar = estadosAtual.iar;
    ibr = estadosAtual.ibr;
    icr = estadosAtual.icr;
    Pmec = estadosAtual.Pmec;
    Te = estadosAtual.Te;
    wmec = estadosAtual.wmec;
    theta_mec = estadosAtual.theta_mec;
    wr = estadosAtual.wr;
    theta_r = estadosAtual.theta_r;

    %% Decimação dos pontos calculados

    if decimador == nPontosDecimacao
        vas_saud(k) = vas;
        vbs_saud(k) = vbs;
        vcs_saud(k) = vcs;
        vasf_saud(k) = rf*i_f;
        vds_saud(k) = vds;
        vqs_saud(k) = vqs;
        vdr_saud(k) = vdr;
        vqr_saud(k) = vqr;
        lambds_saud(k) = lambds;
        lambqs_saud(k) = lambqs;
        lambdr_saud(k) = lambdr;
        lambqr_saud(k) = lambqr;
        lambasf_saud(k) = lambasf;
        lambs_alpha_saud(k) = lambs_alpha;
        lambs_beta_saud(k) = lambs_beta;
        lambs_alpha_beta_mod_saud(k) = lambs_alpha_beta_mod;
        lambs_alpha_beta_ang_saud(k) = lambs_alpha_beta_ang;
        lambr_alpha_saud(k) = lambr_alpha;
        lambr_beta_saud(k) = lambr_beta;
        lambr_alpha_beta_mod_saud(k) = lambr_alpha_beta_mod;
        lambr_alpha_beta_ang_saud(k) = lambr_alpha_beta_ang;
        lambgap_alpha_saud(k) = lambgap_alpha;
        lambgap_beta_saud(k) = lambgap_beta;
        lambgap_alpha_beta_mod_saud(k) = lambgap_alpha_beta_mod;
        lambgap_alpha_beta_ang_saud(k) = lambgap_alpha_beta_ang;
        is_dq_saud(k) = sqrt(ids^2+iqs^2)*sqrt(3)/sqrt(2);
        ids_saud(k) = ids;
        iqs_saud(k) = iqs;
        idr_saud(k) = idr;
        iqr_saud(k) = iqr;
        if_saud(k) = i_f;
        idf_saud(k) = idf;
        iqf_saud(k) = iqf;
        ias_saud(k) = ias;
        ibs_saud(k) = ibs;
        ics_saud(k) = ics;
        iar_saud(k) = iar;
        ibr_saud(k) = ibr;
        icr_saud(k) = icr;
        Pmec_saud(k) = Pmec;
        Te_saud(k) = Te;
        TL_saud(k) = TL;
        wmec_saud(k) = wmec;
        nmec_saud(k) = wmec*30/pi;
        theta_mec_saud(k) = theta_mec;
        wr_saud(k) = wr;
        theta_r_saud(k) = theta_r;
        theta_dq_saud(k) = theta_dq;

        % Prepara os parâmetros para a próxima decimação
        decimador = 0;
        k = k + 1;
    end
    
    % Prepara os parâmetros para o próximo passo de tempo
    decimador = decimador + 1;
    theta_dq = theta_dq + we*dt;
    %delta_d = lambs_alpha_beta_ang;
    delta_d = lambgap_alpha_beta_ang;
end