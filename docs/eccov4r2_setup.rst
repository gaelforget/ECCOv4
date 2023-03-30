
Donwload `MITgcm source code <https://github.com/MITgcm/MITgcm/>`__ and `ECCO V4r2 setup <https://github.com/gaelforget/ECCOv4/>`__ from GitHub. 

::

    git clone https://github.com/MITgcm/MITgcm
    git clone https://github.com/gaelforget/ECCOv4
    mkdir MITgcm/mysetups
    mv ECCOv4 MITgcm/mysetups/.

Re-running `ECCO V4r2` additionally requires surface forcing input (96G of 6-hourly fields), 
initial condition, grid, etc. input (610M), and observational input (25G).

Download these from `here in Dataverse <https://dataverse.harvard.edu/dataverse/ECCOv4r2inputs>`__.

::

    cd("MITgcm/mysetups/ECCOv4")
    include("input/dowload_files.jl")
    import Main.baseline2_files: get_list, get_files

    list1=get_list()
    [get_files(list1,nam1,pwd()) for nam1 in list1.name]
