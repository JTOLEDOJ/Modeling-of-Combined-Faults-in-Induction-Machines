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
mi_saveas('mitFalhas/temp.FEM');

% ###############################################################
% ######## INSERE O CURTO-CIRCUITO NAS ESPIRAS DA FASE AS #######
% ###############################################################

% Cria o circuito em falha da fase as
mi_addcircprop('asf', 0, 1);

% Modifica o desenho caso haja qualquer nível de curto-circuito
if xi_ref(end) ~= 0

    % Inicializa as variáveis
    funcao_espiras_as_curto = funcao_espiras_as;
    passo_deg = 360/Ns_ranhuras;
    angulos_deg = passo_deg/2:passo_deg:360-passo_deg/2;
    raio_superior_ranhura_estator = 54;
    raio_inferior_ranhura_estator = 41;
    ajuste_deg = 1;

    % Exemplo: São 144 espiras de estator; logo, posso remover 7 espiras
    % que passam pelas ranhuras 9 (entrando) e 27 (saindo), equivalente a
    % mais ou menos 5% de falha de curto-circuito no estator
    iVetorRanhuras = [9, 27];
    paresRanhuras = length(iVetorRanhuras)/2;
    espRemovidasPorParRanhura = ...
        round(xi_ref(end)*Ns_efetivo/paresRanhuras);

    % Faz a modificação de cada ranhura com curto-circuito
    for i = iVetorRanhuras
        if espRemovidasPorParRanhura > abs(funcao_espiras_as(i))
            % Não pode remover mais espiras do que as disponíveis
            error(['O usuário está tentando remover ',...
                num2str(espRemovidasPorParRanhura),...
                ' espiras da ranhura ',num2str(i),', mas ela possui',...
                ' apenas ',num2str(abs(funcao_espiras_as(i))),...
                ' espiras disponíveis!']);
        else
            % Variáveis importantes para este passo de cálculo
            angulo_deg = passo_deg*i - passo_deg/2;
            funcao_espiras_as_curto(i) = funcao_espiras_as_curto(i) - ...
                sign(funcao_espiras_as(i))*espRemovidasPorParRanhura;

            if espRemovidasPorParRanhura == abs(funcao_espiras_as(i))
                % Todas as espiras da ranhura foram curto-circuitadas, logo
                % resta apenas a parcela de falha da fase as

                % Basicamente transforma "as" e "asf"
                x = x0 + r_ranhura_estator*cos(deg2rad(angulo_deg));
                y = y0 + r_ranhura_estator*sin(deg2rad(angulo_deg));
                mi_selectlabel(x, y);
                mi_setblockprop('20 AWG', 0, mesh_ranhura, 'asf', 0, 0, ...
                    sign(funcao_espiras_as(i))*espRemovidasPorParRanhura);
                mi_clearselected();
            else
                % Divide a ranhura em duas partes para inserir os circuitos
                % saudável ("as") e em falha ("asf"):

                % Remove o antigo "label" do circuito "as"
                x = x0 + r_ranhura_estator*cos(deg2rad(angulo_deg));
                y = y0 + r_ranhura_estator*sin(deg2rad(angulo_deg));
                mi_selectlabel(x, y);
                mi_deleteselected;

                % Adiciona o novo "label" do circuito "as"
                x = x0 + 1.05*r_ranhura_estator*cos(deg2rad(angulo_deg));
                y = y0 + 1.05*r_ranhura_estator*sin(deg2rad(angulo_deg));
                mi_addblocklabel(x, y);
                mi_selectlabel(x, y);
                mi_setblockprop('20 AWG', 0, mesh_ranhura, 'as', 0, 0, ...
                    funcao_espiras_as_curto(i));
                mi_clearselected();

                % Adiciona o novo "label" do circuito "asf"
                x = x0 + 0.95*r_ranhura_estator*cos(deg2rad(angulo_deg));
                y = y0 + 0.95*r_ranhura_estator*sin(deg2rad(angulo_deg));
                mi_addblocklabel(x, y);
                mi_selectlabel(x, y);
                mi_setblockprop('20 AWG', 0, mesh_ranhura, 'asf', 0, 0, ...
                    sign(funcao_espiras_as(i))*espRemovidasPorParRanhura);
                mi_clearselected();

                % Encontra o ponto de início e fim de um dos segmentos de
                % reta que cercam a fase com curto-circuito para descobrir
                % a coordenada do ponto médio desse segmento
                x = x0 + raio_superior_ranhura_estator*cos(...
                    deg2rad(angulo_deg - ajuste_deg));
                y = y0 + raio_superior_ranhura_estator*sin(...
                    deg2rad(angulo_deg - ajuste_deg));
                ponto1 = mi_selectnode(x,y);

                x = x0 + raio_inferior_ranhura_estator*cos(...
                    deg2rad(angulo_deg - ajuste_deg));
                y = y0 + raio_inferior_ranhura_estator*sin(...
                    deg2rad(angulo_deg - ajuste_deg));
                ponto2 = mi_selectnode(x,y);

                ponto3_medio = ...
                    [(ponto1(1)+ponto2(1))/2, (ponto1(2)+ponto2(2))/2];
                mi_addnode(ponto3_medio);

                % Encontra o ponto de início e fim do outro segmento de
                % reta que cerca a fase com curto-circuito para descobrir
                % a coordenada do ponto médio desse segmento
                x = x0 + raio_superior_ranhura_estator*cos(...
                    deg2rad(angulo_deg + ajuste_deg));
                y = y0 + raio_superior_ranhura_estator*sin(...
                    deg2rad(angulo_deg + ajuste_deg));
                ponto4 = mi_selectnode(x,y);

                x = x0 + raio_inferior_ranhura_estator*cos(...
                    deg2rad(angulo_deg + ajuste_deg));
                y = y0 + raio_inferior_ranhura_estator*sin(...
                    deg2rad(angulo_deg + ajuste_deg));
                ponto5 = mi_selectnode(x,y);

                ponto6_medio = ...
                    [(ponto4(1)+ponto5(1))/2, (ponto4(2)+ponto5(2))/2];
                mi_addnode(ponto6_medio);

                % Divide a ranhura traçando uma reta entre os pontos médios
                mi_addsegment(ponto3_medio(1),ponto3_medio(2),...
                    ponto6_medio(1),ponto6_medio(2));
            end
        end
    end
end

% ###############################################################
% ########################## SIMULAÇÃO ##########################
% ###############################################################

% Parâmetros da simulação
k = 1;
nPontosCiclo = 300;
%nPontosCiclo = 2;       % PARA TESTES
idxPasso = floor((1/f)/nPontosCiclo/dt_decimado);
iVetorRB_falhas = ...
    [idx0:idxPasso:idx1 idx2:idxPasso:idx3 idx4:idxPasso:idx5];
% idxExtensao = floor((1/f)/dt_decimado);
% iVetorRB_falhas = ...   % PARA TESTES
%     [idx0-idxExtensao:idxPasso:idx1+idxExtensao...
%     idx2-idxExtensao:idxPasso:idx3+idxExtensao...
%     idx4-idxExtensao:idxPasso:idx5+idxExtensao];
TeRB_falhas_femm = zeros(size(iVetorRB_falhas));

% Define o problema
mi_probdef(0,'millimeters','planar',1e-8,l_axial,20);

for idx = iVetorRB_falhas

    % #############################################################
    % #### POSICIONA O ROTOR NA POSIÇÃO CORRETA PARA SIMULAÇÃO ####
    % #############################################################

    % Seleciona os elementos de rotor (grupo 1)
    mi_selectgroup(1);

    % Rotaciona o rotor de acordo com o ângulo do ponto de operação
    passo_deg = theta_mec_falhas(idx)*180/pi;
    mi_moverotate(x0,y0,passo_deg);

    % Limpa a seleção dos elementos de rotor
    mi_clearselected();

    % Seleciona os elementos de rotor (grupo 1)
    mi_selectgroup(1);

    % Translada o rotor para a posição de excentricidade em questão
    dx = er_falhas(idx)*cos(delta_r_falhas(idx));
    dy = er_falhas(idx)*sin(delta_r_falhas(idx));
    mi_movetranslate(x0+dx,y0+dy);

    % Limpa a seleção dos elementos de rotor
    mi_clearselected();

    % Define o perfil de alimentação de corrente (fase e pico)
    Ias = ias_falhas(idx);
    Ibs = ibs_falhas(idx);
    Ics = ics_falhas(idx);
    Iasf = ias_falhas(idx) - if_falhas(idx);
    Iar_linha = iar_falhas(idx)*(Ns_efetivo/Nr_efetivo);
    Ibr_linha = ibr_falhas(idx)*(Ns_efetivo/Nr_efetivo);
    Icr_linha = icr_falhas(idx)*(Ns_efetivo/Nr_efetivo);

    mi_modifycircprop('as',1,Ias);
    mi_modifycircprop('bs',1,Ibs);
    mi_modifycircprop('cs',1,Ics);
    mi_modifycircprop('asf',1,Iasf);
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
    TeRB_falhas_femm(k) = mo_blockintegral(22);

    % Fecha a instância de pós-processamento atual
    mo_close();

    % #############################################################
    % ########## RETORNA COM A POSIÇÃO ORIGINAL DO ROTOR ##########
    % #############################################################

    % Seleciona os elementos de rotor (grupo 1)
    mi_selectgroup(1);

    % Translada o rotor para a posição original
    mi_movetranslate(x0-dx,y0-dy);

    % Limpa a seleção dos elementos de rotor
    mi_clearselected();

    % Seleciona os elementos de rotor (grupo 1)
    mi_selectgroup(1);

    % Rotaciona o rotor para a posição original
    mi_moverotate(x0,y0,-passo_deg);

    % Limpa a seleção dos elementos de rotor
    mi_clearselected();

    % Prepara para o próximo passo
    k = k + 1;
end

% Fecha o software FEMM
closefemm();

% Deleta os arquivos temporários
system('rm mitFalhas/temp.FEM mitFalhas/temp.ans');

% ###############################################################
% ####################### GERA AS FIGURAS #######################
% ###############################################################

% Correntes de estator em abc vs. tempo
figure;
plot(tempo,ias_falhas,'-r',tempo,ibs_falhas,'-g',tempo,ics_falhas,'-b',...
    tempo(iVetorRB_falhas),ias_falhas(iVetorRB_falhas),'*r',...
    tempo(iVetorRB_falhas),ibs_falhas(iVetorRB_falhas),'*g',...
    tempo(iVetorRB_falhas),ics_falhas(iVetorRB_falhas),'*b');
xlabel('Tempo [s]');
xlim([tempo(iVetorRB_falhas(1)-100) tempo(iVetorRB_falhas(end)+100)]);
ylabel('Correntes de estator em abc (Fase-Pico) [A]');
grid on;

% Correntes de rotor em abc vs. tempo
figure;
plot(tempo,iar_falhas,'-r',tempo,ibr_falhas,'-g',tempo,icr_falhas,'-b',...
    tempo(iVetorRB_falhas),iar_falhas(iVetorRB_falhas),'*r',...
    tempo(iVetorRB_falhas),ibr_falhas(iVetorRB_falhas),'*g',...
    tempo(iVetorRB_falhas),icr_falhas(iVetorRB_falhas),'*b');
xlabel('Tempo [s]');
xlim([tempo(iVetorRB_falhas(1)-100) tempo(iVetorRB_falhas(end)+100)]);
ylabel('Correntes de rotor em abc (Fase-Pico, Medidas no Estator) [A]');
grid on;

% Torques vs. tempo
figure;
plot(tempo,Te_saud,'-b',tempo,Te_falhas,'-k',...
    tempo(iVetorRB_falhas),TeRB_falhas_femm,'*k');
xlabel('Tempo [s]');
xlim([tempo(iVetorRB_falhas(1)-100) tempo(iVetorRB_falhas(end)+100)]);
ylabel('Torque [N.m]');
legend({'Modelo Saud.','Modelo Falhas','FEMM Falhas'});
grid on;