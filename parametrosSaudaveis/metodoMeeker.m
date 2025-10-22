function [tau_FEA, M, Ll] = metodoMeeker(x0, y0, rotacao_deg, l_axial)

    % Método apresentado no site do FEMM
    % Título: Induction Motor Example
    % Autor: David Meeker (dmeeker@ieee.org)
    % Data: August 20, 2004
    
    % ###############################################################
    % ################### INICIALIZA AS VARIÁVEIS  ##################
    % ###############################################################

    % Frequências de escorregamento
    f_slip_vetor = 0.1:0.1:4;               % [Hz]
    %f_slip_vetor = 0.5:0.5:4;              % [Hz] (PARA TESTES)
    w_slip_vetor = 2*pi*f_slip_vetor;       % [rad/s]
    
    % Correntes das bobinas
    Imax = 1;                               % Amplitude de corrente [A]
    Ias = Imax*exp(1i*deg2rad(0));          % Corrente da fase as [A]
    Ibs = Imax*exp(1i*deg2rad(120));        % Corrente da fase bs [A]
    Ics = Imax*exp(1i*deg2rad(240));        % Corrente da fase cs [A]

    % Declaração de vetores e matrizes
    f_slip_tam = length(f_slip_vetor);      % Tamanho do vetor
    L_vetor = zeros(1,f_slip_tam);          % Indutância [H]
    m_matriz = zeros(f_slip_tam,2);         % Matriz para cálculos
    b_matriz = zeros(f_slip_tam,1);         % Matriz para cálculos
    
    % ###############################################################
    % ####################### PREPARA O FEMM  #######################
    % ###############################################################
    
    % Abre o software FEMM
    openfemm();
    
    % Abre o documento de interesse (este arquivo não será editado)
    opendocument('desenhos/maquinaRotorGaiolaSaudavel.FEM');
    
    % Cria um novo arquivo (este arquivo será editado)
    mi_saveas('parametrosSaudaveis/temp.FEM');
    
    % Rotaciona o rotor
    mi_selectgroup(1);
    mi_moverotate(x0, y0, rotacao_deg);
    mi_clearselected();
    
    % ###############################################################
    % # MEDE A INDUTÂNCIA EM FUNÇÃO DA FREQUÊNCIA DE ESCORREGAMENTO #
    % ###############################################################
    
    % Define o perfil de alimentação de corrente
    mi_modifycircprop('as',1,Ias);
    mi_modifycircprop('bs',1,Ibs);
    mi_modifycircprop('cs',1,Ics);
    
    % Executa a simulação para todas as frequências do vetor
    for i = 1:f_slip_tam
        % Define o problema
        mi_probdef(f_slip_vetor(i),'millimeters','planar',1e-8,l_axial,20);
    
        % Abre o fkern para resolver o problema
        mi_analyze(1);
    
        % Carrega e exibe a solução
        mi_loadsolution();
    
        % Retorna as propriedades do circuito da fase A
        propriedades = mo_getcircuitproperties('as');
    
        % Preenche o vetor de indutância
        L_vetor(i) = propriedades(3)/propriedades(1);
    
        % Fecha a instância de pós-processamento atual
        mo_close();
    end
    
    % Fecha o software FEMM
    closefemm();
    
    % Deleta os arquivos temporários
    system('rm parametrosSaudaveis/temp.FEM parametrosSaudaveis/temp.ans');
    
    % ###############################################################
    % ##### FAZ O AJUSTE DOS PARÂMETROS DE CIRCUITO EQUIVALENTE #####
    % ###############################################################
    
    % Separa a indutância em real e imaginário
    L_re_vetor = real(L_vetor);
    L_im_vetor = imag(L_vetor);
    
    % Prepara a matriz "m" e o vetor "b"
    for i = 1:f_slip_tam
        m_matriz(i,1) = w_slip_vetor(i);
        m_matriz(i,2) = L_im_vetor(i)*w_slip_vetor(i)^2;
        b_matriz(i) = -L_im_vetor(i);
    end
    
    % Encontra as constantes do vetor "c"
    c = inv(transpose(m_matriz)*m_matriz)*transpose(m_matriz)*b_matriz;
    
    % Encontra "tau_FEA", "M" e "Ll"
    tau_FEA = sqrt(c(2));
    M = c(1)/tau_FEA;
    Ll_vetor = L_re_vetor - M./(1+(tau_FEA*w_slip_vetor).^2);
    Ll = mean(Ll_vetor);
    
    % Plota a figura da parte imaginária da indutância por metro
    L_im_vetor_fit = ...
        -tau_FEA*M*w_slip_vetor./(1+(tau_FEA*w_slip_vetor).^2);
    
    figure;
    plot([0, w_slip_vetor],[0, L_im_vetor*(1000/l_axial)],'*k', ...
         [0, w_slip_vetor],[0, L_im_vetor_fit*(1000/l_axial)],'-k');
    xlabel('Frequência [rad/s]');
    ylabel('Indutância por unidade de comprimento [H/m]');
    legend({'Parte imaginária de L (FEMM)', ...
            'Parte imaginária de L (Ajuste)'});
end
