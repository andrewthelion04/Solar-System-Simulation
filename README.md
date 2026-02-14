# Solar System N-Body Simulation 🪐

[cite_start]This project implements a dynamic simulation of the Solar System, including the Sun and the eight major planets, over an 88-day period[cite: 8]. [cite_start]Developed in **MATLAB & Simulink**, the simulation models gravitational interactions using Newtonian mechanics and validates numerical precision against real-world astronomical data[cite: 10, 14].

## 🚀 Objectives
* [cite_start]**N-Body Modeling:** Implementation of the mathematical model for gravitational interaction between $N=9$ bodies[cite: 10].
* [cite_start]**Numerical Analysis:** Comparative study between the variable-step **ode45** solver and a manual **Runge-Kutta 4 (RK4)** implementation[cite: 13].
* [cite_start]**Astronomical Phenomena:** Visualization of Mercury's apparent retrograde motion as seen from Earth[cite: 12].
* [cite_start]**Validation:** Verification of model accuracy using **NASA/JPL Horizons** ephemerides[cite: 14].

## 🛠 Technical Implementation
* [cite_start]**Simulink Architecture:** A modular design using cascaded Integrator blocks and a centralized MATLAB Function for vectorized acceleration calculations[cite: 24, 26].
* [cite_start]**Mathematical Foundation:** Based on Newton's Law of Universal Gravitation, solving second-order differential equations for each celestial body[cite: 16, 17].
* [cite_start]**RK4 Algorithm:** Manually implemented with a fixed step of $h=600s$ (10 minutes) for stress-testing stability against fast-moving bodies like Mercury[cite: 61, 67].

## 📊 Key Results
* [cite_start]**High Precision:** The model achieved a position error of approximately **38 km** for Mercury relative to NASA data, representing a relative error of only $10^{-7}$[cite: 116, 117].
* [cite_start]**Phase Shift Insight:** Detailed analysis shows that fixed-step integrators (RK4) accumulate phase shifts for fast orbits, though they remain highly accurate for slower gas giants[cite: 82, 98].
* [cite_start]**Retrograde Motion:** Successfully reproduced the visual "loop" in Mercury's trajectory from a terrestrial perspective[cite: 58, 125].

## 📂 Project Structure
* [cite_start]`solarSystemsimulation.slx` - The core Simulink model[cite: 38].
* [cite_start]`rk4_vs_simulink.m` - MATLAB script for RK4 implementation and error comparison[cite: 78].
* [cite_start]`error_calculation.m` - Script for calculating numerical deviations between solvers[cite: 114].
* [cite_start]`visualising_mercurys_trajectory.m` - Script for plotting Mercury's apparent retrograde motion[cite: 58].
* [cite_start]`animate_project.m` - 3D animation of the planetary orbits[cite: 40].
* `init_file.m` - Initialization script for physical constants and initial conditions.
* [cite_start]`/NASA JPL` - Folder containing real-world ephemerides for validation[cite: 101].

---
[cite_start]**Author:** Petrișor-Andrei Leu [cite: 3]  
[cite_start]**Institution:** POLITEHNICA Bucharest, Faculty of Automatic Control and Computers [cite: 5]