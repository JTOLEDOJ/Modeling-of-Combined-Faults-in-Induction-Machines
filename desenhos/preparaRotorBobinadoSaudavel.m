% ###############################################################
% ####################### PREPARA O FEMM  #######################
% ###############################################################

% Abre o software FEMM
openfemm();

% Abre o documento de interesse (este arquivo não será editado)
opendocument('desenhos/maquinaModelo.FEM');

% Cria um novo arquivo (este arquivo será editado)
mi_saveas('desenhos/maquinaRotorBobinadoSaudavel.FEM');

% ###############################################################
% ########## ADICIONA MATERIAL E CIRCUITO NAS RANHURAS ##########
% ###############################################################

passo_deg = 360/Nr_ranhuras;
angulos_deg = passo_deg/2:passo_deg:360-passo_deg/2;

% Loop para as ranhuras da fase 'ar'
amplitude_funcao_Nr = 14.85;
funcao_espiras_ar = round(amplitude_funcao_Nr*sin(deg2rad(angulos_deg)));
%figure, stem(funcao_espiras_ar);
Nr_efetivo = sum(funcao_espiras_ar(1:end/2));    % Nr_efetivo = 145

for i = 1:Nr_ranhuras
    x = x0 + r_ranhura_rotor*cos(deg2rad(passo_deg*i - passo_deg/2));
    y = y0 + r_ranhura_rotor*sin(deg2rad(passo_deg*i - passo_deg/2));
    mi_addblocklabel(x, y);
    mi_selectlabel(x, y);
    mi_setblockprop('20 AWG', 0, mesh_ranhura, 'ar', 0, 1, funcao_espiras_ar(i));
    mi_clearselected();
end

% Loop para as ranhuras da fase 'br'
funcao_espiras_br = round(amplitude_funcao_Nr*sin(deg2rad(angulos_deg - 120)));
%figure, stem(funcao_espiras_br);

for i = 1:Nr_ranhuras
    x = x0 + r_ranhura_rotor*cos(deg2rad(passo_deg*i - passo_deg/2 - 2));
    y = y0 + r_ranhura_rotor*sin(deg2rad(passo_deg*i - passo_deg/2 - 2));
    mi_addblocklabel(x, y);
    mi_selectlabel(x, y);
    mi_setblockprop('20 AWG', 0, mesh_ranhura, 'br', 0, 1, funcao_espiras_br(i));
    mi_clearselected();
end

% Loop para as ranhuras da fase 'cr'
funcao_espiras_cr = round(amplitude_funcao_Nr*sin(deg2rad(angulos_deg + 120)));
%figure, stem(funcao_espiras_cr);

for i = 1:Nr_ranhuras
    x = x0 + r_ranhura_rotor*cos(deg2rad(passo_deg*i - passo_deg/2 + 2));
    y = y0 + r_ranhura_rotor*sin(deg2rad(passo_deg*i - passo_deg/2 + 2));
    mi_addblocklabel(x, y);
    mi_selectlabel(x, y);
    mi_setblockprop('20 AWG', 0, mesh_ranhura, 'cr', 0, 1, funcao_espiras_cr(i));
    mi_clearselected();
end

% Dá zoom em todo o modelo
mi_zoomnatural();

% Salva as edições no novo arquivo
mi_saveas('desenhos/maquinaRotorBobinadoSaudavel.FEM');

% Fecha o software FEMM
closefemm();