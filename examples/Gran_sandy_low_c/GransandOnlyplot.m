
fclose('all');
lw=1.5; %line width
cz=9; %the size of the marker
sce=1000*3600*24;
%% -plotting out the concentration total head, saturation and solid salt-
if f2(6)~=0
  fs = 5; % sampling frequency
  % Creating the movie : quality = 100%, no compression is used and the
  % timing is adjusted to the sampling frequency of the time interval
  qt=100;
  %A number from 0 through 100. Higher quality numbers result in higher video quality and larger file sizes
  h=figure;
  set(gcf,'Units','normalized', 'WindowStyle','docked','OuterPosition',[0 0 1 1]);  % maximize the plotting figure
  mov = avifile('pvc1.avi','quality',qt,'compression','indeo5','fps',fs);
  
  for j=1:f2(6):f2(1)

    %--- plot concentration---- 
    subplot(3,7,[1 8]),plot(clab(2,:,1),clab(1,:,1),'rd','MarkerSize',cz); hold on
    plot(clab(2,:,2),clab(1,:,2),'go','MarkerSize',cz);hold on
    plot(clab(2,:,3),clab(1,:,3),'ks','MarkerSize',cz);hold on;
    hleg1 = legend(char(ln(1,3)),char(ln(2,3)),char(ln(3,3)),'Location','SouthEast');
    set(hleg1, 'Box', 'off','FontSize',8)
    subplot(3,7,[1 8]),plot(a1(4,(f3(5)+2):(2*(f3(5)+1)),j),a1(2,(f3(5)+2):(2*(f3(5)+1)),j),'LineWidth',lw);hold off
    xlabel('Concentration')
    ax1 = gca;
    set(ax1,'XAxisLocation','top')
    axis([f5(2) f5(1) a1(2,(f3(5)+2),j) a1(2,(2*(f3(5)+1)),j)])
    % ---plot Saturation-----
    subplot(3,7,[2 9]),plot(slab(2,:,1),slab(1,:,1),'rd','MarkerSize',cz); hold on
                       plot(slab(2,:,2),slab(1,:,2),'go','MarkerSize',cz);hold on
                       plot(slab(2,:,3),slab(1,:,3),'kS','MarkerSize',cz);hold on
    xlabel('Saturation')
    ax1 = gca;
    set(ax1,'YTickLabel','','XAxisLocation','top')
    hleg1 = legend(char(ln2(1,3)),char(ln2(2,3)),char(ln2(3,3)),'Location','SouthEast');
    set(hleg1, 'Box', 'off','FontSize',8)
    subplot(3,7,[2 9]),plot(a1(5,(f3(5)+2):(2*(f3(5)+1)),j),a1(2,(f3(5)+2):(2*(f3(5)+1)),j),'LineWidth',lw);hold off
    axis([f5(4) f5(3) a1(2,(f3(5)+2),j) a1(2,(2*(f3(5)+1)),j)]) 

    % ---plot solid salt by showing new porosity-----
    subplot(3,7,[3 10]),plot(a1(10,(f3(5)+2):(2*(f3(5)+1)),j),a1(2,(f3(5)+2):(2*(f3(5)+1)),j),'LineWidth',lw),title(line1(3,j))
    axis([f5(6) f5(5) a1(2,(f3(5)+2),j) a1(2,(2*(f3(5)+1)),j)])
    xlabel('Porosity')
    ax1 = gca;
    set(ax1,'YTickLabel','','XAxisLocation','top')
    
   % ---plot temperature-----
subplot(3,7,[4 11]),plot(tlab(2,:,1),tlab(1,:,1),'rd','MarkerSize',cz);hold on;
    plot(tlab(2,:,2),tlab(1,:,2),'go','MarkerSize',cz);hold on
    plot(tlab(2,:,3),tlab(1,:,3),'ks','MarkerSize',cz);hold on
    xlabel('Temperature (\circC)')
    axis([f5(8) f5(7) a1(2,(f3(5)+2),j) a1(2,(2*(f3(5)+1)),j)])
    ax1 = gca;
    set(ax1,'YTickLabel','','XAxisLocation','top')    
    hleg1 = legend(char(ln3(1,3)),char(ln3(2,3)),char(ln3(3,3)),'Location','SouthEast');
    set(hleg1, 'Box', 'off','FontSize',8)
    subplot(3,7,[4 11]),plot(a1(13,(f3(5)+2):(2*(f3(5)+1)),j),a1(2,(f3(5)+2):(2*(f3(5)+1)),j),'LineWidth',lw);hold off
    
    % ----Total Head output-------
    subplot(3,7,[5 12]),plot(a1(7,(f3(5)+2):(2*(f3(5)+1)),j),a1(2,(f3(5)+2):(2*(f3(5)+1)),j),'LineWidth',lw)
    xlabel('Total Head (m)')
    axis([f5(10) f5(9) a1(2,(f3(5)+2),j) a1(2,(2*(f3(5)+1)),j)])
    ax1 = gca;
    set(ax1,'YTickLabel','','XAxisLocation','top')
    %set(ax1,'YAxisLocation','right','XAxisLocation','top')
    
    % ----Vertical flux output-------
    subplot(3,7,[6 13]),plot(b1(4,(f3(5)+1):(2*f3(5)),j)*sce,xye(2,(f3(5)+1):(2*f3(5))),'r',qvy1(1,:,j)*sce,fliplr(xye(2,(f3(5)+1):(2*f3(5)))),'b','LineWidth',lw) 
    xlabel('Vertical Flux (mm/day)')
    hleg1 = legend('liquid water','water vapor','Location','SouthEast');
    set(hleg1, 'Box', 'off','FontSize',8)
    axis([f5(12) f5(11) a1(2,(f3(5)+2),j) a1(2,(2*(f3(5)+1)),j)])      %f3(5) is number of element in Y direction. this is the axis limits
    ax1 = gca;
    set(ax1,'YTickLabel','','XAxisLocation','top')
    subplot(3,7,[7 14])%,plot(b1(5,(f3(5)+1):(2*f3(5)),j),xye(2,(f3(5)+1):(2*f3(5))),'LineWidth',lw)
    
    semilogx(b1(5,(f3(5)+1):(2*f3(5)),j),xye(2,(f3(5)+1):(2*f3(5))),'LineWidth',lw)
    xlabel('Relative K')
    axis([f5(14) f5(13) a1(2,(f3(5)+2),j) a1(2,(2*(f3(5)+1)),j)])
    ax1 = gca;
    set(ax1,'YAxisLocation','right','XAxisLocation','top','YColor','k')%,'YTick', 0.00::1E-17)
    
    
    
    %----------------
    % --------plotting the third figure on evaporation as well as salt precipitation-----------
 % this plotting is done by using the salt precipted at the top cell in right most column
 % the reason that temp is created here is that when we call a=b(1,3,:) a is not a array but a [1,1,t] matrix where
 % t is the number of variables in the third rank of b matrix 
 % a1(6,f3(1),1:f2(1))(kg) /xyf(4,3)(m2) /2650(kg/m3) *1000 (mm/m) is to change the unit from kg to mm
temp=0;
temp(1:f2(1))=a1(6,f3(1),1:f2(1))*1000/xyf(4,3)/2165;       %f2(6) is the salt precipitation rate
subplot(3,1,3),H3=plot(et1(1,1:j),et1(2,1:j),'r','LineWidth',lw);hold on  %evaporation
box off


[AX,H1,H2]=plotyy(eslab(1,:),eslab(2,:),ta(2,1:j), temp(1:j));hold on       %lab evaporation and calculated solid salt 
set(get(AX(1),'Ylabel'),'String','Evaporation (mm day^{-1})','FontSize',8) 
set(AX(1),'YColor','k','YTick', 0:5:20)   %,'Ylim',[0 15]'Ylim',[5 18]) if i put Ylim in, then we get tick from another side
set(get(AX(2),'Ylabel'),'String','Solid salt (mm)','color','k') 
set(AX(2),'YColor','k','YTick', 0.00:0.02:0.08)   %,'Ylim',[-0.01 0.06] the limit here seems not working
xlabel('Time (day)') 
title('(d)','fontweight','b','Units', 'normalized','Position', [0 1],'HorizontalAlignment', 'left','FontSize',12) 
set(H1,'LineStyle','none','Marker','s','MarkerSize',cz)  
set(H2,'LineStyle','-','LineWidth',lw)   
axis(AX(1), [0 20 0 20])
axis(AX(2), [0 20 0.00 0.08])


% this part is to change the location of the legend to a user defined
% location
hleg1 = legend([H1,H3,H2],{'Measurements','Calculated evaporation', ...
    'Calculated solid salt on soil surface'},'FontSize',10,'Location','North');
set(hleg1,'Box', 'on','Position',[0.7 0.17 0.16 0.068])
set(hleg1,'units','pixels'); 
     lp=get(hleg1,'outerposition'); 
     set(hleg1,'outerposition',[lp(1:2),300,70]); 
% finish the legend size change
    F = getframe(gcf); % save the current figure
    mov = addframe(mov,F); % add it as the next frame of the movie
  end
mov = close(mov);
saveas(h,'a','fig')
end





%% -------mass balance---------------
if f2(7)~=0
   %tp is to store the total sink persecond
   
   temp=0;
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
fprintf(1,'JOB COMPLETE \n');
