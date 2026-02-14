clear all; clc;

% === 1. DEFINIREA CONSTANTELOR SI MASELOR (SI - kg) ===
G = 6.6743e-11; % Constanta gravitationala

% Masele extrase din fisierele JPL Horizons (si ajustate pentru Barycenter unde e cazul)
m_soare   = 1.98841e30; 
m_mercur  = 3.302e23;   
m_venus   = 4.8685e24;   
m_pamant  = 6.046e24;    
m_marte   = 6.417e23;    
m_jupiter = 1.898e27;
m_saturn  = 5.683e26;
m_uranus  = 8.681e25;
m_neptun  = 1.024e26;

% Vectorul Maselor
M = [m_soare, m_mercur, m_venus, m_pamant, m_marte, m_jupiter, m_saturn, m_uranus, m_neptun];

% === 2. CONDIȚII INIȚIALE (Pozitii si Viteze) ===

raw_soare = [-4.545728382786301E+05, -8.276568449707576E+05, 1.961830981850158E+04, ...
             1.240794959337140E-02,  3.715086392214070E-04, -2.355967972716934E-04];

raw_mercur = [-2.047126786295709E+07, -6.756979520609458E+07, -3.598782844601441E+06, ...
             3.688967406651244E+01,  -1.156353647878473E+01, -4.327613920407869E+00];

raw_venus = [2.466623144659562E+07, -1.067050957545007E+08, -2.884431896068119E+06, ...
             3.385111623982429E+01, 7.964606876781507E+00, -1.843302337195575E+00];

raw_pamant = [-3.675080692686584E+07, 1.417290848196993E+08, 1.129776883219928E+04, ...
             -2.933926536609570E+01, -7.461569367008025E+00, 3.647474211834201E-04];

raw_marte = [5.890058927523990E+07, -2.054352265769322E+08, -5.723569124578565E+06, ...
             2.419929091632867E+01, 8.833802655563568E+00, -4.082212054975201E-01];

raw_jupiter = [-2.581962940163333E+08, 7.352528284600519E+08, 2.728528877674520E+06, ...
             -1.248234891963368E+01, -3.709678837785656E+00, 2.947224891371236E-01];

raw_saturn = [1.421542741242918E+09, 4.105920109561522E+07, -5.731353123121601E+07, ...
             -8.119935758663011E-01, 9.634663857090288E+00, -1.352250345959494E-01];

raw_uranus = [1.475569158596288E+09, 2.513501374713733E+09, -9.781310356934071E+06, ...
             -5.922978645808492E+00, 3.130239463183912E+00, 8.835392808901643E-02];

raw_neptun = [4.468301637822775E+09, 7.869375014342986E+07, -1.045971296337095E+08, ...
             -1.315005143481850E-01, 5.466662984190483E+00, -1.095460999475428E-01];


% === 3. CONVERSIE SI PREGATIRE PENTRU SIMULINK ===

% Factor de conversie km -> m
km2m = 1000;

% Gruparea datelor brute intr-o matrice temporara
Raw_All = [raw_soare; raw_mercur; raw_venus; raw_pamant; raw_marte; ...
           raw_jupiter; raw_saturn; raw_uranus; raw_neptun]'; 
           
% Extragem pozitiile 
P0 = Raw_All(1:3, :) * km2m;

% Extragem vitezele
V0 = Raw_All(4:6, :) * km2m;

% Setari timp simulare
days = 88;
T_sim = days * 24 * 3600; % Secunde

disp('Initializare completa!');
disp(['Masa Soare: ', num2str(M(1))]);
disp(['Pozitie Soare X (m): ', num2str(P0(1,1))]);