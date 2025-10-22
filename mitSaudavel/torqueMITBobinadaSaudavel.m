close all
clc

% ###############################################################
% ####################### PREPARA O FEMM  #######################
% ###############################################################

% Abre o software FEMM
openfemm();

% Abre o documento de interesse (este arquivo não será editado)
opendocument('desenhos/maquinaRotorBobinadoSaudavel.FEM');

% Cria um novo arquivo (este arquivo será editado)
mi_saveas('mitSaudavel/temp.FEM');

% ###############################################################
% ################# INICIALIZAÇÃO DAS VARIÁVEIS #################
% ###############################################################

% Parâmetros da simulação
k = 1;
nPontosCiclo = 300;
%nPontosCiclo = 2;       % PARA TESTES
idxPasso = floor((1/f)/nPontosCiclo/dt_decimado);
idxVetorRB_saud = idx4:idxPasso:idx5;
TeRB_saud_femm = zeros(size(idxVetorRB_saud));

% ###############################################################
% ########################## SIMULAÇÃO ##########################
% ###############################################################

% Define o problema
mi_probdef(0,'millimeters','planar',1e-8,l_axial,20);

for idx = idxVetorRB_saud
    % Seleciona os elementos de rotor (grupo 1)
    mi_selectgroup(1);

    % Rotaciona o rotor de acordo com a rotação do ponto de operação
    passo_deg = theta_mec_saud(idx)*180/pi;
    mi_moverotate(x0,y0,passo_deg);

    % Limpa a seleção dos elementos de rotor
    mi_clearselected();

    % Define o perfil de alimentação de corrente (fase e pico)
    Ias = ias_saud(idx);
    Ibs = ibs_saud(idx);
    Ics = ics_saud(idx);
    Iar_linha = iar_saud(idx)*(Ns_efetivo/Nr_efetivo);
    Ibr_linha = ibr_saud(idx)*(Ns_efetivo/Nr_efetivo);
    Icr_linha = icr_saud(idx)*(Ns_efetivo/Nr_efetivo);

    mi_modifycircprop('as',1,Ias);
    mi_modifycircprop('bs',1,Ibs);
    mi_modifycircprop('cs',1,Ics);
    mi_modifycircprop('ar',1,Iar_linha);
    mi_modifycircprop('br',1,Ibr_linha);
    mi_modifycircprop('cr',1,Icr_linha);

    % Abre o fkern para resolver o problema
    mi_analyze(1);

    % Carrega e exibe a solução
    mi_loadsolution();

    % PARA TESTES
    %pause();

    % Seleciona a área de rotor para cálculo
    mo_groupselectblock(1);

    % Realiza a operação "Steady-state weighted stress tensor torque"
    TeRB_saud_femm(k) = mo_blockintegral(22);

    % Fecha a instância de pós-processamento atual
    mo_close();

    % Seleciona os elementos de rotor (grupo 1)
    mi_selectgroup(1);

    % Faz a rotação do rotor
    mi_moverotate(x0,y0,-passo_deg);

    % Limpa a seleção dos elementos de rotor
    mi_clearselected();

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
    tempo(idxVetorRB_saud),ias_saud(idxVetorRB_saud),'*r',...
    tempo(idxVetorRB_saud),ibs_saud(idxVetorRB_saud),'*g',...
    tempo(idxVetorRB_saud),ics_saud(idxVetorRB_saud),'*b');
xlabel('Tempo [s]');
xlim([tempo(idxVetorRB_saud(1)-100) tempo(idxVetorRB_saud(end)+100)]);
ylabel('Correntes de estator em abc (Fase-Pico) [A]');
ylim([-1.2*Inom*sqrt(2)/sqrt(3) 1.2*Inom*sqrt(2)/sqrt(3)]);
grid on;

% Correntes de rotor em abc vs. tempo
figure;
plot(tempo,iar_saud,'-r',tempo,ibr_saud,'-g',tempo,icr_saud,'-b',...
    tempo(idxVetorRB_saud),iar_saud(idxVetorRB_saud),'*r',...
    tempo(idxVetorRB_saud),ibr_saud(idxVetorRB_saud),'*g',...
    tempo(idxVetorRB_saud),icr_saud(idxVetorRB_saud),'*b');
xlabel('Tempo [s]');
xlim([tempo(idxVetorRB_saud(1)-100) tempo(idxVetorRB_saud(end)+100)]);
ylabel('Correntes de rotor em abc (Fase-Pico, Medidas no Estator) [A]');
ylim([-1.2*Inom*sqrt(2)/sqrt(3) 1.2*Inom*sqrt(2)/sqrt(3)]);
grid on;

% Torques vs. tempo
figure;
plot(tempo,Te_saud,'-k',tempo(idxVetorRB_saud),TeRB_saud_femm,'--k');
xlabel('Tempo [s]');
xlim([tempo(idxVetorRB_saud(1)-100) tempo(idxVetorRB_saud(end)+100)]);
ylabel('Torque [N.m]');
ylim([0.8*TeNom 1.2*TeNom]);
legend({'Modelo','FEMM'});
grid on;