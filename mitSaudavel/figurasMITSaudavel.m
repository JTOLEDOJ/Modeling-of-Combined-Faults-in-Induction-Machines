close all
clc

% Intervalo de análise
idx0_saud = round((tEntraCarga+0.5*(tSaiCarga-tEntraCarga))/dt_decimado);
idx1_saud = idx0_saud + round(1/f/dt_decimado);
idx_saud_vetor = idx0_saud:idx1_saud;
idx_saud_tam = length(idx_saud_vetor);

% Elemento escolhido
i = idx0_saud;

% Velocidade mecânica vs. tempo
figure;
plot(tempo,nmec_saud,'-k',tempo(i),nmec_saud(i),'*k',tempo(i),Nnom,'*b',...
    'LineWidth',lineWidth);
xlabel('Tempo [s]');
ylabel('Velocidade mecânica [rpm]');
legend({'nmec\_saud(t)','nmec\_saud(i)','Nnom'});
grid on;

% Torques vs. tempo
figure;
plot(tempo,Te_saud,'-k',tempo,TL_saud,'-r',tempo(i),Te_saud(i),'*k',...
    tempo(i),TeNom,'*b','LineWidth',lineWidth);
xlabel('Tempo [s]');
ylabel('Torque [N.m]');
legend({'Te\_saud(t)','TL\_saud(t)','Te\_saud(i)','TeNom'});
grid on;

% Potência mecânica vs. tempo
figure;
plot(tempo,Pmec_saud,'-k',tempo(i),Pmec_saud(i),'*k',tempo(i),Pnom,'*b',...
    'LineWidth',lineWidth);
xlabel('Tempo [s]');
ylabel('Potência mecânica [W]');
legend({'Pmec\_saud(t)','Pmec\_saud(i)','Pnom'});
grid on;

% Corrente de estator em dq vs. tempo
figure;
plot(tempo,is_dq_saud,'-k',tempo(i),is_dq_saud(i),'*k',...
    tempo(i),Inom,'*b','LineWidth',lineWidth);
xlabel('Tempo [s]');
ylabel('Corrente de estator em dq (Linha-RMS) [A]');
legend({'I(t)','I(i)','Inom'});
grid on;

% Correntes de estator em abc vs. tempo
[~, idx_iasMax_saud] = max(ias_saud(idx_saud_vetor));
idx_iasMax_saud = idx0_saud + idx_iasMax_saud - 1;
[~, idx_ibsMax_saud] = max(ibs_saud(idx_saud_vetor));
idx_ibsMax_saud = idx0_saud + idx_ibsMax_saud - 1;
[~, idx_icsMax_saud] = max(ics_saud(idx_saud_vetor));
idx_icsMax_saud = idx0_saud + idx_icsMax_saud - 1;

figure;
plot(tempo,ias_saud,'-r',tempo,ibs_saud,'-g',tempo,ics_saud,'-b',...
    tempo(idx0_saud),ias_saud(idx0_saud),'*r',...
    tempo(idx0_saud),ibs_saud(idx0_saud),'*g',...
    tempo(idx0_saud),ics_saud(idx0_saud),'*b',...
    tempo(idx1_saud),ias_saud(idx1_saud),'*r',...
    tempo(idx1_saud),ibs_saud(idx1_saud),'*g',...
    tempo(idx1_saud),ics_saud(idx1_saud),'*b',...
    tempo(idx_iasMax_saud),ias_saud(idx_iasMax_saud),'*k',...
    tempo(idx_ibsMax_saud),ibs_saud(idx_ibsMax_saud),'*k',...
    tempo(idx_icsMax_saud),ics_saud(idx_icsMax_saud),'*k',...
    'LineWidth',lineWidth);
xlabel('Tempo [s]');
ylabel('Correntes de estator em abc (Fase-Pico) [A]');
legend({'i\_as(t)','i\_bs(t)','i\_cs(t)'});
grid on;

% Correntes de rotor em abc vs. tempo
f_desl = (120*f/p - nmec_saud(i))*(p/2)*(pi/30)/(2*pi);
idx2_saud = idx0_saud + round(1/f_desl/dt_decimado);
[~, idx_iarMax_saud] = max(iar_saud(idx0_saud:idx2_saud));
idx_iarMax_saud = idx0_saud + idx_iarMax_saud - 1;
[~, idx_ibrMax_saud] = max(ibr_saud(idx0_saud:idx2_saud));
idx_ibrMax_saud = idx0_saud + idx_ibrMax_saud - 1;
[~, idx_icrMax_saud] = max(icr_saud(idx0_saud:idx2_saud));
idx_icrMax_saud = idx0_saud + idx_icrMax_saud - 1;

figure;
plot(tempo,iar_saud*(Ns/Nr),'-r',...
    tempo,ibr_saud*(Ns/Nr),'-g',...
    tempo,icr_saud*(Ns/Nr),'-b',...
    tempo(idx_iarMax_saud),iar_saud(idx_iarMax_saud)*(Ns/Nr),'*k',...
    tempo(idx_ibrMax_saud),ibr_saud(idx_ibrMax_saud)*(Ns/Nr),'*k',...
    tempo(idx_icrMax_saud),icr_saud(idx_icrMax_saud)*(Ns/Nr),'*k',...
    'LineWidth',lineWidth);
xlabel('Tempo [s]');
ylabel('Correntes de rotor em abc (Fase-Pico, Medidas no Rotor) [A]');
legend({'i\_ar^{\prime}(t)','i\_br^{\prime}(t)','i\_cr^{\prime}(t)'});
grid on;