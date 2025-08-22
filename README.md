# Simulation of Tank Drainage with Differential Equations in MATLAB

This repository contains simulations of tank drainage for different geometric shapes (cylindrical, conical, and spherical) by solving ordinary differential equations (ODEs) in MATLAB. The simulations allow for the visualization of the drainage process and the analysis of the liquid level dynamics over time.

## Repository Contents

* `coneTankDrainage.m`: Script to simulate the drainage of a conical tank.
* `sphericalTank.m`: Script to simulate the drainage of a spherical tank.
* `tankDrainage.m`: Generic (or example) script for tank drainage.
* `vaciadoTanqueCilindrico.m`: Script to simulate the drainage of a cylindrical tank.
* `vaciadoTanqueConico.m`: Script to simulate the drainage of a conical tank.
* `vaciadoTanqueEsferico.m`: Script to simulate the drainage of a spherical tank.

## Equations and Methodology

The tank drainage problem is modeled using Torricelli's Law. The rate of change of the liquid volume with respect to time, $\frac{dV}{dt}$, is related to the area of the outlet orifice and the liquid height. The general equation is:

$$\frac{dV}{dt} = -C_d A_o \sqrt{2gh}$$

Where:
* $V$ is the volume of the liquid in the tank.
* $t$ is time.
* $C_d$ is the discharge coefficient.
* $A_o$ is the area of the outlet orifice.
* $g$ is the acceleration due to gravity.
* $h$ is the height of the liquid.

The simulations solve the resulting ODE, adapted to the specific geometry of each tank, to find the liquid height as a function of time, $h(t)$.

### Tank-Specific Equations

#### Cylindrical Tank
For a cylindrical tank, the cross-sectional area is constant. The resulting ODE is:
$$\pi R^2 \frac{dh}{dt} = -C_d A_o \sqrt{2gh}$$
$$\frac{dh}{dt} = -\frac{C_d A_o \sqrt{2g}}{\pi R^2}\sqrt{h}$$

![Descripción](videos/tankDrainage.gif)

#### Conical Tank
For a conical tank (vertex down), the cross-sectional area changes with height. The resulting ODE is:
$$\pi \left(\frac{R}{H}\right)^2 h^2 \frac{dh}{dt} = -C_d A_o \sqrt{2gh}$$
$$\frac{dh}{dt} = -\frac{C_d A_o \sqrt{2g}}{\pi \left(\frac{R}{H}\right)^2} h^{-1.5}$$

![Descripción](videos/coneTank.gif)

#### Spherical Tank
For a spherical tank, the cross-sectional area also changes with height. The resulting ODE is:
$$\pi(2Rh - h^2) \frac{dh}{dt} = -C_d A_o \sqrt{2gh}$$
$$\frac{dh}{dt} = -\frac{C_d A_o \sqrt{2gh}}{\pi(2Rh - h^2)}$$

![Descripción](videos//sphericalTank.gif)

## Requirements and Usage

* **Software:** MATLAB.
* **Execution:** Simply open any of the scripts (`.m`) in MATLAB and run them. Each script contains the input parameters and instructions to generate the simulation plots.

## Author

* **Author:** Camilo Andrés Cortés Torres