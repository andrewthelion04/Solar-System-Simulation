clc; close all;

% === 1. PRELUARE DATE ===
if ~exist('M', 'var') || ~exist('P0', 'var')
    if exist('init_project.m', 'file'), run('init_project'); end
    if ~exist('P0', 'var'), error('Nu gasesc M si P0. Ruleaza init_project.m!'); end
end

% Setari Simulare
h = 600;                
zile = 7;               
t_end = zile * 24 * 3600;
tspan = 0:h:t_end;

% Vector stare initial
y0 = [P0(:); V0(:)]; 
y_rk4 = zeros(length(y0), length(tspan));
y_rk4(:,1) = y0;

% === 2. RULARE RK4 ===
disp('Rulare RK4 manual...');
ode_solar = @(t, y) calcul_derivate_solar(t, y, M, G);

tic; 
for k = 1:(length(tspan)-1)
    t = tspan(k);
    y_n = y_rk4(:, k);
    
    k1 = ode_solar(t, y_n);
    k2 = ode_solar(t + h/2, y_n + (h/2)*k1);
    k3 = ode_solar(t + h/2, y_n + (h/2)*k2);
    k4 = ode_solar(t + h, y_n + k3*h);
    
    y_rk4(:, k+1) = y_n + (h/6)*(k1 + 2*k2 + 2*k3 + k4);
end
t_calc = toc;
disp(['RK4 finalizat in ', num2str(t_calc), ' secunde.']);

% === 3. PRELUARE SIMULINK ===
has_simulink = false;
try
    Sim_Pos = out.sim_pos; Sim_Time = out.tout; has_simulink = true;
    disp('✅ Date preluate din Simulink (out).');
catch
    if exist('sim_pos', 'var'), Sim_Pos = sim_pos; Sim_Time = tout; has_simulink = true; end
end

if ~has_simulink
    disp('⚠️ Date lipsa. Rulez simularea...');
    try, sim('simulareSistemSolar'); Sim_Pos = out.sim_pos; Sim_Time = out.tout; has_simulink = true; catch, end
end

if has_simulink && size(Sim_Pos, 1) == 3
    Sim_Pos = permute(Sim_Pos, [3, 1, 2]); 
end

% === 4. GENERARE GRAFICE ===
if has_simulink
    names = {'Soare', 'Mercur', 'Venus', 'Pamant', 'Marte', 'Jupiter', 'Saturn', 'Uranus', 'Neptun'};
    erori_maxime = zeros(1, 9);
    
    % --- FIGURA 1: MERCUR (Traiectorie + Eroare Detaliata) ---
    f1 = figure('Name', 'Fig1: Analiza Mercur', 'Color', 'w', 'Position', [50 400 600 500]);
    
    idx_mercur = 2; 
    idx_x = (idx_mercur-1)*3 + 1; % Indexul 4 pentru X Mercur
    
    % Date RK4
    rk_x_merc = y_rk4(idx_x, :);
    
    % Date Simulink (limitat la t_end)
    mask = Sim_Time <= t_end;
    sim_x_raw = Sim_Pos(mask, 1, idx_mercur); 
    sim_t_raw = Sim_Time(mask);
    
    subplot(2,1,1);
    plot(tspan/(24*3600), rk_x_merc, 'r--', 'LineWidth', 2); hold on;
    plot(sim_t_raw/(24*3600), sim_x_raw, 'b', 'LineWidth', 1);
    legend('RK4 Manual', 'Simulink');
    title('Traiectorie Mercur (X)'); ylabel('Pozitie (m)'); grid on;
    
    % Calcul eroare Mercur
    sim_interp = interp1(Sim_Time, squeeze(Sim_Pos(:,1,idx_mercur)), tspan);
    err_merc = abs(rk_x_merc(:) - sim_interp(:)); 
    
    subplot(2,1,2);
    plot(tspan/(24*3600), err_merc/1000, 'k');
    title('Eroarea Absoluta in timp (Mercur)'); 
    ylabel('Eroare (km)'); xlabel('Timp (Zile)'); grid on;
    drawnow;

    % --- CALCUL ERORI MAXIME ---
    for i = 1:9
        ix = (i-1)*3 + 1; iy = (i-1)*3 + 2; iz = (i-1)*3 + 3;
        
        % Extragem coordonatele RK4
        rx = y_rk4(ix, :); ry = y_rk4(iy, :); rz = y_rk4(iz, :);
        
        % Interpolam Simulink
        sx = interp1(Sim_Time, squeeze(Sim_Pos(:,1,i)), tspan);
        sy = interp1(Sim_Time, squeeze(Sim_Pos(:,2,i)), tspan);
        sz = interp1(Sim_Time, squeeze(Sim_Pos(:,3,i)), tspan);
        
        dist = sqrt( (rx(:) - sx(:)).^2 + (ry(:) - sy(:)).^2 + (rz(:) - sz(:)).^2 );

        erori_maxime(i) = max(dist);
    end
    
    % --- FIGURA 2 ---
    f2 = figure('Name', 'Fig2: Top Erori', 'Color', 'w', 'Position', [700 400 600 400]);
    bar(erori_maxime/1000);
    set(gca, 'XTickLabel', names, 'XTick', 1:9);
    ylabel('Eroare Maxima (km)'); 
    title(['Eroarea Maxima acumulata in ', num2str(zile), ' zile']); 
    grid on;
   
    disp('=== TABEL REZULTATE COMPARATIVE ===');
    disp(table(names', round(erori_maxime'/1000, 3), 'VariableNames', {'Planeta', 'Eroare_Max_km'}));

else
    disp('Eroare critica: Nu am date din Simulink.');
end

% Functia Derivata
function dydt = calcul_derivate_solar(~, y, M, G)
    num_bodies = 9;
    pos_vec = y(1:27); vel_vec = y(28:54);
    P = reshape(pos_vec, [3, num_bodies]);
    Acc = zeros(3, num_bodies);
    for i = 1:num_bodies
        for j = 1:num_bodies
            if i ~= j
                r_rel = P(:, j) - P(:, i);
                dist = norm(r_rel);
                Acc(:, i) = Acc(:, i) + (G * M(j) * r_rel) / (dist^3);
            end
        end
    end
    dydt = [vel_vec; Acc(:)];
end