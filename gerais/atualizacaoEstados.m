function estadosAtual = atualizacaoEstados(constantes, estadosAnterior, ...
    vas, vbs, vcs, er, delta_r, xi, rf, TL)

    %% Inicialização das variáveis

    % Desmembramento das variáveis da struct "constantes"
    we = constantes.we;
    p = constantes.p;
    J = constantes.J;
    Ns = constantes.Ns;
    Nr = constantes.Nr;
    rs = constantes.rs;
    rr = constantes.rr;
    Ls = constantes.Ls;
    Lr = constantes.Lr;
    Lm = constantes.Lm;
    Lms = constantes.Lms;
    Lls = constantes.Lls;
    Lsr = constantes.Lsr;
    L_saud_modificada = constantes.L_saud_modificada;
    deg120 = constantes.deg120;
    dt = constantes.dt;
    dt_2 = constantes.dt_2;
    dt_6 = constantes.dt_6;

    % Desmembramento das variáveis da struct "estadosAnterior"
    lambds = estadosAnterior.lambds;
    lambqs = estadosAnterior.lambqs;
    lambdr = estadosAnterior.lambdr;
    lambqr = estadosAnterior.lambqr;
    lambasf = estadosAnterior.lambasf;
    ids = estadosAnterior.ids;
    iqs = estadosAnterior.iqs;
    idr = estadosAnterior.idr;
    iqr = estadosAnterior.iqr;
    i_f = estadosAnterior.i_f;
    wr = estadosAnterior.wr;
    wmec = estadosAnterior.wmec;
    theta_r = estadosAnterior.theta_r;
    theta_mec = estadosAnterior.theta_mec;
    theta_dq = estadosAnterior.theta_dq;
    
    %% Tensões
    
    vs_dq = (2/3)*...
        [cos(theta_dq) cos(theta_dq-deg120) cos(theta_dq+deg120);...
        -sin(theta_dq) -sin(theta_dq-deg120) -sin(theta_dq+deg120);...
        0.5 0.5 0.5]*[vas; vbs; vcs];
    vds = vs_dq(1);
    vqs = vs_dq(2);
    
    vdr = 0;
    vqr = 0;
    
    %% Indutâncias

    % Inicialização de indutâncias da modelagem
    if er ~= 0
        % Caso haja excentricidade, interpola as indutâncias
        [Lbar_self_s, Ltil_self_s, Lbar_mut_s, Ltil_mut_s, Lbar_ecc_s, ...
            Ltil_ecc_s, Lbar_ecc_r, Ltil_ecc_r, Lf_re, Lf_im] = ...
            interpolacaoIndutancias(constantes, er, delta_r);
    else
        % Caso contrário, zera as indutâncias
        [Lbar_self_s, Ltil_self_s, Lbar_mut_s, Ltil_mut_s, Lbar_ecc_s, ...
            Ltil_ecc_s, Lbar_ecc_r, Ltil_ecc_r, Lf_im] = deal(0);

        if xi ~= 0
            Lf_re = Ls;
        else
            Lf_re = 0;
        end
    end
    
    % Inicialização da indutância L
    if xi == 0 && er == 0
        % Condição da máquina saudável: como L é constantes para este caso,
        % o tempo de simulação pode ser reduzido

        L = L_saud_modificada;
    else
        % Condição da máquina com excentricidade e/ou falha entre espiras

        % Indutâncias de lambasf
        Lss11 = Lls + Lms + Lbar_self_s + Ltil_self_s*cos(2*delta_r);
        Lss12 = -0.5*Lms + Lbar_mut_s + Ltil_mut_s*cos(2*delta_r - deg120);
        Lss13 = -0.5*Lms + Lbar_mut_s + Ltil_mut_s*cos(2*delta_r + deg120);
        Lsr11 = Lsr*cos(theta_r);
        Lsr12 = Lsr*cos(theta_r + deg120);
        Lsr13 = Lsr*cos(theta_r - deg120);

        % Indutância L
        L = [...
            % 1ª linha
            Ls + Lbar_ecc_s + Ltil_ecc_s*cos(2*delta_r - 2*theta_dq),...
            Ltil_ecc_s*sin(2*delta_r - 2*theta_dq),...
            Lm,...
            0,...
            -(2/3)*xi*Lf_re*cos(theta_dq) - (2/3)*xi*Lf_im*sin(theta_dq);...

            % 2ª linha
            Ltil_ecc_s*sin(2*delta_r - 2*theta_dq),...
            Ls + Lbar_ecc_s - Ltil_ecc_s*cos(2*delta_r - 2*theta_dq),...
            0,...
            Lm,...
            (2/3)*xi*Lf_re*sin(theta_dq) - (2/3)*xi*Lf_im*cos(theta_dq);...

            % 3ª linha
            Lm,...
            0,...
            Lr + Lbar_ecc_r + Ltil_ecc_r*cos(2*delta_r - 2*theta_dq),...
            Ltil_ecc_r*sin(2*delta_r - 2*theta_dq),...
            -(2/3)*xi*Lm*cos(theta_dq);...

            % 4ª linha
            0,...
            Lm,...
            Ltil_ecc_r*sin(2*delta_r - 2*theta_dq),...
            Lr + Lbar_ecc_r - Ltil_ecc_r*cos(2*delta_r - 2*theta_dq),...
            (2/3)*xi*Lm*sin(theta_dq);...

            % 5ª linha
            xi*(Lss11*cos(theta_dq) + Lss12*cos(theta_dq - deg120) + Lss13*cos(theta_dq + deg120)),...
            -xi*(Lss11*sin(theta_dq) + Lss12*sin(theta_dq - deg120) + Lss13*sin(theta_dq + deg120)),...
            xi*(Ns/Nr)*(Lsr11*cos(theta_dq - theta_r) + Lsr12*cos(theta_dq - theta_r - deg120) + Lsr13*cos(theta_dq - theta_r + deg120)),...
            -xi*(Ns/Nr)*(Lsr11*sin(theta_dq - theta_r) + Lsr12*sin(theta_dq - theta_r - deg120) + Lsr13*sin(theta_dq - theta_r + deg120)),...
            -xi*Lls - xi^2*(Lss11-Lls)...
            ];

        % Na ausência de falha entre espiras, a 5ª coluna e a 5ª linha são
        % nulas, tornando singular a matriz L. Ao realizar o procedimento a
        % seguir, uma possível inversão da matriz L pode ser feita de forma
        % segura e sem particularização.
        if xi == 0
            L(5,5) = 1;
        end

        if isnan(cond(L))
            error('Matriz L mal condicionada! Simulação abortada.');
        end
    end

    %% Fluxos

    % Explicação gráfica do método de Runge-Kutta de 4ª ordem
    % https://www.youtube.com/watch?v=l8sOUHnPkgw

    % 1º passo de Runge-Kutta:
    d1lambds_dt = vds - rs*ids + we*lambqs + (2/3)*xi*rs*cos(theta_dq)*i_f;
    d1lambqs_dt = vqs - rs*iqs - we*lambds - (2/3)*xi*rs*sin(theta_dq)*i_f;
    d1lambdr_dt = vdr - rr*idr + (we-wr)*lambqr;
    d1lambqr_dt = vqr - rr*iqr - (we-wr)*lambdr;
    d1lambasf_dt = (rf + xi*rs)*i_f + xi*rs*(sin(theta_dq)*iqs - cos(theta_dq)*ids);

    lamb1ds = lambds + d1lambds_dt*dt_2;
    lamb1qs = lambqs + d1lambqs_dt*dt_2;
    lamb1dr = lambdr + d1lambdr_dt*dt_2;
    lamb1qr = lambqr + d1lambqr_dt*dt_2;
    lamb1asf = lambasf + d1lambasf_dt*dt_2;
    lamb1 = [lamb1ds; lamb1qs; lamb1dr; lamb1qr; lamb1asf];

    i1 = L\lamb1; % Recomendado pelo MATLAB para fazer inv(L)*lamb1
    i1ds = i1(1);
    i1qs = i1(2);
    i1dr = i1(3);
    i1qr = i1(4);
    i1_f = i1(5);

    % 2º passo de Kunge-Kutta:
    d2lambds_dt = vds - rs*i1ds + we*lamb1qs + (2/3)*xi*rs*cos(theta_dq)*i1_f;
    d2lambqs_dt = vqs - rs*i1qs - we*lamb1ds - (2/3)*xi*rs*sin(theta_dq)*i1_f;
    d2lambdr_dt = vdr - rr*i1dr + (we-wr)*lamb1qr;
    d2lambqr_dt = vqr - rr*i1qr - (we-wr)*lamb1dr;
    d2lambasf_dt = (rf + xi*rs)*i1_f + xi*rs*(sin(theta_dq)*i1qs - cos(theta_dq)*i1ds);

    lamb2ds = lambds + d2lambds_dt*dt_2;
    lamb2qs = lambqs + d2lambqs_dt*dt_2;
    lamb2dr = lambdr + d2lambdr_dt*dt_2;
    lamb2qr = lambqr + d2lambqr_dt*dt_2;
    lamb2asf = lambasf + d2lambasf_dt*dt_2;
    lamb2 = [lamb2ds; lamb2qs; lamb2dr; lamb2qr; lamb2asf];

    i2 = L\lamb2; % Recomendado pelo MATLAB para fazer inv(L)*lamb2
    i2ds = i2(1);
    i2qs = i2(2);
    i2dr = i2(3);
    i2qr = i2(4);
    i2_f = i2(5);

    % 3º passo de Kunge-Kutta:
    d3lambds_dt = vds - rs*i2ds + we*lamb2qs + (2/3)*xi*rs*cos(theta_dq)*i2_f;
    d3lambqs_dt = vqs - rs*i2qs - we*lamb2ds - (2/3)*xi*rs*sin(theta_dq)*i2_f;
    d3lambdr_dt = vdr - rr*i2dr + (we-wr)*lamb2qr;
    d3lambqr_dt = vqr - rr*i2qr - (we-wr)*lamb2dr;
    d3lambasf_dt = (rf + xi*rs)*i2_f + xi*rs*(sin(theta_dq)*i2qs - cos(theta_dq)*i2ds);

    lamb3ds = lambds + d3lambds_dt*dt;
    lamb3qs = lambqs + d3lambqs_dt*dt;
    lamb3dr = lambdr + d3lambdr_dt*dt;
    lamb3qr = lambqr + d3lambqr_dt*dt;
    lamb3asf = lambasf + d3lambasf_dt*dt;
    lamb3 = [lamb3ds; lamb3qs; lamb3dr; lamb3qr; lamb3asf];

    i3 = L\lamb3; % Recomendado pelo MATLAB para fazer inv(L)*lamb3
    i3ds = i3(1);
    i3qs = i3(2);
    i3dr = i3(3);
    i3qr = i3(4);
    i3_f = i3(5);

    % 4º passo de Kunge-Kutta:
    d4lambds_dt = vds - rs*i3ds + we*lamb3qs + (2/3)*xi*rs*cos(theta_dq)*i3_f;
    d4lambqs_dt = vqs - rs*i3qs - we*lamb3ds - (2/3)*xi*rs*sin(theta_dq)*i3_f;
    d4lambdr_dt = vdr - rr*i3dr + (we-wr)*lamb3qr;
    d4lambqr_dt = vqr - rr*i3qr - (we-wr)*lamb3dr;
    d4lambasf_dt = (rf + xi*rs)*i3_f + xi*rs*(sin(theta_dq)*i3qs + cos(theta_dq)*i3ds);

    % Finalização do método de estimação
    lambds = lambds + ...
        (d1lambds_dt + 2*d2lambds_dt + 2*d3lambds_dt + d4lambds_dt)*dt_6;
    lambqs = lambqs + ...
        (d1lambqs_dt + 2*d2lambqs_dt + 2*d3lambqs_dt + d4lambqs_dt)*dt_6;
    lambdr = lambdr + ...
        (d1lambdr_dt + 2*d2lambdr_dt + 2*d3lambdr_dt + d4lambdr_dt)*dt_6;
    lambqr = lambqr + ...
        (d1lambqr_dt + 2*d2lambqr_dt + 2*d3lambqr_dt + d4lambqr_dt)*dt_6;
    lambasf = lambasf + ...
        (d1lambasf_dt + 2*d2lambasf_dt + 2*d3lambasf_dt + d4lambasf_dt)*dt_6;
    lamb = [lambds; lambqs; lambdr; lambqr; lambasf];

    %% Correntes

    % Correntes de estator e rotor em dq
    i_dq = L\lamb; % Recomendado pelo MATLAB para fazer inv(L)*lamb
    ids = i_dq(1);
    iqs = i_dq(2);
    idr = i_dq(3);
    iqr = i_dq(4);

    % Corrente de falha em abc e dq
    i_f = i_dq(5);
    idf = (2/3)*cos(theta_dq)*i_f;
    iqf = -(2/3)*sin(theta_dq)*i_f;

    % Correntes de estator em abc
    is_abc = [cos(theta_dq) -sin(theta_dq) 1;...
              cos(theta_dq-deg120) -sin(theta_dq-deg120) 1;...
              cos(theta_dq+deg120) -sin(theta_dq+deg120) 1]*...
             [ids; iqs; 0];
    ias = is_abc(1);
    ibs = is_abc(2);
    ics = is_abc(3);

    % Correntes de rotor em abc (medidas no estator)
    ir_abc = [cos(theta_dq-theta_r) -sin(theta_dq-theta_r) 1;...
              cos(theta_dq-theta_r-deg120) -sin(theta_dq-theta_r-deg120) 1;...
              cos(theta_dq-theta_r+deg120) -sin(theta_dq-theta_r+deg120) 1]*...
             [idr; iqr; 0];
    iar = ir_abc(1);
    ibr = ir_abc(2);
    icr = ir_abc(3);

    %% Variáveis mecânicas

    % Potência mecânica
    Pmec_h = (3/2)*wr*Lm*(idr*iqs - iqr*ids);
    Pmec_f1 = (3/2)*we*Ltil_ecc_s*(...
        sin(2*delta_r - 2*theta_dq)*(ids^2 - iqs^2) - ...
        cos(2*delta_r - 2*theta_dq)*(2*ids*iqs));
    Pmec_f2 = (3/2)*(we + wr)*Ltil_ecc_r*(...
        sin(2*delta_r - 2*theta_dq)*(idr^2 - iqr^2) - ...
        cos(2*delta_r - 2*theta_dq)*(2*idr*iqr));
    Pmec_f3 = xi*we*Lf_re*(sin(theta_dq)*ids + cos(theta_dq)*iqs)*(-i_f);
    Pmec_f4 = xi*(we*Lf_im - rs)*(sin(theta_dq)*iqs - cos(theta_dq)*ids)*(-i_f);
    Pmec_f5 = xi*(we - wr)*Lm*(sin(theta_dq)*idr + cos(theta_dq)*iqr)*(-i_f);
    Pmec = Pmec_h + Pmec_f1 + Pmec_f2 + Pmec_f3 + Pmec_f4 + Pmec_f5;

    % Torque eletromagnético
    Te = Pmec/((2/p)*wr);

    % Aceleração, velocidade e posição mecânica do rotor
    dwmec_dt = (Te - TL)/J;
    wmec = wmec + dwmec_dt*dt;
    theta_mec = theta_mec + wmec*dt;

    % Velocidade e posição elétrica do rotor
    wr = (p/2)*wmec;
    theta_r = (p/2)*theta_mec;

    %% Fluxos (determinação do ângulo de excentricidade dinâmica)

    % Fluxos de estator no referencial de Clarke
    lambs_alpha_beta = [cos(theta_dq) -sin(theta_dq);...
                        sin(theta_dq) cos(theta_dq)]*...
                       [lambds; lambqs];
    lambs_alpha = lambs_alpha_beta(1);
    lambs_beta = lambs_alpha_beta(2);
    lambs_alpha_beta_mod = abs(lambs_alpha + 1i*lambs_beta);
    lambs_alpha_beta_ang = angle(lambs_alpha + 1i*lambs_beta);

    % Fluxos de rotor no referencial de Clarke (girar apenas por theta_dq)
    lambr_alpha_beta = [cos(theta_dq) -sin(theta_dq);...
                        sin(theta_dq) cos(theta_dq)]*...
                       [lambdr; lambqr];
    lambr_alpha = lambr_alpha_beta(1);
    lambr_beta = lambr_alpha_beta(2);
    lambr_alpha_beta_mod = abs(lambr_alpha + 1i*lambr_beta);
    lambr_alpha_beta_ang = angle(lambr_alpha + 1i*lambr_beta);

    % Fluxos resultante no entreferro no referencial de Clarke (fluxo em
    % comum no estator e no rotor, ou seja, apenas elementos em comum de
    % lambs_dq e lambr_dq)
    lambgap_dq = Lm*((ids+idr) + 1i*(iqs+iqr)) - xi*Lm*(idf + 1i*iqf);
    lambgap_alpha_beta = [cos(theta_dq) -sin(theta_dq);...
                          sin(theta_dq) cos(theta_dq)]*...
                         [real(lambgap_dq); imag(lambgap_dq)];
    lambgap_alpha = lambgap_alpha_beta(1);
    lambgap_beta = lambgap_alpha_beta(2);
    lambgap_alpha_beta_mod = abs(lambgap_alpha + 1i*lambgap_beta);
    lambgap_alpha_beta_ang = angle(lambgap_alpha + 1i*lambgap_beta);

    %% Criação da struct "estadosAtual"

    estadosAtual.vds = vds;
    estadosAtual.vqs = vqs;
    estadosAtual.vdr = vdr;
    estadosAtual.vqr = vqr;
    estadosAtual.lambds = lambds;
    estadosAtual.lambqs = lambqs;
    estadosAtual.lambdr = lambdr;
    estadosAtual.lambqr = lambqr;
    estadosAtual.lambasf = lambasf;
    estadosAtual.lambs_alpha = lambs_alpha;
    estadosAtual.lambs_beta = lambs_beta;
    estadosAtual.lambs_alpha_beta_mod = lambs_alpha_beta_mod;
    estadosAtual.lambs_alpha_beta_ang = lambs_alpha_beta_ang;
    estadosAtual.lambr_alpha = lambr_alpha;
    estadosAtual.lambr_beta = lambr_beta;
    estadosAtual.lambr_alpha_beta_mod = lambr_alpha_beta_mod;
    estadosAtual.lambr_alpha_beta_ang = lambr_alpha_beta_ang;
    estadosAtual.lambgap_alpha = lambgap_alpha;
    estadosAtual.lambgap_beta = lambgap_beta;
    estadosAtual.lambgap_alpha_beta_mod = lambgap_alpha_beta_mod;
    estadosAtual.lambgap_alpha_beta_ang = lambgap_alpha_beta_ang;
    estadosAtual.ids = ids;
    estadosAtual.iqs = iqs;
    estadosAtual.idr = idr;
    estadosAtual.iqr = iqr;
    estadosAtual.i_f = i_f;
    estadosAtual.idf = idf;
    estadosAtual.iqf = iqf;
    estadosAtual.ias = ias;
    estadosAtual.ibs = ibs;
    estadosAtual.ics = ics;
    estadosAtual.iar = iar;
    estadosAtual.ibr = ibr;
    estadosAtual.icr = icr;
    estadosAtual.Pmec = Pmec;
    estadosAtual.Te = Te;
    estadosAtual.wmec = wmec;
    estadosAtual.theta_mec = theta_mec;
    estadosAtual.wr = wr;
    estadosAtual.theta_r = theta_r;

end