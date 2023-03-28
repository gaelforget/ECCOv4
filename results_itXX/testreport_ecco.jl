
module eccotest

using Glob, MITgcmTools, MeshArrays, DataFrames
using Distributed, SharedArrays, Statistics

"""
    compute(pth0)

```
@everywhere begin
 import Pkg; Pkg.activate("03_26/")
 include("03_26/testreport_ecco.jl")
 using SharedArrays
end

Main.eccotest.compute("03_26/run")
```
"""
function compute(pth0)

 lst=Main.eccotest.list_diags_files(pth0)
 nt=length(lst.state_2d_set1)

 tave=193:228
 ntave=length(tave)
 
 pth00=MeshArrays.GRID_LLC90
 RAC=Main.eccotest.RAC_masked(pth00)
 vol=Main.eccotest.vol_masked(pth00)
 G,LC=Main.eccotest.load_llc90_grid()

 ##

 if !isempty(glob("costfun*",pth0))
   fil0=glob("costfun*",pth0)[1]
   fc=Main.eccotest.parse_fc(fil0)
 else
   fc=DataFrame()
 end

 println("done with fc")

 ##

 mH = SharedArray{Float64}(nt)
 mT = SharedArray{Float64}(nt)
 mS = SharedArray{Float64}(nt)

 @sync @distributed for i = 1:nt
  mH[i] = Main.eccotest.calc_mH(lst.state_2d_set1[i],RAC)
  mT[i] = Main.eccotest.calc_mT(lst.state_3d_set1[i],"THETA",vol)
  mS[i] = Main.eccotest.calc_mT(lst.state_3d_set1[i],"SALT",vol)
 end
 
 println("done with monthly")

 ##

 tV_m = SharedArray{Float64}(179,ntave)
 tT_m = SharedArray{Float64}(179,ntave)
 tS_m = SharedArray{Float64}(179,ntave)
 
 @sync @distributed for i in tave
  j=i-tave[1]+1
  tV_m[:,j] .= Main.eccotest.calc_tV(lst.trsp_3d_set1[i],G,LC)
  tmp = Main.eccotest.calc_tT(lst.trsp_3d_set2[i],G,LC)
  tT_m[:,j] .= tmp[1]
  tS_m[:,j] .= tmp[2]
 end

 tV=mean(tV_m,dims=2)
 tS=mean(tS_m,dims=2)
 tT=mean(tT_m,dims=2)

 println("done with transport")

 ##

 return Main.eccotest.assemble(fc,mH,mT,mS,tV,tT,tS)

end

##

function assemble(fc,mH,mT,mS,tV,tT,tS)

table=DataFrame(name=String[],index=Int[],value=Float64[])

#

if (!isempty(fc)) && (sum(occursin.("argo_feb2016_set3",fc.name))>0)

ii=findall(occursin.("argo_feb2016_set3",fc.name))[1]
append!(table,DataFrame(name="jT",index=0,value=fc.cost[ii]/fc.nb[ii]))
ii=findall(occursin.("argo_feb2016_set3",fc.name))[2]
append!(table,DataFrame(name="jS",index=0,value=fc.cost[ii]/fc.nb[ii]))

ii=findall(occursin.("sshv4-lsc",fc.name))[1]
append!(table,DataFrame(name="jHa",index=0,value=fc.cost[ii]/fc.nb[ii]))
ii=findall(occursin.("sshv4-gmsl",fc.name))[1]
append!(table,DataFrame(name="jHg",index=0,value=fc.cost[ii]/fc.nb[ii]))
ii=findall(occursin.("sshv4-mdt",fc.name))[1]
append!(table,DataFrame(name="jHm",index=0,value=fc.cost[ii]/fc.nb[ii]))

ii=findall(occursin.("sst-reynolds",fc.name))[1]
append!(table,DataFrame(name="jTs",index=0,value=fc.cost[ii]/fc.nb[ii]))
ii=findall(occursin.("sss_repeat",fc.name))[1]
append!(table,DataFrame(name="jSs",index=0,value=fc.cost[ii]/fc.nb[ii]))
ii=findall(occursin.("siv4-conc",fc.name))[1]
append!(table,DataFrame(name="jIs",index=0,value=fc.cost[ii]/fc.nb[ii]))

end

[append!(table,DataFrame(name="tV",index=k,value=tV[k])) for k in 1:length(tV)]
[append!(table,DataFrame(name="tT",index=k,value=tT[k])) for k in 1:length(tT)]
[append!(table,DataFrame(name="tS",index=k,value=tS[k])) for k in 1:length(tS)]
[append!(table,DataFrame(name="mH",index=k,value=mH[k])) for k in 1:length(mH)]
[append!(table,DataFrame(name="mT",index=k,value=mT[k])) for k in 1:length(mT)]
[append!(table,DataFrame(name="mS",index=k,value=mS[k])) for k in 1:length(mS)]

return table
end

"""
    compare(A::DataFrame,B::DataFrame)

```
include("03_26/mat_to_table.jl")
ref_file="03_26/ECCOv4/results_itXX/testreport_baseline2.mat"
ref=mat_to_table(ref_file)

compare(report,ref)
```
"""
function compare(A::DataFrame,B::DataFrame)
 println("Error report:")
 for v in unique(A.name)
  x=compare(A,B,v)
  if x > 0.01
    y=Int(round(100*x))
    w=rpad(v,4)
    println("$w : +- $y % large")
  else
    y=Int(floor(log10(x)))
    w=rpad(v,4)
    println("$w : +- 10^$y")
  end
 end
end

"""
    compare(A::DataFrame,B::DataFrame,v::String)
"""
function compare(A::DataFrame,B::DataFrame,v::String)
 a=sort(A[A.name.==v,:],:index)
 b=sort(B[B.name.==v,:],:index)
 nv=length(a.index)
 if nv==1 
   abs(a.value[1]-b.value[1])/abs(a.value[1])
 else
   sqrt(mean((a.value[:]-b.value[:]).^2))/std(a.value[:])
end
end

##

function parse_fc(fil)
    tmp1=readlines(fil)

    fc=(name=String[],cost=Float64[],nb=Int[])

    for i in tmp1
        (tmp2,tmp3)=split(i,"=")
        push!(fc.name,tmp2)
        tmp3=replace(tmp3,"E" => "e")
        tmp3=replace(tmp3,"D" => "e")
        (tmp4,tmp5)=split(tmp3)
        push!(fc.cost,parse(Float64,tmp4))
        push!(fc.nb,Int(parse(Float64,tmp5)))
    end

    fc
end

function list_diags_files(pth0)
  state_2d_set1=glob("state_2d_set1*data",joinpath(pth0,"diags"))
  state_3d_set1=glob("state_3d_set1*data",joinpath(pth0,"diags"))
  trsp_3d_set1=glob("trsp_3d_set1*data",joinpath(pth0,"diags"))
  trsp_3d_set2=glob("trsp_3d_set2*data",joinpath(pth0,"diags"))
  (state_2d_set1=state_2d_set1,state_3d_set1=state_3d_set1,
    trsp_3d_set1=trsp_3d_set1,trsp_3d_set2=trsp_3d_set2)
end

function calc_mH(fil,RAC)
  meta=read_meta(fil)
  i1=findall(meta.fldList[:].=="ETAN")[1]
  i2=findall(meta.fldList[:].=="sIceLoad")[1]
  state_2d_set1=read_mdsio(fil)
  tmp=RAC.*(state_2d_set1[:,:,i1]+state_2d_set1[:,:,i2]./1029)
  sum(tmp)/sum(RAC)
end

function RAC_masked(pth0)
  hFacC=read_mdsio(joinpath(pth0,"hFacC.data"))
  RAC=read_mdsio(joinpath(pth0,"RAC.data"))
  #rac=write(G.RAC)
  for i in eachindex(hFacC[:,:,1])
    hFacC[i]==0 ? RAC[i]=0 : nothing
  end
  return Float64.(RAC)
end

function calc_mH(fil,RAC)
  meta=read_meta(fil)
  i1=findall(meta.fldList[:].=="ETAN")[1]
  i2=findall(meta.fldList[:].=="sIceLoad")[1]
  state_2d_set1=read_mdsio(fil)
  tmp=RAC.*(state_2d_set1[:,:,i1]+state_2d_set1[:,:,i2]./1029)
  sum(tmp)/sum(RAC)
end

function RAC_masked(pth0)
  hFacC=read_mdsio(joinpath(pth0,"hFacC.data"))
  RAC=read_mdsio(joinpath(pth0,"RAC.data"))
  #rac=write(G.RAC)
  for i in eachindex(hFacC[:,:,1])
    hFacC[i]==0 ? RAC[i]=0 : nothing
  end
  return Float64.(RAC)
end

#function calc_mT(fil,nam,vol)
function calc_mT(fil,nam::String,vol)
    tmp=vol.*read_mdsio(fil,Symbol(nam))
    #[sum(tmp[:,:,k])/sum(vol[:,:,k]) for k in 1:size(tmp,3)]
    sum(tmp)/sum(vol)
end
  
function vol_masked(pth0)
    hFacC=read_mdsio(joinpath(pth0,"hFacC.data"))
    RAC=read_mdsio(joinpath(pth0,"RAC.data"))
    DRF=read_mdsio(joinpath(pth0,"DRF.data"))
    for i in eachindex(IndexCartesian(),hFacC)
      hFacC[i]=hFacC[i]*RAC[i[1],i[2]]*DRF[i[3]]
    end
    return Float64.(hFacC)
end

function load_llc90_grid()
    pth=MeshArrays.GRID_LLC90
    γ=GridSpec("LatLonCap",pth)
    G=GridLoad(γ;option="full")
    LC=LatitudeCircles(-89.0:89.0,G)
    G,LC
end

function calc_tV(fil,Γ,LC)
    u=read(read_mdsio(fil,:UVELMASS),Γ.hFacW)  
    v=read(read_mdsio(fil,:VVELMASS),Γ.hFacS)
    (Utr,Vtr)=UVtoTransport(u,v,Γ)

    #integrate across latitude circles and depth
    nz=size(Γ.hFacC,2); nt=12; nl=length(LC)
    MT=fill(0.0,nl)
    for z=1:nz
        UV=Dict("U"=>Utr[:,z],"V"=>Vtr[:,z],"dimensions"=>["x","y"])
        [MT[l]=MT[l]+ThroughFlow(UV,LC[l],Γ) for l=1:nl]
    end

    1e-6*MT
end

function calc_tT(fil,Γ,LC)
    TRx_T=read(read_mdsio(fil,:ADVx_TH)+read_mdsio(fil,:DFxE_TH),Γ.hFacW)  
    TRy_T=read(read_mdsio(fil,:ADVy_TH)+read_mdsio(fil,:DFyE_TH),Γ.hFacS)  
    TRx_S=read(read_mdsio(fil,:ADVx_SLT)+read_mdsio(fil,:DFxE_SLT),Γ.hFacW)  
    TRy_S=read(read_mdsio(fil,:ADVy_SLT)+read_mdsio(fil,:DFyE_SLT),Γ.hFacS)  

    #integrate across latitude circles and depth
    nz=size(Γ.hFacC,2); nt=12; nl=length(LC)
    MT=fill(0.0,nl)
    MS=fill(0.0,nl)
    for z=1:nz
        UV=Dict("U"=>TRx_T[:,z],"V"=>TRy_T[:,z],"dimensions"=>["x","y"])
        [MT[l]=MT[l]+ThroughFlow(UV,LC[l],Γ) for l=1:nl]
        UV=Dict("U"=>TRx_S[:,z],"V"=>TRy_S[:,z],"dimensions"=>["x","y"])
        [MS[l]=MS[l]+ThroughFlow(UV,LC[l],Γ) for l=1:nl]
    end

    return 1e-15*4e6*MT,1e-6*MS
end

end #module testreport_ecco
