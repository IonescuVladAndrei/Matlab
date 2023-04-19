% Constrangeri in timp

%% Constrangeri timp: zerouri instabile (Teorema 1: Raspuns invers)
s = tf('s');

P = (s - 0.6267)/(s^2-1.65*s + 1.889);
C = (48.73*s^2 + 14.89*s - 2.78)/(s^4 + 8.25*s^3 + 29.85*s^2 + 11.47*s);

% Functii de sensibilitate
L = series(P, C);
S = feedback(1, L);
T = feedback(L, 1);

figure('Name', 'Poli si zerouri pt L', 'NumberTitle','off');
pzmap(L)
h = findobj(gcf, 'type', 'line');
set(h, 'linewidth' , 1.5)
%in cadranul I si IV avem zona instabila, iar in cadranul II si III zona stabila
% x = poli,  O = zerouri

%% Simularea iesirii si erorii sistemului in bucla inchisa
% Construirea vectorului de timp
t = 0 : 0.01 : 20;

% Calculul iesirii (y) si a erorii (e)
[y, t]= step(T, t);
[e, t]= step(S, t);

%% Analiza iesirii + erorii - zerouri instabile

figure('Name', 'Poli si zerouri pt T si L', 'NumberTitle','off');
pzmap(T)
hold on
pzmap(L)
h = findobj(gcf, 'type', 'line');
set(h, 'linewidth' , 1.5);
legend('T', 'L')

%validare teorema

%iesirea va intersecta abcisa formata in punctul y(0) de x "zero instabili gasiti pentru L" ori
figure('Name', 'Analiza Iesirea sistemului', 'NumberTitle','off');
title('Iesirea sistemului')
step(T)     %raspunsul sistemului la intrare treapta
hold on
plot(t, y(1)*ones(length(t)), 'red') 
xlabel('Timp [sec]')
ylabel('Amplitudine')
grid on
legend('y(t)', 'abcisa val. init. y(0)')
%in graficul anterior se vor observa 2 zerouri ale lui L in cadranul I si IV (zerouri instabile)
%   atunci iesirea sistemului va intersecta abcisa formata in punctul y(0) [in Matlab vectorii pleaca de la 1, nu 0]
%de 2 ori (adica nr de zerouri instabile)

zero_L = zero(L);
% zerourile instabile sunt zero_L(1) si zero_L(3)    (ambele Re{zero_L(1)} > 0 si Re{zero_L(3)} > 0)


%Sistemul in bucla inchisa (cu reactie negativa unitara) este intern stabil
    %daca urmatoarele integrale sunt egale cu 0

%pentru raspuns la treapta
Integr1 = trapz(t, exp(-zero_L(1)*t).*y);    %respecta cerinta
Integr2 = trapz(t, exp(-zero_L(3)*t).*y);    %nu respecta

%pentru eroare la treapta
    %daca sunt egale cu 1/z
  
Integr3 = trapz(t, exp(-zero_L(1)*t).*e);
real(1/zero_L(1));
%sunt egale     =>  respecta cerinta

Integr4 = trapz(t, exp(-zero_L(3)*t).*e);
real(1/zero_L(3));
%sunt egale     =>  respecta cerinta

%% Analiza iesirii - poli instabili
pol_L = pole(L);
%polii instabili (cu Re{pol_L(i)} > 0) sunt pol_L(4), pol_L(5)

%Sistemul in bucla inchisa (cu reactie negativa unitara) este intern stabil
    %daca urmatoarele integrale sunt egale cu 0

%pentru eroare la treapta
trapz(t, real(exp(-pol_L(4)*t).*e));    %respecta cerinta
trapz(t, real(exp(-pol_L(5)*t).*e));    %respecta cerinta


%pentru raspuns la treapta
    %daca sunt egale cu 1/p

trapz(t, real(exp(-pol_L(4)*t).*y));
real(1/pol_L(4));
%sunt egale     =>  respecta cerinta

trapz(t, real(exp(-pol_L(5)*t).*y));
real(1/pol_L(5));
%sunt egale     =>  respecta cerinta
