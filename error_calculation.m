clc; close all;

% === 1. PRELUARE DATE ===
if ~exist('out', 'var')
    disp('⚠️ Nu gasesc variabila "out". Rulez simularea...');
    try
        sim('simulareSistemSolar');
    catch ME
        error(['Nu pot rula simularea. Verifica modelul .slx! Eroare: ' ME.message]);
    end
end

disp('Preluare date din Simulink...');

try
    raw_pos = out.sim_pos;
    raw_vel = out.sim_vel; 
    Sim_Time = out.tout;
    
    disp('✅ Datele sim_pos si sim_vel au fost gasite in "out".');
catch
    error('Eroare critica: Nu pot accesa out.sim_pos sau out.sim_vel. Verifica daca blocul To Workspace exista!');
end

% === 2. CORECTIE DIMENSIUNI ===
if size(raw_pos, 1) == 3 && size(raw_pos, 2) == 9
    Sim_Pos = permute(raw_pos, [3, 1, 2]);
    Sim_Vel = permute(raw_vel, [3, 1, 2]);
else
    Sim_Pos = raw_pos;
    Sim_Vel = raw_vel;
end

% === 3. IDENTIFICARE MOMENT T = 88 ZILE ===
target_day = 88;
target_sec = target_day * 24 * 3600;

% Gasim indexul de timp cel mai apropiat
[~, idx_end] = min(abs(Sim_Time - target_sec));
found_day = Sim_Time(idx_end) / (24*3600);

disp(['Analiza se face la t = ' num2str(found_day, '%.4f') ' zile (Index: ' num2str(idx_end) ')']);


% === 4. DATE DE REFERINTA JPL HORIZONS ===
km = 1000; % Factor conversie
JPL_Data = zeros(9, 6);

% DATELE JPL - pozitii si viteze la tf
% Structura: [X, Y, Z, VX, VY, VZ]
JPL_Data(1,:) = [-3.616003227749719E+05, -8.192423808450673E+05, 1.778708357190009E+04, 1.199969690492604E-02, 1.875178447095301E-03, -2.435006393185419E-04] * km; % Soare
JPL_Data(2,:) = [-2.028082985558694E+07, -6.759144756871383E+07, -3.612099836878795E+06, 3.691006741069901E+01, -1.149347776136536E+01, -4.323886504027616E+00] * km; % Mercur
JPL_Data(3,:) = [ 4.811462572871421E+07,  9.560269671181457E+07, -1.454561905026384E+06, -3.139114555388979E+01,  1.557352174451042E+01,  2.025636990220985E+00] * km; % Venus
JPL_Data(4,:) = [-1.461475406536185E+08, -3.416937245606323E+07,  2.059893961889111E+04, 6.171131549844301E+00, -2.914821905479119E+01,  1.472819553471894E-03] * km; % Pamant
JPL_Data(5,:) = [ 1.949880837153193E+08, -6.807925475809059E+07, -6.181866486181580E+06, 8.827346482281760E+00,  2.498350149315970E+01,  3.071218182966451E-01] * km; % Marte
JPL_Data(6,:) = [-3.507794556144705E+08,  7.012144275125378E+08,  4.941623275931120E+06, -1.184076500370632E+01, -5.227462089800610E+00,  2.866717411995794E-01] * km; % Jupiter
JPL_Data(7,:) = [ 1.413475817361116E+09,  1.142254922880247E+08, -5.826477834604148E+07, -1.310220607702013E+00,  9.607195045696781E+00, -1.149132588082313E-01] * km; % Saturn
JPL_Data(8,:) = [ 1.430308869372877E+09,  2.536909916375675E+09, -9.108055302811861E+06, -5.982325339924798E+00,  3.027110871076291E+00,  8.873944400848055E-02] * km; % Uranus
JPL_Data(9,:) = [ 4.467109691009355E+09,  1.202539002909733E+08, -1.054255215283145E+08, -1.820369030475492E-01,  5.465537206863230E+00, -1.083584214638393E-01] * km; % Neptun


% === 5. CALCUL ERORI ===
names = {'Soare', 'Mercur', 'Venus', 'Pamant', 'Marte', 'Jupiter', 'Saturn', 'Uranus', 'Neptun'};
err_pos = zeros(9, 1);
err_vel = zeros(9, 1);

for i = 1:9 
    R_sim = squeeze(Sim_Pos(idx_end, :, i))'; 
    V_sim = squeeze(Sim_Vel(idx_end, :, i))';
    
    R_jpl = JPL_Data(i, 1:3)';
    V_jpl = JPL_Data(i, 4:6)';
    
    % Calculam norma diferentei (Distanta Euclidiana)
    err_pos(i) = norm(R_sim - R_jpl);
    err_vel(i) = norm(V_sim - V_jpl);
end


% === 6. AFISARE REZULTATE ===
fprintf('\n==========================================================================\n');
fprintf('   VALIDARE FINALA (SIMULINK vs JPL) -- T = 88 Zile\n');
fprintf('==========================================================================\n');
fprintf('%-10s | %-18s | %-18s\n', 'Corp', 'Eroare Pozitie (km)', 'Eroare Viteza (m/s)');
fprintf('--------------------------------------------------------------------------\n');

for i = 1:9
    fprintf('%-10s | %18.3f | %18.3f\n', names{i}, err_pos(i)/1000, err_vel(i));
end
fprintf('==========================================================================\n');

% --- GRAFICE ---
figure('Name', 'Cerinta 6: Validare Finala', 'Color', 'w', 'Position', [100 100 1000 500]);
subplot(1,2,1);
bar(err_pos/1000, 'FaceColor', [0.2 0.6 0.3]);
title('Eroare Pozitie'); ylabel('Eroare (km)');
set(gca, 'XTickLabel', names, 'XTick', 1:9, 'XTickLabelRotation', 45); grid on;

subplot(1,2,2);
bar(err_vel, 'FaceColor', [0.2 0.4 0.8]);
title('Eroare Viteza'); ylabel('Eroare (m/s)');
set(gca, 'XTickLabel', names, 'XTick', 1:9, 'XTickLabelRotation', 45); grid on;