s = tf('s');

P = 1/(s-2);
%C = k;

%% a) se cere domeniul de variatie al lui k astfel incat se garanteaza stabilitatea interna a buclei de reactie
%plecam cu k = 1

k = 3;
C = k;

% Functiile de sensibilitate
L = series(P, C);
S = feedback(1, L);
T = feedback(L, 1);

%functia de la numitorul lui T trebuie sa fie stabila => zerourile functiei trebuie sa fie in C- sau polii lui T trebuie sa fie in C-

roots(T.den{1})
% pentru k = 1, avem ca raspuns 1 ceea ce nu apartine lui C-
%incercam cu k = 2, k = 3 si asa mai departe
%prima valoare care satsiface conditia: k = 3

%% b) sa se gaseasca dom de variatie al lui k pentru care:
% |e_stationara| < 5% pentru r(t) = 1(t)
%si |e_stationara| < 10% pentru r(t) = cos(wr*t)     wr apartine (0,1)

err_st = 5/100;
err_urm = 10/100;

wr = 1;

%incepem de la k = 3
k = 39;
C = k;

L = series(P, C);
S2 = feedback(1, L);

k = 42;
C = k;
% Functiile de sensibilitate
L = series(P, C);
S = feedback(1, L);
T = feedback(L, 1);

%din grafic se observa faptul ca, spe exemplu, S2 cu k = 39 nu satisface
%conditia de a se afla sub err_urm si err_st
%pe de alta parte, S cu k = 42 satisface conditiile

figure('Name', 'b) cerinte performanta', 'NumberTitle','off');
bodemag(S, S2) 
hold on
bode(tf(err_urm), {0, wr}, '-.r')
bode(tf(err_st), {0, .1}, '-.r')
stem(wr,  mag2db(err_urm), 'r')
xlim([1e-3 1e3]);
grid on
h = findobj(gcf, 'type', 'line');
set(h, 'linewidth' , 2);
legend('S', 'S2' , 'limita err urm', 'limita err st', 'banda err urm');

%% c) Sa se calculeze norma sistemica inf a functiei de sensibilitate S
%atunci cand k este in regiunea de sensibilitate => k > 2

% Caz 1: k in (2, 4)
k = 3;
C = k;

L = series(P, C);
S1 = feedback(1, L);

% Caz 2: k = 4
k = 4;
C = k;

L = series(P, C);
S2 = feedback(1, L);

% Caz 3: k > 4
k = 5;
C = k;

L = series(P, C);
S3 = feedback(1, L);

figure('Name', 'c) Norme', 'NumberTitle','off');
bodemag(S1, S2, S3)
grid
h = findobj(gcf, 'type', 'line');
set(h, 'linewidth' , 1.5);
legend('k=3', 'k=4', 'k=5')

%% d) sa se propuna o functie pondere Ws care sa exprime conditiile de la b) 
% sub forma conditiei de urmarire a referintei

%reluam valorile de la b)
k = 42;
C = k;
L = series(P, C);
S = feedback(1, L);

%construim Ws

%optiunea 1: constant
ks1 = 21;
Ws1 = ks1; 

%optiunea 2: variabil
ks2 = ks1;
T2 = 1;
Ws2 = ks2/(T2*s + 1);

figure('Name', 'd) Construire Ws', 'NumberTitle','off');
bodemag(S, tf(1/Ws1), 1/Ws2)
hold on
bode(tf(err_urm), {0, wr}, '-.r')
bode(tf(err_st), {0, .1}, '-.r')
stem(wr,  mag2db(err_urm), 'r')
xlim([1e-3 1e3]);
grid on
h = findobj(gcf, 'type', 'line');
set(h, 'linewidth' , 2);
legend('S', '1/|Ws1|', '1/|Ws2|', 'limita err urm', 'limita err st', 'banda err urm');
% ks1, ks2 si T2 se aleg asftel incat graficul lui 1/Ws1 si 1/Ws2 ss se afle sub err_urm si err_st

%% e) sa se propuna o functie pondere Ws care sa exprime conditiile de la b) sub forma cnditiei de stabilitate robusta
% pentru P_tilda = a/(s-2), cu  0.5 <= a >= 1.5

%consecinta a stab robuste:
% |P_tilda/P - 1| <= |Wt|   de aici rezulta: 

Wt = tf(1/2);

%stim faptul ca k > 2, ramane de aflat valoarea pentru stabilitate robusta adica |Wt*T| trebuie sa se afle sub 0 dB
k = 3;
C = k;
L = series(P, C);
T1 = feedback(L, 1);

k = 4;
C = k;
L = series(P, C);
T2 = feedback(L, 1);

k = 5;
C = k;
L = series(P, C);
T3 = feedback(L, 1);

figure('Name', 'e) Construire Wt si k', 'NumberTitle','off');
title('Wt')
bodemag(Wt*T1, Wt*T2, Wt*T3, tf(1));
grid on;
legend('k = 3', 'k = 4', 'k = 5');
% rezulta k > 4