% Differential equation for cylindrical tank drainage
function dhdt = cylinderTankODE(~, h, A, a)
    g = 9.81; % Acceleration due to gravity (m/s^2)
    if h <= 0
        dhdt = 0; % No more drainage when empty
    else
        dhdt = -(a / A) * sqrt(2 * g * h); % Torricelli's equation
    end
end

% Parameters for cylinder
R = 1.0;           % Radius of the cylindrical tank (m)
A = pi * R^2;      % Cross-sectional area of the tank (m^2)
h0 = 5.0;          % Initial height of the water (m)
totalTime = 40;    % Total drainage time (seconds)

% Calculate hole size with adjustment factor to ensure complete drainage
g = 9.81;
adjustmentFactor = 1.25; % Increase hole size by 25% to drain faster
a = adjustmentFactor * A * sqrt(h0) / (totalTime * sqrt(2*g));

% Verify drainage time by solving ODE with the calculated hole size
tspan = [0, totalTime];
options = odeset('RelTol', 1e-6, 'AbsTol', 1e-6);
[t_check, h_check] = ode45(@(t, h) cylinderTankODE(t, h, A, a), tspan, h0, options);
final_height = h_check(end);

% If still not empty enough, adjust hole size further
if final_height > 0.05
    % Recalculate with stronger adjustment
    adjustmentFactor = 1.5;
    a = adjustmentFactor * A * sqrt(h0) / (totalTime * sqrt(2*g));
end

% Solve the ODE again with the final adjusted hole size
tspan = linspace(0, totalTime, 1000);
[t, h] = ode45(@(t, h) cylinderTankODE(t, h, A, a), tspan, h0);

% Create figure window
figure;
set(gcf, 'Position', [100, 100, 600, 800]);

% Set up timer for real-time animation
startTime = tic;
isRunning = true;

% Animation loop
while isRunning
    % Get current real time
    currentTime = toc(startTime);
    
    % Clear figure and prepare for drawing
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
    
    % Draw tank outline (fixed rectangle)
    rectangle('Position', [0, 0, 2*R, h0], 'EdgeColor', 'black', 'LineWidth', 2);
    
    % Draw water (blue rectangle that shrinks)
    if currentHeight > 0
        % Gradient color - darker blue when fuller
        waterColor = [0, 0.4 + 0.2*(1-currentHeight/h0), 0.8];
        rectangle('Position', [0, 0, 2*R, currentHeight], 'EdgeColor', 'none', 'FaceColor', waterColor);
    end
    
    % Draw drain hole
    rectangle('Position', [R-0.1, 0, 0.2, 0.05], 'FaceColor', 'black');
    
    % Set axis properties
    axis([-R, 3*R, -1, h0+1]);
    grid on;
    title(sprintf('Tank Drainage: %.1f seconds', currentTime));
    xlabel('Width (m)');
    ylabel('Height (m)');
    
    % Display remaining volume percentage
    volumePercent = 100 * currentHeight / h0;
    text(R, h0*0.5, sprintf('%.1f%%', volumePercent), 'HorizontalAlignment', 'center', 'FontSize', 14);
    
    % Update display
    drawnow;
    
    % Check if we've reached the end
    if currentTime >= totalTime
        title(sprintf('Tank Drainage Complete: %d seconds', totalTime));
        % Draw the final empty tank
        rectangle('Position', [0, 0, 2*R, h0], 'EdgeColor', 'black', 'LineWidth', 2);
        pause(0.5); % Short pause to show empty tank
        break;
    end
    
    % Frame rate control - aim for 30 fps
    pause(0.033); 
end

% Display final empty tank for 3 seconds
clf;
rectangle('Position', [0, 0, 2*R, h0], 'EdgeColor', 'black', 'LineWidth', 2);
axis([-R, 3*R, -1, h0+1]);
grid on;
title(sprintf('Tank Empty: %d seconds', totalTime));
xlabel('Width (m)');
ylabel('Height (m)');
text(R, h0*0.5, '0.0%', 'HorizontalAlignment', 'center', 'FontSize', 14);
pause(3);