% ###############################################################
% ################### INICIALIZA AS VARIÁVEIS  ##################
% ###############################################################

% Monta-se uma matriz de 3 dimensões para cada indutância da máquina
% excêntrica, ou seja, haverá 36 matrizes 3D

% As linhas da matriz se referem à amplitude da excentricidade, variando de
% 10% a 90% do valor do entreferro com passo de 10%, ou seja, 9 valores
ampExc_passo_mm = 0.1*g;
ampExc_inicio_mm = 0.1*g;
ampExc_final_mm = g - ampExc_passo_mm;
ampExc_vetor_mm = ampExc_inicio_mm:ampExc_passo_mm:ampExc_final_mm;
%ampExc_vetor_mm = [0.1*g, 0.5*g, 0.9*g]; % PARA TESTES
ampExc_tam = length(ampExc_vetor_mm);

% As colunas da matriz se referem ao ângulo da excentricidade, variando de
% 0 a 360 graus com passo de 15 graus, ou seja, 25 valores
angExc_passo_deg = 15;
%angExc_passo_deg = 45; % PARA TESTES
angExc_inicio_deg = 0;
angExc_final_deg = 360;
%angExc_final_deg = 60; % PARA TESTES
angExc_vetor_deg = angExc_inicio_deg:angExc_passo_deg:angExc_final_deg;
angExc_tam = length(angExc_vetor_deg);

% Profundidade da matriz se refere ao ângulo de rotação do rotor, variando
% de 0 a 360 graus com passo de 15 graus, ou seja, 25 valores
% ### MESMAS CONFIGURAÇÕES DA MÁQUINA SAUDÁVEL ###

% Cria-se 36 matrizes de indutância
L0 = zeros(ampExc_tam,angExc_tam,angRot_tam);

% Matriz Lss
Lss11_er_matriz = L0; Lss12_er_matriz = L0; Lss13_er_matriz = L0;
Lss21_er_matriz = L0; Lss22_er_matriz = L0; Lss23_er_matriz = L0;
Lss31_er_matriz = L0; Lss32_er_matriz = L0; Lss33_er_matriz = L0;

% Matriz Lsr
Lsr11_er_matriz = L0; Lsr12_er_matriz = L0; Lsr13_er_matriz = L0;
Lsr21_er_matriz = L0; Lsr22_er_matriz = L0; Lsr23_er_matriz = L0;
Lsr31_er_matriz = L0; Lsr32_er_matriz = L0; Lsr33_er_matriz = L0;

% Matriz Lrs
Lrs11_er_matriz = L0; Lrs12_er_matriz = L0; Lrs13_er_matriz = L0;
Lrs21_er_matriz = L0; Lrs22_er_matriz = L0; Lrs23_er_matriz = L0;
Lrs31_er_matriz = L0; Lrs32_er_matriz = L0; Lrs33_er_matriz = L0;

% Matriz Lrr
Lrr11_er_matriz = L0; Lrr12_er_matriz = L0; Lrr13_er_matriz = L0;
Lrr21_er_matriz = L0; Lrr22_er_matriz = L0; Lrr23_er_matriz = L0;
Lrr31_er_matriz = L0; Lrr32_er_matriz = L0; Lrr33_er_matriz = L0;

% ###############################################################
% ####################### PREPARA O FEMM  #######################
% ###############################################################

% Abre o software
openfemm();

% Abre o documento de interesse (este arquivo não será editado)
opendocument('desenhos/maquinaRotorBobinadoSaudavel.FEM');

% Salva um arquivo temporário (este arquivo será editado)
mi_saveas('indutancias/temp.FEM');

% ###############################################################
% ############## REALIZA A SIMULAÇÃO DE 0º A 165º  ##############
% ###############################################################

i = 1; % Refere-se a linha
j = 1; % Refere-se a coluna
k = 1; % Refere-se a profundidade

for angRot_deg = angRot_vetor_deg(1:(angRot_tam-1)/2)
    for angExc_deg = angExc_vetor_deg(1:(angExc_tam-1)/2)
        for ampExc_mm = ampExc_vetor_mm
            % #############################################################
            % #### POSICIONA O ROTOR NA POSIÇÃO CORRETA PARA SIMULAÇÃO ####
            % #############################################################

            % Seleciona os elementos de rotor
            mi_selectgroup(1);

            % Faz a translação do rotor
            dx = ampExc_mm*cos(deg2rad(angExc_deg));
            dy = ampExc_mm*sin(deg2rad(angExc_deg));
            mi_movetranslate(x0+dx,y0+dy);

            % Limpa a seleção dos elementos de rotor
            mi_clearselected();

            % #############################################################
            % ########### AVALIANDO INDUTÂNCIAS PARA Ias = 1 A ############
            % #############################################################

            % Define o perfil de alimentação de corrente
            Ias = 1; Ibs = 0; Ics = 0;
            Iar_linha = 0; Ibr_linha = 0; Icr_linha = 0;
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

            % Retorna as propriedades dos circuitos
            propriedadesCircuitoAs = mo_getcircuitproperties('as');
            propriedadesCircuitoBs = mo_getcircuitproperties('bs');
            propriedadesCircuitoCs = mo_getcircuitproperties('cs');
            propriedadesCircuitoAr = mo_getcircuitproperties('ar');
            propriedadesCircuitoBr = mo_getcircuitproperties('br');
            propriedadesCircuitoCr = mo_getcircuitproperties('cr');

            % Preenche os vetores de indutância
            % * O 3º elemento do vetor captura o fluxo enlaçado do circuito
            % * As 3 primeiras indutâncias são no formato lambda/i
            % * As 3 últimas indutâncias são no formato lambda_linha/i
            Lss11_er_matriz(i,j,k) = propriedadesCircuitoAs(3)/Ias;
            Lss21_er_matriz(i,j,k) = propriedadesCircuitoBs(3)/Ias;
            Lss31_er_matriz(i,j,k) = propriedadesCircuitoCs(3)/Ias;
            Lrs11_er_matriz(i,j,k) = propriedadesCircuitoAr(3)/Ias;
            Lrs21_er_matriz(i,j,k) = propriedadesCircuitoBr(3)/Ias;
            Lrs31_er_matriz(i,j,k) = propriedadesCircuitoCr(3)/Ias;

            % Fecha a instância de pós-processamento atual
            mo_close();

            % #############################################################
            % ########### AVALIANDO INDUTÂNCIAS PARA Ibs = 1 A ############
            % #############################################################

            % Define o perfil de alimentação de corrente
            Ias = 0; Ibs = 1; Ics = 0;
            Iar_linha = 0; Ibr_linha = 0; Icr_linha = 0;
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

            % Retorna as propriedades dos circuitos
            propriedadesCircuitoAs = mo_getcircuitproperties('as');
            propriedadesCircuitoBs = mo_getcircuitproperties('bs');
            propriedadesCircuitoCs = mo_getcircuitproperties('cs');
            propriedadesCircuitoAr = mo_getcircuitproperties('ar');
            propriedadesCircuitoBr = mo_getcircuitproperties('br');
            propriedadesCircuitoCr = mo_getcircuitproperties('cr');

            % Preenche os vetores de indutância
            % * O 3º elemento do vetor captura o fluxo enlaçado do circuito
            % * As 3 primeiras indutâncias são no formato lambda/i
            % * As 3 últimas indutâncias são no formato lambda_linha/i
            Lss12_er_matriz(i,j,k) = propriedadesCircuitoAs(3)/Ibs;
            Lss22_er_matriz(i,j,k) = propriedadesCircuitoBs(3)/Ibs;
            Lss32_er_matriz(i,j,k) = propriedadesCircuitoCs(3)/Ibs;
            Lrs12_er_matriz(i,j,k) = propriedadesCircuitoAr(3)/Ibs;
            Lrs22_er_matriz(i,j,k) = propriedadesCircuitoBr(3)/Ibs;
            Lrs32_er_matriz(i,j,k) = propriedadesCircuitoCr(3)/Ibs;

            % Fecha a instância de pós-processamento atual
            mo_close();

            % #############################################################
            % ########### AVALIANDO INDUTÂNCIAS PARA Ics = 1 A ############
            % #############################################################

            % Define o perfil de alimentação de corrente
            Ias = 0; Ibs = 0; Ics = 1;
            Iar_linha = 0; Ibr_linha = 0; Icr_linha = 0;
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

            % Retorna as propriedades dos circuitos
            propriedadesCircuitoAs = mo_getcircuitproperties('as');
            propriedadesCircuitoBs = mo_getcircuitproperties('bs');
            propriedadesCircuitoCs = mo_getcircuitproperties('cs');
            propriedadesCircuitoAr = mo_getcircuitproperties('ar');
            propriedadesCircuitoBr = mo_getcircuitproperties('br');
            propriedadesCircuitoCr = mo_getcircuitproperties('cr');

            % Preenche os vetores de indutância
            % * O 3º elemento do vetor captura o fluxo enlaçado do circuito
            % * As 3 primeiras indutâncias são no formato lambda/i
            % * As 3 últimas indutâncias são no formato lambda_linha/i
            Lss13_er_matriz(i,j,k) = propriedadesCircuitoAs(3)/Ics;
            Lss23_er_matriz(i,j,k) = propriedadesCircuitoBs(3)/Ics;
            Lss33_er_matriz(i,j,k) = propriedadesCircuitoCs(3)/Ics;
            Lrs13_er_matriz(i,j,k) = propriedadesCircuitoAr(3)/Ics;
            Lrs23_er_matriz(i,j,k) = propriedadesCircuitoBr(3)/Ics;
            Lrs33_er_matriz(i,j,k) = propriedadesCircuitoCr(3)/Ics;

            % Fecha a instância de pós-processamento atual
            mo_close();

            % #############################################################
            % ######## AVALIANDO INDUTÂNCIAS PARA Iar_linha = 1 A #########
            % #############################################################

            % Define o perfil de alimentação de corrente
            Ias = 0; Ibs = 0; Ics = 0;
            Iar_linha = 1; Ibr_linha = 0; Icr_linha = 0;
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

            % Retorna as propriedades dos circuitos
            propriedadesCircuitoAs = mo_getcircuitproperties('as');
            propriedadesCircuitoBs = mo_getcircuitproperties('bs');
            propriedadesCircuitoCs = mo_getcircuitproperties('cs');
            propriedadesCircuitoAr = mo_getcircuitproperties('ar');
            propriedadesCircuitoBr = mo_getcircuitproperties('br');
            propriedadesCircuitoCr = mo_getcircuitproperties('cr');

            % Preenche os vetores de indutância
            % * O 3º elemento do vetor captura o fluxo enlaçado do circuito
            % * As 3 primeiras indutâncias são no formato lambda/i_linha
            % * As 3 últimas indutâncias são no formato lambda_linha/i_linha
            Lsr11_er_matriz(i,j,k) = propriedadesCircuitoAs(3)/Iar_linha;
            Lsr21_er_matriz(i,j,k) = propriedadesCircuitoBs(3)/Iar_linha;
            Lsr31_er_matriz(i,j,k) = propriedadesCircuitoCs(3)/Iar_linha;
            Lrr11_er_matriz(i,j,k) = propriedadesCircuitoAr(3)/Iar_linha;
            Lrr21_er_matriz(i,j,k) = propriedadesCircuitoBr(3)/Iar_linha;
            Lrr31_er_matriz(i,j,k) = propriedadesCircuitoCr(3)/Iar_linha;

            % Fecha a instância de pós-processamento atual
            mo_close();

            % #############################################################
            % ######## AVALIANDO INDUTÂNCIAS PARA Ibr_linha = 1 A #########
            % #############################################################

            % Define o perfil de alimentação de corrente
            Ias = 0; Ibs = 0; Ics = 0;
            Iar_linha = 0; Ibr_linha = 1; Icr_linha = 0;
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

            % Retorna as propriedades dos circuitos
            propriedadesCircuitoAs = mo_getcircuitproperties('as');
            propriedadesCircuitoBs = mo_getcircuitproperties('bs');
            propriedadesCircuitoCs = mo_getcircuitproperties('cs');
            propriedadesCircuitoAr = mo_getcircuitproperties('ar');
            propriedadesCircuitoBr = mo_getcircuitproperties('br');
            propriedadesCircuitoCr = mo_getcircuitproperties('cr');

            % Preenche os vetores de indutância
            % * O 3º elemento do vetor captura o fluxo enlaçado do circuito
            % * As 3 primeiras indutâncias são no formato lambda/i_linha
            % * As 3 últimas indutâncias são no formato lambda_linha/i_linha
            Lsr12_er_matriz(i,j,k) = propriedadesCircuitoAs(3)/Ibr_linha;
            Lsr22_er_matriz(i,j,k) = propriedadesCircuitoBs(3)/Ibr_linha;
            Lsr32_er_matriz(i,j,k) = propriedadesCircuitoCs(3)/Ibr_linha;
            Lrr12_er_matriz(i,j,k) = propriedadesCircuitoAr(3)/Ibr_linha;
            Lrr22_er_matriz(i,j,k) = propriedadesCircuitoBr(3)/Ibr_linha;
            Lrr32_er_matriz(i,j,k) = propriedadesCircuitoCr(3)/Ibr_linha;

            % Fecha a instância de pós-processamento atual
            mo_close();

            % #############################################################
            % ######## AVALIANDO INDUTÂNCIAS PARA Icr_linha = 1 A #########
            % #############################################################

            % Define o perfil de alimentação de corrente
            Ias = 0; Ibs = 0; Ics = 0;
            Iar_linha = 0; Ibr_linha = 0; Icr_linha = 1;
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

            % Retorna as propriedades dos circuitos
            propriedadesCircuitoAs = mo_getcircuitproperties('as');
            propriedadesCircuitoBs = mo_getcircuitproperties('bs');
            propriedadesCircuitoCs = mo_getcircuitproperties('cs');
            propriedadesCircuitoAr = mo_getcircuitproperties('ar');
            propriedadesCircuitoBr = mo_getcircuitproperties('br');
            propriedadesCircuitoCr = mo_getcircuitproperties('cr');

            % Preenche os vetores de indutância
            % * O 3º elemento do vetor captura o fluxo enlaçado do circuito
            % * As 3 primeiras indutâncias são no formato lambda/i_linha
            % * As 3 últimas indutâncias são no formato lambda_linha/i_linha
            Lsr13_er_matriz(i,j,k) = propriedadesCircuitoAs(3)/Icr_linha;
            Lsr23_er_matriz(i,j,k) = propriedadesCircuitoBs(3)/Icr_linha;
            Lsr33_er_matriz(i,j,k) = propriedadesCircuitoCs(3)/Icr_linha;
            Lrr13_er_matriz(i,j,k) = propriedadesCircuitoAr(3)/Icr_linha;
            Lrr23_er_matriz(i,j,k) = propriedadesCircuitoBr(3)/Icr_linha;
            Lrr33_er_matriz(i,j,k) = propriedadesCircuitoCr(3)/Icr_linha;

            % Fecha a instância de pós-processamento atual
            mo_close();

            %pause(); % PARA TESTES

            % #############################################################
            % ########## RETORNA COM A POSIÇÃO ORIGINAL DO ROTOR ##########
            % #############################################################

            % Seleciona os elementos de rotor
            mi_selectgroup(1);

            % Faz a translação do rotor de volta para a posição original
            mi_movetranslate(x0-dx,y0-dy);

            % Limpa a seleção dos elementos de rotor
            mi_clearselected();

            % Atualiza a linha para a próxima etapa
            i = i + 1;

            % Para mostrar o progresso
            disp(['Concluiu agora: ampExc_mm = ',num2str(ampExc_mm),...
                ' mm, angExc_deg = ',num2str(angExc_deg), ...
                ' graus, angRot_deg = ',num2str(angRot_deg),' graus']);
        end

        % Atualiza a coluna para a próxima etapa
        i = 1;
        j = j + 1;
    end

    % Seleciona os elementos de rotor (grupo 1)
    mi_selectgroup(1);

    % Faz a rotação do rotor
    mi_moverotate(x0,y0,angRot_passo_deg);

    % Limpa a seleção dos elementos de rotor
    mi_clearselected();

    % Atualiza a profundidade para a próxima etapa
    j = 1;
    k = k + 1;
end

% Fecha o software FEMM
closefemm();

% Deleta os arquivos temporários
system('rm indutancias/temp.FEM indutancias/temp.ans');

% ###############################################################
% ####### REPETE OS VALORES DE INDUTÂNCIA PARA AS COLUNAS #######
% ###############################################################

% Para todo os elementos, os valores da faixa 180º a 345º são iguais aos
% valores da faixa 0º a 165º, logo é só repetir. Todos os elementos têm
% seu valor de 360º iguais ao de 0º

i = 1; % Refere-se a linha
j = 1; % Refere-se a coluna
k = 1; % Refere-se a profundidade

for angRot_deg = angRot_vetor_deg(1:(angRot_tam-1)/2)
    for angExc_deg = angExc_vetor_deg(1:(angExc_tam-1)/2)
        for ampExc_mm = ampExc_vetor_mm
            % #############################################################
            % # PREENCHE VALORES DE INDUTÂNCIA DAS COLUNAS DE 180º A 345º #
            % #############################################################

            % Primeira coluna da matriz de 36 termos
            Lss11_er_matriz(i,j+(angExc_tam-1)/2,k) = Lss11_er_matriz(i,j,k);
            Lss21_er_matriz(i,j+(angExc_tam-1)/2,k) = Lss21_er_matriz(i,j,k);
            Lss31_er_matriz(i,j+(angExc_tam-1)/2,k) = Lss31_er_matriz(i,j,k);
            Lrs11_er_matriz(i,j+(angExc_tam-1)/2,k) = Lrs11_er_matriz(i,j,k);
            Lrs21_er_matriz(i,j+(angExc_tam-1)/2,k) = Lrs21_er_matriz(i,j,k);
            Lrs31_er_matriz(i,j+(angExc_tam-1)/2,k) = Lrs31_er_matriz(i,j,k);

            % Segunda coluna da matriz de 36 termos
            Lss12_er_matriz(i,j+(angExc_tam-1)/2,k) = Lss12_er_matriz(i,j,k);
            Lss22_er_matriz(i,j+(angExc_tam-1)/2,k) = Lss22_er_matriz(i,j,k);
            Lss32_er_matriz(i,j+(angExc_tam-1)/2,k) = Lss32_er_matriz(i,j,k);
            Lrs12_er_matriz(i,j+(angExc_tam-1)/2,k) = Lrs12_er_matriz(i,j,k);
            Lrs22_er_matriz(i,j+(angExc_tam-1)/2,k) = Lrs22_er_matriz(i,j,k);
            Lrs32_er_matriz(i,j+(angExc_tam-1)/2,k) = Lrs32_er_matriz(i,j,k);

            % Terceira coluna da matriz de 36 termos
            Lss13_er_matriz(i,j+(angExc_tam-1)/2,k) = Lss13_er_matriz(i,j,k);
            Lss23_er_matriz(i,j+(angExc_tam-1)/2,k) = Lss23_er_matriz(i,j,k);
            Lss33_er_matriz(i,j+(angExc_tam-1)/2,k) = Lss33_er_matriz(i,j,k);
            Lrs13_er_matriz(i,j+(angExc_tam-1)/2,k) = Lrs13_er_matriz(i,j,k);
            Lrs23_er_matriz(i,j+(angExc_tam-1)/2,k) = Lrs23_er_matriz(i,j,k);
            Lrs33_er_matriz(i,j+(angExc_tam-1)/2,k) = Lrs33_er_matriz(i,j,k);

            % Quarta coluna da matriz de 36 termos
            Lsr11_er_matriz(i,j+(angExc_tam-1)/2,k) = Lsr11_er_matriz(i,j,k);
            Lsr21_er_matriz(i,j+(angExc_tam-1)/2,k) = Lsr21_er_matriz(i,j,k);
            Lsr31_er_matriz(i,j+(angExc_tam-1)/2,k) = Lsr31_er_matriz(i,j,k);
            Lrr11_er_matriz(i,j+(angExc_tam-1)/2,k) = Lrr11_er_matriz(i,j,k);
            Lrr21_er_matriz(i,j+(angExc_tam-1)/2,k) = Lrr21_er_matriz(i,j,k);
            Lrr31_er_matriz(i,j+(angExc_tam-1)/2,k) = Lrr31_er_matriz(i,j,k);

            % Quinta coluna da matriz de 36 termos
            Lsr12_er_matriz(i,j+(angExc_tam-1)/2,k) = Lsr12_er_matriz(i,j,k);
            Lsr22_er_matriz(i,j+(angExc_tam-1)/2,k) = Lsr22_er_matriz(i,j,k);
            Lsr32_er_matriz(i,j+(angExc_tam-1)/2,k) = Lsr32_er_matriz(i,j,k);
            Lrr12_er_matriz(i,j+(angExc_tam-1)/2,k) = Lrr12_er_matriz(i,j,k);
            Lrr22_er_matriz(i,j+(angExc_tam-1)/2,k) = Lrr22_er_matriz(i,j,k);
            Lrr32_er_matriz(i,j+(angExc_tam-1)/2,k) = Lrr32_er_matriz(i,j,k);

            % Sexta coluna da matriz de 36 termos
            Lsr13_er_matriz(i,j+(angExc_tam-1)/2,k) = Lsr13_er_matriz(i,j,k);
            Lsr23_er_matriz(i,j+(angExc_tam-1)/2,k) = Lsr23_er_matriz(i,j,k);
            Lsr33_er_matriz(i,j+(angExc_tam-1)/2,k) = Lsr33_er_matriz(i,j,k);
            Lrr13_er_matriz(i,j+(angExc_tam-1)/2,k) = Lrr13_er_matriz(i,j,k);
            Lrr23_er_matriz(i,j+(angExc_tam-1)/2,k) = Lrr23_er_matriz(i,j,k);
            Lrr33_er_matriz(i,j+(angExc_tam-1)/2,k) = Lrr33_er_matriz(i,j,k);

            % #############################################################
            % ##### PREENCHE VALORES DE INDUTÂNCIA DA COLUNA DE 360º ######
            % #############################################################

            if j == 1
                % Primeira coluna da matriz de 36 termos
                Lss11_er_matriz(i,angExc_tam,k) = Lss11_er_matriz(i,j,k);
                Lss21_er_matriz(i,angExc_tam,k) = Lss21_er_matriz(i,j,k);
                Lss31_er_matriz(i,angExc_tam,k) = Lss31_er_matriz(i,j,k);
                Lrs11_er_matriz(i,angExc_tam,k) = Lrs11_er_matriz(i,j,k);
                Lrs21_er_matriz(i,angExc_tam,k) = Lrs21_er_matriz(i,j,k);
                Lrs31_er_matriz(i,angExc_tam,k) = Lrs31_er_matriz(i,j,k);

                % Segunda coluna da matriz de 36 termos
                Lss12_er_matriz(i,angExc_tam,k) = Lss12_er_matriz(i,j,k);
                Lss22_er_matriz(i,angExc_tam,k) = Lss22_er_matriz(i,j,k);
                Lss32_er_matriz(i,angExc_tam,k) = Lss32_er_matriz(i,j,k);
                Lrs12_er_matriz(i,angExc_tam,k) = Lrs12_er_matriz(i,j,k);
                Lrs22_er_matriz(i,angExc_tam,k) = Lrs22_er_matriz(i,j,k);
                Lrs32_er_matriz(i,angExc_tam,k) = Lrs32_er_matriz(i,j,k);

                % Terceira coluna da matriz de 36 termos
                Lss13_er_matriz(i,angExc_tam,k) = Lss13_er_matriz(i,j,k);
                Lss23_er_matriz(i,angExc_tam,k) = Lss23_er_matriz(i,j,k);
                Lss33_er_matriz(i,angExc_tam,k) = Lss33_er_matriz(i,j,k);
                Lrs13_er_matriz(i,angExc_tam,k) = Lrs13_er_matriz(i,j,k);
                Lrs23_er_matriz(i,angExc_tam,k) = Lrs23_er_matriz(i,j,k);
                Lrs33_er_matriz(i,angExc_tam,k) = Lrs33_er_matriz(i,j,k);

                % Quarta coluna da matriz de 36 termos
                Lsr11_er_matriz(i,angExc_tam,k) = Lsr11_er_matriz(i,j,k);
                Lsr21_er_matriz(i,angExc_tam,k) = Lsr21_er_matriz(i,j,k);
                Lsr31_er_matriz(i,angExc_tam,k) = Lsr31_er_matriz(i,j,k);
                Lrr11_er_matriz(i,angExc_tam,k) = Lrr11_er_matriz(i,j,k);
                Lrr21_er_matriz(i,angExc_tam,k) = Lrr21_er_matriz(i,j,k);
                Lrr31_er_matriz(i,angExc_tam,k) = Lrr31_er_matriz(i,j,k);

                % Quinta coluna da matriz de 36 termos
                Lsr12_er_matriz(i,angExc_tam,k) = Lsr12_er_matriz(i,j,k);
                Lsr22_er_matriz(i,angExc_tam,k) = Lsr22_er_matriz(i,j,k);
                Lsr32_er_matriz(i,angExc_tam,k) = Lsr32_er_matriz(i,j,k);
                Lrr12_er_matriz(i,angExc_tam,k) = Lrr12_er_matriz(i,j,k);
                Lrr22_er_matriz(i,angExc_tam,k) = Lrr22_er_matriz(i,j,k);
                Lrr32_er_matriz(i,angExc_tam,k) = Lrr32_er_matriz(i,j,k);

                % Sexta coluna da matriz de 36 termos
                Lsr13_er_matriz(i,angExc_tam,k) = Lsr13_er_matriz(i,j,k);
                Lsr23_er_matriz(i,angExc_tam,k) = Lsr23_er_matriz(i,j,k);
                Lsr33_er_matriz(i,angExc_tam,k) = Lsr33_er_matriz(i,j,k);
                Lrr13_er_matriz(i,angExc_tam,k) = Lrr13_er_matriz(i,j,k);
                Lrr23_er_matriz(i,angExc_tam,k) = Lrr23_er_matriz(i,j,k);
                Lrr33_er_matriz(i,angExc_tam,k) = Lrr33_er_matriz(i,j,k);
            end

            % Atualiza a linha para a próxima etapa
            i = i + 1;
        end

        % Atualiza a coluna para a próxima etapa
        i = 1;
        j = j + 1;
    end

    % Atualiza a profundidade para a próxima etapa
    j = 1;
    k = k + 1;
end

% ###############################################################
% ###### REPETE OS VALORES DE INDUTÂNCIA PARA PROFUNDIDADE ######
% ###############################################################

% Para os elementos Lss e Lrr, os valores da faixa 180º a 345º são iguais
% aos valores da faixa 0º a 165º, logo é só repetir. Já para os elementos
% Lsr e Lrs, os valores da faixa 180º a 345º têm valores com sinal oposto
% ao da faixa 0º a 165º, logo é só repetir com o sinal trocado. Por fim,
% todos os elementos têm seu valor de 360º iguais ao de 0º

k = 1; % Refere-se a profundidade

for angRot_deg = angRot_vetor_deg(1:(angRot_tam-1)/2)
    % ###############################################################
    %  PREENCHE VALORES DE INDUTÂNCIA DE PROFUNDIDADE DE 180º A 345º
    % ###############################################################

    % Primeira coluna da matriz de 36 termos
    Lss11_er_matriz(:,:,k+(angRot_tam-1)/2) = Lss11_er_matriz(:,:,k);
    Lss21_er_matriz(:,:,k+(angRot_tam-1)/2) = Lss21_er_matriz(:,:,k);
    Lss31_er_matriz(:,:,k+(angRot_tam-1)/2) = Lss31_er_matriz(:,:,k);
    Lrs11_er_matriz(:,:,k+(angRot_tam-1)/2) = -Lrs11_er_matriz(:,:,k);
    Lrs21_er_matriz(:,:,k+(angRot_tam-1)/2) = -Lrs21_er_matriz(:,:,k);
    Lrs31_er_matriz(:,:,k+(angRot_tam-1)/2) = -Lrs31_er_matriz(:,:,k);

    % Segunda coluna da matriz de 36 termos
    Lss12_er_matriz(:,:,k+(angRot_tam-1)/2) = Lss12_er_matriz(:,:,k);
    Lss22_er_matriz(:,:,k+(angRot_tam-1)/2) = Lss22_er_matriz(:,:,k);
    Lss32_er_matriz(:,:,k+(angRot_tam-1)/2) = Lss32_er_matriz(:,:,k);
    Lrs12_er_matriz(:,:,k+(angRot_tam-1)/2) = -Lrs12_er_matriz(:,:,k);
    Lrs22_er_matriz(:,:,k+(angRot_tam-1)/2) = -Lrs22_er_matriz(:,:,k);
    Lrs32_er_matriz(:,:,k+(angRot_tam-1)/2) = -Lrs32_er_matriz(:,:,k);

    % Terceira coluna da matriz de 36 termos
    Lss13_er_matriz(:,:,k+(angRot_tam-1)/2) = Lss13_er_matriz(:,:,k);
    Lss23_er_matriz(:,:,k+(angRot_tam-1)/2) = Lss23_er_matriz(:,:,k);
    Lss33_er_matriz(:,:,k+(angRot_tam-1)/2) = Lss33_er_matriz(:,:,k);
    Lrs13_er_matriz(:,:,k+(angRot_tam-1)/2) = -Lrs13_er_matriz(:,:,k);
    Lrs23_er_matriz(:,:,k+(angRot_tam-1)/2) = -Lrs23_er_matriz(:,:,k);
    Lrs33_er_matriz(:,:,k+(angRot_tam-1)/2) = -Lrs33_er_matriz(:,:,k);

    % Quarta coluna da matriz de 36 termos
    Lsr11_er_matriz(:,:,k+(angRot_tam-1)/2) = -Lsr11_er_matriz(:,:,k);
    Lsr21_er_matriz(:,:,k+(angRot_tam-1)/2) = -Lsr21_er_matriz(:,:,k);
    Lsr31_er_matriz(:,:,k+(angRot_tam-1)/2) = -Lsr31_er_matriz(:,:,k);
    Lrr11_er_matriz(:,:,k+(angRot_tam-1)/2) = Lrr11_er_matriz(:,:,k);
    Lrr21_er_matriz(:,:,k+(angRot_tam-1)/2) = Lrr21_er_matriz(:,:,k);
    Lrr31_er_matriz(:,:,k+(angRot_tam-1)/2) = Lrr31_er_matriz(:,:,k);

    % Quinta coluna da matriz de 36 termos
    Lsr12_er_matriz(:,:,k+(angRot_tam-1)/2) = -Lsr12_er_matriz(:,:,k);
    Lsr22_er_matriz(:,:,k+(angRot_tam-1)/2) = -Lsr22_er_matriz(:,:,k);
    Lsr32_er_matriz(:,:,k+(angRot_tam-1)/2) = -Lsr32_er_matriz(:,:,k);
    Lrr12_er_matriz(:,:,k+(angRot_tam-1)/2) = Lrr12_er_matriz(:,:,k);
    Lrr22_er_matriz(:,:,k+(angRot_tam-1)/2) = Lrr22_er_matriz(:,:,k);
    Lrr32_er_matriz(:,:,k+(angRot_tam-1)/2) = Lrr32_er_matriz(:,:,k);

    % Sexta coluna da matriz de 36 termos
    Lsr13_er_matriz(:,:,k+(angRot_tam-1)/2) = -Lsr13_er_matriz(:,:,k);
    Lsr23_er_matriz(:,:,k+(angRot_tam-1)/2) = -Lsr23_er_matriz(:,:,k);
    Lsr33_er_matriz(:,:,k+(angRot_tam-1)/2) = -Lsr33_er_matriz(:,:,k);
    Lrr13_er_matriz(:,:,k+(angRot_tam-1)/2) = Lrr13_er_matriz(:,:,k);
    Lrr23_er_matriz(:,:,k+(angRot_tam-1)/2) = Lrr23_er_matriz(:,:,k);
    Lrr33_er_matriz(:,:,k+(angRot_tam-1)/2) = Lrr33_er_matriz(:,:,k);

    % ###############################################################
    % ### PREENCHE VALORES DE INDUTÂNCIA DE PROFUNDIDADE DE 360º ####
    % ###############################################################

    if k == 1
        % Primeira coluna da matriz de 36 termos
        Lss11_er_matriz(:,:,angRot_tam) = Lss11_er_matriz(:,:,k);
        Lss21_er_matriz(:,:,angRot_tam) = Lss21_er_matriz(:,:,k);
        Lss31_er_matriz(:,:,angRot_tam) = Lss31_er_matriz(:,:,k);
        Lrs11_er_matriz(:,:,angRot_tam) = Lrs11_er_matriz(:,:,k);
        Lrs21_er_matriz(:,:,angRot_tam) = Lrs21_er_matriz(:,:,k);
        Lrs31_er_matriz(:,:,angRot_tam) = Lrs31_er_matriz(:,:,k);

        % Segunda coluna da matriz de 36 termos
        Lss12_er_matriz(:,:,angRot_tam) = Lss12_er_matriz(:,:,k);
        Lss22_er_matriz(:,:,angRot_tam) = Lss22_er_matriz(:,:,k);
        Lss32_er_matriz(:,:,angRot_tam) = Lss32_er_matriz(:,:,k);
        Lrs12_er_matriz(:,:,angRot_tam) = Lrs12_er_matriz(:,:,k);
        Lrs22_er_matriz(:,:,angRot_tam) = Lrs22_er_matriz(:,:,k);
        Lrs32_er_matriz(:,:,angRot_tam) = Lrs32_er_matriz(:,:,k);

        % Terceira coluna da matriz de 36 termos
        Lss13_er_matriz(:,:,angRot_tam) = Lss13_er_matriz(:,:,k);
        Lss23_er_matriz(:,:,angRot_tam) = Lss23_er_matriz(:,:,k);
        Lss33_er_matriz(:,:,angRot_tam) = Lss33_er_matriz(:,:,k);
        Lrs13_er_matriz(:,:,angRot_tam) = Lrs13_er_matriz(:,:,k);
        Lrs23_er_matriz(:,:,angRot_tam) = Lrs23_er_matriz(:,:,k);
        Lrs33_er_matriz(:,:,angRot_tam) = Lrs33_er_matriz(:,:,k);

        % Quarta coluna da matriz de 36 termos
        Lsr11_er_matriz(:,:,angRot_tam) = Lsr11_er_matriz(:,:,k);
        Lsr21_er_matriz(:,:,angRot_tam) = Lsr21_er_matriz(:,:,k);
        Lsr31_er_matriz(:,:,angRot_tam) = Lsr31_er_matriz(:,:,k);
        Lrr11_er_matriz(:,:,angRot_tam) = Lrr11_er_matriz(:,:,k);
        Lrr21_er_matriz(:,:,angRot_tam) = Lrr21_er_matriz(:,:,k);
        Lrr31_er_matriz(:,:,angRot_tam) = Lrr31_er_matriz(:,:,k);

        % Quinta coluna da matriz de 36 termos
        Lsr12_er_matriz(:,:,angRot_tam) = Lsr12_er_matriz(:,:,k);
        Lsr22_er_matriz(:,:,angRot_tam) = Lsr22_er_matriz(:,:,k);
        Lsr32_er_matriz(:,:,angRot_tam) = Lsr32_er_matriz(:,:,k);
        Lrr12_er_matriz(:,:,angRot_tam) = Lrr12_er_matriz(:,:,k);
        Lrr22_er_matriz(:,:,angRot_tam) = Lrr22_er_matriz(:,:,k);
        Lrr32_er_matriz(:,:,angRot_tam) = Lrr32_er_matriz(:,:,k);

        % Sexta coluna da matriz de 36 termos
        Lsr13_er_matriz(:,:,angRot_tam) = Lsr13_er_matriz(:,:,k);
        Lsr23_er_matriz(:,:,angRot_tam) = Lsr23_er_matriz(:,:,k);
        Lsr33_er_matriz(:,:,angRot_tam) = Lsr33_er_matriz(:,:,k);
        Lrr13_er_matriz(:,:,angRot_tam) = Lrr13_er_matriz(:,:,k);
        Lrr23_er_matriz(:,:,angRot_tam) = Lrr23_er_matriz(:,:,k);
        Lrr33_er_matriz(:,:,angRot_tam) = Lrr33_er_matriz(:,:,k);
    end

    % Atualiza a linha para a próxima etapa
    k = k + 1;
end