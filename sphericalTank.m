% Spherical Tank Drainage with ODE - Real-time
clear all; close all; clc;

% Differential equation for spherical tank drainage
function dhdt = sphereTankODE(~, h, R, a)
    g = 9.81; % Acceleration due to gravity (m/s^2)
    if h <= 0
        dhdt = 0; % No more drainage when empty
    else
        % For a sphere, calculate the radius at height h
        r_h = sqrt(max(0.001, R^2 - (R - h)^2)); % Radius at height h
        A_h = pi * r_h^2; % Cross-sectional area at height h
        dhdt = -(a / A_h) * sqrt(2 * g * h); % Modified Torricelli's equation
    end
end

% Parameters for sphere
R = 2.5; % Radius of the spherical tank (m)
totalTime = 70; % Total drainage time (seconds)

% Solve the ODE first with MUCH larger hole size to ensure complete drainage
fprintf('Solving ODE for spherical tank drainage...\n');
h0 = 2 * R; % Initial height (full sphere)
a = 0.15; % SIGNIFICANTLY increased hole size to ensure complete drainage
tspan = [0, totalTime];

% Solve ODE
opts = odeset('RelTol', 1e-6, 'AbsTol', 1e-6);
[t, h] = ode45(@(t, h) sphereTankODE(t, h, R, a), tspan, h0, opts);

% Check final value to ensure complete drainage
finalHeight = h(end);
fprintf('Final height at %d seconds: %.4f m\n', totalTime, finalHeight);

% Calculate drain completion time
empty_idx = find(h < 0.01, 1);
if ~isempty(empty_idx)
    actual_drain_time = t(empty_idx);
    fprintf('Tank completely drains in approximately %.1f seconds\n', actual_drain_time);
end

% Delay start of animation by 3 seconds
pause(3); % Added delay before visualization begins

% Initialize figure
figure('Position', [100, 100, 900, 800]);

% Start real-time animation
startTime = tic;
isRunning = true;

while isRunning
    % Get current time
    currentTime = toc(startTime);
    
    % Stop when we reach total time
    if currentTime >= totalTime
        currentTime = totalTime;
        isRunning = false;
    end
    
    % Interpolate height from ODE solution
    currentHeight = interp1(t, h, currentTime, 'linear');
    
    % Ensure non-negative height
    currentHeight = max(0, currentHeight);
    
    % Calculate water level
    z_water = currentHeight - R;
    r_water = sqrt(max(0, R^2 - z_water^2));
    
    % Calculate volume percentage
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
    
    % Create a fresh plot
    clf;
    subplot(1,1,1);
    
    % Make it 3D
    view(3);
    hold on;
    
    % Draw sphere outline
    [X,Y,Z] = sphere(20);
    X = X * R; Y = Y * R; Z = Z * R;
    h_sphere = surf(X, Y, Z);
    set(h_sphere, 'FaceAlpha', 0.1, 'EdgeColor', 'k', 'FaceColor', 'none');
    
    % Draw water level (if not empty)
    if currentHeight > 0.01
        theta = linspace(0, 2*pi, 50);
        x_water = r_water * cos(theta);
        y_water = r_water * sin(theta);
        z_water_pts = z_water * ones(size(theta));
        
        % Draw water level with thick red line
        plot3(x_water, y_water, z_water_pts, 'r-', 'LineWidth', 4);
        
        % Add some red dots to make it more visible
        scatter3(x_water(1:5:end), y_water(1:5:end), z_water_pts(1:5:end), 50, 'r', 'filled');
        
        % Add WATER text
        text(0, 0, z_water + 0.1, 'WATER LEVEL', 'Color', 'r', 'FontWeight', 'bold', ...
             'HorizontalAlignment', 'center', 'FontSize', 14);
    end
    
    % Draw drain hole
    theta = linspace(0, 2*pi, 30);
    hole_r = 0.2;
    fill3(hole_r * cos(theta), hole_r * sin(theta), -R * ones(size(theta)), 'k');
    
    % ALWAYS show percentage counter
    text(0, 0, 0, sprintf('%.1f%%', volumePercent), 'Color', 'r', 'FontSize', 36, ...
         'FontWeight', 'bold', 'HorizontalAlignment', 'center');
    
    % Show debug info in a text box at BOTTOM-right corner (away from title)
    annotation('textbox', [0.65, 0.05, 0.3, 0.2], 'String', ...
              sprintf('Time: %.1f seconds\nHeight: %.2f m\nWater Z: %.2f m\nRadius: %.2f m\nVolume: %.1f%%', ...
                     currentTime, currentHeight, z_water, r_water, volumePercent), ...
              'FontSize', 12, 'BackgroundColor', 'w', 'EdgeColor', 'k');
    
    % Add title
    title(sprintf('Spherical Tank Drainage (ODE Model): %.1f seconds', currentTime));
    
    % Set axis properties
    axis equal;
    grid on;
    xlabel('X (m)'); ylabel('Y (m)'); zlabel('Z (m)');
    xlim([-R-1, R+1]); ylim([-R-1, R+1]); zlim([-R-1, R+1]);
    
    % Force view angle
    view(30, 30);
    
    % Update display
    drawnow;
    
    % For real-time, just add a tiny pause to allow UI updates
    pause(0.01);
end

% Show final "EMPTY" state
% Create a fresh plot for the final state
clf;
subplot(1,1,1);
view(3);
hold on;

% Draw empty sphere
[X,Y,Z] = sphere(20);
X = X * R; Y = Y * R; Z = Z * R;
h_sphere = surf(X, Y, Z);
set(h_sphere, 'FaceAlpha', 0.1, 'EdgeColor', 'k', 'FaceColor', 'none');

% Draw drain hole
theta = linspace(0, 2*pi, 30);
hole_r = 0.2;
fill3(hole_r * cos(theta), hole_r * sin(theta), -R * ones(size(theta)), 'k');

% Show 0% at center
text(0, 0, 0, '0.0%', 'Color', 'r', 'FontSize', 36, ...
     'FontWeight', 'bold', 'HorizontalAlignment', 'center');

% Add final debug info box in bottom-right corner
annotation('textbox', [0.65, 0.05, 0.3, 0.2], 'String', ...
          sprintf('Time: %.1f seconds\nHeight: 0.00 m\nTank Empty\nVolume: 0.0%%', ...
                 totalTime), ...
          'FontSize', 12, 'BackgroundColor', 'w', 'EdgeColor', 'k');

% Add "TANK EMPTY" text
text(0, 0, R/2, 'TANK EMPTY', 'Color', 'r', 'FontSize', 20, ...
     'FontWeight', 'bold', 'HorizontalAlignment', 'center');

% Set axis properties
title(sprintf('Spherical Tank Empty (ODE Model): %d seconds', totalTime));
axis equal;
grid on;
xlabel('X (m)'); ylabel('Y (m)'); zlabel('Z (m)');
xlim([-R-1, R+1]); ylim([-R-1, R+1]); zlim([-R-1, R+1]);
view(30, 30);

% Display final empty state for a few seconds
pause(3);