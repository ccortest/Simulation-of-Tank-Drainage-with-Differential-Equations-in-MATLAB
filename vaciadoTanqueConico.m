% Ecuación diferencial para el drenaje del tanque en forma de cono
function dhdt = coneTankODE(~, h, R, a)
    g = 9.81; % Aceleración debida a la gravedad (m/s^2)
    if h <= 0
        dhdt = 0; % No hay más drenaje cuando está vacío
    else
        % Para un cono, el área transversal varía con la altura: A(h) = π·(r(h))²
        % donde r(h) = (R/H)·h (radio a la altura h)
        H = 5.0; % Altura total del cono
        r_h = (R/H) * h; % Radio actual a la altura h
        A_h = pi * r_h^2; % Área transversal actual a la altura h
        
        dhdt = -(a / A_h) * sqrt(2 * g * h); % Ecuación de Torricelli modificada
    end
end

% Parámetros para el cono
R = 2.0;           % Radio en la parte superior del cono (m)
h0 = 5.0;          % Altura inicial del agua/cono (m)
totalTime = 40;    % Tiempo total de drenaje (segundos)

% Calcular el tamaño del agujero con ajuste para asegurar el drenaje completo
g = 9.81;
a = 0.02; % Estimación inicial para el área del agujero

% Determinar el tamaño apropiado del agujero por prueba y error
fprintf('Encontrando el tamaño apropiado del agujero para el tanque en forma de cono...\n');
tspan = [0, totalTime];
options = odeset('RelTol', 1e-6, 'AbsTol', 1e-6);

% Probar diferentes tamaños de agujero hasta encontrar uno que drene correctamente
while true
    [~, h_test] = ode45(@(t, h) coneTankODE(t, h, R, a), tspan, h0, options);
    final_height = h_test(end);
    
    if final_height < 0.05
        % Suficientemente bueno: el tanque estará esencialmente vacío
        break;
    elseif final_height > 0.5
        % Queda demasiada agua, aumentar el tamaño del agujero en un 20%
        a = a * 1.2;
    else
        % Cerca pero no completamente vacío, ajustar finamente
        a = a * 1.1;
    end
end

fprintf('Tamaño del agujero calculado: %.6f m²\n', a);

% Resolver la ODE con el tamaño final del agujero
tspan = linspace(0, totalTime, 1000);
[t, h] = ode45(@(t, h) coneTankODE(t, h, R, a), tspan, h0);

% Crear la ventana de la figura
figure;
set(gcf, 'Position', [100, 100, 800, 900]);

% Configurar el temporizador para la animación en tiempo real
startTime = tic;
isRunning = true;

% Bucle de animación
while isRunning
    % Obtener el tiempo real actual
    currentTime = toc(startTime);
    
    % Limpiar la figura
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
    
    % Comenzar a graficar
    hold on;
    
    % Crear una visualización limpia del cono - comenzar solo con los bordes
    numPoints = 100;
    theta = linspace(0, 2*pi, numPoints);
    
    % Dibujar el círculo superior del cono
    x_top = R * cos(theta);
    y_top = R * sin(theta);
    z_top = ones(size(theta)) * h0;
    plot3(x_top, y_top, z_top, 'k-', 'LineWidth', 2);
    
    % Dibujar líneas verticales desde la parte superior hasta la inferior
    numLines = 16;
    for i = 1:numLines
        angle = 2*pi * (i-1) / numLines;
        x_line = [R * cos(angle), 0];
        y_line = [R * sin(angle), 0];
        z_line = [h0, 0];
        plot3(x_line, y_line, z_line, 'k-', 'LineWidth', 1.5);
    end
    
    % Dibujar el nivel del agua si hay agua
    if currentHeight > 0
        % Calcular el radio en la altura actual del agua
        current_r = (R/h0) * currentHeight;
        
        % Dibujar el círculo de la superficie del agua
        x_water = current_r * cos(theta);
        y_water = current_r * sin(theta);
        z_water = ones(size(theta)) * currentHeight;
        fill3(x_water, y_water, z_water, [0, 0.5, 0.8], 'EdgeColor', 'none');
        plot3(x_water, y_water, z_water, 'k-', 'LineWidth', 1);
        
        % Mostrar el nivel del agua como un porcentaje
        currentVolume = (1/3) * pi * current_r^2 * currentHeight;
        initialVolume = (1/3) * pi * R^2 * h0;
        volumePercent = 100 * currentVolume / initialVolume;
        text(0, 0, h0*0.5, sprintf('%.1f%%', volumePercent), ...
             'HorizontalAlignment', 'center', 'FontSize', 14, 'FontWeight', 'bold');
    else
        % Mostrar 0% cuando está vacío
        text(0, 0, h0*0.5, '0.0%', ...
             'HorizontalAlignment', 'center', 'FontSize', 14, 'FontWeight', 'bold');
    end
    
    % Dibujar un pequeño círculo negro en la parte inferior para representar el agujero
    plot3(0, 0, 0, 'ko', 'MarkerFaceColor', 'k', 'MarkerSize', 5);
    
    % Configurar la vista
    view(30, 30);
    axis equal;
    grid on;
    xlim([-R-0.5, R+0.5]);
    ylim([-R-0.5, R+0.5]);
    zlim([-0.5, h0+0.5]);
    
    % Etiquetas y título
    xlabel('X (m)');
    ylabel('Y (m)');
    zlabel('Altura (m)');
    title(sprintf('Drenaje del tanque en forma de cono: %.1f segundos', currentTime));
    
    % Actualizar la pantalla
    drawnow;
    
    % Verificar si hemos llegado al final
    if currentTime >= totalTime
        title(sprintf('Tanque en forma de cono vacío: %d segundos', totalTime));
        break;
    end
    
    % Control de la tasa de fotogramas
    pause(0.033);
end


% Mostrar el tanque vacío final durante 3 segundos
title(sprintf('Tanque en forma de cono vacío: %d segundos', totalTime));
text(0, 0, h0*0.5, '0.0%', 'HorizontalAlignment', 'center', 'FontSize', 14, 'FontWeight', 'bold');
pause(3);