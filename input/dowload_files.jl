
module baseline2_files

using Dataverse, DataFrames, CSV
export get_list, get_files

(DataAccessApi,NativeApi)=pyDataverse.APIs()

##

list0=[
    "doi:10.7910/DVN/PICCRE,documentation,inputs_baseline2",
    "doi:10.7910/DVN/9WYSZF,surface forcing fields,forcing_baseline2",
    "doi:10.7910/DVN/7XYXSF,model initialization,inputs_baseline2",
    "doi:10.7910/DVN/GNOREE,in situ T-S profiles,inputs_baseline2",
    "doi:10.7910/DVN/MEDQWY,sea level anomaly,inputs_baseline2",
    "doi:10.7910/DVN/L3OQT0,sea surface temperature,inputs_baseline2",
    "doi:10.7910/DVN/DKXQHO,ice cover fraction,inputs_baseline2",
    "doi:10.7910/DVN/F8BCRF,surface wind stress,inputs_baseline2",
    "doi:10.7910/DVN/SYZMUX,bottom pressure,inputs_baseline2",
    "doi:10.7910/DVN/H2Q1ND,miscellaneous,inputs_baseline2"];

fil0=joinpath(tempdir(),"Dataverse_list.csv")

##

"""
    get_list(; write_file=false)

Create a list of Dataverse folders for ECCOv4r2. If `write_file=true` then write to file `joinpath(tempdir(),"Dataverse_list.csv")`/
"""
function get_list(; write_file=false)
    df=DataFrame(doi=String[],name=String[],folder=String[])
    for i in list0
        tmp1=split(i,",")
        push!(df,(doi=tmp1[1],name=tmp1[2],folder=tmp1[3]))
    end
    write_file ? CSV.write(fil0, df) : nothing
    df
end

##

"""
    get_list(list1::DataFrame,name::String)

Create a list of Dataverse files from folder with specified `name`.

```
fil0="input/dowload_files.jl"
include(fil0); using Main.baseline2_files

list1=get_list()

nam1="surface forcing fields"
list2=get_list(list1,nam1)
```
"""
function get_list(list1::DataFrame,name::String)
    try
        doi=list1[list1.name.==name,:].doi[1]
        pyDataverse.dataset_file_list(doi)
    catch
        ""
    end
end

"""
    get_files(list1::DataFrame,nam1::String)

Create a list of Dataverse files from folder with specified `name`.

```
fil0="Dataverse_files.jl"
include(fil0); using Main.Dataverse_files

list1=get_list()

nam1="model initialization"
get_files(list1,nam1,tempdir())
```
"""
function get_files(list1::DataFrame,nam1::String,path1::String)
    list2=get_list(list1,nam1)
    list3=DataverseDownloads.download_urls(list2)
    path3=joinpath(path1,list1[list1.name.==nam1,:].folder[1])
    !isdir(path3) ? mkdir(path3) : nothing
    println("Download started ...")
    println("  See : $(path3)")
    to_do_list=setdiff(list3.name,readdir(path3))
    [DataverseDownloads.download_files(list3,n,path3) for n in to_do_list];
    println("and now completed!")
    path3
end

end
