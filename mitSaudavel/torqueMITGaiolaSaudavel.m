close all
clc

% ###############################################################
% ####################### PREPARA O FEMM  #######################
% ###############################################################

% Abre o software FEMM
openfemm();

% Abre o documento de interesse (este arquivo não será editado)
opendocument('desenhos/maquinaRotorGaiolaSaudavel.FEM');

% Cria um novo arquivo (este arquivo será editado)
mi_saveas('mitSaudavel/temp.FEM');

% ###############################################################
% ########################## SIMULAÇÃO ##########################
% ###############################################################

% Parâmetros da simulação
k = 1;
nPontosCiclo = 10;
%nPontosCiclo = 2;       % PARA TESTES
idxPasso = floor((1/f)/nPontosCiclo/dt_decimado);
idxVetorRG_saud = idx4:idxPasso:idx5;
TeRG_saud_femm = zeros(size(idxVetorRG_saud));

% IMPORTANTE: Se rotacionar o rotor, percebe-se uma pulsação no torque por
% conta do entreferro da máquina real não ser uniforme (as ranhuras são as
% causadoras naturais dessa variação do entreferro)

for idx = idxVetorRG_saud
    % Define o problema
    freq_slip = (120*f/p - nmec_saud(idx))*(p/2)*(pi/30)/(2*pi);
    mi_probdef(freq_slip,'millimeters','planar',1e-8,l_axial,20);

    % % Seleciona os elementos de rotor (grupo 1)
    % mi_selectgroup(1);
    % 
    % % Rotaciona o rotor de acordo com a rotação do ponto de operação
    % passo_deg = theta_mec_saud(i)*180/pi;
    % mi_moverotate(0,0,passo_deg);
    % 
    % % Limpa a seleção dos elementos de rotor
    % mi_clearselected();

    % Define o perfil de alimentação de corrente (fase e pico)
    Imax_saud = is_dq_saud(idx)*sqrt(2)/sqrt(3);
    Iang_saud = acos(ias_saud(idx0)/Imax_saud) + ...
        we*(tempo(idx) - tempo(idx0));
    Ias_saud = Imax_saud*exp(1i*(0 - Iang_saud));
    Ibs_saud = Imax_saud*exp(1i*(deg120 - Iang_saud));
    Ics_saud = Imax_saud*exp(1i*(-deg120 - Iang_saud));

    mi_modifycircprop('as',1,Ias_saud);
    mi_modifycircprop('bs',1,Ibs_saud);
    mi_modifycircprop('cs',1,Ics_saud);

    % Abre o fkern para resolver o problema
    mi_analyze(1);

    % Carrega e exibe a solução
    mi_loadsolution();

    % PARA TESTES
    %pause();

    % Seleciona a área de rotor para cálculo
    mo_groupselectblock(1);

    % Realiza a operação "Steady-state weighted stress tensor torque"
    TeRG_saud_femm(k) = mo_blockintegral(22);

    % Fecha a instância de pós-processamento atual
    mo_close();

    % % Seleciona os elementos de rotor (grupo 1)
    % mi_selectgroup(1);
    % 
    % % Faz a rotação do rotor
    % mi_moverotate(0,0,-passo_deg);
    % 
    % % Limpa a seleção dos elementos de rotor
    % mi_clearselected();

    % Prepara para o próximo passo
    k = k + 1;
end

% Fecha o software FEMM
closefemm();

% Deleta os arquivos temporários
system('rm mitSaudavel/temp.FEM mitSaudavel/temp.ans');

% ###############################################################
% ####################### GERA AS FIGURAS #######################
% ###############################################################

% Correntes de estator em abc vs. tempo
figure;
plot(tempo,ias_saud,'-r',tempo,ibs_saud,'-g',tempo,ics_saud,'-b',...
    tempo(idxVetorRG_saud),ias_saud(idxVetorRG_saud),'*r',...
    tempo(idxVetorRG_saud),ibs_saud(idxVetorRG_saud),'*g',...
    tempo(idxVetorRG_saud),ics_saud(idxVetorRG_saud),'*b');
xlabel('Tempo [s]');
xlim([tempo(idxVetorRG_saud(1)-100) tempo(idxVetorRG_saud(end)+100)]);
ylabel('Correntes de estator em abc (Fase-Pico) [A]');
ylim([-1.2*Inom*sqrt(2)/sqrt(3) 1.2*Inom*sqrt(2)/sqrt(3)]);
grid on;

% Torques vs. tempo
figure;
plot(tempo,Te_saud,'-k',tempo(idxVetorRG_saud),-TeRG_saud_femm,'*k');
xlabel('Tempo [s]');
xlim([tempo(idxVetorRG_saud(1)-100) tempo(idxVetorRG_saud(end)+100)]);
ylabel('Torque [N.m]');
ylim([0.99*TeNom 1.01*TeNom]);
legend({'Modelo','FEMM'});
grid on;