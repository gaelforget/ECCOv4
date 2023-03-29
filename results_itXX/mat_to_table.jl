
using MAT, CSV, DataFrames

"""
    mat_to_table(fil; WriteToCSV=false)

```
using Glob
pth1="results_itXX/"
mat_files=glob("*.mat",pth1)
fil=mat_files[2]
mat_to_table(fil)
```
"""
function mat_to_table(fil; WriteToCSV=false)
 mat=matread(fil)
 table=DataFrame(name=String[],index=Int[],value=Float64[])
 for i in keys(mat)
  j=mat[i]
  isa(j,Number) ? append!(table,DataFrame(name=i,index=0,value=j)) : nothing
  isa(j,Array) ? [append!(table,DataFrame(name=i,index=k,value=j[k])) for k in 1:length(j)] : nothing
 end
 WriteToCSV ? CSV.write(fil[1:end-4]*"_data.csv",table) : nothing
 return table
end

