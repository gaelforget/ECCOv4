#Using cfncluster with EC2 to run ECCO v4-r2

[This file][] provides instructions to run ECCO v4 r2 (Forget et al. 2015, 2016) using [MITgcm][] and [cfncluster][]. General purpose documentation for ECCO v4 r2 users can be found in [eccov4.pdf][]. For user support, if needed, contact <ecco-support@mit.edu> or <mitgcm-support@mit.edu>.

[eccov4.pdf]: https://github.com/gaelforget/ECCO_v4_r2/blob/master/eccov4.pdf
[This file]: https://github.com/gaelforget/ECCO_v4_r2/blob/master/example_scripts/README.cfncluster.md

[cfncluster documentation]: http://cfncluster.readthedocs.io/en/latest/
[cfncluster]: https://aws.amazon.com/hpc/cfncluster/
[AWS]: https://aws.amazon.com/

[MITgcm]: http://mitgcm.org/
[Estimating the Circulation and Climate of the Ocean]: http://ecco-group.org/

**important warning:**  
before proceeding any further, users are advised to read the cfncluster documentation (<http://cfncluster.readthedocs.io/en/latest/index.html>) and learn about [AWS][] pricing policies. The cluster created via steps 1 and 2 below consists of one master instance (on-demand; m4.large) and six compute instances (spot; c4.4xlarge). Costs to the user may exceed several dollars per hour. Users are advised to evaluate costs for themselves before creating any cluster and to delete clusters as soon as they can be dispensed with in order to stop paying AWS EC2 charges (see step 7). 


##Instructions

###step 1:  
- launch a micro-instance of the Amazon Linux AMI (ami-9be6f38c at the time of writing); log-in and install the cfncluster software (see [cfncluster documentation][] for detail):  
`sudo yum -y update`  
`sudo pip install cfncluster`  
- download the configuration file templates from github:  
`sudo yum -y install git`  
`git clone https://github.com/gaelforget/ECCO_v4_r2`  
`mv ECCO_v4_r2/example_scripts/config.step* .`  
- to allow cfncluster to start instances, type `cfncluster configure` and provide user information as prompted; cfncluster will store this infomation in **.cfncluster/config**.  

###step 2:  
- to setup a cluster that can run ECCO v4 r2, edit **.cfncluster/config** in analogy with the patch provided by `diff config.step1 config.step2`  
- **create the cluster (e.g., mycluster1) by typing** `cfncluster create mycluster1`
- this process launches the master and compute instances according to the .cfncluster/config specifications. Instances launched by cfncluster can be monitored via AWS console.  
- the cluster creation process may take 30 minutes or more. To verify that the process completed successfully, type `cfncluster status mycluster1` afterwards.

###step 3:
- for now, the micro-instance created in step 1 and used in step 2 to create the cluster can be stopped but it should not be terminated until the cluster has been deleted in step 7.
- to proceed with steps 4-6, **log into the master instance** as indicated in the AWS console. 

###step 4:
- to **prepare the ECCO v4 r2 model run**, execute the following commands:  
	`cd /shared`  
	`git clone https://github.com/gaelforget/ECCO_v4_r2`  
	`source ./ECCO_v4_r2/example_scripts/setup_rhel.sh`  
	`source ./setup_export.sh`  
	`source ./ECCO_v4_r2/example_scripts/setup_MITgcm.sh`  
- setup\_rhel.sh (1) updates software if needed and (2) generates setup\_export.sh; setup\_export.sh (3) defines environment variables that MITgcm relies on; setup\_MITgcm.sh (4) installs MITgcm, (5) compiles and runs a short test, and (6) compiles the ECCO v4 r2 setup.

###step 5:
- to **run ECCO v4 r2 on 96 vCPUs** using the SGE queuing system, type:  
`qsub -pe mpi 96 ./ECCO_v4_r2/example_scripts/run_eccov4r2.sh`
- during the model run the cluster activity can be monitored using `qhost` and `qstat`. The model run will proceed from 1992 to 2011 and may take about 8 min to simulate 1 month. 
- once the model run is complete, `qstat` should return an empty list and `tail run/STDOUT.0000` should display text that concludes with **PROGRAM MAIN: Execution ended Normally**.

###step 6:
- _post-processing remains to be documented_

###step 7:
- **to stop paying for your cluster, e.g. mycluster1, delete it by typing** `cfncluster delete mycluster1` in the micro-instance from step 1.
- to verify that all clusters have been deleted, type `cfncluster list` and refer to the AWS console where all cluster instances should now appear as "terminated".


##References

ECCO v4 r2 ([Estimating the Circulation and Climate of the Ocean][], version 4, release 2) is an ocean state estimate and solution of the [MITgcm][] that covers the period from 1992 to 2011 (Forget et al., 2016). It is a minor update of the original ECCO v4 solution (Forget et al., 2015) that benefits from a few additional corrections listed in Forget et al. (2016) and is easier to analyze and re-run. It is available @ <https://dataverse.harvard.edu/dataverse/ECCOv4r2> and via ftp @ <ftp://mit.ecco-group.org/ecco_for_las/version_4/release2/>

Forget, G., J.-M. Campin, P. Heimbach, C. N. Hill, R. M. Ponte, and C. Wunsch, 2015: ECCO version 4: an integrated framework for non-linear inverse modeling and global ocean state estimation. Geoscientific Model Development, 8, 3071-3104, http://dx.doi.org/10.5194/gmd-8-3071-2015, <http://www.geosci-model-dev.net/8/3071/2015/>

Forget, G., J.-M. Campin, P. Heimbach, C. N. Hill, R. M. Ponte, and C. Wunsch, 2016: ECCO Version 4: Second Release, http://hdl.handle.net/1721.1/102062, <https://dspace.mit.edu/bitstream/handle/1721.1/102062/standardAnalysis.pdf?sequence=1>


