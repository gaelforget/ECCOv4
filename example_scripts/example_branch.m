function []=example_branch(iPtr);
% []=example_branch(iPtr);
%
%This function loads model output from llc90drwn3 and
%illustrates the following computations via gcmfaces
%for tracer # iPtr in diags/ptr* (iPtr=20 by default).
%
% 1) zonan mean (time dependent, top level)
% 2) interpolation (time dependent, top level)
% 3) section (time mean, all depth levels)
% 4) global mean (time dependent, top level)
%
%example:
%  example_branch;
%
%requirements:
%  gcmfaces/       (matlab codes)
%  grid output     (netcdf or binary files)
%  diags/          (binary files)

if isempty(which('gcmfaces'));
   p = genpath('gcmfaces/'); addpath(p);
end;

gcmfaces_global;

if isempty(mygrid);
   grid_load;
end;

if isempty(whos('iPtr'));
   iPtr=20;
end;

%%

fprintf('loading model output...\n');

dirIn='./';
fld=rdmds([dirIn 'diags/ptr'],NaN,'rec',iPtr);
nt=size(fld,4); fld=convert2gcmfaces(fld); 
fld=fld.*repmat(mygrid.mskC,[1 1 1 nt]);
fld_sur=squeeze(fld(:,:,1,:));

%%

fprintf('computing zonal means...\n');

[zm,X,Y]=calc_zonmean_T(fld);
[zm_sur]=calc_zonmean_T(fld_sur);

figureL; 
tmpx=X(:,1)*ones(1,nt); tmpy=ones(179,1)*[1:nt]; tmpz=zm_sur-mean(zm_sur,2)*ones(1,nt);
subplot(2,1,1); pcolor(tmpx,tmpy,tmpz); shading interp; ylabel('time'); title('anomaly');
subplot(2,1,2); pcolor(X,Y,zm(:,:,1)); shading interp; ylabel('depth'); title('time mean');

%%

fprintf('interpolating to 1/2 degree grid...\n');

lon=[-179.75:0.5:179.75]; lat=[-89.75:0.5:89.75];
[lat,lon] = meshgrid(lat,lon);

interp=gcmfaces_interp_coeffs(lon(:),lat(:));

tmp1=convert2vector(fld_sur);
tmp0=1*~isnan(tmp1);
tmp1(isnan(tmp1))=0;
%
tmp0=interp.SPM*tmp0;
tmp1=interp.SPM*tmp1;
%
fld_interp=reshape(tmp1./tmp0,[size(lon) nt]);

figureL;
subplot(2,1,1); pcolor(lon,lat,fld_interp(:,:,1)); shading flat; title(num2str(1));
subplot(2,1,2); pcolor(lon,lat,fld_interp(:,:,nt)); shading flat; title(num2str(nt));

%%

fprintf('extracting 158W section ...\n');

[LO,LA,fld_section,X,Y]=gcmfaces_section([-158 -158],[-89 90],fld);
figureL; aa=[-90 90 -1000 0];  
subplot(2,1,1); pcolor(X,Y,fld_section(:,:,1)); shading flat; axis(aa); colorbar;
subplot(2,1,2); pcolor(X,Y,fld_section(:,:,nt)); shading flat; axis(aa); colorbar;

%%

msk=mygrid.mskC.*mygrid.hFacC;
msk=msk.*mk3D(mygrid.RAC,msk).*mk3D(mygrid.DRF,msk);
msk=repmat(msk,[1 1 1 nt]);
fld_glo=squeeze(nansum(fld.*msk,0)./nansum(msk,0));

figureL; plot(fld_glo(1,:)); xlabel('time'); title('global mean');

%%

fprintf('Done.\n');

