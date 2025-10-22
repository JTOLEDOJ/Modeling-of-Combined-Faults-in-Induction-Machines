% ###############################################################
% ################### INICIALIZA AS VARIÁVEIS  ##################
% ###############################################################

% Por comparação dos circuitos do Lipo (Figs. 19 e 20):
Ls = Ll + M;            % Ls = Lr = 0.2732803202886788
Lr = Ls;
Lm = sqrt(M*Lr);        % Lm = 0.2714072900799525
Lms = Lm*2/3;           % Lms = 0.180938193386635
Lmr = Lms;
rs = Rs;                % rs = 6.1
rr = (Lr/M)*Rr;         % rr = 3.152177025493911
Lls = Ls - Lm;          % Lls = 0.001873030208726312
Llr = Lls;

% Definição de outros parâmetros
Ns = Ns_efetivo;
Nr = Nr_efetivo;
Lsr = (Nr/Ns)*Lms;
Lmr_linha = (Nr/Ns)^2*Lmr;
Llr_linha = (Nr/Ns)^2*Llr;
Lr_linha = (Nr/Ns)^2*Lr;
rr_linha = (Nr/Ns)^2*rr;

% Parâmetros de Simulação
passo = 1;
velInicial = 0;
velFinal = 120*f/p;
cont = 1;

% Declaração dos vetores
TeVetor_Tradicional = zeros(1,velFinal-velInicial+1);
pMecVetor_Tradicional = zeros(1,velFinal-velInicial+1);
isVetor_Tradicional = zeros(1,velFinal-velInicial+1);
irVetor_Tradicional = zeros(1,velFinal-velInicial+1);
pEleVetor_Tradicional = zeros(1,velFinal-velInicial+1);
rendVetor_Tradicional = zeros(1,velFinal-velInicial+1);
fpVetor_Tradicional = zeros(1,velFinal-velInicial+1);
nVetor_Tradicional = zeros(1,velFinal-velInicial+1);

% ###############################################################
% ##################### INÍCIO DA SIMULAÇÃO #####################
% ###############################################################

for n = velInicial:passo:velFinal
    % Velocidade mecânica do rotor [rad/s]
    wMec = n*(pi/30);

    % Escorregamento
    s = (we - (p/2)*wMec)/we;

    % Impedâncias e correntes
    Zr = 1i*we*Llr + rr/s;
    Zm = 1i*we*Lm;
    Zrm = (Zr*Zm)/(Zr+Zm);
    Zeq = rs + 1i*we*Lls + Zrm;
    is = vs/Zeq; % Corrente de fase e pico
    vrm = vs - (rs + 1i*we*Lls)*is;
    ir = -vrm/Zr;
    im = vrm/Zm;

    % Resultados
    Te = (3/2)*(p/2)*Lm*(imag(is)*real(ir)-real(is)*imag(ir));
    pMec = Te*wMec;
    pEle = (3/2)*real(vs*conj(is));
    rend = pMec/pEle;
    fp = cos(angle(vs) - angle(is));

    % Salvando dados no vetor
    TeVetor_Tradicional(cont) = Te;
    pMecVetor_Tradicional(cont) = pMec;
    isVetor_Tradicional(cont) = is;
    irVetor_Tradicional(cont) = ir;
    pEleVetor_Tradicional(cont) = pEle;
    rendVetor_Tradicional(cont) = rend;
    fpVetor_Tradicional(cont) = fp;
    nVetor_Tradicional(cont) = n;
    cont = cont + 1;
end

disp(['Velocidade nominal: ',num2str(nNom),' rpm']);
disp(['Torque nominal: ',num2str(TeNom),' N.m']);
disp(['Potência nominal: ',num2str(pNom),' W']);
disp(['Corrente nominal: ',num2str(iNom),' A']);
disp(['Fator de potência nominal: ',num2str(fpNom*100),' %']);
disp(['Eficiência nominal: ',num2str(rendNom*100),' %']);
disp(['Torque máximo: ',num2str(100*max(TeVetor_Tradicional)/TeNom),' %']);
disp(['Ip/In: ',num2str(max(abs(isVetor_Tradicional)*sqrt(3)/sqrt(2))/iNom)]);

% ###############################################################
% ####################### GERA AS FIGURAS #######################
% ###############################################################

figure, hold on;
plot(nVetor_Original,TeVetor_Original);
plot(nVetor_Tradicional,TeVetor_Tradicional);
plot(nNom,TeNom,'r*');
xlabel('Velocidade mecânica [RPM]');
ylabel('Torque eletromagnético [N.m]');
legend({'Original','Tradicional','Nominal'});
grid on;

figure, hold on;
plot(nVetor_Original,pMecVetor_Original);
plot(nVetor_Tradicional,pMecVetor_Tradicional);
plot(nNom,pNom,'r*');
xlabel('Velocidade mecânica [RPM]');
ylabel('Potência mecânica [W]');
legend({'Original','Tradicional','Nominal'});
grid on;

figure, hold on;
plot(nVetor_Original,abs(isVetor_Original)*sqrt(3)/sqrt(2));
plot(nVetor_Tradicional,abs(isVetor_Tradicional)*sqrt(3)/sqrt(2));
plot(nNom,iNom,'r*');
xlabel('Velocidade mecânica [RPM]');
ylabel('Corrente de estator (Linha-RMS) [A]');
legend({'Original','Tradicional','Nominal'});
grid on;

figure, hold on;
plot(nVetor_Original,fpVetor_Original);
plot(nVetor_Tradicional,fpVetor_Tradicional);
plot(nNom,fpNom,'r*');
xlabel('Velocidade mecânica [RPM]');
ylabel('Fator de potência');
legend({'Original','Tradicional','Nominal'});
grid on;

figure, hold on;
plot(nVetor_Original,rendVetor_Original);
plot(nVetor_Tradicional,rendVetor_Tradicional);
plot(nNom,rendNom,'r*');
xlabel('Velocidade mecânica [RPM]');
ylabel('Eficiência');
legend({'Original','Tradicional','Nominal'});
grid on;

% ###############################################################
% ######### PARÂMETROS DO CIRCUITO EQUIVALENTE EM P.U ###########
% ###############################################################

% Criando as bases (página 106 do livro do Umans)
Sbase = pNom;
Vbase = vNom; % Tensão Linha-RMS
Ibase = Sbase/(sqrt(3)*Vbase); % Corrente Linha-RMS
Zbase = Vbase/(sqrt(3)*Ibase);
webase = we;
Lbase = Zbase/webase;

% Calculando valores dos componentes
rs_pu = rs/Zbase;
rr_pu = rr/Zbase;
Lm_pu = Lm/Lbase;
Lls_pu = Lls/Lbase;
Llr_pu = Llr/Lbase;
disp(' ');
disp(['rs_pu: ',num2str(rs_pu)]);
disp(['rr_pu: ',num2str(rr_pu)]);
disp(['Lm_pu: ',num2str(Lm_pu)]);
disp(['Lls_pu + Llr_pu: ',num2str(Lls_pu+Llr_pu)]);