s = tf('s');
P = 1/(s+0.01)^2;
%pas 1
%construire Ws si Wt conform cerintei
k = 10;
Ws = k/((s+1)^2);
Wt = 0.1*s/(0.05*s+1);

%pas 2
%calculare wj si wi 
figure('Name', 'Extragere wj si wi', 'NumberTitle','off');
bodemag(Ws, Wt, tf(1));
hold on
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
%extragem valorile pentru wj (joasa frecv) si wi (inalta frecventa) in
%functie de intersctia cu linia 0 db
wj = 3;
wi = 11.6;
%de asemenea se observa ca se respecta buna definire min{|Ws|,|Wt|} < 1 , |Wt| << 1 la frecv
%joase si |Ws| << 1 la frecv inalte ( 1 -> db: 0)


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

%pas 3
%construire L (in exemplul asta, L este destul de simplu de construit, doar
%ne 'jucam' cu b si c pana cand gasim solutia

a = 10.5;   %obligatoriu mai mare ca 10 pt a satisface cerinta la joasa frecventa
            %de exemplu, pt a = 9, L s-ar afla sub RJF
b = 1;      % b si c se aleg pentru a satisface cerintele la medie frecventa
c = 0.1;    %influenteaza performanta robusta
%a = 13.2;
%b = 2;
%c = 0.05;      
L = a/((b*s+1)*(c*s+1));        %exces pol zerouri pt L >= P       exces = nr_poli - nr_zerori

figure('Name', 'Restrictii', 'NumberTitle','off');
semilogx(w_span(index_wj), rjf(index_wj),'red')
hold on
semilogx(w_span(index_wi), rif(index_wi),'black')
hold on
bodemag(L)
grid on
legend('RJF', 'RIF', 'L');
title('Restrictii la joasa si inalta frecventa')
%din grafic se observa ca panta functiei L nu depaseste -40 dB/decada in
%jurul frecventei medii

%pas 4
%se verifica ca L este stabil (hod trece la dreapta lui -1)
figure('Name', 'Verificare L stabil', 'NumberTitle','off');
nyquist(L)
legend('L');
title('Verificare L stabil');

%pas 5
%Calcul C
C = L/P;
S = feedback(1,series(P,C));
T = feedback(series(P,C),1);
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
