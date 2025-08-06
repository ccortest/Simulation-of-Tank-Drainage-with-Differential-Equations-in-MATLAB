% Ecuación diferencial para el drenaje del tanque cilíndrico
function dhdt = cylinderTankODE(~, h, A, a)
    g = 9.81; % Aceleración debida a la gravedad (m/s^2)
    if h <= 0
        dhdt = 0; % No hay más drenaje cuando está vacío
    else
        dhdt = -(a / A) * sqrt(2 * g * h); % Ecuación de Torricelli
    end
end

% Parámetros para el cilindro
R = 1.0;           % Radio del tanque cilíndrico (m)
A = pi * R^2;      % Área transversal del tanque (m^2)
h0 = 5.0;          % Altura inicial del agua (m)
totalTime = 40;    % Tiempo total de drenaje (segundos)

% Calcular el tamaño del agujero con factor de ajuste para asegurar el drenaje completo
g = 9.81;
adjustmentFactor = 1.25; % Aumentar el tamaño del agujero en un 25% para drenar más rápido
a = adjustmentFactor * A * sqrt(h0) / (totalTime * sqrt(2*g));

% Verificar el tiempo de drenaje resolviendo la ODE con el tamaño del agujero calculado
tspan = [0, totalTime];
options = odeset('RelTol', 1e-6, 'AbsTol', 1e-6);
[t_check, h_check] = ode45(@(t, h) cylinderTankODE(t, h, A, a), tspan, h0, options);
final_height = h_check(end);

% Si aún no está lo suficientemente vacío, ajustar aún más el tamaño del agujero
if final_height > 0.05
    % Recalcular con un ajuste más fuerte
    adjustmentFactor = 1.5;
    a = adjustmentFactor * A * sqrt(h0) / (totalTime * sqrt(2*g));
end

% Resolver la ODE nuevamente con el tamaño final ajustado del agujero
tspan = linspace(0, totalTime, 1000);
[t, h] = ode45(@(t, h) cylinderTankODE(t, h, A, a), tspan, h0);

% Crear la ventana de la figura
figure;
set(gcf, 'Position', [100, 100, 600, 800]);

% Configurar el temporizador para la animación en tiempo real
startTime = tic;
isRunning = true;

% Bucle de animación
while isRunning 
    % Obtener el tiempo real actual
    currentTime = toc(startTime);
    
    % Limpiar la figura y prepararse para dibujar
    clf;
    
    % Encontrar la altura del agua en el tiempo actual usando interpolación
    if currentTime <= totalTime
        currentHeight = interp1(t, h, min(currentTime, totalTime), 'linear');
        % Asegurarse de que la altura no sea negativa y sea realmente cero al final
        if currentHeight < 0.05 && currentTime > totalTime * 0.95
            currentHeight = 0;
        end
    else
        currentHeight = 0;
        isRunning = false; % Terminar la animación después de totalTime
    end
    
    % Dibujar el contorno del tanque (rectángulo fijo)
    rectangle('Position', [0, 0, 2*R, h0], 'EdgeColor', 'black', 'LineWidth', 2);
    
    % Dibujar el agua (rectángulo azul que se reduce)
    if currentHeight > 0
        % Color degradado - azul más oscuro cuando está más lleno
        waterColor = [0, 0.4 + 0.2*(1-currentHeight/h0), 0.8];
        rectangle('Position', [0, 0, 2*R, currentHeight], 'EdgeColor', 'none', 'FaceColor', waterColor);
    end
    
    % Dibujar el agujero de drenaje
    rectangle('Position', [R-0.1, 0, 0.2, 0.05], 'FaceColor', 'black');
    
    % Establecer propiedades del eje
    axis([-R, 3*R, -1, h0+1]);
    grid on;
    title(sprintf('Drenaje del tanque: %.1f segundos', currentTime));
    xlabel('Ancho (m)');
    ylabel('Altura (m)');
    
    % Mostrar el porcentaje de volumen restante
    volumePercent = 100 * currentHeight / h0;
    text(R, h0*0.5, sprintf('%.1f%%', volumePercent), 'HorizontalAlignment', 'center', 'FontSize', 14);
    
    % Actualizar la pantalla
    drawnow;
    
    % Verificar si hemos llegado al final
    if currentTime >= totalTime
        title(sprintf('Drenaje del tanque completo: %d segundos', totalTime));
        % Dibujar el tanque vacío final
        rectangle('Position', [0, 0, 2*R, h0], 'EdgeColor', 'black', 'LineWidth', 2);
        pause(0.5); % Pequeña pausa para mostrar el tanque vacío
        break;
    end
    
    % Control de la tasa de fotogramas - objetivo de 30 fps
    pause(0.033); 
end

% Mostrar el área del orificio al final de la simulación

fprintf('Área final del orificio: %.4f m²\n', a);

% Mostrar el tanque vacío final durante 3 segundos
clf;
rectangle('Position', [0, 0, 2*R, h0], 'EdgeColor', 'black', 'LineWidth', 2);
axis([-R, 3*R, -1, h0+1]);
grid on;
title(sprintf('Tanque vacío: %d segundos', totalTime));
xlabel('Ancho (m)');
ylabel('Altura (m)');
text(R, h0*0.5, '0.0%', 'HorizontalAlignment', 'center', 'FontSize', 14);
pause(3);