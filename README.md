# Solar System N-Body Simulation 🪐

This project implements a dynamic simulation of the Solar System, including the Sun and the eight major planets, over an 88-day period. Developed in **MATLAB & Simulink**, the simulation models gravitational interactions using Newtonian mechanics and validates numerical precision against real-world astronomical data.

## 🚀 Objectives
* **N-Body Modeling:** Implementation of the mathematical model for gravitational interaction between $N=9$ bodies.
* **Numerical Analysis:** Comparative study between the variable-step **ode45** solver and a manual **Runge-Kutta 4 (RK4)** implementation.
* **Astronomical Phenomena:** Visualization of Mercury's apparent retrograde motion as seen from Earth.
* **Validation:** Verification of model accuracy using **NASA/JPL Horizons** ephemerides.

## 🛠 Technical Implementation
* **Simulink Architecture:** A modular design using cascaded Integrator blocks and a centralized MATLAB Function for vectorized acceleration calculations.
* **Mathematical Foundation:** Based on Newton's Law of Universal Gravitation, solving second-order differential equations for each celestial body.
* **RK4 Algorithm:** Manually implemented with a fixed step of $h=600s$ (10 minutes) for stress-testing stability against fast-moving bodies like Mercury.

## 📊 Key Results
* **High Precision:** The model achieved a position error of approximately **38 km** for Mercury relative to NASA data, representing a relative error of only $10^{-7}.
* **Phase Shift Insight:** Detailed analysis shows that fixed-step integrators (RK4) accumulate phase shifts for fast orbits, though they remain highly accurate for slower gas giants.
* **Retrograde Motion:** Successfully reproduced the visual "loop" in Mercury's trajectory from a terrestrial perspective.

## 📂 Project Structure
* `solarSystemsimulation.slx` - The core Simulink model[cite: 38].
* `rk4_vs_simulink.m` - MATLAB script for RK4 implementation and error comparison.
* `error_calculation.m` - Script for calculating numerical deviations between solvers.
* `visualising_mercurys_trajectory.m` - Script for plotting Mercury's apparent retrograde motion.
* `animate_project.m` - 3D animation of the planetary orbits.
* `init_file.m` - Initialization script for physical constants and initial conditions.
* `/NASA JPL` - Folder containing real-world ephemerides for validation.

---
**Author:** Petrișor-Andrei Leu [cite: 3]  
**Institution:** POLITEHNICA Bucharest, Faculty of Automatic Control and Computers [cite: 5]
