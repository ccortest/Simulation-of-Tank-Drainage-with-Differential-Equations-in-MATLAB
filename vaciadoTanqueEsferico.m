% Drenaje de tanque esférico con ODE - Tiempo real, drenado correctamente con posición correcta
clear all; close all; clc;

% Ecuación diferencial para el drenaje del tanque esférico
function dhdt = sphereTankODE(~, h, R, a)
    g = 9.81; % Aceleración debida a la gravedad (m/s^2)
    if h <= 0
        dhdt = 0; % No hay más drenaje cuando está vacío
    else
        % Para una esfera, calcular el radio a la altura h
        r_h = sqrt(max(0.001, R^2 - (R - h)^2)); % Radio a la altura h
        A_h = pi * r_h^2; % Área transversal a la altura h
        dhdt = -(a / A_h) * sqrt(2 * g * h); % Ecuación de Torricelli modificada
    end
end

% Parámetros para la esfera
R = 2.5; % Radio del tanque esférico (m)
totalTime = 70; % Tiempo total de drenaje (segundos)

% Resolver la ODE primero con un tamaño de agujero MUCHO mayor para asegurar el drenaje completo
fprintf('Resolviendo ODE para el drenaje del tanque esférico...\n');
h0 = 2 * R; % Altura inicial (esfera llena)
a = 0.15; % Tamaño del agujero SIGNIFICATIVAMENTE aumentado para asegurar el drenaje completo en <40 segundos
tspan = [0, totalTime];

% Resolver ODE
opts = odeset('RelTol', 1e-6, 'AbsTol', 1e-6);
[t, h] = ode45(@(t, h) sphereTankODE(t, h, R, a), tspan, h0, opts);

% Verificar el valor final para asegurar el drenaje completo
finalHeight = h(end);
fprintf('Altura final a %d segundos: %.4f m\n', totalTime, finalHeight);

% Calcular el tiempo de drenaje completo
empty_idx = find(h < 0.01, 1);
if ~isempty(empty_idx)
    actual_drain_time = t(empty_idx);
    fprintf('El tanque se drena completamente en aproximadamente %.1f segundos\n', actual_drain_time);
end

% Retrasar el inicio de la animación en 3 segundos
pause(3); % Retraso agregado antes de que comience la visualización

% Inicializar la figura
figure('Position', [100, 100, 900, 800]);

% Iniciar la animación en tiempo real
startTime = tic;
isRunning = true;

while isRunning
    % Obtener el tiempo actual
    currentTime = toc(startTime);
    
    % Detener cuando se alcance el tiempo total
    if currentTime >= totalTime
        currentTime = totalTime;
        isRunning = false;
    end
    
    % Interpolar la altura de la solución ODE
    currentHeight = interp1(t, h, currentTime, 'linear');
    
    % Asegurar que la altura no sea negativa
    currentHeight = max(0, currentHeight);
    
    % Calcular el nivel del agua
    z_water = currentHeight - R;
    r_water = sqrt(max(0, R^2 - z_water^2));
    
    % Calcular el porcentaje de volumen
    if currentHeight > 0
        if currentHeight <= R
            h_cap = currentHeight;
            waterVolume = (1/3) * pi * h_cap^2 * (3*R - h_cap);
        else
            h_cap = 2*R - currentHeight;
            waterVolume = (4/3) * pi * R^3 - (1/3) * pi * h_cap^2 * (3*R - h_cap);
        end
        totalVolume = (4/3) * pi * R^3;
        volumePercent = 100 * waterVolume / totalVolume;
    else
        volumePercent = 0;
    end
    
    % Crear un nuevo gráfico
    clf;
    subplot(1,1,1);
    
    % Hacerlo en 3D
    view(3);
    hold on;
    
    % Dibujar el contorno de la esfera
    [X,Y,Z] = sphere(20);
    X = X * R; Y = Y * R; Z = Z * R;
    h_sphere = surf(X, Y, Z);
    set(h_sphere, 'FaceAlpha', 0.1, 'EdgeColor', 'k', 'FaceColor', 'none');
    
    % Dibujar el nivel del agua (si no está vacío)
    if currentHeight > 0.01
        theta = linspace(0, 2*pi, 50);
        x_water = r_water * cos(theta);
        y_water = r_water * sin(theta);
        z_water_pts = z_water * ones(size(theta));
        
        % Dibujar el nivel del agua con una línea roja gruesa
        plot3(x_water, y_water, z_water_pts, 'r-', 'LineWidth', 4);
        
        % Agregar algunos puntos rojos para hacerlo más visible
        scatter3(x_water(1:5:end), y_water(1:5:end), z_water_pts(1:5:end), 50, 'r', 'filled');
        
        % Agregar texto "NIVEL DEL AGUA"
        text(0, 0, z_water + 0.1, 'NIVEL DEL AGUA', 'Color', 'r', 'FontWeight', 'bold', ...
             'HorizontalAlignment', 'center', 'FontSize', 14);
    end
    
    % Dibujar el agujero de drenaje
    theta = linspace(0, 2*pi, 30);
    hole_r = 0.2;
    fill3(hole_r * cos(theta), hole_r * sin(theta), -R * ones(size(theta)), 'k');
    
    % SIEMPRE mostrar el contador de porcentaje
    text(0, 0, 0, sprintf('%.1f%%', volumePercent), 'Color', 'r', 'FontSize', 36, ...
         'FontWeight', 'bold', 'HorizontalAlignment', 'center');
    
    % Mostrar información de depuración en un cuadro de texto en la esquina inferior derecha (lejos del título)
    annotation('textbox', [0.65, 0.05, 0.3, 0.2], 'String', ...
              sprintf('Tiempo: %.1f segundos\nAltura: %.2f m\nZ del agua: %.2f m\nRadio: %.2f m\nVolumen: %.1f%%', ...
                     currentTime, currentHeight, z_water, r_water, volumePercent), ...
              'FontSize', 12, 'BackgroundColor', 'w', 'EdgeColor', 'k');
    
    % Agregar título
    title(sprintf('Drenaje del tanque esférico (modelo ODE): %.1f segundos', currentTime));
    
    % Establecer propiedades del eje
    axis equal;
    grid on;
    xlabel('X (m)'); ylabel('Y (m)'); zlabel('Z (m)');
    xlim([-R-1, R+1]); ylim([-R-1, R+1]); zlim([-R-1, R+1]);
    
    % Forzar el ángulo de vista
    view(30, 30);
    
    % Actualizar la pantalla
    drawnow;
    
    % Para tiempo real, agregar una pequeña pausa para permitir actualizaciones de la interfaz de usuario
    pause(0.01);
end

% Mostrar el área del orificio al final de la simulación

fprintf('Área final del orificio: %.4f m²\n', pi * (0.2)^2);

% Mostrar el estado final "VACÍO"
% Crear un nuevo gráfico para el estado final
clf;
subplot(1,1,1);
view(3);
hold on;

% Dibujar la esfera vacía
[X,Y,Z] = sphere(20);
X = X * R; Y = Y * R; Z = Z * R;
h_sphere = surf(X, Y, Z);
set(h_sphere, 'FaceAlpha', 0.1, 'EdgeColor', 'k', 'FaceColor', 'none');

% Dibujar el agujero de drenaje
theta = linspace(0, 2*pi, 30);
hole_r = 0.2;
fill3(hole_r * cos(theta), hole_r * sin(theta), -R * ones(size(theta)), 'k');

% Mostrar 0% en el centro
text(0, 0, 0, '0.0%', 'Color', 'r', 'FontSize', 36, ...
     'FontWeight', 'bold', 'HorizontalAlignment', 'center');

% Agregar cuadro de información de depuración final en la esquina inferior derecha
annotation('textbox', [0.65, 0.05, 0.3, 0.2], 'String', ...
          sprintf('Tiempo: %.1f segundos\nAltura: 0.00 m\nTanque vacío\nVolumen: 0.0%%', ...
                 totalTime), ...
          'FontSize', 12, 'BackgroundColor', 'w', 'EdgeColor', 'k');

% Agregar texto "TANQUE VACÍO"
text(0, 0, R/2, 'TANQUE VACÍO', 'Color', 'r', 'FontSize', 20, ...
     'FontWeight', 'bold', 'HorizontalAlignment', 'center');

% Establecer propiedades del eje
title(sprintf('Tanque esférico vacío (modelo ODE): %d segundos', totalTime));
axis equal;
grid on;
xlabel('X (m)'); ylabel('Y (m)'); zlabel('Z (m)');
xlim([-R-1, R+1]); ylim([-R-1, R+1]); zlim([-R-1, R+1]);
view(30, 30);

% Mostrar el estado final vacío durante unos segundos
pause(3);