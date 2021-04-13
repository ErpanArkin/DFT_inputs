#!/usr/bin/env python

from ase.io.trajectory import TrajectoryReader
from ase.optimize.bfgslinesearch import BFGSLineSearch
from ase.optimize import QuasiNewton, BFGS, FIRE
from ase.constraints import UnitCellFilter, FixAtoms
from ase.calculators.vdwcorrection import vdWTkatchenko09prl
from gpaw.analyse.hirshfeld import HirshfeldPartitioning
from gpaw.analyse.vdwradii import vdWradii
from gpaw.cdft.cdft import *
from gpaw import *
from ase import *
from ase.io import *
from ase.units import Bohr

# a = read('POSCAR')
# a = TrajectoryReader('history.traj')[-1]
# a.pbc = [True, True, False]

x = iread('charge_Hirshfeld.xyz')
for i in x:
    a = i.copy()
# # fix graphene position
# mask = [atom.symbol is 'C' for atom in a]
# a.set_constraint(FixAtoms(mask=mask))


calc = GPAW(basis='dzp',
            xc='PBE',
            mode='lcao',
            #h=0.18,
            spinpol=True,
            charge=0.0,
            kpts=[(-1/3,1/3,0)], #Dirac point
            # symmetry='off',
            occupations=FermiDirac(0.05),
            mixer=MixerDif(0.05, 4, 50),
            poissonsolver=PoissonSolver(eps=1e-12),
            parallel={'sl_auto': True},
            nbands='110%',
            maxiter=150,
            txt='scf.txt',
            convergence={'energy': 1.e-5})
#TS09 vdw

radii = vdWradii(a.get_chemical_symbols(), 'PBE')
calc_vdw = vdWTkatchenko09prl(HirshfeldPartitioning(calc),radii)
a.set_calculator(calc_vdw)

# The current cDFT calculator looks more ore less the same
cons_id = list(range(98))
#cons_id.extend([172,114,101,153,108,215,211,105])
cdft = CDFT(calc=a.calc.calculator,
            atoms=a,
            charge_regions=[cons_id],
            charges=[-1],
            #method='L-BFGS-B',
            #mu={'C': 1.54, 'Li': 0.5},
            minimizer_options={'gtol':0.1},
            txt='cdft.txt')
            #self_consistent=False,
            #charge_coefs=[-4.661])

#calc.attach(cdft.calc.write, 5, 'cdft_every.gpw', mode='all')
a.set_calculator(cdft)
# a.get_potential_energy()
# cdft.calc.write('cdft.gpw', mode='all')
# uf = UnitCellFilter(a, mask=[True, True, False, False, False, True])


def print_e():  # write charge to xyz, and print ech
    a.set_initial_charges(a.get_atomic_numbers() -
                          cdft.get_number_of_electrons_on_atoms())
    write('charge_Hirshfeld.xyz', a, append=True)

    elm_chg = {i: 0 for i in set(a.get_chemical_symbols())}

    for i, j in zip(a.get_chemical_symbols(), a.get_initial_charges()):
        elm_chg[i] += j

    for i in sorted(elm_chg.keys()):
        print(' ', i, elm_chg[i], end='')
    print(' sum {}'.format(sum(elm_chg.values())))

    # density = calc.get_all_electron_density(gridrefinement=1) * Bohr**3
    # write('density-scf.cube', a, data=density)


relax = FIRE(a, logfile='qn.log', trajectory='relax-cdft.traj')
relax.attach(print_e)
relax.run(fmax=1.e-2)


# a.write('CONTCAR', format='vasp')
cdft.calc.write('cdft_last.gpw', mode='all')
