% ###############################################################
% ####################### PREPARA O FEMM  #######################
% ###############################################################

% Abre o software FEMM
openfemm();

% Abre o documento de interesse (este arquivo não será editado)
opendocument('desenhos/maquinaModelo.FEM');

% Cria um novo arquivo (este arquivo será editado)
mi_saveas('desenhos/maquinaRotorGaiolaSaudavel.FEM');

% ###############################################################
% ########## ADICIONA MATERIAL E CIRCUITO NAS RANHURAS ##########
% ###############################################################

% Loop para as ranhuras de rotor
passo_deg = 360/Nr_ranhuras;

for i = 1:Nr_ranhuras
    x = x0 + r_ranhura_rotor*cos(deg2rad(passo_deg*i - passo_deg/2));
    y = y0 + r_ranhura_rotor*sin(deg2rad(passo_deg*i - passo_deg/2));
    mi_addblocklabel(x, y);
    mi_selectlabel(x, y);
    mi_setblockprop('Aluminum, 1100', 0, mesh_ranhura, '<None>', 0, 1, 0);
    mi_clearselected();

    x = x0 + r_ranhura_rotor*cos(deg2rad(passo_deg*i - passo_deg/2 - 2));
    y = y0 + r_ranhura_rotor*sin(deg2rad(passo_deg*i - passo_deg/2 - 2));
    mi_addblocklabel(x, y);
    mi_selectlabel(x, y);
    mi_setblockprop('Aluminum, 1100', 0, mesh_ranhura, '<None>', 0, 1, 0);
    mi_clearselected();

    x = x0 + r_ranhura_rotor*cos(deg2rad(passo_deg*i - passo_deg/2 + 2));
    y = y0 + r_ranhura_rotor*sin(deg2rad(passo_deg*i - passo_deg/2 + 2));
    mi_addblocklabel(x, y);
    mi_selectlabel(x, y);
    mi_setblockprop('Aluminum, 1100', 0, mesh_ranhura, '<None>', 0, 1, 0);
    mi_clearselected();
end

% Dá zoom em todo o modelo
mi_zoomnatural();

% Salva as edições no novo arquivo
mi_saveas('desenhos/maquinaRotorGaiolaSaudavel.FEM');

% Fecha o software FEMM
closefemm();