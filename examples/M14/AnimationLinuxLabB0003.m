%close(mov);

fclose('all');
lw=3; %line width
cz=9; %the size of the marker
sce=1000*3600*24;  % the unit conversion parameter from m/s to mm/day
fz=18; % fontsize
fl=15; % label font size

%% coordinate transformation for accumulative evaporation
% (T)ranslation for (T)ime (C)oordinate (day)
ttc=0.3;
% find out the the base accumulative evaporation rate before new zero time
i=1;
while (taetlab(i)-taetlab(1))<ttc
  i=i+1;
end
%  (A)ccumulative (E)vapora(T)ion from (LAB) (A)fter (T)transformation
aetlabat=zeros(max(ndaet),f6(4));
aetlabat(i:max(ndaet),1)=aetlab(i:max(ndaet),1)-aetlab(i,1);
%% ---preparing saturation over time data WARNING: the location changes with cell discretisiation ----
% starts from the second result becasue the first one is not stored in a(13)
% (S)aturation over (T)ime at (1 cm) below the surface
st1cm=zeros(f2(2)-1,1);
% (S)aturation over (T)ime at (9 cm) below the surface
st9cm=zeros(f2(2)-1,1);
st14cm=zeros(f2(2)-1,1);
st13cm=zeros(f2(2)-1,1);
for i=1:f2(2)-1
  st1cm(i)=a1(5,(2*(f3(5)+1)),i);
  st9cm(i)=a1(5,(2*(f3(5)+1)-9),i);
  st13cm(i)=mean(a1(5,(2*(f3(5)+1))-2:(2*(f3(5)+1)),i));
  st14cm(i)=mean(a1(5,(2*(f3(5)+1))-3:(2*(f3(5)+1)),i));
end
%% ---preparing temperature over time data WARNING: the location changes with cell discretisiation ----
% starts from the second result becasue the first one is not stored in a(13)
% (T)emperature over (T)ime at (1 cm) below the surface (Celsius)
tt3cm=zeros(f2(2)-1,1);
% (T)emperature over (T)ime at (9 cm) below the surface (Celsius)
tt8cm=zeros(f2(2)-1,1);

tt1cm=zeros(f2(2)-1,1);
tt11cm=zeros(f2(2)-1,1);
tt5cm=zeros(f2(2)-1,1);

for i=1:f2(2)-1
  tt1cm(i)=a1(13,(2*(f3(5)+1)-1),i);
  tt3cm(i)=a1(13,(2*(f3(5)+1)-3),i);
  tt5cm(i)=a1(13,(2*(f3(5)+1)-5),i);
  tt8cm(i)=a1(13,(2*(f3(5)+1)-8),i);
  tt11cm(i)=a1(13,(2*(f3(5)+1)-11),i);
end

%% -plotting out the saturation total head, saturation and solid salt-
if f2(6)~=0
  fs = 5; % sampling frequency
  % Creating the movie : quality = 100%, no compression is used and the
  % timing is adjusted to the sampling frequency of the time interval
  qt=100;
  %A number from 0 through 100. Higher quality numbers result in higher video quality and larger file sizes
  h=figure;
  set(gcf,'Units','normalized', 'WindowStyle','docked','OuterPosition',[0 0 1 1]);  % maximize the plotting figure
  mov =  VideoWriter('linux.avi');% avifile('pvc1.avi','quality',qt,'compression','indeo5','fps',fs);
  mov.FrameRate = 5;mov.Quality=qt;
  open(mov);
  
  for j=2:50:f2(1)   %:f2(6):f2(1)
   %% ---plot temperature-----
    subplot('Position',[0.04 0.62 0.12 0.35])
    %plot(tlab(2,:,1),tlab(1,:,1),'rd','MarkerSize',cz);hold on;
    %plot(tlab(2,:,2),tlab(1,:,2),'go','MarkerSize',cz);hold on
    %plot(tlab(2,:,3),tlab(1,:,3),'ks','MarkerSize',cz);hold on
    plot(a1(13,(f3(5)+2):(2*(f3(5)+1)),j),a1(2,(f3(5)+2):(2*(f3(5)+1)),j),'LineWidth',lw);hold on
    plot([mean(tlab(1:ndt(3),3)),mean(tlab(1:ndt(1),1)),mean(tlab(1:ndt(2),2))],[0.12,0.17,0.2],'or','markersize',10,'markerface','r');hold off
    axis([f5(8) f5(7) a1(2,(f3(5)+2),j) a1(2,(2*(f3(5)+1)),j)])
    ylabel('Depth (m)','FontSize',fz,'FontWeight','bold')
    xlabel('Temperature (\circC)','FontSize',fz,'FontWeight','bold')
    ax1 = gca;
    set(ax1,'FontSize',fl,'FontWeight','bold')
   %% ---Saturation output ----------------
    subplot('Position',[0.18 0.62 0.12 0.35])
    plot(a1(5,(f3(5)+2):(2*(f3(5)+1)),j),a1(2,(f3(5)+2):(2*(f3(5)+1)),j),'LineWidth',lw);hold off
    xlabel('Saturation','FontSize',fz,'FontWeight','bold')
    axis([f5(4) f5(3) a1(2,(f3(5)+2),j) a1(2,(2*(f3(5)+1)),j)])
    ax1 = gca;
    set(ax1,'YTickLabel','')
    set(ax1,'FontSize',fl,'FontWeight','bold')    
    
    %% ----Total Head output-------
    subplot('Position',[0.32 0.62 0.12 0.35])
    plot(a1(7,(f3(5)+2):(2*(f3(5)+1)),j),a1(2,(f3(5)+2):(2*(f3(5)+1)),j),'LineWidth',lw);hold off
    xlabel('Total Head (m)','FontSize',fz,'FontWeight','bold')
    axis([f5(10) f5(9) a1(2,(f3(5)+2),j) a1(2,(2*(f3(5)+1)),j)])
    ax1 = gca;
    set(ax1,'YTickLabel','')
    set(ax1,'FontSize',fl,'FontWeight','bold')
    %set(ax1,'YAxisLocation','right','XAxisLocation','top')
    
    %% ----Vertical flux output-------
    subplot('Position',[0.46 0.62 0.12 0.35])
    plot(b1(4,(f3(5)+1):(2*f3(5)),j)*sce,xye(2,(f3(5)+1):2*f3(5)),'r',qvy1(1,:,j)*sce,fliplr(xye(2,(f3(5)+1):(2*f3(5)))),'b','LineWidth',lw) 
    xlabel('Vertical Flux (mm/day)','FontSize',fz,'FontWeight','bold')
    hleg1 = legend('liquid water','water vapor','Location','SouthEast');
    set(hleg1, 'Box', 'off','FontSize',fz)
    axis([f5(12) f5(11) a1(2,(f3(5)+2),j) a1(2,(2*(f3(5)+1)),j)])      %f3(5) is number of element in Y direction. this is the axis limits
    ax1 = gca;
    set(ax1,'YTickLabel','')
    set(ax1,'FontSize',fl,'FontWeight','bold')
%     subplot(3,7,[7 14])%,plot(b1(5,(f3(5)+1):(2*f3(5)),j),xye(2,(f3(5)+1):(2*f3(5))),'LineWidth',lw)
    %% ----Relative K-------
    subplot('Position',[0.60 0.62 0.12 0.35])
    semilogx(b1(5,(f3(5)+1):(2*f3(5)),j),xye(2,(f3(5)+1):(2*f3(5))),'LineWidth',lw)
    xlabel('Relative K','FontSize',fz,'FontWeight','bold')
    axis([f5(14) f5(13) a1(2,(f3(5)+2),j) a1(2,(2*(f3(5)+1)),j)])
    ax1 = gca;
    set(ax1,'YAxisLocation','right','YColor','k')%,'YTick', 0.00::1E-17)
    title(line1(3,j),'fontweight','b','Units', 'normalized','Position', [0.5 1],'HorizontalAlignment', 'Center','FontSize',fz)
    
%% ----Transient evaporation rate ------------
subplot('Position',[0.04 0.33 0.45 0.23])
plot(et1(1,2:j)+ttc,et1(2,2:j),'b','LineWidth',lw);hold on  % calculated evaporation
plot(tetlab(:,1)-tetlab(1,1),etlab(:,1)*sce,'r');hold on
plot(tetlab(:,2)-tetlab(1,2),etlab(:,2)*sce,'g');hold off
 hleg1 = legend('Calculated','Original measured data','fitting measured data','Location','NorthEast');
 set(hleg1, 'Box', 'off','FontSize',fz)
 xlabel('Time (day)','FontSize',fz,'FontWeight','bold')
 ylabel('ET (mm/day)','FontSize',fz,'FontWeight','bold')
     ax1 = gca;
    set(ax1,'FontSize',fl,'FontWeight','bold')
    
axis([0 6 0 15])
%% ----accumulative evaporation rate ------------
subplot('Position',[0.04 0.05 0.45 0.23])
plot(aet1(1,1:j)+ttc,aet1(2,1:j),'b','LineWidth',lw);hold on  %Calculated evaporation
plot(taetlab(:,1)-taetlab(1,1),aetlabat(:,1),'r');hold off
xlabel('Time (day)','FontSize',fz,'FontWeight','bold')
ylabel('AET (mm)','FontSize',fz,'FontWeight','bold')
hleg1 = legend('Calculated','Original data','Location','NorthEast');
set(hleg1, 'Box', 'off','FontSize',fz)
ax1 = gca;
set(ax1,'FontSize',fl,'FontWeight','bold')
axis([0 6 0 40])
%% -----Saturation over time --------------------
subplot('Position',[0.55 0.33 0.45 0.23])
plot(tslab(:,1)-tslab(1,1),slab(:,1),'r');hold on
plot(tslab(:,2)-tslab(1,2),slab(:,2),'g');hold on
plot(ta(2,1:j)+ttc,st1cm(1:j),'r','LineWidth',lw);hold on
plot(ta(2,1:j)+ttc,st13cm(1:j),'b','LineWidth',lw);hold on
plot(ta(2,1:j)+ttc,st14cm(1:j),'k','LineWidth',lw);hold on
plot(ta(2,1:j)+ttc,st9cm(1:j),'g','LineWidth',lw);hold off
xlabel('Time (day)','FontSize',fz,'FontWeight','bold')
ylabel('Saturation','FontSize',fz,'FontWeight','bold')
ax1 = gca;
set(ax1,'FontSize',fl,'FontWeight','bold')
axis([0 6 0 1.1])
%% -----Temperature over time --------------------
subplot('position',[0.55 0.05 0.45 0.23])
plot(ttlab(1:ndt(1),1)-ttlab(1,1),tlab(1:ndt(1),1),'r');hold on
plot(ttlab(1:ndt(2),2)-ttlab(1,2),tlab(1:ndt(2),2),'g');hold on
plot(ttlab(1:ndt(3),3)-ttlab(1,3),tlab(1:ndt(3),3),'b');hold on
plot(ttlab(1:ndt(4),4)-ttlab(1,4),tlab(1:ndt(4),4),'c');hold on

plot(ta(2,1:j)+ttc,tt1cm(1:j),'r','LineWidth',lw);hold on
plot(ta(2,1:j)+ttc,tt3cm(1:j),'g','LineWidth',lw);hold on
plot(ta(2,1:j)+ttc,tt5cm(1:j),'b','LineWidth',lw);hold on
plot(ta(2,1:j)+ttc,tt8cm(1:j),'c','LineWidth',lw);hold on
plot(ta(2,1:j)+ttc,tt11cm(1:j),'k','LineWidth',lw);hold off

xlabel('Time (day)','FontSize',fz,'FontWeight','bold')
ylabel('Temperature','FontSize',fz,'FontWeight','bold')
ax1 = gca;
set(ax1,'FontSize',fl,'FontWeight','bold')
% [AX,H1,H2]=plotyy(eslab(1,:),eslab(2,:),ta(2,1:j), temp(1:j));hold on       %lab evaporation and calculated solid salt 
% 
% set(get(AX(1),'Ylabel'),'String','Evaporation (mm day^{-1})','FontSize',8) 
% set(AX(1),'YColor','k','YTick', 0:5:20)   %,'Ylim',[0 15]'Ylim',[5 18]) if i put Ylim in, then we get tick from another side
% set(get(AX(2),'Ylabel'),'String','Solid salt (mm)','color','k') 
% set(AX(2),'YColor','k','YTick', 0.00:0.02:0.08)   %,'Ylim',[-0.01 0.06] the limit here seems not working
% xlabel('Time (day)') 
% title('(d)','fontweight','b','Units', 'normalized','Position', [0 1],'HorizontalAlignment', 'left','FontSize',12) 
% set(H1,'LineStyle','none','Marker','s','MarkerSize',cz)  
% set(H2,'LineStyle','-','LineWidth',lw)   
% axis(AX(1), [0 20 0 20])
% axis(AX(2), [0 20 0.00 0.08])


% % this part is to change the location of the legend to a user defined
% % location
% hleg1 = legend([H1,H3,H2],{'Measurements','Calculated evaporation', ...
%     'Calculated solid salt on soil surface'},'FontSize',10,'Location','North');
% set(hleg1,'Box', 'on','Position',[0.7 0.17 0.16 0.068])
% set(hleg1,'units','pixels'); 
%      lp=get(hleg1,'outerposition'); 
%      set(hleg1,'outerposition',[lp(1:2),300,70]); 
% finish the legend size change
    F = getframe(gcf); % save the current figure
    writeVideo(mov,F);% add it as the next frame of the movie
  end
close(mov);
saveas(h,'a','fig')
end





%% -------mass balance---------------
if f2(7)~=0
   %tp is to store the total sink persecond
   
   
   temp=v.*a1(3,:,1).*a1(2,:,1).*(1000+702.24*a1(1,:,1));
   tw=sum(temp);
   ts=sum(temp.*a1(1,:,1));
   mt=sum(a(11,:,f2(2)-1)-temp);
   ms=sum(a(12,:,f2(2)-1)-v.*a1(3,:,1).*a1(2,:,1).*(1000+702.24*a1(1,:,1)).*a1(1,:,1));
   tp=sum(sum(p,3),2);
    
    
    
   fn=fopen('OPT.DAT','w');
   fprintf(fn,' INITIAL WATER STORAGE IS                 :  %+13.5E \n ',tw);
   fprintf(fn,'WATER STORAGE DIFF. GAIN(+)/LOSS(-) IS   :  %+13.5E \n ',mt);
   fprintf(fn,'TOTAL PRESSURE BOUNDARY IN(+)/OUT(-) IS  :  %+13.5E \n ',tp(1,1)*f4(3));
   fprintf(fn,'TOTAL WATER SOURCE(+)/SINK(-) BOUDARY IS :  %+13.5E \n ',tf(1,1)*f4(3));
   fprintf(fn,'ABSOLUTE MASS DIF. BTW STORAGE AND IN&OUT:  %+13.5E \n ',-mt+(tp(1,1)+tf(1,1))*f4(3));
   fprintf(fn,'RELATIVE MASS DIF. BTW STORAGE AND IN&OUT:  %+13.5E \n\n ',(-mt+(tp(1,1)+tf(1,1))*f4(3))/mt);
   
   fprintf(fn,'INITIAL SOLUTE STORAGE IS                :  %+13.5E \n ',ts);
   fprintf(fn,'SOLUTE STORAGE DIFF. GAIN(+)/LOSS(-) IS  :  %+13.5E \n ',ms);
   fprintf(fn,'TOTAL PRESSURE BOUNDARY IN(+)/OUT(-) IS  :  %+13.5E \n ',tp(3,1)*f4(3));
   fprintf(fn,'TOTAL WATER SOURCE(+)/SINK(-) BOUDARY IS :  %+13.5E \n ',tf(3,1)*f4(3));
   fprintf(fn,'ABSOLUTE MASS DIF. BTW STORAGE AND IN&OUT:  %+13.5E \n ',-ms+(tp(3,1)+tf(3,1))*f4(3));
   fprintf(fn,'RELATIVE MASS DIF. BTW STORAGE AND IN&OUT:  %+13.5E \n \n ',(-ms+(tp(3,1)+tf(3,1))*f4(3))/ms);
   fclose(fn);

end

%% FINISH
clear mov F
save('Data.mat') 
fprintf(1,'JOB COMPLETE \n');
