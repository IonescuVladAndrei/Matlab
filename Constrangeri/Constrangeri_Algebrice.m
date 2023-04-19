% Constrangeri algebrice

%% Constrangeri algebrice I: S+T=1
s = tf('s');

Ws = 0.25/(s*(s+2)^2);
Wt = 0.01*s^3/(s/1000 + 1)^3;

% Verificare conditie necesara: 
% min{|Ws(jw)|, |Wt(jw)|} < 1, oricare w

figure
bodemag(Ws, Wt)
hold on
bodemag(tf(1), '-.r')
legend('|Ws(jw)|', '|Wt(jw)|', 'prag')
grid on

N = 1000;
w_log = logspace(-2, 4, N);
[mag1, ~]= bode(Ws, w_log);
[mag2, ~]= bode(Wt, w_log);
mag1 = reshape(mag1, 1, length(mag1));
mag2 = reshape(mag2, 1, length(mag2));

plot(w_log, [mag2db(mag2(mag2<mag1)) mag2db(mag1(mag1<=mag2))], '-.g','linewidth' , 2, 'DisplayName','B. def')
%se observa faptul ca |Ws| si |Wt| se intersecteaza sub pragul de 0 dB,
%|Ws| este sub prag la frevente inalte si |Wt| este sub prag la frecvente joase

%% Constrangeri algebrice II: Constrangeri de interpolare

s = tf('s');
P = (s - 0.6267)/(s^2-1.65*s + 1.889);
C = (48.73*s^2 + 14.89*s - 2.78)/(s^4 + 8.25*s^3 + 29.85*s^2 + 11.47*s);
L = series(P, C);
S = feedback(1, L);
T = feedback(L, 1);

% mai intai se verifica conditia de performanta robusta
% se pastreaza Ws si Wt
N = 1000;
w_log = logspace(-4, 4, N);

[mag1, ~]= bode(series(S, Ws), w_log);
[mag2, ~]= bode(series(T,Wt), w_log);

mag1 = reshape(mag1, 1, length(mag1));
mag2 = reshape(mag2, 1, length(mag2));

rob_perf=max(mag1 + mag2); % = 0.7773  <  1, deci conditia de performanta robusta se respecta


% Calculul zerourilor si polilor lui P(s)
% atentie! trebuie sa ne asiguram ca zero_P si pol_P au partea reala >= cu 0
zero_P = roots(P.num{1})
pol_P = roots(P.den{1})

% Verificare conditii de interpolare

%trebuie sa fie aprox 1
S_zero = polyval(S.num{1}, zero_P) ./ polyval(S.den {1}, zero_P);

%trebuie sa fie aprox 0
T_zero = polyval(T.num{1}, zero_P) ./ polyval(T.den {1}, zero_P);

%trebuie sa fie aprox 0
S_pol = polyval(S .num{1}, pol_P) ./ polyval(S.den {1}, pol_P);

%trebuie sa fie aprox 1
T_pol = polyval(T.num{1}, pol_P) ./ polyval(T.den{1}, pol_P);