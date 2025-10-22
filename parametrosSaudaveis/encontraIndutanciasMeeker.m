% Inicialização das variáveis
rotacao_deg_vetor = 0:1:360/Nr_ranhuras-1;
rotacao_deg_tam = length(rotacao_deg_vetor);
tau_FEA_vetor = zeros(1,rotacao_deg_tam);
M_vetor = zeros(1,rotacao_deg_tam);
Ll_vetor = zeros(1,rotacao_deg_tam);

% Faz o cálculo para várias posições do rotor e tira a média. Não precisa
% girar mais do que o ângulo de uma ranhura, pois os valores se repetem.

% Simulação
i = 1;
for rotacao_deg = rotacao_deg_vetor
    [tau_FEA, M, Ll] = metodoMeeker(x0, y0, rotacao_deg, l_axial);

    tau_FEA_vetor(i) = tau_FEA;
    M_vetor(i) = M;
    Ll_vetor(i) = Ll;

    i = i + 1;
end

% Encontra "tau_FEA", "M" e "Ll"
tau_FEA = mean(tau_FEA_vetor);          % tau_FEA = 0.08669574014354693
M = mean(M_vetor);                      % M = 0.2695470973933687
Ll = mean(Ll_vetor);                    % Ll = 0.003733222895310113