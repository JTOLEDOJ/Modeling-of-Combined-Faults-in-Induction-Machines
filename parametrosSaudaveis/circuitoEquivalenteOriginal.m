% ###############################################################
% ################### INICIALIZA AS VARIÁVEIS  ##################
% ###############################################################

% Parâmetros do motor
tau = tau_FEA;  % Constante de tempo do motor [s]
Rr = M/tau;     % Resistência do rotor [Ohms]     % Rr = 3.109115822150715
Rs = 6.1;       % Resistência do estator [Ohms]

% Dados nominais do motor (informados)
vNom = 220;             % Tensão Linha-RMS [V]
vs = vNom*sqrt(2);      % Tensão Fase-Pico [V] -> Fechado em delta
pNom = 2*745.7;         % Potência [W]
p = 2;                  % Número de polos por fase
f = 60;                 % Frequência da fonte [Hz]
we = 2*pi*f;            % Velocidade elétrica do imã [rad/s]

% Parâmetros de Simulação
passo = 0.05;
velInicial = 0;
velFinal = 120*f/p;
cont = 1;

% Declaração dos vetores
TeVetor_Original = zeros(1,velFinal-velInicial+1);
pMecVetor_Original = zeros(1,velFinal-velInicial+1);
isVetor_Original = zeros(1,velFinal-velInicial+1);
irVetor_Original = zeros(1,velFinal-velInicial+1);
pEleVetor_Original = zeros(1,velFinal-velInicial+1);
rendVetor_Original = zeros(1,velFinal-velInicial+1);
fpVetor_Original = zeros(1,velFinal-velInicial+1);
nVetor_Original = zeros(1,velFinal-velInicial+1);

% ###############################################################
% ##################### INÍCIO DA SIMULAÇÃO #####################
% ###############################################################

for n = velInicial:passo:velFinal
    % Velocidade mecânica do rotor [rad/s]
    wMec = n*(pi/30);

    % Escorregamento
    s = (we - (p/2)*wMec)/we;

    % Impedâncias e correntes
    Zr = Rr/s;
    Zm = 1i*we*M;
    Zrm = (Zr*Zm)/(Zr+Zm);
    %Zeq = Rs + 1i*we*Ll + Zrm;
    Zeq = Rs + 1i*we*( Ll + M/(1 + 1i*tau*s*we) );
    is = vs/Zeq; % Corrente de fase e pico
    vrm = vs - (Rs + 1i*we*Ll)*is;
    ir = vrm/Zr;
    im = vrm/Zm;

    % Resultados
    Te = (3/2)*(p/2)*M*abs(is)^2*((tau*s*we)/(1+(tau*s*we)^2));
    pMec = Te*wMec;
    pEle = (3/2)*real(vs*conj(is));
    rend = pMec/pEle;
    fp = cos(angle(vs) - angle(is));

    % Salvando dados no vetor
    TeVetor_Original(cont) = Te;
    pMecVetor_Original(cont) = pMec;
    isVetor_Original(cont) = is;
    irVetor_Original(cont) = ir;
    pEleVetor_Original(cont) = pEle;
    rendVetor_Original(cont) = rend;
    fpVetor_Original(cont) = fp;
    nVetor_Original(cont) = n;
    cont = cont + 1;
end

% ###############################################################
% ############# VALORES NO PONTO DE OPERAÇÃO NOMINAL ############
% ###############################################################

% Dados nominais do motor (calculados)
idx_pMec_max = find(pMecVetor_Original == max(pMecVetor_Original));
diferenca = abs(pMecVetor_Original - pNom);
[~, idx] = min(diferenca(idx_pMec_max:end));
idx_nom = idx + idx_pMec_max - 1;
pNom = pMecVetor_Original(idx_nom); % Atualiza o valor de potência
nNom = nVetor_Original(idx_nom);
fpNom = fpVetor_Original(idx_nom);
rendNom = rendVetor_Original(idx_nom);
iNom = abs(isVetor_Original(idx_nom))*sqrt(3)/sqrt(2);
TeNom = TeVetor_Original(idx_nom);
disp(['Velocidade nominal: ',num2str(nNom),' rpm']);
disp(['Torque nominal: ',num2str(TeNom),' N.m']);
disp(['Potência nominal: ',num2str(pNom),' W']);
disp(['Corrente nominal: ',num2str(iNom),' A']);
disp(['Fator de potência nominal: ',num2str(fpNom*100),' %']);
disp(['Eficiência nominal: ',num2str(rendNom*100),' %']);
disp(['Torque máximo: ',num2str(100*max(TeVetor_Original)/TeNom),' %']);
disp(['Ip/In: ',num2str(max(abs(isVetor_Original)*sqrt(3)/sqrt(2))/iNom)]);

% ###############################################################
% ####################### GERA AS FIGURAS #######################
% ###############################################################

figure, hold on;
plot(nVetor_Original,TeVetor_Original);
plot(nNom,TeNom,'r*');
xlabel('Velocidade mecânica [RPM]');
ylabel('Torque eletromagnético [N.m]');
grid on;

figure, hold on;
plot(nVetor_Original,pMecVetor_Original);
plot(nNom,pNom,'r*');
xlabel('Velocidade mecânica [RPM]');
ylabel('Potência mecânica [W]');
grid on;

figure, hold on;
plot(nVetor_Original,abs(isVetor_Original)*sqrt(3)/sqrt(2));
plot(nNom,iNom,'r*');
xlabel('Velocidade mecânica [RPM]');
ylabel('Corrente de estator (Linha-RMS) [A]');
grid on;

figure, hold on;
plot(nVetor_Original,fpVetor_Original);
plot(nNom,fpNom,'r*');
xlabel('Velocidade mecânica [RPM]');
ylabel('Fator de potência');
grid on;

figure, hold on;
plot(nVetor_Original,rendVetor_Original);
plot(nNom,rendNom,'r*');
xlabel('Velocidade mecânica [RPM]');
ylabel('Eficiência');
grid on;

% ###############################################################
% ########## PARÂMETROS DO CIRCUITO EQUIVALENTE EM P.U. #########
% ###############################################################

% Criando as bases (página 106 do livro do Umans)
Sbase = pNom;
Vbase = vNom; % Tensão Linha-RMS
Ibase = Sbase/(sqrt(3)*Vbase); % Corrente Linha-RMS
Zbase = Vbase/(sqrt(3)*Ibase);
webase = we;
Lbase = Zbase/webase;

% Calculando valores dos componentes
Rs_pu = Rs/Zbase;
Rr_pu = Rr/Zbase;
M_pu = M/Lbase;
Ll_pu = Ll/Lbase;
disp(' ');
disp(['Rs_pu: ',num2str(Rs_pu)]);
disp(['Rr_pu: ',num2str(Rr_pu)]);
disp(['M_pu: ',num2str(M_pu)]);
disp(['Ll_pu: ',num2str(Ll_pu)]);