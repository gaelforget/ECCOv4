function []=testreport_write(mytest,suffOut,subDir,doUpdate);

if isempty(whos('doUpdate')); doUpdate=0; end;

%extract variables from mytest structure
myref=[];
listVars={'jT','jS','jTs','jSs','jIs','jHa','jHg','jHm'};
listVars={listVars{:},'mH','mT','mS','tV','tT','tS','info'};
listAvail=fieldnames(mytest);
[listVars,ia,ib] = intersect(listVars,listAvail, 'stable');

for vv=1:length(listVars); v=listVars{vv}; eval([v '=mytest.' v ';']); end;

%use location of testreport_write.m for output dir ...
tmp1=which('testreport_write.m');
tmp2=strfind(tmp1,filesep);
dir0=tmp1(1:tmp2(end));

%... or a subdirectory of it :
if isempty(who('subDir')); subDir=''; end;
if ~isdir(fullfile(dir0,subDir)); mkdir(fullfile(dir0,subDir)); end;
nmFile=fullfile(dir0,subDir,['testreport_' suffOut '.mat']);
%create output file if needed
if ~doUpdate; eval(['save ' nmFile ' info;']); end;
%add variables to file
for vv=1:length(listVars); eval(['save ' nmFile ' -append '  listVars{vv} ';']); end;

