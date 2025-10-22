% ###############################################################
% ################### INICIALIZA AS VARIÁVEIS  ##################
% ###############################################################

% Se refere ao ângulo de rotação do rotor, variando de 0 a 360 graus com
% passo de 15 graus, ou seja, 25 valores
angRot_passo_deg = 15;
angRot_inicio_deg = 0;
angRot_final_deg = 360;
%angRot_final_deg = 60; % PARA TESTES
angRot_vetor_deg = angRot_inicio_deg:angRot_passo_deg:angRot_final_deg;
angRot_tam = length(angRot_vetor_deg);

% Cria-se 36 matrizes de indutância
L0 = zeros(1,angRot_tam);

% Matriz Lss
Lss11_saud_vetor = L0; Lss12_saud_vetor = L0; Lss13_saud_vetor = L0;
Lss21_saud_vetor = L0; Lss22_saud_vetor = L0; Lss23_saud_vetor = L0;
Lss31_saud_vetor = L0; Lss32_saud_vetor = L0; Lss33_saud_vetor = L0;

% Matriz Lsr
Lsr11_saud_vetor = L0; Lsr12_saud_vetor = L0; Lsr13_saud_vetor = L0;
Lsr21_saud_vetor = L0; Lsr22_saud_vetor = L0; Lsr23_saud_vetor = L0;
Lsr31_saud_vetor = L0; Lsr32_saud_vetor = L0; Lsr33_saud_vetor = L0;

% Matriz Lrs
Lrs11_saud_vetor = L0; Lrs12_saud_vetor = L0; Lrs13_saud_vetor = L0;
Lrs21_saud_vetor = L0; Lrs22_saud_vetor = L0; Lrs23_saud_vetor = L0;
Lrs31_saud_vetor = L0; Lrs32_saud_vetor = L0; Lrs33_saud_vetor = L0;

% Matriz Lrr
Lrr11_saud_vetor = L0; Lrr12_saud_vetor = L0; Lrr13_saud_vetor = L0;
Lrr21_saud_vetor = L0; Lrr22_saud_vetor = L0; Lrr23_saud_vetor = L0;
Lrr31_saud_vetor = L0; Lrr32_saud_vetor = L0; Lrr33_saud_vetor = L0;

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

k = 1;
for angRot_deg = angRot_vetor_deg(1:(angRot_tam-1)/2)
    % ###############################################################
    % ############ AVALIANDO INDUTÂNCIAS PARA Ias = 1 A #############
    % ###############################################################

    % Define o perfil de alimentação de corrente
    Ias = 1; Ibs = 0; Ics = 0; Iar_linha = 0; Ibr_linha = 0; Icr_linha = 0;
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
    Lss11_saud_vetor(k) = propriedadesCircuitoAs(3)/Ias;
    Lss21_saud_vetor(k) = propriedadesCircuitoBs(3)/Ias;
    Lss31_saud_vetor(k) = propriedadesCircuitoCs(3)/Ias;
    Lrs11_saud_vetor(k) = propriedadesCircuitoAr(3)/Ias;
    Lrs21_saud_vetor(k) = propriedadesCircuitoBr(3)/Ias;
    Lrs31_saud_vetor(k) = propriedadesCircuitoCr(3)/Ias;

    % Fecha a instância de pós-processamento atual
    mo_close();

    % ###############################################################
    % ############ AVALIANDO INDUTÂNCIAS PARA Ibs = 1 A #############
    % ###############################################################

    % Define o perfil de alimentação de corrente
    Ias = 0; Ibs = 1; Ics = 0; Iar_linha = 0; Ibr_linha = 0; Icr_linha = 0;
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
    Lss12_saud_vetor(k) = propriedadesCircuitoAs(3)/Ibs;
    Lss22_saud_vetor(k) = propriedadesCircuitoBs(3)/Ibs;
    Lss32_saud_vetor(k) = propriedadesCircuitoCs(3)/Ibs;
    Lrs12_saud_vetor(k) = propriedadesCircuitoAr(3)/Ibs;
    Lrs22_saud_vetor(k) = propriedadesCircuitoBr(3)/Ibs;
    Lrs32_saud_vetor(k) = propriedadesCircuitoCr(3)/Ibs;

    % Fecha a instância de pós-processamento atual
    mo_close();

    % ###############################################################
    % ############ AVALIANDO INDUTÂNCIAS PARA Ics = 1 A #############
    % ###############################################################

    % Define o perfil de alimentação de corrente
    Ias = 0; Ibs = 0; Ics = 1; Iar_linha = 0; Ibr_linha = 0; Icr_linha = 0;
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
    Lss13_saud_vetor(k) = propriedadesCircuitoAs(3)/Ics;
    Lss23_saud_vetor(k) = propriedadesCircuitoBs(3)/Ics;
    Lss33_saud_vetor(k) = propriedadesCircuitoCs(3)/Ics;
    Lrs13_saud_vetor(k) = propriedadesCircuitoAr(3)/Ics;
    Lrs23_saud_vetor(k) = propriedadesCircuitoBr(3)/Ics;
    Lrs33_saud_vetor(k) = propriedadesCircuitoCr(3)/Ics;

    % Fecha a instância de pós-processamento atual
    mo_close();

    % ###############################################################
    % ######### AVALIANDO INDUTÂNCIAS PARA Iar_linha = 1 A ##########
    % ###############################################################

    % Define o perfil de alimentação de corrente
    Ias = 0; Ibs = 0; Ics = 0; Iar_linha = 1; Ibr_linha = 0; Icr_linha = 0;
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
    Lsr11_saud_vetor(k) = propriedadesCircuitoAs(3)/Iar_linha;
    Lsr21_saud_vetor(k) = propriedadesCircuitoBs(3)/Iar_linha;
    Lsr31_saud_vetor(k) = propriedadesCircuitoCs(3)/Iar_linha;
    Lrr11_saud_vetor(k) = propriedadesCircuitoAr(3)/Iar_linha;
    Lrr21_saud_vetor(k) = propriedadesCircuitoBr(3)/Iar_linha;
    Lrr31_saud_vetor(k) = propriedadesCircuitoCr(3)/Iar_linha;

    % Fecha a instância de pós-processamento atual
    mo_close();

    % ###############################################################
    % ######### AVALIANDO INDUTÂNCIAS PARA Ibr_linha = 1 A ##########
    % ###############################################################

    % Define o perfil de alimentação de corrente
    Ias = 0; Ibs = 0; Ics = 0; Iar_linha = 0; Ibr_linha = 1; Icr_linha = 0;
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
    Lsr12_saud_vetor(k) = propriedadesCircuitoAs(3)/Ibr_linha;
    Lsr22_saud_vetor(k) = propriedadesCircuitoBs(3)/Ibr_linha;
    Lsr32_saud_vetor(k) = propriedadesCircuitoCs(3)/Ibr_linha;
    Lrr12_saud_vetor(k) = propriedadesCircuitoAr(3)/Ibr_linha;
    Lrr22_saud_vetor(k) = propriedadesCircuitoBr(3)/Ibr_linha;
    Lrr32_saud_vetor(k) = propriedadesCircuitoCr(3)/Ibr_linha;

    % Fecha a instância de pós-processamento atual
    mo_close();

    % ###############################################################
    % ######### AVALIANDO INDUTÂNCIAS PARA Icr_linha = 1 A ##########
    % ###############################################################

    % Define o perfil de alimentação de corrente
    Ias = 0; Ibs = 0; Ics = 0; Iar_linha = 0; Ibr_linha = 0; Icr_linha = 1;
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
    Lsr13_saud_vetor(k) = propriedadesCircuitoAs(3)/Icr_linha;
    Lsr23_saud_vetor(k) = propriedadesCircuitoBs(3)/Icr_linha;
    Lsr33_saud_vetor(k) = propriedadesCircuitoCs(3)/Icr_linha;
    Lrr13_saud_vetor(k) = propriedadesCircuitoAr(3)/Icr_linha;
    Lrr23_saud_vetor(k) = propriedadesCircuitoBr(3)/Icr_linha;
    Lrr33_saud_vetor(k) = propriedadesCircuitoCr(3)/Icr_linha;

    % Fecha a instância de pós-processamento atual
    mo_close();

    %pause(); % PARA TESTES

    % Para mostrar o progresso
    disp(['Concluiu agora: angRot_deg = ',num2str(angRot_deg),' graus']);

    % Seleciona os elementos de rotor (grupo 1)
    mi_selectgroup(1);

    % Faz a rotação do rotor
    mi_moverotate(x0,y0,angRot_passo_deg);

    % Limpa a seleção dos elementos de rotor
    mi_clearselected();

    % Atualiza a profundidade para a próxima etapa
    k = k + 1;
end

% Fecha o software FEMM
closefemm();

% Deleta os arquivos temporários
system('rm indutancias/temp.FEM indutancias/temp.ans');

% ###############################################################
% ###### REPETE OS VALORES DE INDUTÂNCIA PARA PROFUNDIDADE ######
% ###############################################################

% Para os elementos Lss e Lrr, os valores da faixa 180º a 345º são iguais
% aos valores da faixa 0º a 165º, logo é só repetir. Já para os elementos
% Lsr e Lrs, os valores da faixa 180º a 345º têm valores com sinal oposto
% ao da faixa 0º a 165º, logo é só repetir com o sinal trocado. Por fim,
% todos os elementos têm seu valor de 360º iguais ao de 0º

k = 1;
for angRot_deg = angRot_vetor_deg(1:(angRot_tam-1)/2)
    % ###############################################################
    %  PREENCHE VALORES DE INDUTÂNCIA DE PROFUNDIDADE DE 180º A 345º
    % ###############################################################

    % Primeira coluna da matriz de 36 termos
    Lss11_saud_vetor(k+(angRot_tam-1)/2) = Lss11_saud_vetor(k);
    Lss21_saud_vetor(k+(angRot_tam-1)/2) = Lss21_saud_vetor(k);
    Lss31_saud_vetor(k+(angRot_tam-1)/2) = Lss31_saud_vetor(k);
    Lrs11_saud_vetor(k+(angRot_tam-1)/2) = -Lrs11_saud_vetor(k);
    Lrs21_saud_vetor(k+(angRot_tam-1)/2) = -Lrs21_saud_vetor(k);
    Lrs31_saud_vetor(k+(angRot_tam-1)/2) = -Lrs31_saud_vetor(k);

    % Segunda coluna da matriz de 36 termos
    Lss12_saud_vetor(k+(angRot_tam-1)/2) = Lss12_saud_vetor(k);
    Lss22_saud_vetor(k+(angRot_tam-1)/2) = Lss22_saud_vetor(k);
    Lss32_saud_vetor(k+(angRot_tam-1)/2) = Lss32_saud_vetor(k);
    Lrs12_saud_vetor(k+(angRot_tam-1)/2) = -Lrs12_saud_vetor(k);
    Lrs22_saud_vetor(k+(angRot_tam-1)/2) = -Lrs22_saud_vetor(k);
    Lrs32_saud_vetor(k+(angRot_tam-1)/2) = -Lrs32_saud_vetor(k);

    % Terceira coluna da matriz de 36 termos
    Lss13_saud_vetor(k+(angRot_tam-1)/2) = Lss13_saud_vetor(k);
    Lss23_saud_vetor(k+(angRot_tam-1)/2) = Lss23_saud_vetor(k);
    Lss33_saud_vetor(k+(angRot_tam-1)/2) = Lss33_saud_vetor(k);
    Lrs13_saud_vetor(k+(angRot_tam-1)/2) = -Lrs13_saud_vetor(k);
    Lrs23_saud_vetor(k+(angRot_tam-1)/2) = -Lrs23_saud_vetor(k);
    Lrs33_saud_vetor(k+(angRot_tam-1)/2) = -Lrs33_saud_vetor(k);

    % Quarta coluna da matriz de 36 termos
    Lsr11_saud_vetor(k+(angRot_tam-1)/2) = -Lsr11_saud_vetor(k);
    Lsr21_saud_vetor(k+(angRot_tam-1)/2) = -Lsr21_saud_vetor(k);
    Lsr31_saud_vetor(k+(angRot_tam-1)/2) = -Lsr31_saud_vetor(k);
    Lrr11_saud_vetor(k+(angRot_tam-1)/2) = Lrr11_saud_vetor(k);
    Lrr21_saud_vetor(k+(angRot_tam-1)/2) = Lrr21_saud_vetor(k);
    Lrr31_saud_vetor(k+(angRot_tam-1)/2) = Lrr31_saud_vetor(k);

    % Quinta coluna da matriz de 36 termos
    Lsr12_saud_vetor(k+(angRot_tam-1)/2) = -Lsr12_saud_vetor(k);
    Lsr22_saud_vetor(k+(angRot_tam-1)/2) = -Lsr22_saud_vetor(k);
    Lsr32_saud_vetor(k+(angRot_tam-1)/2) = -Lsr32_saud_vetor(k);
    Lrr12_saud_vetor(k+(angRot_tam-1)/2) = Lrr12_saud_vetor(k);
    Lrr22_saud_vetor(k+(angRot_tam-1)/2) = Lrr22_saud_vetor(k);
    Lrr32_saud_vetor(k+(angRot_tam-1)/2) = Lrr32_saud_vetor(k);

    % Sexta coluna da matriz de 36 termos
    Lsr13_saud_vetor(k+(angRot_tam-1)/2) = -Lsr13_saud_vetor(k);
    Lsr23_saud_vetor(k+(angRot_tam-1)/2) = -Lsr23_saud_vetor(k);
    Lsr33_saud_vetor(k+(angRot_tam-1)/2) = -Lsr33_saud_vetor(k);
    Lrr13_saud_vetor(k+(angRot_tam-1)/2) = Lrr13_saud_vetor(k);
    Lrr23_saud_vetor(k+(angRot_tam-1)/2) = Lrr23_saud_vetor(k);
    Lrr33_saud_vetor(k+(angRot_tam-1)/2) = Lrr33_saud_vetor(k);

    % ###############################################################
    % ### PREENCHE VALORES DE INDUTÂNCIA DE PROFUNDIDADE DE 360º ####
    % ###############################################################

    if k == 1
        % Primeira coluna da matriz de 36 termos
        Lss11_saud_vetor(angRot_tam) = Lss11_saud_vetor(k);
        Lss21_saud_vetor(angRot_tam) = Lss21_saud_vetor(k);
        Lss31_saud_vetor(angRot_tam) = Lss31_saud_vetor(k);
        Lrs11_saud_vetor(angRot_tam) = Lrs11_saud_vetor(k);
        Lrs21_saud_vetor(angRot_tam) = Lrs21_saud_vetor(k);
        Lrs31_saud_vetor(angRot_tam) = Lrs31_saud_vetor(k);

        % Segunda coluna da matriz de 36 termos
        Lss12_saud_vetor(angRot_tam) = Lss12_saud_vetor(k);
        Lss22_saud_vetor(angRot_tam) = Lss22_saud_vetor(k);
        Lss32_saud_vetor(angRot_tam) = Lss32_saud_vetor(k);
        Lrs12_saud_vetor(angRot_tam) = Lrs12_saud_vetor(k);
        Lrs22_saud_vetor(angRot_tam) = Lrs22_saud_vetor(k);
        Lrs32_saud_vetor(angRot_tam) = Lrs32_saud_vetor(k);

        % Terceira coluna da matriz de 36 termos
        Lss13_saud_vetor(angRot_tam) = Lss13_saud_vetor(k);
        Lss23_saud_vetor(angRot_tam) = Lss23_saud_vetor(k);
        Lss33_saud_vetor(angRot_tam) = Lss33_saud_vetor(k);
        Lrs13_saud_vetor(angRot_tam) = Lrs13_saud_vetor(k);
        Lrs23_saud_vetor(angRot_tam) = Lrs23_saud_vetor(k);
        Lrs33_saud_vetor(angRot_tam) = Lrs33_saud_vetor(k);

        % Quarta coluna da matriz de 36 termos
        Lsr11_saud_vetor(angRot_tam) = Lsr11_saud_vetor(k);
        Lsr21_saud_vetor(angRot_tam) = Lsr21_saud_vetor(k);
        Lsr31_saud_vetor(angRot_tam) = Lsr31_saud_vetor(k);
        Lrr11_saud_vetor(angRot_tam) = Lrr11_saud_vetor(k);
        Lrr21_saud_vetor(angRot_tam) = Lrr21_saud_vetor(k);
        Lrr31_saud_vetor(angRot_tam) = Lrr31_saud_vetor(k);

        % Quinta coluna da matriz de 36 termos
        Lsr12_saud_vetor(angRot_tam) = Lsr12_saud_vetor(k);
        Lsr22_saud_vetor(angRot_tam) = Lsr22_saud_vetor(k);
        Lsr32_saud_vetor(angRot_tam) = Lsr32_saud_vetor(k);
        Lrr12_saud_vetor(angRot_tam) = Lrr12_saud_vetor(k);
        Lrr22_saud_vetor(angRot_tam) = Lrr22_saud_vetor(k);
        Lrr32_saud_vetor(angRot_tam) = Lrr32_saud_vetor(k);

        % Sexta coluna da matriz de 36 termos
        Lsr13_saud_vetor(angRot_tam) = Lsr13_saud_vetor(k);
        Lsr23_saud_vetor(angRot_tam) = Lsr23_saud_vetor(k);
        Lsr33_saud_vetor(angRot_tam) = Lsr33_saud_vetor(k);
        Lrr13_saud_vetor(angRot_tam) = Lrr13_saud_vetor(k);
        Lrr23_saud_vetor(angRot_tam) = Lrr23_saud_vetor(k);
        Lrr33_saud_vetor(angRot_tam) = Lrr33_saud_vetor(k);
    end
    
    % Atualiza a linha para a próxima etapa
    k = k + 1;
end