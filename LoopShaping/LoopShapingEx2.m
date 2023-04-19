s = tf('s');
%Fie sistemul:
P = (s + 0.6267)/(s^2 + 1.65*s + 1.889);
%care este supus unei avarii, prin care amortizoarele elevatoarelor îşi pierd 90% din eficacitate
%practic se schimba coeficientul de la numitor, s de ordin 1
Pa = (s + 0.6267)/(s^2 + 0.165*s + 1.889);
Wt = 0.01*s^3/(s/1000+1)^3;
Ws = 1/(s*(s+2)^2);

figure('Name', 'Extragere wj si wi', 'NumberTitle','off');
bodemag(Ws, Wt, tf(1));
hold on;
grid on;
legend('|Ws|', '|Wt|', 'prag');
title('Extragere wj si wi');

N = 1000;
w_log = logspace(-2, 4, N);
[mag1a, ~]= bode(Ws, w_log);
[mag2a, ~]= bode(Wt, w_log);
mag1a = reshape(mag1a, 1, length(mag1a));
mag2a = reshape(mag2a, 1, length(mag2a));

plot(w_log, [mag2db(mag2a(mag2a<mag1a)) mag2db(mag1a(mag1a<=mag2a))], '-.g','linewidth' , 2, 'DisplayName','B. def')
%de aici reiese
wi = 4.65;
wj = 0.246;

%pas 2
%construire L prin trial and error
%dimensiunea graficului
w_span = logspace(-3,3,1e3);


[mag_Ws,~]=bode(Ws, w_span);
[mag_Wt,~]=bode(Wt, w_span);
mag_Ws = reshape(mag_Ws, 1, 1e3);   %reshape pastreaza din tabloul de 3 doar un vector de 1
mag_Wt = reshape(mag_Wt, 1, 1e3);
rjf = mag2db(mag_Ws./(1-mag_Wt));
rif = mag2db((1-mag_Ws)./mag_Wt);
%trunchere grafic pt restrictii rjf si rif
index_wj = w_span < wj;
index_wi = w_span > wi;

%% v1
%luam C = 1 si L = Pa*C
%este o metoda relativ comuna pentru inceput
C = 1;
L = Pa*C;

figure('Name', 'Restrictii V1', 'NumberTitle','off');
semilogx(w_span(index_wj), rjf(index_wj),'red')
hold on
semilogx(w_span(index_wi), rif(index_wi),'black')
hold on
bodemag(L)
grid on
xlim([1e-3 1e3])
legend('RJF', 'RIF', 'L');
title('L1 Restrictii la joasa si inalta frecventa')

%ne uitam la faza pentru a ne asigura ca sistemul in bucla inchisa este stabil
%click dreapta in interiorul graficului de faza (Phase), -> Characteristics -> All stability margins
figure('Name', 'Restrictii V1 Phase', 'NumberTitle','off');
bode(L)
grid on
xlim([1e-3 1e3])
legend('L');
title('L1 Restrictii la joasa si inalta frecventa')
%"Closed loop stable? Yes" => este ok, trecem mai departe

%% v2
%L nu este nici deasupra lui RJF, nici sub RIF
%remediem acest fapt prin inmultirea cu un integrator
L = L/s;

figure('Name', 'Restrictii V2', 'NumberTitle','off');
semilogx(w_span(index_wj), rjf(index_wj),'red')
hold on
semilogx(w_span(index_wi), rif(index_wi),'black')
hold on
bodemag(L)
grid on
xlim([1e-3 1e3])
legend('RJF', 'RIF', 'L');
title('L2 Restrictii la joasa si inalta frecventa')

%ne uitam la faza pentru a ne asigura ca sistemul in bucla inchisa este stabil
%click dreapta in interiorul graficului de faza (Phase), -> Characteristics -> All stability margins
figure('Name', 'Restrictii V2 Phase', 'NumberTitle','off');
bode(L)
grid on
xlim([1e-3 1e3])
legend('L');
title('L2 Restrictii la joasa si inalta frecventa')
%hover peste margine (al treilea punct)
%"Closed loop stable? No" => Sistemul s-a destabilizat in bucla inchisa din cauza fazei suplimentare
%Comparand graficul fazei din bode "Restrictii V2 Phase" cu "Restrictii V1 Phase", se observa ca L pleaca din -90 in loc de 0

%% v3
%intrucat se destabilizează sistemul in bucla inchisa, introducem un filtru de tip Notch

%De ce filtru Notch?
%Explicatia simpla: avem o cocoasa 
%Explicatia profes: vrem sa atenuam varful de rezonanta si sa fortam marginea de faza a sistemului inapoi in gama pozitiva

w_N = 1.337; %ales din grafic (cel cu amplitudine), fiind varful cocoasei
%forumla: zeta_t = evalfr(Pa/L,w_N*1i)/2; 
zeta_t = 0.05; %ar trebui ales dupa formula, insa nu are efectul dorit asupra graficului fazei

L = L*(s^2+2*w_N*zeta_t*s+w_N^2)/(s^2+ w_N*s +w_N^2);

figure('Name', 'Restrictii V3', 'NumberTitle','off');
semilogx(w_span(index_wj), rjf(index_wj),'red')
hold on
semilogx(w_span(index_wi), rif(index_wi),'black')
hold on
bodemag(L)
grid on
xlim([1e-3 1e3])
legend('RJF', 'RIF', 'L');
title('L3 Restrictii la joasa si inalta frecventa')


figure('Name', 'Restrictii V3 Phase', 'NumberTitle','off');
bode(L)
grid on
xlim([1e-3 1e3])
legend('L');
title('L3 Restrictii la joasa si inalta frecventa')
%"Closed loop stable? Yes" => este ok, trecem mai departe

%% v4

% L se afla in continuare deasupra lui RIF (il sectioneaza)
% Introducem un bloc de compensare cu panta(la frecvente inalte)
%cu N = 1 si w_r = 14.5
%aleg 14.5 si nu, spre exemplu 1, pentru a mentine sub -40 db/dec panta la medie frecventa

L = L*14.5/(s+14.5);

figure('Name', 'Restrictii V4', 'NumberTitle','off');
semilogx(w_span(index_wj), rjf(index_wj),'red')
hold on
semilogx(w_span(index_wi), rif(index_wi),'black')
hold on
bodemag(L)
grid on
xlim([1e-3 1e3])
legend('RJF', 'RIF', 'L');
title('L4 Restrictii la joasa si inalta frecventa')
% L se afla deasupra lui RJF si sub RIF
%din grafic se observa ca panta functiei L nu depaseste -40 dB/decada in
%jurul frecventei medii

figure('Name', 'Restrictii V4 Phase', 'NumberTitle','off');
bode(L)
grid on
xlim([1e-3 1e3])
legend('L');
title('L4 Restrictii la joasa si inalta frecventa')
%"Closed loop stable? Yes" => este ok, trecem mai departe

%pas 4
%se verifica ca L este stabil (hod trece la dreapta lui -1)
figure('Name', 'Verificare L stabil', 'NumberTitle','off');
nyquist(L)
legend('L');
title('Verificare L stabil');
%este stabil

%pas 5
%Calcul C
C = L/Pa;
S = feedback(1,series(Pa,C));
T = feedback(series(Pa,C),1);
%se verifica C propriu (aka grad numitor => grad numarator)
%C este propriu


%pas 6
%se verifica robustetea
[mag_WsS,~]=bode(Ws*S, w_span);
[mag_WtT,~]=bode(Wt*T, w_span);
mag_WsS = reshape(mag_WsS, 1, 1e3);
mag_WtT = reshape(mag_WtT, 1, 1e3);
mag_WsS_WtT = mag2db(mag_WsS+mag_WtT);

w_span = logspace(-3,2,1e3);
figure('Name', 'Conditie performanta robusta', 'NumberTitle','off');
line([0.01,10^2],[0,0],'Color', 'magenta');
hold on
semilogx(w_span, mag_WsS_WtT);
grid on
legend('prag', '|Ws*S|+|Wt*T|');
title('Conditie performanta robusta')
%se observa ca se afla sub 0 db (prag)