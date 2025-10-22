% ###############################################################
% ####################### PREPARA O FEMM  #######################
% ###############################################################

% Abre o software FEMM
openfemm();

% Abre o documento de interesse (este arquivo não será editado)
opendocument('desenhos/maquinaRotorGaiolaSaudavel.FEM');

% Cria um novo arquivo (este arquivo será editado)
mi_saveas('parametrosSaudaveis/temp.FEM');

% ###############################################################
% ########################## SIMULAÇÃO ##########################
% ###############################################################

% Parâmetros da simulação
nRG_regPerm_vetor = 50:50:length(nVetor_Tradicional)-1;
%nRG_regPerm_vetor = 400:400:length(nVetor_Tradicional)-1; % Para testes
nRG_regPerm_tam = length(nRG_regPerm_vetor);
TeRG_regPerm_vetor = zeros(1,nRG_regPerm_tam);

i = 1;
for nRG_regPerm = nRG_regPerm_vetor
    % Define o problema
    freq_slip = ...
        (120*f/p-nVetor_Tradicional(nRG_regPerm))*(p/2)*(pi/30)/(2*pi);
    mi_probdef(freq_slip,'millimeters','planar',1e-8,l_axial,20);

    % Define o perfil de corrente
    Imax = ...
        abs(isVetor_Tradicional(nRG_regPerm));  % Amplitude de corrente [A]
    Ias = Imax*exp(1i*deg2rad(0));              % Corrente da fase as [A]
    Ibs = Imax*exp(1i*deg2rad(120));            % Corrente da fase bs [A]
    Ics = Imax*exp(1i*deg2rad(240));            % Corrente da fase cs [A]

    mi_modifycircprop('as',1,Ias);
    mi_modifycircprop('bs',1,Ibs);
    mi_modifycircprop('cs',1,Ics);

    % Abre o fkern para resolver o problema
    mi_analyze(1);

    % Carrega e exibe a solução
    mi_loadsolution();

    % Seleciona a área de rotor para cálculo do torque
    mo_groupselectblock(1);

    % Realiza a operação "Steady-state weighted stress tensor torque"
    TeRG_regPerm_vetor(i) = mo_blockintegral(22);

    % Fecha a instância de pós-processamento atual
    mo_close();

    % Prepara para o próximo passo
    i = i + 1;
end

% Fecha o software FEMM
closefemm();

% Deleta os arquivos temporários
system('rm parametrosSaudaveis/temp.FEM parametrosSaudaveis/temp.ans');

% ###############################################################
% ####################### GERA AS FIGURAS #######################
% ###############################################################

figure, hold on;
plot(nVetor_Original,TeVetor_Original);
plot(nVetor_Tradicional,TeVetor_Tradicional);
plot(nRG_regPerm_vetor,-TeRG_regPerm_vetor);
plot(nNom,TeNom,'r*');
xlabel('Velocidade mecânica [RPM]');
ylabel('Torque eletromagnético [N.m]');
legend({'Original','Tradicional','FEMM','Nominal'});
grid on;