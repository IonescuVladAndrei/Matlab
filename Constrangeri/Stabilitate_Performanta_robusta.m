s = tf('s');


P = tf([1 0.6267], [1 1.65 1.889]);
C = tf([0.8613 1.423 1.567], [1 2.772  4.37  1.817 0]);

L = series(C, P);
S = feedback(1, L);
T = feedback(L, 1);

%% Stabilitate robusta
% Pondere frecventiala - stabilitate robusta
Wt = 0.01*s^3/(s/1000 + 1)^3;

% varinta 1

figure('Name', 'Conditie stabilitate robusta', 'NumberTitle','off');
bodemag(Wt*T)
hold on
bodemag(tf(1))
grid on
legend('|Wt*T|', 'prag');
title('Conditie stabilitate robusta V1')
% se observa ca |Wt*T| se afla sub 0 dB deci conditia de stabilitate robusta este adevarata


% varianta 2
%practic aceeasi cu varianta 1

figure('Name', 'Conditie stabilitate robusta', 'NumberTitle','off');
bodemag(1/(Wt*T))
hold on
bodemag(T)
grid on
legend('|1/(Wt*T)|', '|T|');
title('Conditie stabilitate robusta V2')
% |1/(Wt*T)| > |T| deci conditia de stabilitate robusta este adevarata


% varianta 3
stab_rob = norm(Wt*T, "inf");  % = 0.0091 care este sub 1, deci este stabil robust

%% Performante nominale
% Pondere frecventiala - performante nominale
Ws = 1/(s*(s + 2)^2);

% varinta 1

figure('Name', 'Conditie performanta nominala', 'NumberTitle','off');
bodemag(Ws*S)
hold on
bodemag(tf(1))
grid on
legend('|Ws*S|', 'prag');
title('Conditie performanta nominala V1')
% se observa ca |Ws*S| se afla sub 0 dB deci conditia de performanta nominala este adevarata

% varianta 2

figure('Name', 'Conditie performanta nominala', 'NumberTitle','off');
bodemag(1/(Ws*S))
hold on
bodemag(S)
grid on
legend('|1/(Ws*S)|', '|S|');
title('Conditie performanta nominala V2')
% |1/(Ws*S)| > |S| deci conditia de performanta nominala este adevarata

% varianta 3
perf_nom = norm(Ws*S, "inf"); % = 0.8738 care este sub 1, deci conditia de performanta nominala este adevarata

%% Performanta Robusta

% varianta 1

N = 1000;
w_log = logspace(-2, 4, N);
w_lin = linspace(1e-3, 1e3, N);

[mag1, ~]= bode(series(S, Ws), w_log);
[mag2, ~]= bode(series(T,Wt), w_log);

mag1 = reshape(mag1, 1, length(mag1));
mag2 = reshape(mag2, 1, length(mag2));

rob_perf=max(mag1 + mag2); % = 0.8735 care este sub 1, deci conditia de performanta robusta se respecta

%varianta 2
%(cea corecta zic eu)

w_span = logspace(-3,3,1e3);
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
%se observa din grafic ca |Ws*S|+|Wt*T| se afla sub valoarea de 0 db deci
%conditia de performanta robusta este adevarata

%varianta 3


figure('Name', 'Conditie performanta robusta', 'NumberTitle','off');
bodemag(Ws*S+Wt*T)
hold on
bodemag(tf(1))
legend('|Ws*S|+|Wt*T|', 'prag');
title('Conditie performanta robusta')
%se observa ca |Ws*S|+|Wt*T| se afla sub 0 dB deci conditia de performanta robusta este adevarata