%#######################################################################
%
%Femur Cartilage THicKness Confidence Interval BioMarkers Female Program 
%
%          M-File which reads the femur cartilage thickness differences
%     for the biomarkers female control knees and plots the control 
%     cartilage thickness differences, calculates and plots the 95% 
%     confidence interval (CI) assuming a zero mean and plots the
%     biomarkers female case cartilage thickness differences that
%     are greater than the confidence interval.
%
%     NOTES:  1.  Control MAT files fcthkbrkbmf.mat and fb_rngf.mat
%             must be in the current subdirectory and case MAT files
%             ..\..\fcthkbrkf.mat and ..\..\fb_rngf.mat must be in
%             their directory.
%
%             2.  Requires the Matlab Statistics toolbox.
%
%     05-Oct-2016 * Mack Gardner-Morse
%

%#######################################################################
%
% Print Plots to PS File
%
iprt = false;
% iprt = true;
%
% PS Output Plot File Name
%
if iprt
  psfnam = 'fcthkcibmf.ps';
end
%
gr = sqrt(5)/2-0.5;     % Golden ratio (for dark green color)
%
% Get Control "Standard" Grid
%
load fb_rngf.mat;
%
% Get the Control Femur Cartilage Thickness Differences
%
load fcthkbrkbmf.mat;
%
% Plot the Control Mean Differences
%
dthk = dthk_ctrl;
idn = find(dthkn_ctrl<2);
dthk(idn) = NaN;
%
figure;
orient landscape;
colormap jet;
%
hp = patch(tq(quad'),zq(quad'),dthk(quad'),dthk(quad'), ...
           'FaceColor','interp','EdgeColor','interp');
%
caxis([-0.5 0.5]);
hb = colorbar;
title({'Cartilage Thickness Differences'; 'Female Controls'}, ...
       'FontSize',16,'FontWeight','bold');
%
if iprt
  print('-dpsc2','-r300',psfnam);
end
%
% Calculate 95% CI
%
ci = NaN(nq,1);
idv = find(dthkn_ctrl>=2);
t = tinv(0.975,dthkn_ctrl(idv)-1);
ci(idv) = (t.*dthks_ctrl(idv))./sqrt(dthkn_ctrl(idv));
%
% Plot 95% CI
%
figure;
orient landscape;
colormap jet;
%
hp = patch(tq(quad'),zq(quad'),ci(quad'),ci(quad'), ...
           'FaceColor','interp','EdgeColor','interp');
%
caxis([0 0.8]);
hb = colorbar;
title('95% CI for Female Controls','FontSize',16,'FontWeight','bold');
%
if iprt
  print('-dpsc2','-r300','-append',psfnam);
end
%
% Get Case Grid
%
tq_ctrl = tq;
zq_ctrl = zq;
load('..\..\fb_rngf.mat');
%
tmin = max([min(tq_ctrl); min(tq)]);
tmax = min([max(tq_ctrl); max(tq)]);
%
zmin = max([min(zq_ctrl); min(zq)]);
zmax = min([max(zq_ctrl); max(zq)]);
%
% Interpolate Confidence Interval to Case Grid
%
cii = interp2(reshape(tq_ctrl,78,122),reshape(zq_ctrl,78,122), ...
              reshape(ci,78,122),tq,zq);
idt = find(tq>tmax|tq<tmin);
cii(idt) = NaN;         % Make sure any extrapolation is NaN
idq = find(zq>zmax|zq<zmin);
cii(idq) = NaN;         % Make sure any extrapolation is NaN
%
% Get the Case Femur Cartilage Thickness Differences
%
load('..\..\fcthkbrkf.mat');
dthk = dthk_case;
dthk(idt) = NaN;
dthk(idq) = NaN;
%
% Plot the Case Mean Differences
%
idn = find(dthkn_case<3);
dthk(idn) = NaN;
%
figure;
orient landscape;
colormap jet;
%
hp = patch(tq(quad'),zq(quad'),dthk(quad'),dthk(quad'), ...
           'FaceColor','interp','EdgeColor','interp');
%
caxis([-0.6 0.6]);
hb = colorbar;
title({'Cartilage Thickness Differences'; 'Female Cases'}, ...
       'FontSize',16,'FontWeight','bold');
%
if iprt
  print('-dpsc2','-r300','-append',psfnam);
end
%
% Plot the Case Mean Differences Greater Than the Control 95%
% Confidence Interval
%
cii(isnan(cii)) = Inf;
dthk(abs(dthk)<cii) = 0;
%
figure;
orient landscape;
colormap jet;
%
hp = patch(tq(quad'),zq(quad'),dthk(quad'),dthk(quad'), ...
           'FaceColor','interp','EdgeColor','interp');
%
caxis([-0.6 0.6]);
hb = colorbar;
title({'Cartilage Thickness Differences'; ...
       'Female Cases Greater Than 95% CI'}, ...
       'FontSize',16,'FontWeight','bold');
%
if iprt
  print('-dpsc2','-r300','-append',psfnam);
end
%
% Adjust Color Map
%
map = jet;
map(32:33,:) = repmat(0.7,2,3);
colormap(map);
caxis([-0.5 0.5]);
%
close(1:3);
%
% Get Femur Regions
%
idreg = xlsread(['..\..\BM_Femur_Case_MatFiles\Female\' ...
                 'Partitions6_fe.xlsx']);   % Only reads first sheet
%
% Add Regions
%
hold on;
hl1 = plot([-95; 20],[-0.5; -0.5],'k-','LineWidth',2);     % Lateral-medial boundary
hl2 = plot([-144; -144],[-40; -15],'k-','LineWidth',2);    % Posterior medial boundary
hl3 = plot([-144; -144],[5; 35],'k-','LineWidth',2);       % Posterior lateral boundary
%
idla = find(idreg==3);  % Lateral anterior (trochlea)
idlc = find(idreg==2);  % Lateral center
ir3 = nod2tri(idla,trig,2);            % Anterior triangles
ir2 = nod2tri(idlc,trig,2);            % Center triangles
bid2 = meshbnd4(trig(ir2,:));          % Center boundary
bid3 = meshbnd4(trig(ir3,:));          % Anterior boundary
%
tzs2 = sortrows([tq(bid2) zq(bid2)],2);
for k = 0:40            % Loop through the z coordinates (every mm)
   id = find(tzs2(:,2)==k);
   tz2(k+1,:) = [max(tzs2(id,1)) k];   % Maximum of center region
end
%
tzs3 = sortrows([tq(bid3) zq(bid3)],2);
for k = 0:40            % Loop through the z coordinates (every mm)
   id = find(tzs3(:,2)==k);
   tz3(k+1,:) = [min(tzs3(id,1)) k];   % Minimum of anterior region
end
tzl = (tz2+tz3)./2;     % Region boundary between the two boundaries
hl4 = plot(tzl(1:35,1),tzl(1:35,2),'k-','LineWidth',2);    % Lateral boundary
%
idma = find(idreg==6);  % Medial anterior (trochlea)
idmc = find(idreg==5);  % Medial center
ir6 = nod2tri(idma,trig,2);            % Anterior triangles
ir5 = nod2tri(idmc,trig,2);            % Center triangles
bid5 = meshbnd4(trig(ir5,:));          % Center boundary
bid6 = meshbnd4(trig(ir6,:));          % Anterior boundary
%
tzs5 = sortrows([tq(bid5) zq(bid5)],2);
for k = -40:-1          % Loop through the z coordinates (every mm)
   id = find(tzs5(:,2)==k);
   tz5(abs(k),:) = [max(tzs5(id,1)) k];% Maximum of center region
end
%
tzs6 = sortrows([tq(bid6) zq(bid6)],2);
for k = -40:-1          % Loop through the z coordinates (every mm)
   id = find(tzs6(:,2)==k);
   tz6(abs(k),:) = [min(tzs6(id,1)) k];% Minimum of anterior region
end
tzm = (tz5+tz6)./2;     % Region boundary between the two boundaries
hl5 = plot(tzm(1:36,1),tzm(1:36,2),'k-','LineWidth',2);    % Medial boundary
%
% Add Grid Points
%
idp = find(dthkn_case>2);
np = size(idp,1);
hp = plot3(tq(idp),zq(idp),repmat(1.8,np,1),'k.','LineWidth',1, ...
           'MarkerSize',6);
%
% Get Unadjusted p-values
%
xnam = '..\..\Femoral Female, unadjusted.xls';
%
shtnams = {'Lateral Anterior';
           'Lateral Central';
           'Lateral Posterior';
           'Medial Anterior';
           'Medial Central';
           'Medial Posterior' };
%
pids = [];              % Point IDs
pvals = [];             % Unadjusted p-values
for m = 1:6
   [vals,ptxt] = xlsread(xnam,shtnams{m});
   ptxt = char(ptxt(2:end,1));         % Get first column without the header
   pids = [pids; str2num(ptxt(:,4:end))];
   pvals = [pvals; vals(:,2)];         % Corrected p-values
end
%
idpv = find(pvals<0.05);               % Significant p-values
ipid = pids(idpv);                     % Points with significant p-values
%
dthk = dthk_case;
dthk(idt) = NaN;
dthk(idq) = NaN;
%
ipidp = ipid(find(dthk(ipid)>0));      % Positive changes (increases)
ipidn = ipid(find(dthk(ipid)<0));      % Negative changes (decreases)
%
% Get Adjusted p-values
%
xnamAP = '..\..\Femoral Female, adjusted for AP_Trans.xls';
%
pidsAP = [];            % Point IDs
pvalsAP = [];           % Adjusted p-values
for m = 1:6
   [vals,ptxt] = xlsread(xnamAP,shtnams{m});
   ptxt = char(ptxt(2:end,1));         % Get first column without the header
   pidsAP = [pidsAP; str2num(ptxt(:,4:end))];
   pvalsAP = [pvalsAP; vals(:,2)];     % Corrected p-values
end
%
idpvAP = find(pvalsAP<0.05);           % Significant p-values
ipidAP = pidsAP(idpvAP);               % Points with significant p-values
%
% Plot Female Cartilage Thickness Differences with Unadjusted
% Signficant Points
%
tqp = tq(ipidp);        % Positive changes (increases)
zqp = zq(ipidp);
np = size(ipidp,1);
%
% hp = plot3(tqp,zqp,repmat(2,np,1),'g.','Color',[0 gr 0],'MarkerSize',7);
% hs = plot3([tqp-1 tqp-1 tqp+1 tqp+1 tqp-1]',[zqp-0.5 zqp+0.5 ...
%            zqp+0.5 zqp-0.5 zqp-0.5]',repmat(2,5,np),'g-', ...
%            'Color',[0 gr 0],'LineWidth',0.5);    % Draw squares around significant points
hp = plot3(tqp,zqp,repmat(2,np,1),'r.','MarkerSize',7);
hsp = plot3([tqp-1 tqp-1 tqp+1 tqp+1 tqp-1]',[zqp-0.5 zqp+0.5 ...
            zqp+0.5 zqp-0.5 zqp-0.5]',repmat(2,5,np),'r-', ...
            'LineWidth',0.5);          % Draw squares around significant points
%
tqn = tq(ipidn);        % Negative changes (decreases)
zqn = zq(ipidn);
nn = size(ipidn,1);
%
hn = plot3(tqn,zqn,repmat(2,nn,1),'b.','MarkerSize',7);
hsn = plot3([tqn-1 tqn-1 tqn+1 tqn+1 tqn-1]',[zqn-0.5 zqn+0.5 ...
            zqn+0.5 zqn-0.5 zqn-0.5]',repmat(2,5,nn),'b-', ...
            'LineWidth',0.5);          % Draw squares around significant points
%
% Add Labels
%
axlim = axis;
axis off;
text(axlim(1)-10,0,'Lateral \rightarrow','FontSize',16,'FontWeight', ...
     'bold','HorizontalAlignment','center','Rotation',90);
text(sum(axlim(1:2))/2,axlim(3),'Anterior \rightarrow','FontSize', ...
     16,'FontWeight','bold','HorizontalAlignment','center');
%
% Save to JPEG File
%
clear c* d*;
% print -djpeg95 -r600 fcthkcibmf.jpg
%
return
%
% Plot Female Cartilage Thickness Differences with Adjusted Signficant
% Points
%
delete(hp);
delete(hsp);
delete(hn);
delete(hsn);
%
tqAP = tq(ipidAP);
zqAP = zq(ipidAP);
np = size(ipidAP,1);
%
hp = plot3(tqAP,zqAP,repmat(2,np,1),'g.','MarkerSize',7,'Color',[0 gr 0]);
hs = plot3([tqAP-1 tqAP-1 tqAP+1 tqAP+1 tqAP-1]',[zqAP-0.5 zqAP+0.5  ...
           zqAP+0.5 zqAP-0.5 zqAP-0.5]',repmat(2,5,np),'g-', ...
           'Color',[0 gr 0],'LineWidth',0.5);    % Draw squares around significant points
%
% Save to JPEG File
%
print -djpeg95 -r600 fcthkcibmfAP.jpg
%
return