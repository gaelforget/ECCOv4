function [mytest]=testreport_ecco(mytest,nameRef,listTests,dirRun,useGcmfaces);
%if called with NO input parameters then display help to this function, otherwise 
%inputs : 
%   mytest : structure containing test results (set to [] if starting from scractch) 
%   nameRef : name of the reference set of results (e.g. 'release1' or 'checkpoint64v')
%   listTests : choice of test (digit between 0 and 3)
% [todo]     -2 -> snapshot (monitor) global mean temperature and salinity
% [todo]     -1 -> snapshot (monitor) global mean Free Surface
%             0 -> 2008-2010 distance to argo profiles
%             1 -> monthly global mean Free Surface
%             2 -> monthly global mean temperature and salinity
%             3 -> 2008-2010 meridional transport of volume (requires gcmfaces)
%             4 -> 2008-2010 meridional transport of heat and salt (requires gcmfaces)
%optional inputs :
%   dirRun : x if provided then test variables will be computed using files in dirRun
%              and user may be further prompted for file locations (subdirectories)
%            x if NOT provided then it is assumed that test variables are readily 
%              provided by user (as part of mytest structure)
%   useGcmfaces : specifies to use gcmfaces or not (1/0) for computational purposes
%
%mytest0=testreport_ecco([],'release1'); mytest0.info.interactive=0; mytest0.info.verbose=0;
%mytest=testreport_ecco(mytest0,'release1',[-1:4],'r4it11.code20141030/',1);
%testreport_ecco(mytest,'release1');
%testreport_write(mytest,'r4it11.code20141030','2014novCosts')

if nargin==0;
mytest=[];
myinfo.verbose=1;
myinfo.interactive=1;
mytest.info=myinfo;
help testreport_ecco;
return;
end;

if isempty(which('nansum'));
  wrnng=sprintf(['The NaN-function suite (nansum.m, etc.) appears to be missing. It can be \n' ...
                 'added as part of the statistics or downloaded from the matlabcentral file \n' ...
                 'exchange or http://freesourcecode.net/matlabprojects/57491/nan-suite-in-matlab']);
  %warning(wrnng); error('missing nansum.m, etc. (see above warning');
  error(wrnng);
end;

if nargin==1;
dirRun=mytest;
mytest0=testreport_ecco([],'release1'); mytest0.info.interactive=0;%initialization 
mytest=testreport_ecco(mytest0,'release1',[-1:4],dirRun,1);%compute the tests
testreport_ecco(mytest,'release1');%display the results
testreport_ecco(mytest,'baseline1');%display the results
testreport_ecco(mytest,'baseline2');%display the results
testreport_ecco(mytest,'release3');%display the results
nmOut=input('\nPlease type experiment name (e.g. \n ''myRun'') to save the result of \n testreport\_ecco (or hit return to skip)\n');
if ~isempty(nmOut); testreport_write(mytest,nmOut); end;
return;
end;

global mygrid;
if isempty(mytest);
  myinfo.verbose=1; myinfo.interactive=1; mygrid=[];
else;
  myinfo=mytest.info;
end;

if myinfo.verbose; fprintf('\n=> testreport_ecco started\n\n'); end;

listJ={'jT','jS','jTs','jSs','jIs','jHa','jHm'};

% -------------------------------------------------------------------------

if myinfo.verbose; fprintf('-> testreport_ecco setup started\n'); end;

if isempty(who('dirRun')); dirRun=[]; end;
if ~isempty(dirRun)|~isfield(myinfo,'dirRun');
   myinfo.dirRun=dirRun;
end;
if isempty(who('useGcmfaces')); useGcmfaces=0; end;

if myinfo.verbose; tic; end;

%load reference
fileRef=['testreport_' nameRef '.mat'];
if isempty(which(fileRef)); error([fileRef ' not found in path']); end;
myinfo.ref=nameRef; mytest.ref=load(fileRef);

%choose whether to compute or use result readily provided in myinfo
myinfo.compute=~isempty(dirRun);
if ~myinfo.compute;
listTests=[];
elseif myinfo.compute&~isfield(myinfo,'useGcmfaces');
  myinfo.useGcmfaces=useGcmfaces;
elseif myinfo.compute&myinfo.useGcmfaces~=useGcmfaces;
  fprintf('(over-riding useGcmfaces with value already in myinfo)\n');
end;

%computing test quantities requires model output, either :
%  a) in nctiles (netcdf) format that includes grid information
%  b) in (mitgcm) binary format for physical variable and grid information
if myinfo.compute&max(listTests)>0&~isfield(myinfo,'dirGrid'); 
  myinfo=testreport_files(myinfo,dirRun);
  if isempty(myinfo.dirNctiles)&(isempty(myinfo.dirMds)|isempty(myinfo.dirGrid));
    myinfo.compute=0;
  end;
end;

%to compute test quantities with gcmfaces : load GRID/ content into mygrid (global variable)
if myinfo.compute&max(listTests)>0;
  testreport_loadgrid(myinfo);
end;

if myinfo.verbose; fprintf('-> testreport_ecco setup completed\n\n'); end;
if myinfo.verbose; toc; tic; end;

% -------------------------------------------------------------------------

if ismember(0,listTests)&~isempty(dir([dirRun filesep 'costfunction00*']));
fprintf('-> cost function test started\n');
%
fil=dir([dirRun filesep 'costfunction00*']);
if length(fil)>1;
  warning('Multiple costfunction00* were found -- will use latest >0 values.');
  tmp1=[fil(:).datenum];
  [tmp1,II] = sort(tmp1);
else;
  II=1;
end;

for ii=1:length(listJ); eval(['mytest.' listJ{ii} '=NaN;']); end;
for ii=II;
  myinfo.costfile=fil(ii).name;
  fid=fopen([dirRun filesep myinfo.costfile],'rt');
  fc=struct('name','','value',NaN,'entries',NaN);
  nn=0;
  %
  while 1;
    tline = fgetl(fid);
    if ~ischar(tline), break, end
    tmp1=strfind(tline,'=');
    tmp2=eval(['[' tline(tmp1+1:end) ']']);
    if tmp2(1)>0;
      nn=nn+1;
      fc(nn).name=deblank(tline(1:tmp1-1));
      fc(nn).value=tmp2(1);
      fc(nn).entries=tmp2(2);
      end;
  end;
  fclose(fid);
  %
  jj=find(strcmp({fc(:).name},'argo_feb2016_set3              prof_T'));
  if isempty(jj);
    jj=find(strcmp({fc(:).name},'argo_feb2013_2008_to_2010      prof_T'));
  end;
  if ~isempty(jj); mytest.jT=fc(jj).value./fc(jj).entries; end;
  jj=find(strcmp({fc(:).name},'argo_feb2016_set3              prof_S'));
  if isempty(jj);
    jj=find(strcmp({fc(:).name},'argo_feb2013_2008_to_2010      prof_S'));
  end;
  %
  if ~isempty(jj); mytest.jS=fc(jj).value./fc(jj).entries; end;
  jj=find(strcmp({fc(:).name},'sshv4-lsc       (gencost 15)'));
  if ~isempty(jj); mytest.jHa=fc(jj).value./fc(jj).entries; end;
  jj=find(strcmp({fc(:).name},'sshv4-gmsl      (gencost 16)'));
  if ~isempty(jj); mytest.jHg=fc(jj).value./fc(jj).entries; end;
  jj=find(strcmp({fc(:).name},'sshv4-mdt       (gencost 11)'));
  if ~isempty(jj); mytest.jHm=fc(jj).value./fc(jj).entries; end;
  %
  jj=find(strcmp({fc(:).name},'sst-reynolds    (gencost  4)'));
  if ~isempty(jj); mytest.jTs=fc(jj).value./fc(jj).entries; end;
  jj=find(strcmp({fc(:).name},'sss_repeat      (gencost 17)'));
  if ~isempty(jj); mytest.jSs=fc(jj).value./fc(jj).entries; end;
  jj=find(strcmp({fc(:).name},'siv4-conc       (gencost  1)'));
  if ~isempty(jj); mytest.jIs=fc(jj).value./fc(jj).entries; end;
  %
end;

fprintf('-> cost function test completed\n\n');
elseif ismember(0,listTests);
fprintf('-> cost function test omitted (costfunction0011 not found in %s)\n\n',dirRun);
end;

% -------------------------------------------------------------------------

if ismember(1,listTests);
fprintf('-> monthly free surface height test started \n');
%
sz=myinfo.ioSize(1:2);
rac=mygrid.RAC.*(mygrid.hFacC(:,:,1)>0);
racsum=nansum(rac(:));
%
mH=NaN*zeros(1,240);
for tt=1:240;
if mod(tt,12)==0&myinfo.verbose;
   fprintf('year %d completed (out of 20) for test 1\n',tt/12);
end;
if ~isempty(myinfo.dirNctiles);
    ETAN=testreport_loadnctiles(myinfo,myinfo.filesNctiles{1},'ETAN',sz,tt);
    sIceLoad=testreport_loadnctiles(myinfo,myinfo.filesNctiles{2},'sIceLoad',sz,tt);
else;
    ETAN=testreport_loadmds(myinfo,myinfo.filesMds{1},myinfo.nrecMds(1),sz,tt);
    sIceLoad=testreport_loadmds(myinfo,myinfo.filesMds{2},myinfo.nrecMds(2),sz,tt);
end;
tmp=rac.*(ETAN+sIceLoad/1029);
mH(tt)=nansum(tmp(:))/racsum;
end;
%
mytest.mH=mH;
%
fprintf('-> monthly free surface height test completed \n\n');
end;

% -------------------------------------------------------------------------

if ismember(2,listTests);
fprintf('-> monthly T,S test started \n');
%
sz=myinfo.ioSize;
vol=repmat(mygrid.RAC,[1 1 myinfo.ioSize(3)]).*mygrid.hFacC;
for kk=1:myinfo.ioSize(3); vol(:,:,kk)=mygrid.DRF(kk)*vol(:,:,kk); end;
volsum=nansum(vol(:));
%
mT=NaN*zeros(1,240);
mS=NaN*zeros(1,240);
for tt=1:240;
if mod(tt,12)==0&myinfo.verbose;
   fprintf('year %d completed (out of 20) for test 2\n',tt/12);
end;
if ~isempty(myinfo.dirNctiles);
    Tvol=vol.*testreport_loadnctiles(myinfo,myinfo.filesNctiles{3},'THETA',sz,tt);
    Svol=vol.*testreport_loadnctiles(myinfo,myinfo.filesNctiles{4},'SALT',sz,tt);
else;
    Tvol=vol.*testreport_loadmds(myinfo,myinfo.filesMds{3},myinfo.nrecMds(3),sz,tt);
    Svol=vol.*testreport_loadmds(myinfo,myinfo.filesMds{4},myinfo.nrecMds(4),sz,tt);
end;
mT(tt)=nansum(Tvol(:))/volsum;
mS(tt)=nansum(Svol(:))/volsum;
end;
%
mytest.mT=mT;
mytest.mS=mS;
%
fprintf('-> monthly T,S test completed \n\n');
end;

% -------------------------------------------------------------------------

if ismember(3,listTests)&myinfo.useGcmfaces;
fprintf('-> tV test started \n');
%
sz=myinfo.ioSize;
UVELMASS=0*mygrid.hFacC;
VVELMASS=0*mygrid.hFacC;
TT=[193:228]; nt=length(TT);
for tt=TT;
if ~isempty(myinfo.dirNctiles);
    UVELMASS=UVELMASS+1/nt*testreport_loadnctiles(myinfo,myinfo.filesNctiles{5},'UVELMASS',sz,tt);
    VVELMASS=VVELMASS+1/nt*testreport_loadnctiles(myinfo,myinfo.filesNctiles{6},'VVELMASS',sz,tt);
else;
    UVELMASS=UVELMASS+1/nt*testreport_loadmds(myinfo,myinfo.filesMds{5},myinfo.nrecMds(5),sz,tt);
    VVELMASS=VVELMASS+1/nt*testreport_loadmds(myinfo,myinfo.filesMds{6},myinfo.nrecMds(6),sz,tt);
end;
end;
%
U=UVELMASS.*mygrid.mskW; V=VVELMASS.*mygrid.mskS;
mytest.tV=1e-6*calc_MeridionalTransport(UVELMASS,VVELMASS,1);
%
fprintf('-> tV test completed \n\n');
elseif ismember(3,listTests);
fprintf('-> tV test omitted (gcmfaces not used) \n\n');
end;

if ismember(4,listTests)&myinfo.useGcmfaces;
fprintf('-> tT,tS test started \n');
%
sz=myinfo.ioSize;
TRx_T=0*mygrid.hFacC; TRy_T=0*mygrid.hFacC;
TRx_S=0*mygrid.hFacC; TRy_S=0*mygrid.hFacC;
%special case of vertically integrated output :
if isempty(myinfo.dirNctiles);
  tmp0=rdmds([myinfo.filesMds{7} '.0000000732']);
  if length(size(tmp0))==3; 
    TRx_T=TRx_T(:,:,1); TRy_T=TRy_T(:,:,1);
    TRx_S=TRx_S(:,:,1); TRy_S=TRy_S(:,:,1);
    sz(3)=1;
  end;
end;
%
TT=[193:228]; nt=length(TT);
for tt=TT;
if ~isempty(myinfo.dirNctiles);
    TRx_T=TRx_T+1/nt*testreport_loadnctiles(myinfo,myinfo.filesNctiles{7},'ADVx_TH',sz,tt);
    TRx_T=TRx_T+1/nt*testreport_loadnctiles(myinfo,myinfo.filesNctiles{8},'DFxE_TH',sz,tt);
    TRy_T=TRy_T+1/nt*testreport_loadnctiles(myinfo,myinfo.filesNctiles{9},'ADVy_TH',sz,tt);
    TRy_T=TRy_T+1/nt*testreport_loadnctiles(myinfo,myinfo.filesNctiles{10},'DFyE_TH',sz,tt);
    TRx_S=TRx_S+1/nt*testreport_loadnctiles(myinfo,myinfo.filesNctiles{7+4},'ADVx_SLT',sz,tt);
    TRx_S=TRx_S+1/nt*testreport_loadnctiles(myinfo,myinfo.filesNctiles{8+4},'DFxE_SLT',sz,tt);
    TRy_S=TRy_S+1/nt*testreport_loadnctiles(myinfo,myinfo.filesNctiles{9+4},'ADVy_SLT',sz,tt);
    TRy_S=TRy_S+1/nt*testreport_loadnctiles(myinfo,myinfo.filesNctiles{10+4},'DFyE_SLT',sz,tt);
else;
    TRx_T=TRx_T+1/nt*testreport_loadmds(myinfo,myinfo.filesMds{7},myinfo.nrecMds(7),sz,tt);
    TRx_T=TRx_T+1/nt*testreport_loadmds(myinfo,myinfo.filesMds{8},myinfo.nrecMds(8),sz,tt);
    TRy_T=TRy_T+1/nt*testreport_loadmds(myinfo,myinfo.filesMds{9},myinfo.nrecMds(9),sz,tt);
    TRy_T=TRy_T+1/nt*testreport_loadmds(myinfo,myinfo.filesMds{10},myinfo.nrecMds(10),sz,tt);
    TRx_S=TRx_S+1/nt*testreport_loadmds(myinfo,myinfo.filesMds{7+4},myinfo.nrecMds(7+4),sz,tt);
    TRx_S=TRx_S+1/nt*testreport_loadmds(myinfo,myinfo.filesMds{8+4},myinfo.nrecMds(8+4),sz,tt);
    TRy_S=TRy_S+1/nt*testreport_loadmds(myinfo,myinfo.filesMds{9+4},myinfo.nrecMds(9+4),sz,tt);
    TRy_S=TRy_S+1/nt*testreport_loadmds(myinfo,myinfo.filesMds{10+4},myinfo.nrecMds(10+4),sz,tt);
end;
end;
%
mytest.tT=1e-15*4e6*calc_MeridionalTransport(TRx_T,TRy_T,0);
mytest.tS=1e-6*calc_MeridionalTransport(TRx_S,TRy_S,0);
%
fprintf('-> tT,tS test completed \n\n');
elseif ismember(3,listTests);
fprintf('-> tT,tS test omitted (gcmfaces not used) \n\n');
end;

% -------------------------------------------------------------------------

if ~myinfo.compute;
listTests=[];
%
if isfield(mytest,'jT')&isfield(mytest,'jS'); listTests=[listTests;0];
for ii=1:length(listJ); 
  kk=listJ{ii};
  if isfield(mytest,kk);
  if ~isfield(mytest.ref,kk); mytest.ref=setfield(mytest.ref,kk,NaN); end;
  eval(['mytest.' kk '_test=testreport_metric(mytest.' kk ',mytest.ref.' kk ');']);
  end;
end;
end;
%
if isfield(mytest,'mH'); listTests=[listTests;1];
mytest.mH_test=testreport_metric(mytest.mH,mytest.ref.mH);
end;
%
if isfield(mytest,'mT')&isfield(mytest,'mS'); listTests=[listTests;2];
mytest.mT_test=testreport_metric(mytest.mT,mytest.ref.mT);
mytest.mS_test=testreport_metric(mytest.mS,mytest.ref.mS);
end;
%
if isfield(mytest,'tV'); listTests=[listTests;3];
mytest.tV_test=testreport_metric(mytest.tV,mytest.ref.tV);
end;
%
if isfield(mytest,'tT'); listTests=[listTests;4];
mytest.tT_test=testreport_metric(mytest.tT,mytest.ref.tT);
mytest.tS_test=testreport_metric(mytest.tS,mytest.ref.tS);
end;
%
end;

% -------------------------------------------------------------------------

%build list of test for display
listTmp=fieldnames(mytest);
listTests={};
for ii=1:length(listTmp);
if ismember('_test',listTmp{ii});
listTests{length(listTests)+1}=listTmp{ii}(1:end-5);
end;
end;

%build character strings (two lines)
tmp0='digits of agreement';
if ~isempty(myinfo.dirRun);
  tmp1=strfind(myinfo.dirRun(1:end-1),filesep);
  if isempty(tmp1); tmp0=myinfo.dirRun;
  else; tmp0=myinfo.dirRun(tmp1(end)+1:end);
  end;
end;
ln1=[char(ones(1,length(tmp0))*double(' ')) ' & '];
ln2=[tmp0 ' & '];
%
for ii=1:length(listTests);
tmp1=listTests{ii}; n1=length(tmp1);
tmp2=getfield(mytest,[tmp1 '_test']);
mytest=rmfield(mytest,[tmp1 '_test']);%rm field , then add it again ...
mytest=setfield(mytest,[tmp1 '_test'],tmp2);%... so that it shows at the end
if ~isnan(tmp2);
if tmp2>1e-2; tmp2=sprintf('%3d',round(100*tmp2)); n2=0;
else; tmp2=['(' num2str(round(log10(tmp2))) ')']; n2=0;
end;
n2=n2+length(tmp2);
%
tmp10=char(ones(1,max(n1,n2)-n1)*double(' '));
tmp20=char(ones(1,max(n1,n2)-n2)*double(' '));
%
ln1=[ln1 tmp10 tmp1 ' & '];
ln2=[ln2 tmp20 tmp2 ' & '];
end;
end;
%
tmp1='(reference is)'; n1=length(tmp1);
tmp2=nameRef; n2=length(tmp2);
tmp1=[tmp1 char(ones(1,max(n1,n2)-n1)*double(' '))];
tmp2=[tmp2 char(ones(1,max(n1,n2)-n2)*double(' '))];
%
ln1=[ln1 ' ' tmp1 ' \\\\ \n'];
ln2=[ln2 ' ' tmp2 ' \\\\ \n'];

%store results report as mytest.results
lndash=char(ones(1,length(ln1)-5)*double('-')); lndash=[lndash '\n'];
if isfield(mytest,'results'); mytest=rmfield(mytest,'results'); end;
mytest.results=sprintf('%s%s%s%s',['\n' lndash],ln1,ln2,[lndash '\n']);

%print results report to screen
fprintf(mytest.results);

% -------------------------------------------------------------------------

if isfield(mytest,'info'); mytest=rmfield(mytest,'info'); end;
mytest.info=myinfo;

%list of secondary routines :
%  testreport_metric :
%  testreport_files :
%  testreport_loadgrid :
%  testreport_loadmds :
%  testreport_loadnctiles :

% -------------------------------------------------------------------------

if myinfo.verbose; fprintf('\n\n=> testreport_ecco completed\n\n'); end;
if myinfo.verbose; toc; end;

function [d]=testreport_metric(cur,ref,nrm);

if isempty(whos('nrm'))&(length(ref(:))==1);
  nrm=abs(ref);
elseif isempty(whos('nrm'));
  nrm=nanstd(ref(:));
end;
d=sqrt(nanmean((cur(:)-ref(:)).^2))/nrm;


% -------------------------------------------------------------------------

function [myinfo]=testreport_files(myinfo,dirRun);

% Step 0)
% check that 
% a) gcmfaces is in the matlab path
% b) GRID/ directory is found
% c) diags/ or ncitles/ contain files needed for test

% a) gcmfaces is in the matlab path

myinfo.useGcmfaces=myinfo.useGcmfaces*~isempty(which('gcmfaces_global'));
myinfo.useMitprof=~isempty(which('MITprof_path'));
myinfo.ioSize=[90 1170 50];

% b) diags/ contain binary files needed for test

myinfo.dirMds='';
myinfo.filesMds={'','','','','','','','','',''};
myinfo.nrecMds=NaN*zeros(1,10);

testMds=-1;

test0=~isempty(dir(fullfile(dirRun,'state_2d_set1*')));
test1=~isempty(dir(fullfile(dirRun,'diags','state_2d_set1*')));
test2=~isempty(dir(fullfile(dirRun,'diags','STATE','state_2d_set1*')));
test3=~isdir(fullfile(dirRun,'nctiles'));
if (test0|test1|test2)&myinfo.interactive;
  myinfo.dirMds=['diags' filesep];
  fprintf('\nuse?\nbinary files found in diags/ directory ? (type 1)\n');
  fprintf('or binary files in another directory (tbd) ? (type 0)\n');
  testMds=input('or use nctiles files in tbd directory? (type -1)\n');
elseif (test0|test1|test2)
  myinfo.dirMds=['diags' filesep];
  fprintf('Will use binary files found in diags/ directory\n');
  testMds=1;
elseif test3;
  fprintf('\nuse? \nbinary files in tbd directory? (type 0)\n');
  testMds=input('or use nctiles files in tbd directory? (type -1)\n');
end;

if testMds==0;
  myinfo.dirMds=input('\nspecify directory of binary files :\n');
elseif testMds==-1;
  myinfo.dirMds='';
end;

if ~isempty(myinfo.dirMds);
  myinfo.ioSize=[90 1170 50];
  %
  if ~isempty(dir(fullfile(dirRun,'state_2d_set1*')));
    myinfo.filesMds{1}=fullfile(dirRun,'state_2d_set1'); myinfo.nrecMds(1)=1;
    myinfo.filesMds{2}=fullfile(dirRun,'state_2d_set1'); myinfo.nrecMds(2)=7;
  elseif ~isempty(dir(fullfile(dirRun,myinfo.dirMds,'state_2d_set1*')));
    myinfo.filesMds{1}=fullfile(dirRun,myinfo.dirMds,'state_2d_set1'); myinfo.nrecMds(1)=1;
    myinfo.filesMds{2}=fullfile(dirRun,myinfo.dirMds,'state_2d_set1'); myinfo.nrecMds(2)=7;
  elseif ~isempty(dir(fullfile(dirRun,myinfo.dirMds,'STATE','state_2d_set1*')));
    myinfo.filesMds{1}=fullfile(dirRun,myinfo.dirMds,'STATE','state_2d_set1'); myinfo.nrecMds(1)=1;
    myinfo.filesMds{2}=fullfile(dirRun,myinfo.dirMds,'STATE','state_2d_set1'); myinfo.nrecMds(2)=7;
  end;
  %
  if ~isempty(dir(fullfile(dirRun,'state_3d_set1*')));
    myinfo.filesMds{3}=fullfile(dirRun,'state_3d_set1'); myinfo.nrecMds(3)=1;
    myinfo.filesMds{4}=fullfile(dirRun,'state_3d_set1'); myinfo.nrecMds(4)=2;
  elseif ~isempty(dir(fullfile(dirRun,myinfo.dirMds,'state_3d_set1*')));
    myinfo.filesMds{3}=fullfile(dirRun,myinfo.dirMds,'state_3d_set1'); myinfo.nrecMds(3)=1;
    myinfo.filesMds{4}=fullfile(dirRun,myinfo.dirMds,'state_3d_set1'); myinfo.nrecMds(4)=2;
  elseif ~isempty(dir(fullfile(dirRun,myinfo.dirMds,'STATE','state_3d_set1*')));
    myinfo.filesMds{3}=fullfile(dirRun,myinfo.dirMds,'STATE','state_3d_set1'); myinfo.nrecMds(3)=1;
    myinfo.filesMds{4}=fullfile(dirRun,myinfo.dirMds,'STATE','state_3d_set1'); myinfo.nrecMds(4)=2;
  end;
  %
  if ~isempty(dir(fullfile(dirRun,'trsp_3d_set1*')));
    myinfo.filesMds{5}=fullfile(dirRun,'trsp_3d_set1'); myinfo.nrecMds(5)=1;
    myinfo.filesMds{6}=fullfile(dirRun,'trsp_3d_set1'); myinfo.nrecMds(6)=2;
  elseif ~isempty(dir(fullfile(dirRun,myinfo.dirMds,'trsp_3d_set1*')));
    myinfo.filesMds{5}=fullfile(dirRun,myinfo.dirMds,'trsp_3d_set1'); myinfo.nrecMds(5)=1;
    myinfo.filesMds{6}=fullfile(dirRun,myinfo.dirMds,'trsp_3d_set1'); myinfo.nrecMds(6)=2;
  elseif ~isempty(dir(fullfile(dirRun,myinfo.dirMds,'TRSP','trsp_3d_set1*')));
    myinfo.filesMds{5}=fullfile(dirRun,myinfo.dirMds,'TRSP','trsp_3d_set1'); myinfo.nrecMds(5)=1;
    myinfo.filesMds{6}=fullfile(dirRun,myinfo.dirMds,'TRSP','trsp_3d_set1'); myinfo.nrecMds(6)=2;
  end;
  %
  fil='';
  if ~isempty(dir(fullfile(dirRun,'trsp_3d_set2*')));
    fil=fullfile(dirRun,'trsp_3d_set2');
  elseif ~isempty(dir(fullfile(dirRun,myinfo.dirMds,'trsp_3d_set2*')));
    fil=fullfile(dirRun,myinfo.dirMds,'trsp_3d_set2');
  elseif ~isempty(dir(fullfile(dirRun,myinfo.dirMds,'TRSP','trsp_3d_set2*')));
    fil=fullfile(dirRun,myinfo.dirMds,'TRSP','trsp_3d_set2');
  elseif ~isempty(dir(fullfile(dirRun,'trsp_2d_set1*')));
    fil=fullfile(dirRun,'trsp_2d_set1');
  elseif ~isempty(dir(fullfile(dirRun,myinfo.dirMds,'trsp_2d_set1*')));
    fil=fullfile(dirRun,myinfo.dirMds,'trsp_2d_set1');
  elseif ~isempty(dir(fullfile(dirRun,myinfo.dirMds,'TRSP','trsp_2d_set1*')));
    fil=fullfile(dirRun,myinfo.dirMds,'TRSP','trsp_2d_set1');
  end;
  if ~isempty(fil);
    myinfo.filesMds{7}=fil; myinfo.nrecMds(7)=3;
    myinfo.filesMds{8}=fil; myinfo.nrecMds(8)=1;
    myinfo.filesMds{9}=fil; myinfo.nrecMds(9)=4;
    myinfo.filesMds{10}=fil; myinfo.nrecMds(10)=2;
    myinfo.filesMds{7+4}=fil; myinfo.nrecMds(7+4)=3+4;
    myinfo.filesMds{8+4}=fil; myinfo.nrecMds(8+4)=1+4;
    myinfo.filesMds{9+4}=fil; myinfo.nrecMds(9+4)=4+4;
    myinfo.filesMds{10+4}=fil; myinfo.nrecMds(10+4)=2+4;
    fil='';
  end;
end;

% c) nctiles/ contain netcdf files needed for test

myinfo.dirNctiles='';
myinfo.filesNctiles={'','','','','','','','','','','','','',''};

if isempty(myinfo.dirMds);

testNctiles=0;

if isdir(fullfile(dirRun,'nctiles'))&myinfo.interactive;
  myinfo.dirNctiles=['nctiles' filesep];
  fprintf('\nuse? \nnctiles files in nctiles/ directory ? (type 1)\n');
  testNctiles=input('or nctiles files in another directory (tbd)? (type 0)\n');
elseif isdir(fullfile(dirRun,'nctiles'));
  myinfo.dirNctiles=['nctiles' filesep];
  fprintf('Will use nctiles files in nctiles/ directory\n');
  testNctiles=1;
end;

if testNctiles==0;
  myinfo.dirNctiles=input('\nprovide directory of nctiles files :\n');
end;

if ~isempty(myinfo.dirNctiles);
  myinfo.ioSize=[90 1170 50];
  myinfo.filesNctiles={'','','','','',''};
  list0={'ETAN','sIceLoad','THETA','SALT','UVELMASS','VVELMASS'};
  list0={list0{:},'ADVx_TH','DFxE_TH','ADVy_TH','DFyE_TH'};
  list0={list0{:},'ADVx_SLT','DFxE_SLT','ADVy_SLT','DFyE_SLT'};
  for ii=1:length(list0);
    tmpfile=fullfile(dirRun,'nctiles',list0{ii});
    if ~isempty(dir([tmpfile '*.nc'])); myinfo.filesNctiles{ii}=tmpfile; end;
    tmpfile=fullfile(dirRun,'nctiles',list0{ii},list0{ii});
    if ~isempty(dir([tmpfile '*.nc'])); myinfo.filesNctiles{ii}=tmpfile; end;
  end;
end;

end;%if isempty(myinfo.dirMds);

% d) GRID/ directory is found (needed if binary files or gcmfaces is to be used)

myinfo.dirGrid='';

testGrid=0;

test1=~isempty(dir(fullfile(dirRun,'various','XC.*')));
if test1; myinfo.dirGrid=fullfile(dirRun,'various',filesep); end;
test1=~isempty(dir(fullfile(dirRun,'XC.*')));
if test1; myinfo.dirGrid=fullfile(dirRun,filesep); end;
test1=~isempty(dir(fullfile('GRID','XC.*')));
if test1; myinfo.dirGrid=fullfile('GRID',filesep); end;

if ~isempty(myinfo.dirGrid)&myinfo.interactive;
  fprintf(['\nuse? \ngrid files in  ' myinfo.dirGrid ' directory ? (type 1)\n']);
  testGrid=input('or grid files in another directory ? (type 0)\n');
elseif ~isempty(myinfo.dirGrid);
  fprintf(['Will use grid files in  ' myinfo.dirGrid ' directory\n']);
  testGrid=1;
end;

if testGrid==0;
  myinfo.dirGrid=input('\nprovide directory of grid files :\n');
end;

if isempty(dir([myinfo.dirGrid 'XC*']));
  error(['\nmissing files in grid directory (' myinfo.dirGrid ')']);
end;

% -------------------------------------------------------------------------

function []=testreport_loadgrid(myinfo);

global mygrid;
mygrid=[];

% Step 1)
% Set grid parameters and read in grid information for v4.
% This example assumes the grid files are in directory ./GRID/
% Change according to where the grid files actually are.

if myinfo.useGcmfaces&~isfield(mygrid,'XC');
  nF=5; fileFormat='compact';  %format specification
  grid_load(myinfo.dirGrid,nF,fileFormat,0,1);
end;

if ~myinfo.useGcmfaces;

  if ~isempty(myinfo.dirNctiles);

    fprintf('instead of using THETA I need hFAcC in a nctiles file \n');

    fileName=myinfo.filesNctiles{3};
    %
    varName='thic'; sz=[1 myinfo.ioSize(3)];
    mygrid.DRF=testreport_loadnctiles(myinfo,fileName,varName,sz,[]);
    %
    varName='area'; sz=myinfo.ioSize(1:2);
    mygrid.RAC=testreport_loadnctiles(myinfo,fileName,varName,sz,[]);
    %
    varName='land'; sz=myinfo.ioSize(1:3);
    mygrid.hFacC=testreport_loadnctiles(myinfo,fileName,varName,sz,[]);

  else;%we are using grid data in mds format

    fileName=fullfile(myinfo.dirGrid,'DRF'); sz=[1 myinfo.ioSize(3)];
    mygrid.DRF=testreport_loadmds(myinfo,fileName,1,sz,[]);
    %
    fileName=fullfile(myinfo.dirGrid,'RAC'); sz=myinfo.ioSize(1:2);
    mygrid.RAC=testreport_loadmds(myinfo,fileName,1,sz,[]);
    %
    fileName=fullfile(myinfo.dirGrid,'hFacC'); sz=myinfo.ioSize(1:3);
    mygrid.hFacC=testreport_loadmds(myinfo,fileName,1,sz,[]);

  end;

end;

% -------------------------------------------------------------------------

function [fld]=testreport_loadmds(myinfo,fileName,nrec,fldSize,trec);

if ~isempty(trec);
list0=dir([fileName '*data']);
tmp=list0(trec).name(end-15:end-5);
fileName=[fileName tmp];
end;

tmp=fileread([fileName '.meta']);
nn=strfind(tmp,'float');
prec=tmp(nn:nn+6);
%
fid = fopen([fileName '.data'],'r','b');
for nn=1:nrec;
fld=fread(fid,prod(fldSize),prec);
fld=reshape(fld,fldSize);
end;
fclose(fid);

if myinfo.useGcmfaces; fld=convert2gcmfaces(fld); end;

% -------------------------------------------------------------------------

function [fld]=testreport_loadnctiles(myinfo,fileName,fldName,fldSize,nrec);

if myinfo.useGcmfaces;

if isempty(nrec); nree=1; end;
fld=read_nctiles(fileName,fldName,nrec);

else;

fld=NaN*zeros(fldSize);
for ff=1:13;
  theNetCDFFile=sprintf('%s.%04d.nc',fileName,ff);
  nc=netcdf.open(theNetCDFFile,'nowrite');
  varid = netcdf.inqVarID(nc,fldName);
  %
  [name,xtype,dimids,natts]=netcdf.inqVar(nc,varid);
  n1=length(dimids); n2=length(fldSize);
  if n1<=n2;
    tmp=netcdf.getVar(nc,varid);
  else;
    count=[fldSize 1]; count(2)=count(2)/13;
    start=zeros(size(count)); start(end)=nrec-1;
    tmp=netcdf.getVar(nc,varid,start,count);
  end;
  %
  if prod(fldSize)==prod(size(tmp));
    fld=tmp;
  else;
    fld(:,90*(ff-1)+[1:90],:)=tmp;
  end;
  netcdf.close(nc);
end;

end;


