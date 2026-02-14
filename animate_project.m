clc; close all;

% === 1. PRELUARE DATE ===
found = false;
if exist('out', 'var')
    try, pos_data = out.sim_pos; found = true; catch, end
end
if ~found && exist('sim_pos', 'var'), pos_data = sim_pos; found = true; end
if ~found, error('Nu gasesc datele! Ruleaza simularea in Simulink.'); end

dims = size(pos_data);
if length(dims) == 3 && dims(1) == 3
    pos_data = permute(pos_data, [3, 1, 2]); 
end
[n_steps, ~, n_bodies] = size(pos_data);

% === 2. CALCUL MATEMATIC ===
idx_mercur = 2; idx_pamant = 4;
% Cerinta 4
dX = pos_data(:, 1, idx_mercur) - pos_data(:, 1, idx_pamant);
dY = pos_data(:, 2, idx_mercur) - pos_data(:, 2, idx_pamant);
dZ = pos_data(:, 3, idx_mercur) - pos_data(:, 3, idx_pamant);
dist_rel = sqrt(dX.^2 + dY.^2 + dZ.^2);
lambda_deg = rad2deg(unwrap(atan2(dY, dX)));
beta_deg   = rad2deg(asin(dZ ./ dist_rel));

% Cerinta 2 (Scalare)
power_scale = 0.35; 
pos_vis = pos_data; 
real_distances = zeros(n_steps, n_bodies); 
for t = 1:n_steps
    for i = 1:n_bodies
        r_real = sqrt(pos_data(t,1,i)^2 + pos_data(t,2,i)^2 + pos_data(t,3,i)^2);
        real_distances(t, i) = r_real;
        if r_real > 1000
            scale_ratio = (r_real .^ power_scale) / r_real;
            pos_vis(t, :, i) = pos_data(t, :, i) * scale_ratio;
        end
    end
end

% === 3. CONFIGURARE GRAFICĂ===
names = {'Soare', 'Mercur', 'Venus', 'Pamant', 'Marte', 'Jupiter', 'Saturn', 'Uranus', 'Neptun'};
colors = [1.0 0.8 0.2; 0.7 0.7 0.7; 0.9 0.8 0.6; 0.0 0.5 1.0; 0.9 0.3 0.1; 0.8 0.6 0.4; 0.9 0.8 0.5; 0.5 0.9 0.9; 0.2 0.3 0.8];
sizes = [80, 15, 20, 20, 18, 50, 45, 35, 35]; 


f = figure('Name', 'Proiect Final', 'Color', 'k', 'Position', [50 50 1000 900], 'InvertHardcopy', 'off');

ax1 = subplot(4, 1, [1 2 3]); 
set(ax1, 'Color', 'k', 'XColor', 'w', 'YColor', 'w', 'ZColor', 'w', 'GridColor', 'w', 'MinorGridColor', 'w');
hold(ax1, 'on'); grid(ax1, 'on'); axis(ax1, 'equal'); view(ax1, 3);
ax1.GridAlpha = 0.2; 
xlabel(ax1, 'X (Scalat)'); ylabel(ax1, 'Y (Scalat)'); 
title(ax1, 'Sistemul Solar (Vizualizare Scalată)', 'Color', 'w', 'FontSize', 14);

% Elemente statice 3D
theta = linspace(0, 2*pi, 200);
for i = 2:n_bodies 
    r_avg = mean(sqrt(pos_vis(:,1,i).^2 + pos_vis(:,2,i).^2));
    plot3(ax1, r_avg*cos(theta), r_avg*sin(theta), zeros(size(theta)), '--', 'Color', [colors(i,:) 0.3]);
end

h_planets = gobjects(1, n_bodies);
h_trails  = gobjects(1, n_bodies);
h_labels  = gobjects(1, n_bodies);
for i = 1:n_bodies
    h_trails(i) = plot3(ax1, nan, nan, nan, '-', 'Color', [colors(i,:) 0.6]);
    h_planets(i) = scatter3(ax1, nan, nan, nan, sizes(i), colors(i,:), 'filled', 'MarkerEdgeColor', 'w');
    h_labels(i) = text(ax1, nan, nan, nan, '', 'Color', 'w', 'FontSize', 8, 'Interpreter', 'none');
end
max_lim = max(max(max(abs(pos_vis)))) * 1.2;
xlim(ax1, [-max_lim max_lim]); ylim(ax1, [-max_lim max_lim]);

ax2 = subplot(4, 1, 4);

set(ax2, 'Color', [0.05 0.05 0.05], 'XColor', 'w', 'YColor', 'w', 'GridColor', 'w');
hold(ax2, 'on'); grid(ax2, 'on');
title(ax2, 'Cerinta 4: Retrogradarea lui Mercur', 'Color', 'w');
xlabel(ax2, 'Longitudine \lambda', 'Color', 'w'); ylabel(ax2, 'Latitudine \beta', 'Color', 'w');

plot(ax2, lambda_deg, beta_deg, '-', 'Color', [0.3 0.3 0.3], 'LineWidth', 1); % Traseu fundal
h_retro_trail = plot(ax2, nan, nan, 'c-', 'LineWidth', 2); 
h_retro_point = plot(ax2, nan, nan, 'or', 'MarkerSize', 6, 'MarkerFaceColor', 'r');

xlim(ax2, [min(lambda_deg)-2, max(lambda_deg)+2]);
ylim(ax2, [min(beta_deg)-0.5, max(beta_deg)+0.5]);

% === 4. RULARE ===
durata_animatie = 15; 
step_skip = ceil(n_steps / (durata_animatie * 30));
if step_skip < 1, step_skip = 1; end
AU_in_meter = 1.496e11; 

for k = 1:step_skip:n_steps
    % Update 3D
    for i = 1:n_bodies
        x = pos_vis(k, 1, i); y = pos_vis(k, 2, i); z = pos_vis(k, 3, i);
        set(h_trails(i), 'XData', pos_vis(1:step_skip:k, 1, i), 'YData', pos_vis(1:step_skip:k, 2, i), 'ZData', pos_vis(1:step_skip:k, 3, i));
        set(h_planets(i), 'XData', x, 'YData', y, 'ZData', z);
        if i > 1
            dist_au = real_distances(k, i) / AU_in_meter;
            set(h_labels(i), 'Position', [x, y, z], 'String', sprintf(' %s\n %.2f AU', names{i}, dist_au));
        end
    end
    
    % Update 2D
    set(h_retro_trail, 'XData', lambda_deg(1:step_skip:k), 'YData', beta_deg(1:step_skip:k));
    set(h_retro_point, 'XData', lambda_deg(k), 'YData', beta_deg(k));
    
    % Titlu General
    ziua = k * (88 / n_steps);
    sgtitle(['Ziua: ' sprintf('%.1f', ziua) ' / 88'], 'Color', 'w');
    
    drawnow limitrate;
end