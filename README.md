# ECCO version 4

[![DOI](https://zenodo.org/badge/76184688.svg)](https://zenodo.org/badge/latestdoi/76184688)
[![Documentation Status](https://readthedocs.org/projects/eccov4/badge/?version=latest)](https://eccov4.readthedocs.io/en/latest/?badge=latest)

**Content:**

This repository contains model settings and documentation ([readthedocs](http://eccov4.readthedocs.io/en/latest/)) that allow users to download, analyze, rerun, or modify ECCO version 4 ocean state estimates using the [MITgcm](http://mitgcm.org/) via on-premise computers or [cloud-computing recipes](example_scripts/README.md)). Model output can be analyzed and manipulated using the [gcmfaces][] and [MITprof][] toolboxes in `Matlab / Octave`. Other toolboxes are available in `Python` and `Julia`. For user support, please contact <mitgcm-support@mit.edu> or <ecco-support@mit.edu>.

[Estimating the Circulation and Climate of the Ocean]: https://ecco.jpl.nasa.gov
[MIT general circulation model]: https://mitgcm.readthedocs.io
[Amazon Web Services' cfncluster]: https://aws.amazon.com/hpc/cfncluster/
[Dataverse]: https://dataverse.harvard.edu/dataverse/ECCOv4r2
[FTP]: ftp://mit.ecco-group.org/ecco_for_las/version_4/release2/
[gcmfaces]: https://github.com/gaelforget/gcmfaces
[MITprof]: https://github.com/gaelforget/MITprof
[direct download]: https://dspace.mit.edu/bitstream/handle/1721.1/102062/standardAnalysis.pdf

**ECCO version 4 release 2:** 

[Estimating the Circulation and Climate of the Ocean][] version 4 release 2 is an ocean state estimate and solution of the [MIT general circulation model][] that covers the period from 1992 to 2011 (Forget et al., 2016). It is a minor update of the original ECCO version 4 solution (Forget et al., 2015) that benefits from a few additional corrections listed in Forget et al. (2016) and is easier to analyze and re-run. Its input and output are available for direct download via FTP and permanently archived via [Dataverse][]. 

ECCOv4 r2 FTP: `ftp://mit.ecco-group.org/ecco_for_las/version_4/release2/`

Other ECCOv4 solutions: see **Other known solutions** in the [documentation](https://eccov4.readthedocs.io)

**References:**

Forget, G., J.-M. Campin, P. Heimbach, C. N. Hill, R. M. Ponte, and C. Wunsch, 2015: ECCO version 4: an integrated framework for non-linear inverse modeling and global ocean state estimation. Geoscientific Model Development, 8, 3071-3104, <http://dx.doi.org/10.5194/gmd-8-3071-2015>, <http://www.geosci-model-dev.net/8/3071/2015/>

Forget, G., J.-M. Campin, P. Heimbach, C. N. Hill, R. M. Ponte, and C. Wunsch, 2016: ECCO Version 4: Second Release, <http://hdl.handle.net/1721.1/102062>, [direct download][]

