%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Proyecto Sistemas de control:
% Integrantes:
%     -Gabriel de Jesús Alemán Ruiz 
%         Carné: B90175
%    -Otto 
%         Carné: 
%     -José Mario 
%         Carné:                                                    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-
%Primera parte: Obtención de la salida, entrada y tiempo.
%-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-

clc;
clear all;
close all;

% Graficar la variable controlada como función del tiempo:

filename = 'Flujo_delta_60a80.csv'; %Se importa el archivo ".csv"
data = xlsread(filename); %Datos

y = data(:, 3);              %Variable controlada
u = data(:, 2);              %Señal de control 
t = data(:, 1);              %Tiempo


linewidth = 2;

%Graficar la variable controlada como función del tiempo:
y_t =figure(1);
hold on
plot(t, y, "r", "linewidth", linewidth) 
plot(t, u, "b", "linewidth", linewidth)      
hold off

title("Variable controlada como función del tiempo.")
xlabel("Tiempo (s)")
ylabel("Variable controlada (flujo de aire)")

legend('Señal controlada (y)', 'Señal de control (u)')
grid()

%Guardar gráfica.
savefig(y_t,'VariableControladaEnFuncionDelTiemp.fig')
%%

%-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-
%Segunda parte: Identificación del modelo del proceso.
%-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-

clc;
close all;

s = tf('s'); %Variable compleja "S"
ti = 220.1;  %Tiempo de aplicada la perturbación.

%Identificación del modelo a través de la curva de reacción del proceso:
uf = 80; ui = 60; %Valores final e inicial de la entrada
yf = 80; yi = 53; %Valores final e inicial de la salida

%Diferencia:
delta_y = yf-yi; delta_u = uf-ui;

%Ganancia del proceso:
Kp_planta = delta_y/delta_u;

%Tiempos al 75%, 50% y 25% (obtenidos a partir de la gráfica):
t75 = 221.885-ti; %Tiempo al 75%
t50 = 221.249-ti; %Tiempo al 50%
t25 = 220.798-ti; %Tiempo al 25%


%Modelo de primer orden:
T_planta_1er = 0.9102*(t75-t25);
L_planta_1er = 1.2620*t25-0.2626*t75;

%Modelo de segundo orden (sub-amortiguado):
 T_planta_2do = 0.5776*(t75-t25);
 L_planta_2do = 1.5552*t25-0.5552*t75;
 
% %Modelo de segundo orden (sobre-amortiguado):
a = (-0.6240*t25+0.9866*t50-0.3626*t75)/(0.3533*t25-0.7036*t50+0.3503*t75);
T = (t75-t25)/(0.9866+0.7036*a);
T1 = T;
T2 = a*T;
L = t75-(1.3421+1.3455*a)*T ;

%Funciones de transferencia para los modelos:
display('Funciones de transferencia obtenidas con método 123');
display('------------------------------------------------------')
P1erOrden = Kp_planta*exp(-L_planta_1er*s)/(T_planta_1er*s+1)
P2doOrden = Kp_planta*exp(-L_planta_2do*s)/(T_planta_2do*s+1)
P2doOrdeSob = Kp_planta*exp(-L*s)/((T1*s+1)*(T2*s+1))

%Salidas:
y_1erOrden=lsim(P1erOrden, u, t)-delta_y;
y_2doOrden =lsim(P2doOrden, u, t)-delta_y;
y_2doOrdenSobAmort =lsim(P2doOrdeSob, u, t)-delta_y;


%Graficar diferentes modelos obtenidos:
mod=figure(2);
hold on
plot(t, y, "r", "linewidth", linewidth) 
plot(t, u, "b", "linewidth", linewidth) 

plot(t, y_1erOrden, "--g", "linewidth", linewidth) 
plot(t, y_2doOrden, ":cyan", "linewidth", linewidth) 
plot(t, y_2doOrdenSobAmort, "-.m", "linewidth", linewidth) 

title("Comparación modelos con método 123 de Alfaro.")
xlabel("Tiempo (s)")
ylabel("Variable controlada (flujo de aire)")

legend("Salida", "Entrada", "1er orden", "2do orden", "2do orden sobre amortiguado") 
hold off
grid()

%Guardar gráfica.
savefig(mod,'ComparaciónDeModelos.fig')
%%

%-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-
%%Obtención de parámetros para controlador PI:
%-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-

clc;
s = tf('s'); %Variable compleja "S"

%Modelos de primer orden obtenidos para el proceso con el 
%systemIdentification

P_0 = 0.9503/(1.183*s+1)
P_1 = 1.552/(1.143*s+1)

%Planta P0
k=0.9503;
Tc=1.75;
T=1.183;
kp=(2-Tc)/(Tc*k)
Ti=Tc*(2-Tc)*T
%%
systemIdentification

