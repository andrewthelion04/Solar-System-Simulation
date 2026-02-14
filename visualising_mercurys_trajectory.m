clc; close all;

% === 1. PRELUARE DATE (Metoda robustă) ===
found = false;
if exist('out', 'var')
    try, pos_data = out.sim_pos; found = true; catch, end
end
if ~found && exist('sim_pos', 'var'), pos_data = sim_pos; found = true; end

if ~found, error('Nu gasesc datele! Ruleaza simularea in Simulink.'); end

% Corectie orientare date (Timp x 3 x Corpuri)
dims = size(pos_data);
if length(dims) == 3 && dims(1) == 3
    pos_data = permute(pos_data, [3, 1, 2]); 
end

% === 2. CALCUL MATEMATIC ===
% Indici (conform vectorului M din init): 2 = Mercur, 4 = Pamant
idx_mercur = 2;
idx_pamant = 4;

% A. Vectorul Relativ (De la Pamant spre Mercur)
% r_rel = r_Mercur - r_Pamant
dX = pos_data(:, 1, idx_mercur) - pos_data(:, 1, idx_pamant);
dY = pos_data(:, 2, idx_mercur) - pos_data(:, 2, idx_pamant);
dZ = pos_data(:, 3, idx_mercur) - pos_data(:, 3, idx_pamant);

% Distanța scalară (r)
R = sqrt(dX.^2 + dY.^2 + dZ.^2);

% B. Conversia în Coordonate Ecliptice (Formulele 3a și 3b din PDF)
% Lambda (Longitudinea) - atan2 returnează valori intre -pi si pi
lambda_rad = atan2(dY, dX);

% Beta (Latitudinea) - asin(z / r)
beta_rad = asin(dZ ./ R);

% C. Conversia în Grade
% Folosim 'unwrap' pentru Lambda ca să nu avem salturi bruște de la 180 la -180
% Acest lucru face graficul continuu.
lambda_deg = rad2deg(unwrap(lambda_rad)); 
beta_deg = rad2deg(beta_rad);

% === 3. VIZUALIZARE (GRAFICUL CERUT) ===
figure('Name', 'Cerinta 4: Traiectoria Ecliptica', 'Color', 'w');

% Plotam Beta in functie de Lambda
plot(lambda_deg, beta_deg, 'b-', 'LineWidth', 2);
hold on; grid on;

% Marcam punctele de Start si Stop pentru claritate
plot(lambda_deg(1), beta_deg(1), 'go', 'MarkerFaceColor', 'g', 'MarkerSize', 8);
plot(lambda_deg(end), beta_deg(end), 'rs', 'MarkerFaceColor', 'r', 'MarkerSize', 8);

% Adaugam sageti pentru a arata directia (optional, dar util)
if length(lambda_deg) > 20
    idx_mid = round(length(lambda_deg)/2);
    quiver(lambda_deg(idx_mid), beta_deg(idx_mid), ...
           lambda_deg(idx_mid+1)-lambda_deg(idx_mid), ...
           beta_deg(idx_mid+1)-beta_deg(idx_mid), ...
           'MaxHeadSize', 2, 'Color', 'k', 'LineWidth', 2);
end

xlabel('Longitudine Ecliptică \lambda (grade)');
ylabel('Latitudine Ecliptică \beta (grade)');
title('Traiectoria aparentă a lui Mercur (văzută de pe Pământ)');
subtitle('Bucla reprezintă mișcarea retrogradă');
legend('Traiectorie', 'Start (t=0)', 'Stop (t=final)', 'Directie');

% === 4. INTERPRETARE AUTOMATA ===
disp('Analiza Cerinta 4:');
disp(['Variatia Longitudinii: ', num2str(max(lambda_deg) - min(lambda_deg)), ' grade']);
disp(['Variatia Latitudinii:  ', num2str(max(beta_deg) - min(beta_deg)), ' grade']);
disp('Daca graficul arata o bucla sau o forma de "S", ai surprins fenomenul de retrogradare.');