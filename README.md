# Instructions for Understanding the Code Tree of the Paper Titled "Modeling of Three-Phase Induction Machines Under Combined Inter-Turn Fault and Mechanical Eccentricity"

## NOTE: The code will be made available upon the acceptance of the paper for publication. This is to ensure compliance with the agreement signed by the authors, which guarantees that the work, or any part of it, has not been previously published elsewhere.

Modification of the Meeker (2004) design
Files in the "desenhos" folder

First, the SolidWorks file "modificaDesenho.SLDPRT" imports "desenhoOriginal.DXF", which is available in the FEMM example, and exports "desenhoModificado.DXF". Next, the FEMM file "maquinaCrua.FEM" imports "desenhoModificado.DXF". It is necessary to open the "maquinaCrua.FEM" file, go to "Properties » Materials Library", make the materials available for use, and save the file.

Execution of the "etapa1_desenhosSaudaveis.m" file
Files in the "desenhos" folder

First, the "preparaModelo.m" file uses "maquinaCrua.FEM" as a base to create the "maquinaModelo.FEM" file. Next, the model is used by "preparaRotorGaiolaSaudavel.m" and "preparaRotorBobinadoSaudavel.m" to generate the files "maquinaRotorGaiolaSaudavel.FEM" and "maquinaRotorBobinadaSaudavel.FEM", respectively. Finally, simulation data is saved in "dados/etapa1.mat" and "dados/parametrosConstrutivos.mat".

Execution of the "etapa2_parametrosSaudaveis.m" file
Files in the "parametrosSaudaveis" folder

First, data is loaded from "dados/parametrosConstrutivos.mat". Next, the "encontraIndutanciasMeeker.m" file is executed, which calls the "metodoMeeker.m" function multiple times (the angular position of the rotor around its axis is varied for each iteration) and obtains the average parameters tau, M, and Ll. The values are applied in the "circuitoEquivalenteOriginal.m" file, where Rr is defined and Rs is adjusted to produce steady-state curves with the desired characteristics. The nominal operating point data is also defined in this file. Finally, since it is desirable to use the parameters rs, rr, Lm, Lls, and Llr instead of Rs, Rr, M, and Ll, the "circuitoEquivalenteTradicional.m" file finds these parameters. Finally, "verificaCurvaTorque.m" produces the torque versus speed curve in FEMM, for comparison with the curves obtained from the equivalent circuit files. At the end, simulation data is saved in "dados/etapa2.mat" and "dados/parametrosSaudaveis_Meeker.mat".

Execution of the "etapa3_caracterizacaoIndutancias.m" file
Files in the "indutancias" folder

First, data is loaded from "dados/parametrosConstrutivos.mat". Subsequently, the "caracterizacaoMaquinaSaudavel.m" file performs the characterization of the healthy machine's inductances. That is, it energizes one of the six machine coils (three stator and three rotor) and measures the amount of flux linked by all coils (this procedure is repeated for the other 5 coils). At the end of the process, 36 inductance vectors of the machine without eccentricity are obtained. The "caracterizacaoMaquinaExcentrica.m" file performs the same procedure for various rotor eccentricities (amplitude and angle). Finally, simulation data is saved in "dados/etapa3.mat" and "dados/indutancias.mat".

Execution of the "etapa4_simulacaoDinamica.m" file
Files in the "gerais", "mitFalhas.m", and "mitSaudavel.m" folders

First, data is loaded from "dados/indutancias.mat", "dados/parametrosConstrutivos.mat", and "dados/parametrosSaudaveis_Meeker.mat". Next, the "inicializacaoConstantes.m" file defines all the constants for the dynamic simulation of the healthy and faulty machine, including a lookup table with inductance information for various rotor eccentricities (amplitude and angle). Subsequently, some states (voltage, current, flux, position, and speed) are initialized by "inicializacaoEstados.m". The "simulacaoMITSaudavel.m" file executes, for the healthy machine, the update of these states at each time step of the simulation, doing so through the "atualizacaoEstados.m" function. The "figurasMITSaudavel" file then generates the figures, such as torque, speed, and current. The same is done for the faulty machine using the files "simulacaoMITFalhas.m" and "figurasMITFalhas.m". In the case of the machine having eccentricity, the "interpolacaoIndutancias.m" file inside "atualizacaoEstados.m" must be used to interpolate the inductances, in order to get more operating points than those measured and contained in the lookup table. Finally, simulation data is saved in "dados/etapa4.mat".

NOTE: The codes only work with the MATLAB-FEMM integration (you must perform the procedure defined at github.com/JTOLEDOJ/Toolbox-FEMM-MATLAB-Octave-Linux).
Execution of the "etapa5_validacaoComputacional.m" file
Files in the "mitFalhas.m" and "mitSaudavel.m" folders

First, data is loaded from "dados/parametrosConstrutivos.mat" and "dados/etapa4.mat". Next, the "torqueMITGaiolaSaudavel.m" and "torqueMITBobinadaSaudavel.m" files capture some points from the dynamic simulation and insert them into the machines drawn in FEMM to compare the torques produced by the mathematical model with those produced by finite elements. The same occurs for the faulty machine, but the "torqueMITBobinadaFalhas.m" file adds the faults in FEMM and executes the numerical simulation.
