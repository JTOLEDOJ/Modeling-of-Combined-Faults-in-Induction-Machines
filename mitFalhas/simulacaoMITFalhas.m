% Informações: O código está configurado para dar partida na MIT saudável,
% inserir carga em degrau, acrescentar primeiro excentricidade estática e
% depois dinâmica, acrescentar falha entre espiras e remover carga

%% Inicialização das variáveis

% Vetores de dados
vas_falhas = zeros(1,tamVetor);
vbs_falhas = zeros(1,tamVetor);
vcs_falhas = zeros(1,tamVetor);
vasf_falhas = zeros(1,tamVetor);
vds_falhas = zeros(1,tamVetor);
vqs_falhas = zeros(1,tamVetor);
vdr_falhas = zeros(1,tamVetor);
vqr_falhas = zeros(1,tamVetor);
lambds_falhas = zeros(1,tamVetor);
lambqs_falhas = zeros(1,tamVetor);
lambdr_falhas = zeros(1,tamVetor);
lambqr_falhas = zeros(1,tamVetor);
lambasf_falhas = zeros(1,tamVetor);
lambs_alpha_falhas = zeros(1,tamVetor);
lambs_beta_falhas = zeros(1,tamVetor);
lambs_alpha_beta_mod_falhas = zeros(1,tamVetor);
lambs_alpha_beta_ang_falhas = zeros(1,tamVetor);
lambr_alpha_falhas = zeros(1,tamVetor);
lambr_beta_falhas = zeros(1,tamVetor);
lambr_alpha_beta_mod_falhas = zeros(1,tamVetor);
lambr_alpha_beta_ang_falhas = zeros(1,tamVetor);
lambgap_alpha_falhas = zeros(1,tamVetor);
lambgap_beta_falhas = zeros(1,tamVetor);
lambgap_alpha_beta_mod_falhas = zeros(1,tamVetor);
lambgap_alpha_beta_ang_falhas = zeros(1,tamVetor);
is_dq_falhas = zeros(1,tamVetor);
ids_falhas = zeros(1,tamVetor);
iqs_falhas = zeros(1,tamVetor);
idr_falhas = zeros(1,tamVetor);
iqr_falhas = zeros(1,tamVetor);
if_falhas = zeros(1,tamVetor);
idf_falhas = zeros(1,tamVetor);
iqf_falhas = zeros(1,tamVetor);
ias_falhas = zeros(1,tamVetor);
ibs_falhas = zeros(1,tamVetor);
ics_falhas = zeros(1,tamVetor);
iar_falhas = zeros(1,tamVetor);
ibr_falhas = zeros(1,tamVetor);
icr_falhas = zeros(1,tamVetor);
Pmec_falhas = zeros(1,tamVetor);
Te_falhas = zeros(1,tamVetor);
TL_falhas = zeros(1,tamVetor);
wmec_falhas = zeros(1,tamVetor);
nmec_falhas = zeros(1,tamVetor);
theta_mec_falhas = zeros(1,tamVetor);
wr_falhas = zeros(1,tamVetor);
theta_r_falhas = zeros(1,tamVetor);
theta_dq_falhas = zeros(1,tamVetor);
xi_falhas = zeros(1,tamVetor);
rf_falhas = zeros(1,tamVetor);
est_falhas = zeros(1,tamVetor);
delta_st_falhas = zeros(1,tamVetor);
ed_falhas = zeros(1,tamVetor);
delta_d_falhas = zeros(1,tamVetor);
er_falhas = zeros(1,tamVetor);
delta_r_falhas = zeros(1,tamVetor);

% Outros
tEfetivoEntraEd_falhas = NaN;

%% Loop de simulação

for t = tInicial:dt:tFinal
    
    %% Tensões de estator
    
    vas = Vmax*cos(we*t);
    vbs = Vmax*cos(we*t-deg120);
    vcs = Vmax*cos(we*t+deg120);

    %% Curto-circuito entre espiras

    % Verificar se está no intervalo de curto
    if t >= tEntraCurto && t < tSaiCurto
        % Descobrir qual intervalo de curto a simulação está
        idx_curto = find(t < tAcumulativoCurto(2:end), 1, 'first');

        % Atualizar os valores de xi e rf de acordo com o índice
        xi = xi_ref(idx_curto);
        rf = rf_ref(idx_curto);
    else
        % Máquina saudável
        xi = 0;
        rf = rf_inf;
    end

    %% Excentricidade mecânica

    % Estática
    if t >= tEntraEst && t < tSaiEst
        est = est_ref;
    else
        est = 0;
    end

    % Dinâmica
    % Ponto de melhoria: a entrada é suave, mas a saída ainda é abrupta
    if t >= tEntraEd && t < tSaiEd && entrouEd == false && ...
            abs(delta_d - delta_st) < erroMaxSincEd
        % Garante sincronismo de delta_d com delta_st
        entrouEd = true;
        tEfetivoEntraEd_falhas = t;
        erroEfetivoSincEd_falhas = abs(delta_d - delta_st);
        ed = taxaCrescEd;
    elseif t >= tEntraEd && t < tSaiEd && entrouEd == true
        % Garante que a excentricidade não seja colocada de forma abrupta
        if ed < ed_ref
            ed = ed + taxaCrescEd;
        else
            ed = ed_ref;
        end
    else
        ed = 0;
    end

    % Resultante
    er = sqrt(est^2 + ed^2 - 2*est*ed*cos(pi + delta_st - delta_d));
    delta_r = atan2(est*sin(delta_st)+ed*sin(delta_d), ...
        est*cos(delta_st)+ed*cos(delta_d));

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
        vas_falhas(k) = vas;
        vbs_falhas(k) = vbs;
        vcs_falhas(k) = vcs;
        vasf_falhas(k) = rf*i_f;
        vds_falhas(k) = vds;
        vqs_falhas(k) = vqs;
        vdr_falhas(k) = vdr;
        vqr_falhas(k) = vqr;
        lambds_falhas(k) = lambds;
        lambqs_falhas(k) = lambqs;
        lambdr_falhas(k) = lambdr;
        lambqr_falhas(k) = lambqr;
        lambasf_falhas(k) = lambasf;
        lambs_alpha_falhas(k) = lambs_alpha;
        lambs_beta_falhas(k) = lambs_beta;
        lambs_alpha_beta_mod_falhas(k) = lambs_alpha_beta_mod;
        lambs_alpha_beta_ang_falhas(k) = lambs_alpha_beta_ang;
        lambr_alpha_falhas(k) = lambr_alpha;
        lambr_beta_falhas(k) = lambr_beta;
        lambr_alpha_beta_mod_falhas(k) = lambr_alpha_beta_mod;
        lambr_alpha_beta_ang_falhas(k) = lambr_alpha_beta_ang;
        lambgap_alpha_falhas(k) = lambgap_alpha;
        lambgap_beta_falhas(k) = lambgap_beta;
        lambgap_alpha_beta_mod_falhas(k) = lambgap_alpha_beta_mod;
        lambgap_alpha_beta_ang_falhas(k) = lambgap_alpha_beta_ang;
        is_dq_falhas(k) = sqrt(ids^2+iqs^2)*sqrt(3)/sqrt(2);
        ids_falhas(k) = ids;
        iqs_falhas(k) = iqs;
        idr_falhas(k) = idr;
        iqr_falhas(k) = iqr;
        if_falhas(k) = i_f;
        idf_falhas(k) = idf;
        iqf_falhas(k) = iqf;
        ias_falhas(k) = ias;
        ibs_falhas(k) = ibs;
        ics_falhas(k) = ics;
        iar_falhas(k) = iar;
        ibr_falhas(k) = ibr;
        icr_falhas(k) = icr;
        Pmec_falhas(k) = Pmec;
        Te_falhas(k) = Te;
        TL_falhas(k) = TL;
        wmec_falhas(k) = wmec;
        nmec_falhas(k) = wmec*30/pi;
        theta_mec_falhas(k) = theta_mec;
        wr_falhas(k) = wr;
        theta_r_falhas(k) = theta_r;
        theta_dq_falhas(k) = theta_dq;
        xi_falhas(k) = xi;
        rf_falhas(k) = rf;
        est_falhas(k) = est;
        delta_st_falhas(k) = delta_st;
        ed_falhas(k) = ed;
        delta_d_falhas(k) = delta_d;
        er_falhas(k) = er;
        delta_r_falhas(k) = delta_r;

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