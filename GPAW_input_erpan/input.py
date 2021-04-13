#!/usr/bin/env python

from ase.io.trajectory import TrajectoryReader
from ase.optimize.bfgslinesearch import BFGSLineSearch
from ase.optimize import QuasiNewton, BFGS, FIRE
from ase.constraints import UnitCellFilter
from ase.calculators.vdwcorrection import vdWTkatchenko09prl
from gpaw.analyse.hirshfeld import HirshfeldPartitioning
from gpaw.analyse.vdwradii import vdWradii
from gpaw.cdft.cdft import *
from gpaw import *
from ase import *
from ase.io import *
from ase.units import Bohr

a = read('CONTCAR.xyz')
a.pbc = [True, True, False]

calc = GPAW(basis='dzp',
            xc='PBE',
            mode='lcao',
            # h=0.18,
            spinpol=True,
            charge=0.0,
            kpts=[(-1/3,1/3,0)],  # 18 irreducible kpts
            # symmetry='off',
            occupations=FermiDirac(0.1),
            mixer=MixerDif(0.05, 4, 50),
            poissonsolver=PoissonSolver(dipolelayer='xy', eps=1e-12, metallic_electrodes='both'),
            parallel={'sl_auto': True},
            nbands='110%',
            maxiter=150,
            txt='scf.txt',
            convergence={'energy': 1.e-5})

#TS09 vdw

radii = vdWradii(a.get_chemical_symbols(), 'PBE')
calc_vdw = vdWTkatchenko09prl(HirshfeldPartitioning(calc),radii)
a.set_calculator(calc_vdw)
a.get_potential_energy()

density = calc.get_all_electron_density(gridrefinement=4) * Bohr**3
write('density-scf.cube', a, data=density)

spin = (calc.get_all_electron_density(gridrefinement = 4,spin=0) - 
       calc.get_all_electron_density(gridrefinement = 4,spin=1)) * Bohr**3
write('spin-scf.cube', a, data=spin)

# a.write('CONTCAR', format='vasp')
calc.write('scf.gpw', mode='all')
