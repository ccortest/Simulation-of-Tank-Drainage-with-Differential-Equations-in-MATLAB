% Differential equation for cone-shaped tank drainage
function dhdt = coneTankODE(~, h, R, a)
    g = 9.81; % Acceleration due to gravity (m/s^2)
    if h <= 0
        dhdt = 0; % No more drainage when empty
    else
        % For a cone, the cross-sectional area varies with height: A(h) = π·(r(h))²
        % where r(h) = (R/H)·h (radius at height h)
        H = 5.0; % Total height of the cone
        r_h = (R/H) * h; % Current radius at height h
        A_h = pi * r_h^2; % Current cross-sectional area at height h
        
        dhdt = -(a / A_h) * sqrt(2 * g * h); % Modified Torricelli's equation
    end
end

% Parameters for cone
R = 2.0;           % Radius at the top of the cone (m)
h0 = 5.0;          % Initial height of the water/cone (m)
totalTime = 40;    % Total drainage time (seconds)

% Calculate hole size with adjustment to ensure complete drainage
g = 9.81;
a = 0.02; % Initial guess for hole area

% Determine appropriate hole size by trial and error
fprintf('Finding appropriate hole size for cone tank...\n');
tspan = [0, totalTime];
options = odeset('RelTol', 1e-6, 'AbsTol', 1e-6);

% Test different hole sizes until we find one that drains properly
while true
    [~, h_test] = ode45(@(t, h) coneTankODE(t, h, R, a), tspan, h0, options);
    final_height = h_test(end);
    
    if final_height < 0.05
        % Good enough: tank will be essentially empty
        break;
    elseif final_height > 0.5
        % Too much water left, increase hole size by 20%
        a = a * 1.2;
    else
        % Close but not quite empty, fine-tune
        a = a * 1.1;
    end
end

fprintf('Calculated hole size: %.6f m²\n', a);

% Solve ODE with the final hole size
tspan = linspace(0, totalTime, 1000);
[t, h] = ode45(@(t, h) coneTankODE(t, h, R, a), tspan, h0);

% Create figure window
figure;
set(gcf, 'Position', [100, 100, 800, 900]);

% Set up timer for real-time animation
startTime = tic;
isRunning = true;

% Animation loop
while isRunning
    % Get current real time
    currentTime = toc(startTime);
    
    % Clear figure
    clf;
    
    % Find water height at current time using interpolation
    if currentTime <= totalTime
        currentHeight = interp1(t, h, min(currentTime, totalTime), 'linear');
        % Ensure height is non-negative and truly zero at the end
        if currentHeight < 0.05 && currentTime > totalTime * 0.95
            currentHeight = 0;
        end
    else
        currentHeight = 0;
        isRunning = false; % End animation after totalTime
    end
    
    % Start plotting
    hold on;
    
    % Create clean cone visualization - start with just the edges
    numPoints = 100;
    theta = linspace(0, 2*pi, numPoints);
    
    % Draw the top circle of the cone
    x_top = R * cos(theta);
    y_top = R * sin(theta);
    z_top = ones(size(theta)) * h0;
    plot3(x_top, y_top, z_top, 'k-', 'LineWidth', 2);
    
    % Draw vertical lines from top to bottom
    numLines = 16;
    for i = 1:numLines
        angle = 2*pi * (i-1) / numLines;
        x_line = [R * cos(angle), 0];
        y_line = [R * sin(angle), 0];
        z_line = [h0, 0];
        plot3(x_line, y_line, z_line, 'k-', 'LineWidth', 1.5);
    end
    
    % Draw the water level if there's any water
    if currentHeight > 0
        % Calculate the radius at current water height
        current_r = (R/h0) * currentHeight;
        
        % Draw water surface circle
        x_water = current_r * cos(theta);
        y_water = current_r * sin(theta);
        z_water = ones(size(theta)) * currentHeight;
        fill3(x_water, y_water, z_water, [0, 0.5, 0.8], 'EdgeColor', 'none');
        plot3(x_water, y_water, z_water, 'k-', 'LineWidth', 1);
        
        % Show the water level as a percentage
        currentVolume = (1/3) * pi * current_r^2 * currentHeight;
        initialVolume = (1/3) * pi * R^2 * h0;
        volumePercent = 100 * currentVolume / initialVolume;
        text(0, 0, h0*0.5, sprintf('%.1f%%', volumePercent), ...
             'HorizontalAlignment', 'center', 'FontSize', 14, 'FontWeight', 'bold');
    else
        % Show 0% when empty
        text(0, 0, h0*0.5, '0.0%', ...
             'HorizontalAlignment', 'center', 'FontSize', 14, 'FontWeight', 'bold');
    end
    
    % Draw a small black circle at the bottom to represent the hole
    plot3(0, 0, 0, 'ko', 'MarkerFaceColor', 'k', 'MarkerSize', 5);
    
    % Set up the view
    view(30, 30);
    axis equal;
    grid on;
    xlim([-R-0.5, R+0.5]);
    ylim([-R-0.5, R+0.5]);
    zlim([-0.5, h0+0.5]);
    
    % Labels and title
    xlabel('X (m)');
    ylabel('Y (m)');
    zlabel('Height (m)');
    title(sprintf('Cone Tank Drainage: %.1f seconds', currentTime));
    
    % Update display
    drawnow;
    
    % Check if we've reached the end
    if currentTime >= totalTime
        title(sprintf('Cone Tank Empty: %d seconds', totalTime));
        break;
    end
    
    % Frame rate control
    pause(0.033);
end

% Display final empty tank for 3 seconds
title(sprintf('Cone Tank Empty: %d seconds', totalTime));
text(0, 0, h0*0.5, '0.0%', 'HorizontalAlignment', 'center', 'FontSize', 14, 'FontWeight', 'bold');
pause(3);