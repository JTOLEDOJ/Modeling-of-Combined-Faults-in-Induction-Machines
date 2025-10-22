function [Lbar_self_s, Ltil_self_s, Lbar_mut_s, Ltil_mut_s, Lbar_ecc_s, ...
    Ltil_ecc_s, Lbar_ecc_r, Ltil_ecc_r, Lf_re, Lf_im] = ...
    interpolacaoIndutancias(constantes, er, delta_r)
    
    %% Inicialização das variáveis
    
    % Desmembramento das variáveis da struct "constantes" para uso local
    angExc_vetor_deg = constantes.angExc_vetor_deg;
    angRot_vetor_deg = constantes.angRot_vetor_deg;
    angExc_tam = constantes.angExc_tam;
    angRot_tam = constantes.angRot_tam;
    Ns = constantes.Ns;
    Nr = constantes.Nr;
    Ls = constantes.Ls;
    Lms = constantes.Lms;
    Lls = constantes.Lls;
    Lmr_linha = constantes.Lmr_linha;
    Llr_linha = constantes.Llr_linha;
    F = constantes.F;
    
    % Declaração dos vetores
    Lss11_ed_vetor = zeros(1,angExc_tam);
    Lss12_ed_vetor = zeros(1,angExc_tam);
    Lss13_ed_vetor = zeros(1,angExc_tam);
    Lss21_ed_vetor = zeros(1,angExc_tam);
    Lss22_ed_vetor = zeros(1,angExc_tam);
    Lss23_ed_vetor = zeros(1,angExc_tam);
    Lss31_ed_vetor = zeros(1,angExc_tam);
    Lss32_ed_vetor = zeros(1,angExc_tam);
    Lss33_ed_vetor = zeros(1,angExc_tam);
    Lrr11_est_vetor = zeros(1,angRot_tam);
    Lrr12_est_vetor = zeros(1,angRot_tam);
    Lrr13_est_vetor = zeros(1,angRot_tam);
    Lrr21_est_vetor = zeros(1,angRot_tam);
    Lrr22_est_vetor = zeros(1,angRot_tam);
    Lrr23_est_vetor = zeros(1,angRot_tam);
    Lrr31_est_vetor = zeros(1,angRot_tam);
    Lrr32_est_vetor = zeros(1,angRot_tam);
    Lrr33_est_vetor = zeros(1,angRot_tam);
    
    % Outros
    ampExc_mm = er;
    
    %% Indutâncias da máquina excêntrica em função de delta_r
    
    % Definição das (angExc_tam-1)/2 primeiras indutâncias
    j = 1; angRot_deg = 0;
    for angExc_deg = angExc_vetor_deg(1:(angExc_tam-1)/2)
        % Interpolação pela função F(), obtida de griddedInterpolant()
        interpolacoes = F(ampExc_mm,angExc_deg,angRot_deg);
    
        % Preenchimento dos vetores
        Lss11_ed_vetor(j) = interpolacoes(1);
        Lss12_ed_vetor(j) = interpolacoes(2);
        Lss13_ed_vetor(j) = interpolacoes(3);
        Lss21_ed_vetor(j) = interpolacoes(4);
        Lss22_ed_vetor(j) = interpolacoes(5);
        Lss23_ed_vetor(j) = interpolacoes(6);
        Lss31_ed_vetor(j) = interpolacoes(7);
        Lss32_ed_vetor(j) = interpolacoes(8);
        Lss33_ed_vetor(j) = interpolacoes(9);
    
        % Prepara para o próximo passo
        j = j + 1;
    end
    
    % Definição das indutâncias restantes (por simetria)
    j = 1;
    for angExc_deg = angExc_vetor_deg(1:(angExc_tam-1)/2)
        % Definição das (angExc_tam-1)/2 indutâncias seguintes
        Lss11_ed_vetor(j+(angExc_tam-1)/2) = Lss11_ed_vetor(j);
        Lss12_ed_vetor(j+(angExc_tam-1)/2) = Lss12_ed_vetor(j);
        Lss13_ed_vetor(j+(angExc_tam-1)/2) = Lss13_ed_vetor(j);
        Lss21_ed_vetor(j+(angExc_tam-1)/2) = Lss21_ed_vetor(j);
        Lss22_ed_vetor(j+(angExc_tam-1)/2) = Lss22_ed_vetor(j);
        Lss23_ed_vetor(j+(angExc_tam-1)/2) = Lss23_ed_vetor(j);
        Lss31_ed_vetor(j+(angExc_tam-1)/2) = Lss31_ed_vetor(j);
        Lss32_ed_vetor(j+(angExc_tam-1)/2) = Lss32_ed_vetor(j);
        Lss33_ed_vetor(j+(angExc_tam-1)/2) = Lss33_ed_vetor(j);
    
        % Definição da última indutância
        if j == 1
            Lss11_ed_vetor(angExc_tam) = Lss11_ed_vetor(j);
            Lss12_ed_vetor(angExc_tam) = Lss12_ed_vetor(j);
            Lss13_ed_vetor(angExc_tam) = Lss13_ed_vetor(j);
            Lss21_ed_vetor(angExc_tam) = Lss21_ed_vetor(j);
            Lss22_ed_vetor(angExc_tam) = Lss22_ed_vetor(j);
            Lss23_ed_vetor(angExc_tam) = Lss23_ed_vetor(j);
            Lss31_ed_vetor(angExc_tam) = Lss31_ed_vetor(j);
            Lss32_ed_vetor(angExc_tam) = Lss32_ed_vetor(j);
            Lss33_ed_vetor(angExc_tam) = Lss33_ed_vetor(j);
        end
    
        % Prepara para o próximo passo
        j = j + 1;
    end
    
    % Matriz Lss (elementos da diagonal principal)
    Lss_self_ed_max = mean([max(Lss11_ed_vetor),max(Lss22_ed_vetor),...
        max(Lss33_ed_vetor)]);
    Lss_self_ed_min = mean([min(Lss11_ed_vetor),min(Lss22_ed_vetor),...
        min(Lss33_ed_vetor)]);
    Lss_self_ed_media = mean([Lss_self_ed_max,Lss_self_ed_min]);
    Lbar_self_s = Lss_self_ed_media - (Lms + Lls);
    Ltil_self_s = abs(Lss_self_ed_max - Lss_self_ed_media);
    
    % Matriz Lss (elementos fora da diagonal principal)
    Lss_mutua_ed_max = mean([...
        max(Lss12_ed_vetor),max(Lss13_ed_vetor),max(Lss21_ed_vetor),...
        max(Lss23_ed_vetor),max(Lss31_ed_vetor),max(Lss32_ed_vetor)]);
    Lss_mutua_ed_min = mean([...
        min(Lss12_ed_vetor),min(Lss13_ed_vetor),min(Lss21_ed_vetor),...
        min(Lss23_ed_vetor),min(Lss31_ed_vetor),min(Lss32_ed_vetor)]);
    Lss_mutua_ed_media = mean([Lss_mutua_ed_max,Lss_mutua_ed_min]);
    Lbar_mut_s = Lss_mutua_ed_media - (-Lms/2);
    Ltil_mut_s = abs(Lss_mutua_ed_max - Lss_mutua_ed_media);
    
    %% Indutâncias da máquina excêntrica em função de theta_r
    
    % Definição das (angRot_tam-1)/2 primeiras indutâncias
    k = 1; angExc_deg = rad2deg(delta_r);
    for angRot_deg = angRot_vetor_deg(1:(angRot_tam-1)/2)
        % Interpolação pela função F(), obtida de griddedInterpolant()
        interpolacoes = F(ampExc_mm,angExc_deg,angRot_deg);
    
        % Preenchimento dos vetores
        Lrr11_est_vetor(k) = interpolacoes(10);
        Lrr12_est_vetor(k) = interpolacoes(11);
        Lrr13_est_vetor(k) = interpolacoes(12);
        Lrr21_est_vetor(k) = interpolacoes(13);
        Lrr22_est_vetor(k) = interpolacoes(14);
        Lrr23_est_vetor(k) = interpolacoes(15);
        Lrr31_est_vetor(k) = interpolacoes(16);
        Lrr32_est_vetor(k) = interpolacoes(17);
        Lrr33_est_vetor(k) = interpolacoes(18);
    
        % Prepara para o próximo passo
        k = k + 1;
    end
    
    % Definição das indutâncias restantes (por simetria)
    k = 1;
    for angRot_deg = angRot_vetor_deg(1:(angRot_tam-1)/2)
        % Definição das (angRot_tam-1)/2 indutâncias seguintes
        Lrr11_est_vetor(k+(angRot_tam-1)/2) = Lrr11_est_vetor(k);
        Lrr12_est_vetor(k+(angRot_tam-1)/2) = Lrr12_est_vetor(k);
        Lrr13_est_vetor(k+(angRot_tam-1)/2) = Lrr13_est_vetor(k);
        Lrr21_est_vetor(k+(angRot_tam-1)/2) = Lrr21_est_vetor(k);
        Lrr22_est_vetor(k+(angRot_tam-1)/2) = Lrr22_est_vetor(k);
        Lrr23_est_vetor(k+(angRot_tam-1)/2) = Lrr23_est_vetor(k);
        Lrr31_est_vetor(k+(angRot_tam-1)/2) = Lrr31_est_vetor(k);
        Lrr32_est_vetor(k+(angRot_tam-1)/2) = Lrr32_est_vetor(k);
        Lrr33_est_vetor(k+(angRot_tam-1)/2) = Lrr33_est_vetor(k);
    
        % Definição da última indutância
        if k == 1
            Lrr11_est_vetor(angRot_tam) = Lrr11_est_vetor(k);
            Lrr12_est_vetor(angRot_tam) = Lrr12_est_vetor(k);
            Lrr13_est_vetor(angRot_tam) = Lrr13_est_vetor(k);
            Lrr21_est_vetor(angRot_tam) = Lrr21_est_vetor(k);
            Lrr22_est_vetor(angRot_tam) = Lrr22_est_vetor(k);
            Lrr23_est_vetor(angRot_tam) = Lrr23_est_vetor(k);
            Lrr31_est_vetor(angRot_tam) = Lrr31_est_vetor(k);
            Lrr32_est_vetor(angRot_tam) = Lrr32_est_vetor(k);
            Lrr33_est_vetor(angRot_tam) = Lrr33_est_vetor(k);
        end
    
        % Prepara para o próximo passo
        k = k + 1;
    end
    
    % Matriz Lrr (elementos da diagonal principal)
    Lrr_self_est_max = mean([max(Lrr11_est_vetor),max(Lrr22_est_vetor),...
        max(Lrr33_est_vetor)]);
    Lrr_self_est_min = mean([min(Lrr11_est_vetor),min(Lrr22_est_vetor),...
        min(Lrr33_est_vetor)]);
    Lrr_self_est_media = mean([Lrr_self_est_max,Lrr_self_est_min]);
    Lbar_self_r_linha = Lrr_self_est_media - (Lmr_linha + Llr_linha);
    Ltil_self_r_linha = abs(Lrr_self_est_max - Lrr_self_est_media);
    
    % Matriz Lrr (elementos fora da diagonal principal)
    Lrr_mutua_est_max = mean([...
        max(Lrr12_est_vetor),max(Lrr13_est_vetor),max(Lrr21_est_vetor),...
        max(Lrr23_est_vetor),max(Lrr31_est_vetor),max(Lrr32_est_vetor)]);
    Lrr_mutua_est_min = mean([...
        min(Lrr12_est_vetor),min(Lrr13_est_vetor),min(Lrr21_est_vetor),...
        min(Lrr23_est_vetor),min(Lrr31_est_vetor),min(Lrr32_est_vetor)]);
    Lrr_mutua_est_media = mean([Lrr_mutua_est_max,Lrr_mutua_est_min]);
    Lbar_mut_r_linha = Lrr_mutua_est_media - (-Lmr_linha/2);
    Ltil_mut_r_linha = abs(Lrr_mutua_est_max - Lrr_mutua_est_media);
    
    %% Grandezas definidas na modelagem alpha-beta
    
    Lbar_ecc_s = Lbar_self_s - Lbar_mut_s;
    Ltil_ecc_s = 0.5*Ltil_self_s + Ltil_mut_s;
    
    Lbar_ecc_r_linha = Lbar_self_r_linha - Lbar_mut_r_linha;
    Ltil_ecc_r_linha = 0.5*Ltil_self_r_linha + Ltil_mut_r_linha;
    
    %% Grandezas definidas na modelagem dq
    
    % Subseção de grandezas eletromagnéticas
    Lbar_ecc_r = (Ns/Nr)^2*Lbar_ecc_r_linha;
    Ltil_ecc_r = (Ns/Nr)^2*Ltil_ecc_r_linha;
    
    % Subseção de grandezas mecânicas
    Lf_re = Ls + Lbar_ecc_s + ...
        (2*Ltil_ecc_s - 1.5*Ltil_mut_s)*cos(2*delta_r);
    Lf_im = 1.5*Ltil_mut_s*sin(2*delta_r);
end