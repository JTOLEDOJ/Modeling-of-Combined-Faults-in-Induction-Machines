% ###############################################################
% ################### INICIALIZA AS VARIÁVEIS  ##################
% ###############################################################

% Definição das variáveis de entrada
g = 0.375;                      % Comprimento do entreferro [mm]
r_int_rotor = 12.5;             % Raio interno do rotor [mm]
r_ext_rotor = 40;               % Raio externo do rotor [mm]
r_int_estator = r_ext_rotor+g;  % Raio interno do estator [mm]
r_ext_estator = 65;             % Raio externo do estator [mm]
r_front = r_ext_estator;        % Raio da fronteira da simulação [mm]
r_ranhura_estator = 47.5;       % Distância inserção material estator [mm]
r_ranhura_rotor = 32.5;         % Distância inserção material rotor [mm]
Ns_ranhuras = 36;               % Número ranhuras de estator
Nr_ranhuras = 30;               % Número ranhuras de rotor
l_axial = 110;                  % Comprimento axial do motor [mm]
mesh_coroa = 1;                 % Tamanho da malha das coroas
mesh_eixo = mesh_coroa;         % Tamanho da malha do eixo
mesh_gap = 0.09;                % Tamanho da malha do entreferro de ar
mesh_ranhura = 0.5;             % Tamanho da malha das ranhuras

% Outras dimensões [mm]
d1 = 20; d2 = 60;
d3 = (r_ext_estator+r_front)/2;

% ###############################################################
% ####################### PREPARA O FEMM  #######################
% ###############################################################

% Abre o software FEMM
openfemm();

% Abre o documento de interesse (este arquivo não será editado)
opendocument('desenhos/maquinaCrua.FEM');

% Cria um novo arquivo (este arquivo será editado)
mi_saveas('desenhos/maquinaModelo.FEM');

% Define o problema
mi_probdef(0,'millimeters','planar',1e-8,l_axial,20);

% ###############################################################
% ##################### DEFINE A FRONTEIRA ######################
% ###############################################################

% Define o centro do rotor
x0 = 0; y0 = 0;

% Desenha a fronteira da simulação
x1 = x0 + r_front; y1 = y0;
%mi_addnode(x1, y1);

x2 = x0 - r_front; y2 = y0;
%mi_addnode(x2, y2);

% Adiciona arcos para formar um círculo completo
%mi_addarc(x1, y1, x2, y2, 180, 1);
%mi_addarc(x2, y2, x1, y1, 180, 1);

% Cria a condição de contorno da simulação
mi_addboundprop('A = 0', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);

% Seleciona os arcos para aplicar a condição de contorno
mi_selectarcsegment(x0, y0 + r_front);
mi_selectarcsegment(x0, y0 - r_front);
mi_setarcsegmentprop(1, 'A = 0', 0, 0);

% ###############################################################
% ############# DEFINE OS GRUPOS E CRIA OS CIRCUITOS ############
% ###############################################################

% Define o grupo de estator
mi_selectcircle(x0, y0, 1.0001*r_front, 4);
mi_setgroup(0);
mi_clearselected();

% Define o grupo de rotor
mi_selectcircle(x0, y0, 1.0001*r_ext_rotor, 4);
mi_setgroup(1);
mi_clearselected();

mi_addcircprop('as', 0, 1);
mi_addcircprop('bs', 0, 1);
mi_addcircprop('cs', 0, 1);
mi_addcircprop('ar', 0, 1);
mi_addcircprop('br', 0, 1);
mi_addcircprop('cr', 0, 1);

% ###############################################################
% ########## ADICIONA MATERIAL E CIRCUITO NAS RANHURAS ##########
% ###############################################################

passo_deg = 360/Ns_ranhuras;
angulos_deg = passo_deg/2:passo_deg:360-passo_deg/2;

% Loop para as ranhuras da fase 'as'
amplitude_funcao_Ns = 12.8;
funcao_espiras_as = round(amplitude_funcao_Ns*sin(deg2rad(angulos_deg)));
%figure, stem(funcao_espiras_as);
Ns_efetivo = sum(funcao_espiras_as(1:end/2));   % Ns_efetivo = 144

for i = 1:Ns_ranhuras
    x = x0 + r_ranhura_estator*cos(deg2rad(passo_deg*i - passo_deg/2));
    y = y0 + r_ranhura_estator*sin(deg2rad(passo_deg*i - passo_deg/2));
    mi_addblocklabel(x, y);
    mi_selectlabel(x, y);
    mi_setblockprop('20 AWG', 0, mesh_ranhura, 'as', 0, 0, funcao_espiras_as(i));
    mi_clearselected();
end

% Loop para as ranhuras da fase 'bs'
funcao_espiras_bs = round(amplitude_funcao_Ns*sin(deg2rad(angulos_deg - 120)));
%figure, stem(funcao_espiras_bs);

for i = 1:Ns_ranhuras
    x = x0 + r_ranhura_estator*cos(deg2rad(passo_deg*i - passo_deg/2 - 2));
    y = y0 + r_ranhura_estator*sin(deg2rad(passo_deg*i - passo_deg/2 - 2));
    mi_addblocklabel(x, y);
    mi_selectlabel(x, y);
    mi_setblockprop('20 AWG', 0, mesh_ranhura, 'bs', 0, 0, funcao_espiras_bs(i));
    mi_clearselected();
end

% Loop para as ranhuras da fase 'cs'
funcao_espiras_cs = round(amplitude_funcao_Ns*sin(deg2rad(angulos_deg + 120)));
%figure, stem(funcao_espiras_cs);

for i = 1:Ns_ranhuras
    x = x0 + r_ranhura_estator*cos(deg2rad(passo_deg*i - passo_deg/2 + 2));
    y = y0 + r_ranhura_estator*sin(deg2rad(passo_deg*i - passo_deg/2 + 2));
    mi_addblocklabel(x, y);
    mi_selectlabel(x, y);
    mi_setblockprop('20 AWG', 0, mesh_ranhura, 'cs', 0, 0, funcao_espiras_cs(i));
    mi_clearselected();
end

% Rotaciona o rotor
passo_deg = 360/Nr_ranhuras;
mi_selectgroup(1);
mi_moverotate(x0, y0, passo_deg/2);
mi_clearselected();

mi_selectcircle(x0, y0, 1.0001*r_int_rotor, 4);
mi_moverotate(x0, y0, -passo_deg/2);
mi_clearselected();

% ###############################################################
% ########### ADICIONA MATERIAL AO RESTANTE DA MÁQUINA ##########
% ###############################################################

% Adiciona material ao eixo mecânico (malha definida automaticamente)
mi_addblocklabel(x0, y0);
mi_selectlabel(x0, y0);
mi_setblockprop('1020 Steel', 0, mesh_eixo, '<None>', 0, 1, 0);
mi_clearselected();

% Adiciona material à coroa de rotor
mi_addblocklabel(x0, y0 + d1);
mi_selectlabel(x0, y0 + d1);
mi_setblockprop('M-19 Steel', 0, mesh_coroa, '<None>', 0, 1, 0);
mi_clearselected();

% Adiciona material ao entreferro
passo_deg = 360/Ns_ranhuras;
x = x0 + r_int_estator*cos(deg2rad(90 + passo_deg/2));
y = y0 + r_int_estator*sin(deg2rad(90 + passo_deg/2));
mi_addblocklabel(x, y);
mi_selectlabel(x, y);
mi_setblockprop('Air', 0, mesh_gap, '<None>', 0, 0, 0);
mi_clearselected();

% Adiciona material à coroa de estator
mi_addblocklabel(x0, y0 + d2);
mi_selectlabel(x0, y0 + d2);
mi_setblockprop('M-19 Steel', 0, mesh_coroa, '<None>', 0, 0, 0);
mi_clearselected();

%% Adiciona material à região de fronteira (malha definida automaticamente)
%mi_addblocklabel(x0, y0 + d3);
%mi_selectlabel(x0, y0 + d3);
%mi_setblockprop('Air', 1, 0, '<None>', 0, 0, 0);
%mi_clearselected();

% Dá zoom em todo o modelo
mi_zoomnatural();

% Salva as edições no novo arquivo
mi_saveas('desenhos/maquinaModelo.FEM');

% Fecha o software FEMM
closefemm();