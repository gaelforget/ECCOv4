
Users can donwload the `MITgcm` from `this github repository <https://github.com/MITgcm/MITgcm/>`__ and the model setup there from `that github repository <https://github.com/gaelforget/ECCOv4/>`__ by typing:

::

    git clone https://github.com/MITgcm/MITgcm
    git clone https://github.com/gaelforget/ECCOv4
    mkdir MITgcm/mysetups
    mv ECCOv4 MITgcm/mysetups/.

Re-running `ECCO v4 r2` additionally requires surface forcing input (96G of 6-hourly fields in `ECCO v4 r2`), initial condition, grid, etc. input (610M), and observational input (25G).

These are downloaded from the `Harvard Dataverse <https://dataverse.harvard.edu/dataverse/ECCOv4r2inputs>`__ archive as follows.

::

    julia> cd("MITgcm/mysetups/ECCOv4")
    julia> include("input/dowload_files.jl")
    julia> using Main.baseline2_files
    julia> list1=get_list()
    julia> [get_files(list1,nam1,pwd()) for nam1 in list1.name]
