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
bodemag(Ws, Wt);
line([0.01,10^3],[0,0],'Color', 'magenta');
grid on;
legend('Ws', 'Wt');
title('Extragere wj si wi');
%extragem valorile pentru wj (joasa frecv) si wi (inalta frecventa) in
%functie de intersctia cu linia 0 db
wj = 3;
wi = 11.6;
%de asemenea se observa ca se respecta buna definire, |Wt| << 1 la frecv
%joase si |Ws| << 1 la frecv inalte


%dimensiunea graficului
w_span = logspace(-3,3,1e3);

%nu 
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
%construire L 
a = 10.5;
b = 1;
c = 0.1;
L = a/((b*s+1)*(c*s+1));

figure('Name', 'Restrictii', 'NumberTitle','off');
semilogx(w_span(index_wj), rjf(index_wj),'red')
hold on
semilogx(w_span(index_wi), rif(index_wi),'black')
hold on
bodemag(L)
grid on
legend('RJF', 'RIF', 'L');
title('Restrictii la joasa si inalta frecventa')

%pas 4
%se verifica ca L este stabil (hod trece la dreapta lui -1)
figure('Name', 'Verificare L stabil', 'NumberTitle','off');
nyquist(L)
legend('L');
title('Verificare L stabil');

%pas 5
%Calcul C
C = P/L;
S = 1/(1+L);
T = L/(1+L);
%se verifica C propriu (aka grad numitor <= grad numarator)
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
line([0.01,10^2],[1,1],'Color', 'magenta');
hold on
semilogx(w_span, mag_WsS_WtT);
grid on
legend('1 dB', '|Ws*S|+|Wt*T|');
title('Conditie performanta robusta')
%se observa ca se afla sub 1 db