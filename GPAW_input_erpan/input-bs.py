#!/usr/bin/env python

from gpaw import GPAW
from glob import glob

file = glob('*.gpw')[0]

calc = GPAW(file,
            nbands='110%',
            fixdensity=True,
            symmetry='off',
            kpts={'path': 'MGKM', 'npoints': 60},
            convergence={'bands': 8})


calc.get_potential_energy()

bs = calc.band_structure()
bs.plot(filename='bs.png', show=True, emax=10.0)