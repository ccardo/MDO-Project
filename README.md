# MDO-Project
Repository containing the files (mostly MATLAB plus other text files) necessary for the Multidisciplinary Design Optimization project.


# To Do:
```
- Create the initial Aircraft struct (which will change during optim):
  -> Wing: Geom, Airfoils, eta, inc
  -> Aero: CL, Re, M, alt, V, MaxIterIndex
  -> Weight: MTOW, Wing
  -> Visc
  -> Var: M_des, 

- Create a Parameter struct (which will stay fixed):
  -> Geometry: twist, fuelTankStart, fuelTankEnd, spars, b1, TE_sweep1, dihedral
  -> Weight: Fuel, A-W, deltaPayload
  -> Performance: V_des_ref, h_des_ref, CT_ref
  -> nMax

- Write *Structures* Discipline

- Code MDA
- Code Optimizer

- Write bounds 
```
