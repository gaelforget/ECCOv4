
module eccotest

using Glob, MITgcmTools, MeshArrays, DataFrames
using Distributed, SharedArrays, Statistics

alt_names=false

"""
    compute(pth0)

```
@everywhere begin
 include("test/testreport_ecco.jl")
 using SharedArrays
end

report=eccotest.compute("run")
```
"""
function compute(pth0)

 alt_names ? lst=list_diags_files_alt(pth0) : lst=list_diags_files(pth0)
 nt=length(lst.state_2d_set1)

 tave=193:228
 ntave=length(tave)
 
 #pth00=MeshArrays.GRID_LLC90
 pth00=pth0 #"run"
 RAC=Main.eccotest.RAC_masked(pth00)
 vol=Main.eccotest.vol_masked(pth00)
 G,LC=Main.eccotest.load_llc90_grid(pth00)

 ##

 if !isempty(glob("costfun*",pth0))
   fil0=glob("costfun*",pth0)[1]
   fc=Main.eccotest.parse_fc(fil0)
   println("Done with fc")
 else
   fc=DataFrame()
 end

 ##

 mH = SharedArray{Float64}(nt)
 mT = SharedArray{Float64}(nt)
 mS = SharedArray{Float64}(nt)

 @sync @distributed for i = 1:nt
  mH[i] = Main.eccotest.calc_mH(lst.state_2d_set1[i],RAC)
  mT[i] = Main.eccotest.calc_mT(lst.state_3d_set1[i],:THETA,vol)
  mS[i] = Main.eccotest.calc_mT(lst.state_3d_set1[i],:SALT,vol)
 end

 println("done with monthly")

 ##

 if nt<maximum(tave)
   tV,tT,tS=[],[],[]
 else

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
 end

 ##

 return Main.eccotest.assemble(fc,mH,mT,mS,tV,tT,tS)

#return mH,mT,mS

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
include("test/mat_to_table.jl")
ref_file="test/testreport_baseline2.mat"
ref=mat_to_table(ref_file)

eccotest.compare(report,ref)
```
"""
function compare(A::DataFrame,B::DataFrame)
 println("Error report:")
 for v in intersect(unique(A.name),unique(B.name))
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
    compare(A::DataFrame,B::DataFrame,v::AbstractString)
"""
function compare(A::DataFrame,B::DataFrame,v::AbstractString)
 a=sort(A[A.name.==v,:],:index)
 b=sort(B[B.name.==v,:],:index)
 nv=min(length(a.index),length(b.index))
 #nv=6
 if nv==1 
   abs(a.value[1]-b.value[1])/abs(a.value[1])
 else
   sqrt(mean((a.value[1:nv]-b.value[1:nv]).^2))/std(a.value[1:nv])
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
  if isdir(joinpath(pth0,"diags","STATE"))
      (STATE,TRSP)=("STATE","TRSP")
  else
      (STATE,TRSP)=("","")
  end
  state_2d_set1=glob("state_2d_set1*data",joinpath(pth0,"diags",STATE))
  state_3d_set1=glob("state_3d_set1*data",joinpath(pth0,"diags",STATE))
  trsp_3d_set1=glob("trsp_3d_set1*data",joinpath(pth0,"diags",TRSP))
  trsp_3d_set2=glob("trsp_3d_set2*data",joinpath(pth0,"diags",TRSP))
  (state_2d_set1=state_2d_set1,state_3d_set1=state_3d_set1,
    trsp_3d_set1=trsp_3d_set1,trsp_3d_set2=trsp_3d_set2)
end

function list_diags_files_alt(pth0)
  state_2d_set1=glob("ETAN_mon_mean*data",joinpath(pth0,"ETAN_mon_mean"))
  state_3d_set1=glob("THETA_mon_mean*data",joinpath(pth0,"THETA_mon_mean"))
  trsp_3d_set1=glob("UVELMASS_mon_mean*data",joinpath(pth0,"UVELMASS_mon_mean"))
  trsp_3d_set2=glob("ADVx_TH_mon_mean*data",joinpath(pth0,"ADVx_TH_mon_mean"))
  (state_2d_set1=state_2d_set1,state_3d_set1=state_3d_set1,
    trsp_3d_set1=trsp_3d_set1,trsp_3d_set2=trsp_3d_set2)
end

function read_mdsio_mH(fil,nam)
 alt_names ? fil2=replace(fil,"ETAN" => nam) : fil2=fil
 read_mdsio(fil2,nam)
end

function calc_mH(fil,RAC)
  ETAN=read_mdsio_mH(fil,:ETAN)
  sIceLoad=read_mdsio_mH(fil,:sIceLoad)
  tmp=RAC.*(ETAN+sIceLoad./1029)
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

function RAC_masked(pth0)
  hFacC=read_mdsio(joinpath(pth0,"hFacC.data"))
  RAC=read_mdsio(joinpath(pth0,"RAC.data"))
  #rac=write(G.RAC)
  for i in eachindex(hFacC[:,:,1])
    hFacC[i]==0 ? RAC[i]=0 : nothing
  end
  return Float64.(RAC)
end

function read_mdsio_mT(fil,nam)
 alt_names ? fil2=replace(fil,"THETA" => nam) : fil2=fil
 read_mdsio(fil2,nam)
end

#function calc_mT(fil,nam,vol)
function calc_mT(fil,nam::Symbol,vol)
    tmp=vol.*read_mdsio_mT(fil,nam)
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

function load_llc90_grid(pth=MeshArrays.GRID_LLC90)
    pth==MeshArrays.GRID_LLC90 ? γ=GridSpec("LatLonCap",pth) : γ=gcmgrid(pth, "LatLonCap", 5,
      [(90, 270), (90, 270), (90, 90), (270, 90), (270, 90)], [90 1170], Float32, read, write)
    G=GridLoad(γ;option="full")
    LC=LatitudeCircles(-89.0:89.0,G)
    G,LC
end

function read_mdsio_tV(fil,nam)
 alt_names ? fil2=replace(fil,"UVELMASS" => nam) : fil2=fil
 read_mdsio(fil2,nam)
end

function calc_tV(fil,Γ,LC)
    u=read(read_mdsio_tV(fil,:UVELMASS),Γ.hFacW)  
    v=read(read_mdsio_tV(fil,:VVELMASS),Γ.hFacS)
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

function read_mdsio_tT(fil,nam)
 alt_names ? fil2=replace(fil,"ADVx_TH" => nam) : fil2=fil
 read_mdsio(fil2,nam)
end

function calc_tT(fil,Γ,LC)
    TRx_T=read(read_mdsio_tT(fil,:ADVx_TH)+read_mdsio_tT(fil,:DFxE_TH),Γ.hFacW)  
    TRy_T=read(read_mdsio_tT(fil,:ADVy_TH)+read_mdsio_tT(fil,:DFyE_TH),Γ.hFacS)  
    TRx_S=read(read_mdsio_tT(fil,:ADVx_SLT)+read_mdsio_tT(fil,:DFxE_SLT),Γ.hFacW)  
    TRy_S=read(read_mdsio_tT(fil,:ADVy_SLT)+read_mdsio_tT(fil,:DFyE_SLT),Γ.hFacS)  

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
