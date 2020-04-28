% this file has been update to accomodate SUTRA6.1 with four more output for film flow
clear all
fclose('all');

tic
% nnv -- node numbers in the vertical direction
% nnh -- node numbers in the horizontal direction

%% ------------read EN.IPT----------
fn=fopen('EN.IPT');
line=fgetl(fn);
while  line(1)=='#'
  line=fgetl(fn);
end
line=fgetl(fn);
%f9=fscanf(fn,'%100s',[1,16]);
%line=fgets(fn);
%f1= textscan(fn,'%s','HeaderLines',8,'EndOfLine', 'p.' );
f1= textscan(line,'%s');
%f1=strread(line,'%s');
%a=fscanf(fn, '%3g ', [3 1],'HeaderLines',18);
%dummy=fscanf(fn,'%*s',2);
line=fgetl(fn);
f2=fscanf(fn,['%f' ' '],[1,10]);
line=fgetl(fn);
f3=fscanf(fn,['%f' ' '],[1,9]);
line=fgetl(fn);
f4=fscanf(fn,['%f' ' '],[1,4]);
line=fgetl(fn);
f5=fscanf(fn,['%f' ' '],[1,16]);
if f2(7)~=0
line=fgetl(fn);
v=fscanf(fn, '%g', [1 f3(1)]);
end
fclose(fn);
%% ---------some variables -----------
nnv=f3(5)+1; 
nnh=f3(6)+1;


%% --------define matrix -----------
% a(1,nodenumber,timestep) is x position 
% a(2,nodenumber,timestep) is z position
% a(3,nodenumber,timestep) is pressure result
% a(4,nodenumber,timestep) is concentration
% a(5,nodenumber,timestep) is Saturation
% a(6,nodenumber,timestep) is solid mass
% a(7,nodenumber,timestep) is total head
% a(8,nodenumber,timestep) is u velocity (interpolated)
% a(9,nodenumber,timestep) is v velocity (interpolated)
% a(10,nodenumber,timestep) porosity
% a(11,nodenumber,timestep) water mass
% a(12,nodenumber,timestep) solute mass
% a(13,nodenumber,timestep) temperature
% ta(1,:) is the time step numbers
% ta(2,:) is the real time (s) of this time step
ta=zeros(2,f2(2)-1);
a1=zeros([13,f3(1),f2(2)]);
a2=zeros([13,f3(1),f2(2)]);
a3=zeros([13,f3(1),f2(2)]);
a4=zeros([13,f3(1),f2(2)]);
a5=zeros([13,f3(1),f2(2)]);
% xye(1,elementnumber) is the x posity of the element (centrinod of the element)
% xye(2,elementnumber) is the y posity of the element (centrinod of the element)
% b(1,nodenumber,timestep) is the x velocity of the element
% b(2,nodenumber,timestep) is the y velocity of the element
% b(3,nodenumber,timestep) is the x flux density of the element
% b(4,nodenumber,timestep) is the y flux density of the element
% b(5,nodenumber,timestep) is the relative hydraulic conductivity of the element
% b(6,nodenumber,timestep) is the x flux density of the element due to film flow  (QXF)
% b(7,nodenumber,timestep) is the y flux density of the element due to film flow  (QYF)
% b(8,nodenumber,timestep) is (S)aturated (P)ermeability due to (F)ilm flow
% b(9,nodenumber,timestep) is (R)elative (P)ermeability due to (F)ilm flow
b1=zeros([9,f3(2),f2(1)]);
b2=zeros([9,f3(2),f2(1)]);
b3=zeros([9,f3(2),f2(1)]);
b4=zeros([9,f3(2),f2(1)]);
b5=zeros([9,f3(2),f2(1)]);
% line1 is the header of .nod file
line1=cell(5,f2(2));
% line2 is the header of .ele file
line2=cell(5,f2(1));
% line3 is the header of pv.dat file
line3=cell(1,f2(2)-1);

% the following matrices is applied by bcof reading
% bcof(1,source/sink nodenumber, timestep) is water sink
% bcof(2,source/sink nodenumber, timestep) is solute concentration of water sink
% bcof(3,source/sink nodenumber, timestep) is solute concentration
bcof1=zeros([3,f3(4),f2(4)]);
bcof2=zeros([3,f3(4),f2(4)]);
bcof3=zeros([3,f3(4),f2(4)]);
bcof4=zeros([3,f3(4),f2(4)]);
bcof5=zeros([3,f3(4),f2(4)]);
% xyf(1,source/sink node number) node sequence
% xyf(2,source/sink node number) x position
% xyf(3,source/sink node number) y position
% xyf(4,source/sink node number) area of node in xz panel (harea)
% xyf(5,source/sink node number) area of node in yz panel (varea)
% xyf(6,source/sink node number) area of node in xy panel (farea)
xyf=zeros([4,f3(4)]);
% tf(1,time steps) time steps
% tf(1,time steps) actual time (days)
% tf(2,time steps) evaporation rate (mm/day)
tf1=zeros([3,f2(4)]);
tf2=zeros([3,f2(4)]);
tf3=zeros([3,f2(4)]);
tf4=zeros([3,f2(4)]);
tf5=zeros([3,f2(4)]);

% tbp(1,time steps) time steps
% tbp(2,time steps) actual time (days)
% tbp(3,time steps) sink suction rate (mm/day)
% xyp(1,:)node sequence
% xyp(2,:)x location
% xyp(3,:)y location
% p1(resultant source/sink of fluid, solute conc of fluid, resultant source/sink of solute)
tbp1=zeros([3,f2(3)]);
tbp2=zeros([3,f2(3)]);
tbp3=zeros([3,f2(3)]);
tbp4=zeros([3,f2(3)]);
tbp5=zeros([3,f2(3)]);
p1=zeros([3,f3(3),f2(3)]);
p2=zeros([3,f3(3),f2(3)]);
p3=zeros([3,f3(3),f2(3)]);
p4=zeros([3,f3(3),f2(3)]);
p5=zeros([3,f3(3),f2(3)]);
xyp=zeros([3,f3(3)]);

% et is used in bco.dat
% et(1,:) is the time (day)
% et(2:end,:) is the evaporation rate (m/s) at each node
% this method is more precise to calc the et rate
et1=zeros([f3(6)+2,f2(1)]);
et2=zeros([f3(6)+2,f2(1)]);
et3=zeros([f3(6)+2,f2(1)]);
et4=zeros([f3(6)+2,f2(1)]);
et5=zeros([f3(6)+2,f2(1)]);

% qvx qvy are the vapor flux, their directions are along the element boundaries. see notebook p121 of year 2011
% warning: both matrices has been transposed due to the reading sequence using fscanf command
qvy1=zeros([f3(6)+1,f3(5),f2(2)-1]);
qvx1=zeros([f3(6),f3(5)+1,f2(2)-1]);
qvy2=zeros([f3(6)+1,f3(5),f2(2)-1]);
qvx2=zeros([f3(6),f3(5)+1,f2(2)-1]);
qvy3=zeros([f3(6)+1,f3(5),f2(2)-1]);
qvx3=zeros([f3(6),f3(5)+1,f2(2)-1]);
qvy4=zeros([f3(6)+1,f3(5),f2(2)-1]);
qvx4=zeros([f3(6),f3(5)+1,f2(2)-1]);
qvy5=zeros([f3(6)+1,f3(5),f2(2)-1]);
qvx5=zeros([f3(6),f3(5)+1,f2(2)-1]);




%% --------read the first .nod file ----------
if char(f1{1,1}(3,1))~='#'
cd (char(f1{1,1}(3,1)))   % going to the folder
end
if f2(2)~=0
nod=[char(f1{1,1}(1,1)),'.NOD'];
fn=fopen(nod);
%-how can I improve this ?   for header
for i=1:12
  line=fgetl(fn);
end
temp=fscanf(fn, '%*s %g %g %*s %*g %*s %*g %*s %*g', [2 f2(2)]);
ta(1:2,:)=temp(1:2,2:f2(2));
ta(2,:)=ta(2,:)/86400; %changing time from seconds to day
line=fgetl(fn);
for j=1:f2(2)
  %sub header in each output
  for i=1:5
    line1(i,j)={fgetl(fn)};
  end
  if j==1
      % jump the first round
      temp=fscanf(fn, '%*g %*g %*g %*g %g %g %*g %g %*g %*g %*g %*g', [3 f3(1)]);
      temp={fgetl(fn)};
      % it is funny that if I let temp to read the first line it is going
      % to be problematic, the algorithm of fscanf is design
  else
      a1([1:6 10:13],:,j-1)=fscanf(fn, '%*g %g %g %g %g %g %g %g %g %g %*g %g', [10 f3(1)]);
      line=fgetl(fn);   %if the last column is not captured, it
      %requires to use the previous line
      a1(13,:,j-1)=a1(13,:,j-1)-273.15; %change the temperature unit from kelven to celsius
      a1(7,:,j-1)=a1(3,:,j-1)/9.81./(1000+702.24*(a1(4,:,j-1)-0.0001))+a1(2,:,j-1);     % calculating the total head
  end

end %j
fclose(fn);
temp=0;
fprintf(1,'First .NOD file reading finished\n');
end
%% -------------read first .ele------------
if f2(1)~=0
temp=zeros([4,f3(2)]);
nod=[char(f1{1,1}(1,1)),'.ELE'];
fn=fopen(nod);
% head read
for i=1:(f2(1)+12)
  line=fgetl(fn);
end
for j=1:f2(1)   %j
  %sub header in each output
  for i=1:5
    line2(i,j)={fgetl(fn)};
  end
  % data read
  if j==1
    temp=fscanf(fn, '%*g %g %g %g %g %g %g %g %g %g %g %g', [11 f3(2)]);
  %  xye only needs to be recorded at the first time step
    xye(:,:)=temp(1:2,:);
    b1(1:9,:,j)=temp(3:11,:);
    temp={fgetl(fn)};
  else
    b1(1:9,:,j)=fscanf(fn, '%*g %*g %*g %g %g %g %g %g %g %g %g %g', [9 f3(2)]);
    temp={fgetl(fn)};
  end
end   %j
fclose(fn);
temp=0;
fprintf(1,'First .ELE file reading finished\n');
end

%% ------------------read first .bcof----------------
if f2(4)~=0
nod=[char(f1{1,1}(1,1)),'.BCOF'];
fn=fopen(nod);
for i=1:12
  line=fgetl(fn);
end
temp=fscanf(fn, '%*s %g %g ', [2 f2(4)]);
tf1(1:2,:)=temp;
tf1(2,:)=tf1(2,:)/86400;
for j=1:f2(4)   %j
  %sub header in each output
  for i=1:7
    line3(i,j)={fgetl(fn)};
  end
  % data read
  if j==1
    temp=fscanf(fn, '%g %*s %*s %g %g %g %g %g %g ', [7 f3(4)]);
  %  xye only needs to be recorded at the first time step
    xyf(1:3,:)=temp([1,5:6],:);
    bcof1(1:3,:,j)=temp(2:4,:);
  else
    bcof1(1:3,:,j)=fscanf(fn, '%*g %*s %*s %g %g %g %*g %*g %*g', [3 f3(4)]);
    temp={fgetl(fn)};
  end
end   %j
fclose(fn);
temp=0;
fprintf(1,'First .BCOF file reading finished\n');
end
%% ------------------read the first .bcop----------------
if f2(3)~=0
temp=0;
nod=[char(f1{1,1}(1,1)),'.BCOP'];
fn=fopen(nod);
for i=1:12
  line=fgetl(fn);
end
temp=fscanf(fn, '%*s %g %g ', [2 f2(3)]);
% tbp(1,time steps) time steps
% tbp(2,time steps) actual time (days)
% tbp(3,time steps) sink suction rate (mm/day)
tbp1(1:2,:)=temp;
tbp1(2,:)=tbp1(2,:)/86400;           %tbp1(time step, real time (day),
for j=1:f2(3)   %j
  %sub header in each output
  for i=1:7
    line4(i,j)={fgetl(fn)};
  end
  % data read
  if j==1
    temp=fscanf(fn, '%g %*s %*s %g %g %g %*g %*g %g %g %*g', [6 f3(3)]);
  %  xye only needs to be recorded at the first time step
    xyp(:,:)=temp([1,5:6],:);
    p1(1:3,:,j)=temp(2:4,:);
    line=fgetl(fn);
  else
    p1(1:3,:,j)=fscanf(fn, '%*g %*s %*s %g %g %g %*g %*g %*g %*g %*g', [3 f3(3)]);
    temp={fgetl(fn)};
  end
     %b3=f(:,:,j);   %this line is just for checking
end   %j
fclose(fn);
temp=0;
fprintf(1,'First .BCOP file reading finished\n');
end
%% ------------------read first bco.dat for evaporation rate opt--------------
if f2(8)~=0
temp=0;    
fn=fopen('BCO.DAT');
line=fgetl(fn);
temp=fscanf(fn, '%*g %*g %*g %*g %g %g %g %g %g %g ', [6 f3(4)]);  % NODE, X,Y,Z,XX,YY,HAREA,VAREA,FAREA,R
xyf(4:6,:)=temp(3:5,:); 
% xyf(1,source/sink node number) node sequence
% xyf(2,source/sink node number) x position
% xyf(3,source/sink node number) y position
% xyf(4,source/sink node number) area of each node in xy panel
% xyf(5,source/sink node number) area of node in yz panel (varea)
% xyf(6,source/sink node number) area of node in xy panel (farea)
xyr=temp([1:2,6],:);
% xyr(1, source/sink node number) is xx
% xyr(2, source/sink node number) is yy
% xyr(3, source/sink node number) is R in cylindrical coordinate

% how to vectorize it?
% calculating evaporation rate
% the disadvantage of this method is that the next node could also be affected by 
% the node below.
% so to some extent the result from .bcof is kind of useless
% instead, the best way of getting the accumulative evaporation rate is from et1 
%for i=1:f2(4)                          % time step increasement
%tf1(3,i)=sum(bcof1(1,1:6,i)./xyf(4,1:6));
%end
%tf1(3,:)=tf1(3,:)*86400/(f3(6)+1);      % f3(6) is the overall node on the surface

% further read about the evaporation rate
line=fgetl(fn);

% the format of %g can be less than the numbers in the [  ]. in that case, the data obtain will repeat using the pattern given by %g. 
temp=fscanf(fn, '%g', [(nnh+2) f2(8)]); % here using only one %g would be enough
% notice: temp here stores the evaporation rate at all time steps, which is important to obtain the precise
% result for the accumulative evaporation. however, et1 only stores the evaporation rate at perticular snapshot
% this is due to too large array size.

et1(1,:)=ta(2,:);
aet1(1,:)=ta(2,:);
for i=1:f2(1)  % loop for each snapshot
   if i==1
       et1(2:nnh+1,i)=-temp(3:nnh+2,ta(1,i))*3600*24*1000;   %3600*24*1000 changes the unit from m/s to mm/day
       aet1(2:nnh+1,i)=-temp(3:nnh+2,ta(1,i))*f4(3)*1000;   % unit (mm), 1000 is used to change the unit from m to mm
   else
       et1(2:nnh+1,i)=-temp(3:nnh+2,ta(1,i))*3600*24*1000;   % unit mm/day
       aet1(2:nnh+1,i)=aet1(2:nnh+1,i-1)-sum( temp(3:nnh+2,ta(1,i-1)+1:ta(1,i))  ,2) *f4(3)*1000;
   end
end
% avet1 -- the accumulated evaporation on the whole surface. algorithm= et*area/whole area
avet1=(xyf(4,1:nnh)*aet1(2:(f3(6)+2),:))/sum(xyf(4,1:nnh));
% et1=temp(2:nnh+2,1:f2(8));  % delete the first line
% et1(2:(f3(6)+2),:)=-et1(2:(f3(6)+2),:).*(3600*24*1000); %change m/s to mm/day

% -- calculate the accumulative evaporation rate, then store it in aet1, this is used in the figure of accumulative 
%  evaporation rate
% aet1(1,:) % duration of the time snapshot
% aet1(2,:) % accumulative evaporation rate from the whole surface, (mm) remember, this result is regardless of the area.



%aet1(1,:)=et1(1,:);
%for i=1:f2(1)   % time step loops
%   if i==1
%    aet1(2:(f3(6)+2),i)=et1(2:(f3(6)+2),i)*et1(1,i); % et1(1,:) is duration (day)
%   else
%    aet1(2:(f3(6)+2),i)=aet1(2:(f3(6)+2),i-1)+et1(2:(f3(6)+2),i)*(et1(1,i)-et1(1,i-1));
%   end
%end

fprintf(1,'First bco.dat file reading finished\n');
end
%% -------------read first qv.dat----------------------------
fn=fopen('QV.DAT');
   line=fgetl(fn);
for i=2:f2(2)-1
   line3(i)={fgetl(fn)};
   qvx1(:,:,i)=fscanf(fn, '%g %g ', [f3(6),f3(5)+1]);
   qvy1(:,:,i)=fscanf(fn, '%g %g %g ',[f3(6)+1,f3(5)]);
   %line=fgetl(fn);
end
%% -----------calculating the first drying front location----------
if f2(10)~=0
    % ef(1,1:SWELE) is the time of the output (day)
    % ef(2:(f3(5)+2),1:SWELE) is the position of the drying front
    ef1=zeros(f3(6)+2,f2(1));  % initialize the size of ef
    ef1(1,:)=ta(2,:);   
    
    for k=1:(f3(6)+1)   % loop of node on x direction
    
    for i=1:f2(1)   % loop for 
      for j=1:f3(5)+1
          if a1(5,k*(f3(5)+1)-j+1,i)>=f2(10)     % warning: this check is from the top of the column to the bottom
              ef1(k+1,i)=a1(2,k*(f3(5)+1)-j+1,i);
              break
          end
      end
    end
    
    end
end

fprintf(1,'First qv.dat file reading finished\n');
%% --going back to the original folder---
if char(f1{1,1}(3,1))~='#'
cd ('..')
end
%% --------read the second .nod file ----------

if char(f1{1,1}(4,1))~='#'
cd (char(f1{1,1}(4,1)))
if f2(2)~=0
nod=[char(f1{1,1}(1,1)),'.NOD'];
fn=fopen(nod);
%-how can I improve this ?   for header
for i=1:12
  line=fgetl(fn);
end
temp=fscanf(fn, '%*s %g %g %*s %*g %*s %*g %*s %*g', [2 f2(2)]);
ta(1:2,:)=temp(1:2,2:f2(2));
ta(2,:)=ta(2,:)/86400; %changing time from seconds to day
line=fgetl(fn);
for j=1:f2(2)
  %sub header in each output
  for i=1:5
    line1(i,j)={fgetl(fn)};
  end
  if j==1
      % jump the first round
      temp=fscanf(fn, '%*g %*g %*g %*g %g %g %*g %g %*g %*g %*g %*g', [3 f3(1)]);
      temp={fgetl(fn)};
      % it is funny that if I let temp to read the first line it is going
      % to be problematic, the algorithm of fscanf is design
  else
      a2([1:6 10:13],:,j-1)=fscanf(fn, '%*g %g %g %g %g %g %g %g %g %g %*g %g', [10 f3(1)]);
      line=fgetl(fn);   %if the last column is not captured, it
      %requires to use the previous line
      a2(13,:,j-1)=a2(13,:,j-1)-273.15; %change the temperature unit from kelven to celsius
      a2(7,:,j-1)=a2(3,:,j-1)/9.81./(1000+702.24*(a2(4,:,j-1)-0.0001))+a2(2,:,j-1);     % calculating the total head
  end

end %j
fclose(fn);
temp=0;
fprintf(1,'Second .NOD file reading finished\n');
end
%% -------------read Second .ele------------
if f2(1)~=0
temp=zeros([4,f3(2)]);
nod=[char(f1{1,1}(1,1)),'.ELE'];
fn=fopen(nod);
% head read
for i=1:(f2(1)+12)
  line=fgetl(fn);
end
for j=1:f2(1)   %j
  %sub header in each output
  for i=1:5
    line2(i,j)={fgetl(fn)};
  end
  % data read
  if j==1
    temp=fscanf(fn, '%*g %g %g %g %g %g %g %g %g %g %g %g', [11 f3(2)]);
  %  xye only needs to be recorded at the first time step
    xye(:,:)=temp(1:2,:);
    b2(1:9,:,j)=temp(3:11,:);
    temp={fgetl(fn)};
  else
    b1(1:9,:,j)=fscanf(fn, '%*g %*g %*g %g %g %g %g %g %g %g %g %g', [9 f3(2)]);
    temp={fgetl(fn)};
  end
end   %j
fclose(fn);
temp=0;
fprintf(1,'Second .ELE file reading finished\n');
end

%% ------------------read second .bcof----------------
if f2(4)~=0
nod=[char(f1{1,1}(1,1)),'.BCOF'];
fn=fopen(nod);
for i=1:12
  line=fgetl(fn);
end
temp=fscanf(fn, '%*s %g %g ', [2 f2(4)]);
tf2(1:2,:)=temp;
tf2(2,:)=tf2(2,:)/86400;
for j=1:f2(4)   %j
  %sub header in each output
  for i=1:7
    line3(i,j)={fgetl(fn)};
  end
  % data read
  if j==1
    temp=fscanf(fn, '%g %*s %*s %g %g %g %g %g %g ', [7 f3(4)]);
  %  xye only needs to be recorded at the first time step
    xyf(1:3,:)=temp([1,5:6],:);
    bcof2(1:3,:,j)=temp(2:4,:);
  else
    bcof2(1:3,:,j)=fscanf(fn, '%*g %*s %*s %g %g %g %*g %*g %*g', [3 f3(4)]);
    temp={fgetl(fn)};
  end
end   %j
fclose(fn);
temp=0;
fprintf(1,'second .BCOF file reading finished\n');
end
%% ------------------read the second .bcop----------------
if f2(3)~=0
temp=0;
nod=[char(f1{1,1}(1,1)),'.BCOP'];
fn=fopen(nod);
for i=1:12
  line=fgetl(fn);
end
temp=fscanf(fn, '%*s %g %g ', [2 f2(3)]);
% tbp(1,time steps) time steps
% tbp(2,time steps) actual time (days)
% tbp(3,time steps) sink suction rate (mm/day)
tbp2(1:2,:)=temp;
tbp2(2,:)=tbp2(2,:)/86400;           %tbp1(time step, real time (day),
for j=1:f2(3)   %j
  %sub header in each output
  for i=1:7
    line4(i,j)={fgetl(fn)};
  end
  % data read
  if j==1
    temp=fscanf(fn, '%g %*s %*s %g %g %g %*g %*g %g %g %*g', [6 f3(3)]);
  %  xye only needs to be recorded at the first time step
    xyp(:,:)=temp([1,5:6],:);
    p2(1:3,:,j)=temp(2:4,:);
    line=fgetl(fn);
  else
    p2(1:3,:,j)=fscanf(fn, '%*g %*s %*s %g %g %g %*g %*g %*g %*g %*g', [3 f3(3)]);
    temp={fgetl(fn)};
  end
     %b3=f(:,:,j);   %this line is just for checking
end   %j
fclose(fn);
temp=0;
fprintf(1,'second .BCOP file reading finished\n');
end
%% ------------------read second bco.dat for evaporation rate opt--------------
if f2(8)~=0
temp=0;    
fn=fopen('BCO.DAT');
line=fgetl(fn);
temp=fscanf(fn, '%*g %*g %*g %*g %g %g %g %g %g %g ', [6 f3(4)]);  % NODE, X,Y,Z,XX,YY,HAREA,VAREA,FAREA,R
xyf(4:6,:)=temp(3:5,:); 
% xyf(1,source/sink node number) node sequence
% xyf(2,source/sink node number) x position
% xyf(3,source/sink node number) y position
% xyf(4,source/sink node number) area of each node in xy panel
% xyf(5,source/sink node number) area of node in yz panel (varea)
% xyf(6,source/sink node number) area of node in xy panel (farea)
xyr=temp([1:2,6],:);
% xyr(1, source/sink node number) is xx
% xyr(2, source/sink node number) is yy
% xyr(3, source/sink node number) is R in cylindrical coordinate

% how to vectorize it?
% calculating evaporation rate
% the disadvantage of this method is that the next node could also be affected by 
% the node below.
% so to some extent the result from .bcof is kind of useless
% instead, the best way of getting the accumulative evaporation rate is from et1 
%for i=1:f2(4)                          % time step increasement
%tf1(3,i)=sum(bcof1(1,1:6,i)./xyf(4,1:6));
%end
%tf1(3,:)=tf1(3,:)*86400/(f3(6)+1);      % f3(6) is the overall node on the surface

% further read about the evaporation rate
line=fgetl(fn);

% the format of %g can be less than the numbers in the [  ]. in that case, the data obtain will repeat using the pattern given by %g. 
temp=fscanf(fn, '%g', [(nnh+2) f2(8)]); % here using only one %g would be enough
% notice: temp here stores the evaporation rate at all time steps, which is important to obtain the precise
% result for the accumulative evaporation. however, et1 only stores the evaporation rate at perticular snapshot
% this is due to too large array size.

et2(1,:)=ta(2,:);
aet2(1,:)=ta(2,:);
for i=1:f2(1)  % loop for each snapshot
   if i==1
       et2(2:nnh+1,i)=-temp(3:nnh+2,ta(1,i))*3600*24*1000;   %3600*24*1000 changes the unit from m/s to mm/day
       aet2(2:nnh+1,i)=-temp(3:nnh+2,ta(1,i))*f4(3)*1000;   % unit (mm), 1000 is used to change the unit from m to mm
   else
       et2(2:nnh+1,i)=-temp(3:nnh+2,ta(1,i))*3600*24*1000;   % unit mm/day
       aet2(2:nnh+1,i)=aet2(2:nnh+1,i-1)-sum( temp(3:nnh+2,ta(1,i-1)+1:ta(1,i))  ,2) *f4(3)*1000;
   end
end
%avet2=sum(aet2(2:(f3(6)+2),:),1)/(f3(6)+1);
avet2=(xyf(4,1:nnh)*aet2(2:(f3(6)+2),:))/sum(xyf(4,1:nnh));
% et1=temp(2:nnh+2,1:f2(8));  % delete the first line
% et1(2:(f3(6)+2),:)=-et1(2:(f3(6)+2),:).*(3600*24*1000); %change m/s to mm/day

% -- calculate the accumulative evaporation rate, then store it in aet1, this is used in the figure of accumulative 
%  evaporation rate
% aet1(1,:) % duration of the time snapshot
% aet1(2,:) % accumulative evaporation rate from the whole surface, (mm) remember, this result is regardless of the area.



%aet1(1,:)=et1(1,:);
%for i=1:f2(1)   % time step loops
%   if i==1
%    aet1(2:(f3(6)+2),i)=et1(2:(f3(6)+2),i)*et1(1,i); % et1(1,:) is duration (day)
%   else
%    aet1(2:(f3(6)+2),i)=aet1(2:(f3(6)+2),i-1)+et1(2:(f3(6)+2),i)*(et1(1,i)-et1(1,i-1));
%   end
%end

fprintf(1,'Second bco.dat file reading finished\n');
end
%% -------------read Second qv.dat----------------------------
fn=fopen('QV.DAT');
   line=fgetl(fn);
for i=2:f2(2)-1
   line3(i)={fgetl(fn)};
   qvx2(:,:,i)=fscanf(fn, '%g %g ', [f3(6),f3(5)+1]);
   qvy2(:,:,i)=fscanf(fn, '%g %g %g ',[f3(6)+1,f3(5)]);
   %line=fgetl(fn);
end
%% -----------calculating the first drying front location----------
if f2(10)~=0
    % ef(1,1:SWELE) is the time of the output (day)
    % ef(2:(f3(5)+2),1:SWELE) is the position of the drying front
    ef2=zeros(f3(6)+2,f2(1));  % initialize the size of ef
    ef2(1,:)=ta(2,:);   
    
    for k=1:(f3(6)+1)   % loop of node on x direction
    
    for i=1:f2(1)   % loop for 
      for j=1:f3(5)+1
          if a2(5,k*(f3(5)+1)-j+1,i)>=f2(10)     % warning: this check is from the top of the column to the bottom
              ef2(k+1,i)=a2(2,k*(f3(5)+1)-j+1,i);
              break
          end
      end
    end
    
    end
end

fprintf(1,'Second qv.dat file reading finished\n');
cd ('..')
end

%% --------read the Third .nod file ----------
if char(f1{1,1}(5,1))~='#'
cd (char(f1{1,1}(5,1)))
if f2(2)~=0
nod=[char(f1{1,1}(1,1)),'.NOD'];
fn=fopen(nod);
%-how can I improve this ?   for header
for i=1:12
  line=fgetl(fn);
end
temp=fscanf(fn, '%*s %g %g %*s %*g %*s %*g %*s %*g', [2 f2(2)]);
ta(1:2,:)=temp(1:2,2:f2(2));
ta(2,:)=ta(2,:)/86400; %changing time from seconds to day
line=fgetl(fn);
for j=1:f2(2)
  %sub header in each output
  for i=1:5
    line1(i,j)={fgetl(fn)};
  end
  if j==1
      % jump the first round
      temp=fscanf(fn, '%*g %*g %*g %*g %g %g %*g %g %*g %*g %*g %*g', [3 f3(1)]);
      temp={fgetl(fn)};
      % it is funny that if I let temp to read the first line it is going
      % to be problematic, the algorithm of fscanf is design
  else
      a3([1:6 10:13],:,j-1)=fscanf(fn, '%*g %g %g %g %g %g %g %g %g %g %*g %g', [10 f3(1)]);
      line=fgetl(fn);   %if the last column is not captured, it
      %requires to use the previous line
      a3(13,:,j-1)=a3(13,:,j-1)-273.15; %change the temperature unit from kelven to celsius
      a3(7,:,j-1)=a3(3,:,j-1)/9.81./(1000+702.24*(a3(4,:,j-1)-0.0001))+a3(2,:,j-1);     % calculating the total head
  end

end %j
fclose(fn);
temp=0;
fprintf(1,'Third .NOD file reading finished\n');
end
%% -------------read third .ele------------
if f2(1)~=0
temp=zeros([4,f3(2)]);
nod=[char(f1{1,1}(1,1)),'.ELE'];
fn=fopen(nod);
% head read
for i=1:(f2(1)+12)
  line=fgetl(fn);
end
for j=1:f2(1)   %j
  %sub header in each output
  for i=1:5
    line2(i,j)={fgetl(fn)};
  end
  % data read
  if j==1
   temp=fscanf(fn, '%*g %g %g %g %g %g %g %g %g %g %g %g', [11 f3(2)]);
  %  xye only needs to be recorded at the first time step
    xye(:,:)=temp(1:2,:);
    b3(1:9,:,j)=temp(3:11,:);
    temp={fgetl(fn)};
  else
    b1(1:9,:,j)=fscanf(fn, '%*g %*g %*g %g %g %g %g %g %g %g %g %g', [9 f3(2)]);
    temp={fgetl(fn)};
  end
end   %j
fclose(fn);
temp=0;
fprintf(1,'Third .ELE file reading finished\n');
end

%% ------------------read third .bcof----------------
if f2(4)~=0
nod=[char(f1{1,1}(1,1)),'.BCOF'];
fn=fopen(nod);
for i=1:12
  line=fgetl(fn);
end
temp=fscanf(fn, '%*s %g %g ', [2 f2(4)]);
tf3(1:2,:)=temp;
tf3(2,:)=tf3(2,:)/86400;
for j=1:f2(4)   %j
  %sub header in each output
  for i=1:7
    line3(i,j)={fgetl(fn)};
  end
  % data read
  if j==1
    temp=fscanf(fn, '%g %*s %*s %g %g %g %g %g %g ', [7 f3(4)]);
  %  xye only needs to be recorded at the first time step
    xyf(1:3,:)=temp([1,5:6],:);
    bcof3(1:3,:,j)=temp(2:4,:);
  else
    bcof3(1:3,:,j)=fscanf(fn, '%*g %*s %*s %g %g %g %*g %*g %*g', [3 f3(4)]);
    temp={fgetl(fn)};
  end
end   %j
fclose(fn);
temp=0;
fprintf(1,'Third .BCOF file reading finished\n');
end
%% ------------------read the third .bcop----------------
if f2(3)~=0
temp=0;
nod=[char(f1{1,1}(1,1)),'.BCOP'];
fn=fopen(nod);
for i=1:12
  line=fgetl(fn);
end
temp=fscanf(fn, '%*s %g %g ', [2 f2(3)]);
% tbp(1,time steps) time steps
% tbp(2,time steps) actual time (days)
% tbp(3,time steps) sink suction rate (mm/day)
tbp3(1:2,:)=temp;
tbp3(2,:)=tbp3(2,:)/86400;           %tbp1(time step, real time (day),
for j=1:f2(3)   %j
  %sub header in each output
  for i=1:7
    line4(i,j)={fgetl(fn)};
  end
  % data read
  if j==1
    temp=fscanf(fn, '%g %*s %*s %g %g %g %*g %*g %g %g %*g', [6 f3(3)]);
  %  xye only needs to be recorded at the first time step
    xyp(:,:)=temp([1,5:6],:);
    p3(1:3,:,j)=temp(2:4,:);
    line=fgetl(fn);
  else
    p3(1:3,:,j)=fscanf(fn, '%*g %*s %*s %g %g %g %*g %*g %*g %*g %*g', [3 f3(3)]);
    temp={fgetl(fn)};
  end
     %b3=f(:,:,j);   %this line is just for checking
end   %j
fclose(fn);
temp=0;
fprintf(1,'First .BCOP file reading finished\n');
end
%% ------------------read third bco.dat for evaporation rate opt--------------
if f2(8)~=0
temp=0;    
fn=fopen('BCO.DAT');
line=fgetl(fn);
temp=fscanf(fn, '%*g %*g %*g %*g %g %g %g %g %g %g ', [6 f3(4)]);  % NODE, X,Y,Z,XX,YY,HAREA,VAREA,FAREA,R
xyf(4:6,:)=temp(3:5,:); 
% xyf(1,source/sink node number) node sequence
% xyf(2,source/sink node number) x position
% xyf(3,source/sink node number) y position
% xyf(4,source/sink node number) area of each node in xy panel
% xyf(5,source/sink node number) area of node in yz panel (varea)
% xyf(6,source/sink node number) area of node in xy panel (farea)
xyr=temp([1:2,6],:);
% xyr(1, source/sink node number) is xx
% xyr(2, source/sink node number) is yy
% xyr(3, source/sink node number) is R in cylindrical coordinate

% how to vectorize it?
% calculating evaporation rate
% the disadvantage of this method is that the next node could also be affected by 
% the node below.
% so to some extent the result from .bcof is kind of useless
% instead, the best way of getting the accumulative evaporation rate is from et1 
%for i=1:f2(4)                          % time step increasement
%tf1(3,i)=sum(bcof1(1,1:6,i)./xyf(4,1:6));
%end
%tf1(3,:)=tf1(3,:)*86400/(f3(6)+1);      % f3(6) is the overall node on the surface

% further read about the evaporation rate
line=fgetl(fn);

% the format of %g can be less than the numbers in the [  ]. in that case, the data obtain will repeat using the pattern given by %g. 
temp=fscanf(fn, '%g', [(nnh+2) f2(8)]); % here using only one %g would be enough
% notice: temp here stores the evaporation rate at all time steps, which is important to obtain the precise
% result for the accumulative evaporation. however, et1 only stores the evaporation rate at perticular snapshot
% this is due to too large array size.

et3(1,:)=ta(2,:);
aet3(1,:)=ta(2,:);
for i=1:f2(1)  % loop for each snapshot
   if i==1
       et3(2:nnh+1,i)=-temp(3:nnh+2,ta(1,i))*3600*24*1000;   %3600*24*1000 changes the unit from m/s to mm/day
       aet3(2:nnh+1,i)=-temp(3:nnh+2,ta(1,i))*f4(3)*1000;   % unit (mm), 1000 is used to change the unit from m to mm
   else
       et3(2:nnh+1,i)=-temp(3:nnh+2,ta(1,i))*3600*24*1000;   % unit mm/day
       aet3(2:nnh+1,i)=aet3(2:nnh+1,i-1)-sum( temp(3:nnh+2,ta(1,i-1)+1:ta(1,i))  ,2) *f4(3)*1000;
   end
end
%avet3=sum(aet3(2:(f3(6)+2),:),1)/(f3(6)+1);
avet3=(xyf(4,1:nnh)*aet3(2:(f3(6)+2),:))/sum(xyf(4,1:nnh));
% et1=temp(2:nnh+2,1:f2(8));  % delete the first line
% et1(2:(f3(6)+2),:)=-et1(2:(f3(6)+2),:).*(3600*24*1000); %change m/s to mm/day

% -- calculate the accumulative evaporation rate, then store it in aet1, this is used in the figure of accumulative 
%  evaporation rate
% aet1(1,:) % duration of the time snapshot
% aet1(2,:) % accumulative evaporation rate from the whole surface, (mm) remember, this result is regardless of the area.



%aet1(1,:)=et1(1,:);
%for i=1:f2(1)   % time step loops
%   if i==1
%    aet1(2:(f3(6)+2),i)=et1(2:(f3(6)+2),i)*et1(1,i); % et1(1,:) is duration (day)
%   else
%    aet1(2:(f3(6)+2),i)=aet1(2:(f3(6)+2),i-1)+et1(2:(f3(6)+2),i)*(et1(1,i)-et1(1,i-1));
%   end
%end

fprintf(1,'Third bco.dat file reading finished\n');
end
%% -------------read third qv.dat----------------------------
fn=fopen('QV.DAT');
   line=fgetl(fn);
for i=2:f2(2)-1
   line3(i)={fgetl(fn)};
   qvx1(:,:,i)=fscanf(fn, '%g %g ', [f3(6),f3(5)+1]);
   qvy1(:,:,i)=fscanf(fn, '%g %g %g ',[f3(6)+1,f3(5)]);
   %line=fgetl(fn);
end
%% -----------calculating the first drying front location----------
if f2(10)~=0
    % ef(1,1:SWELE) is the time of the output (day)
    % ef(2:(f3(5)+2),1:SWELE) is the position of the drying front
    ef3=zeros(f3(6)+2,f2(1));  % initialize the size of ef
    ef3(1,:)=ta(2,:);   
    
    for k=1:(f3(6)+1)   % loop of node on x direction
    
    for i=1:f2(1)   % loop for 
      for j=1:f3(5)+1
          if a3(5,k*(f3(5)+1)-j+1,i)>=f2(10)     % warning: this check is from the top of the column to the bottom
              ef3(k+1,i)=a3(2,k*(f3(5)+1)-j+1,i);
              break
          end
      end
    end
    
    end
end
fprintf(1,'Third qv.dat file reading finished\n');
cd ('..')
end
%% fourth
%% --------read the Fourth .nod file ----------
if char(f1{1,1}(6,1))~='#'
cd (char(f1{1,1}(6,1)))
if f2(2)~=0
nod=[char(f1{1,1}(1,1)),'.NOD'];
fn=fopen(nod);
%-how can I improve this ?   for header
for i=1:12
  line=fgetl(fn);
end
temp=fscanf(fn, '%*s %g %g %*s %*g %*s %*g %*s %*g', [2 f2(2)]);
ta(1:2,:)=temp(1:2,2:f2(2));
ta(2,:)=ta(2,:)/86400; %changing time from seconds to day
line=fgetl(fn);
for j=1:f2(2)
  %sub header in each output
  for i=1:5
    line1(i,j)={fgetl(fn)};
  end
  if j==1
      % jump the first round
      temp=fscanf(fn, '%*g %*g %*g %*g %g %g %*g %g %*g %*g %*g %*g', [3 f3(1)]);
      temp={fgetl(fn)};
      % it is funny that if I let temp to read the first line it is going
      % to be problematic, the algorithm of fscanf is design
  else
      a4([1:6 10:13],:,j-1)=fscanf(fn, '%*g %g %g %g %g %g %g %g %g %g %*g %g', [10 f3(1)]);
      line=fgetl(fn);   %if the last column is not captured, it
      %requires to use the previous line
      a4(13,:,j-1)=a4(13,:,j-1)-273.15; %change the temperature unit from kelven to celsius
      a4(7,:,j-1)=a4(3,:,j-1)/9.81./(1000+702.24*(a4(4,:,j-1)-0.0001))+a4(2,:,j-1);     % calculating the total head
  end

end %j
fclose(fn);
temp=0;
fprintf(1,'Fourth .NOD file reading finished\n');
end
%% -------------read Fourth .ele------------
if f2(1)~=0
temp=zeros([4,f3(2)]);
nod=[char(f1{1,1}(1,1)),'.ELE'];
fn=fopen(nod);
% head read
for i=1:(f2(1)+12)
  line=fgetl(fn);
end
for j=1:f2(1)   %j
  %sub header in each output
  for i=1:5
    line2(i,j)={fgetl(fn)};
  end
  % data read
  if j==1
temp=fscanf(fn, '%*g %g %g %g %g %g %g %g %g %g %g %g', [11 f3(2)]);
  %  xye only needs to be recorded at the first time step
    xye(:,:)=temp(1:2,:);
    b4(1:9,:,j)=temp(3:11,:);
    temp={fgetl(fn)};
  else
    b1(1:9,:,j)=fscanf(fn, '%*g %*g %*g %g %g %g %g %g %g %g %g %g', [9 f3(2)]);
    temp={fgetl(fn)};
  end
end   %j
fclose(fn);
temp=0;
fprintf(1,'Fourth .ELE file reading finished\n');
end

%% ------------------read Fourth .bcof----------------
if f2(4)~=0
nod=[char(f1{1,1}(1,1)),'.BCOF'];
fn=fopen(nod);
for i=1:12
  line=fgetl(fn);
end
temp=fscanf(fn, '%*s %g %g ', [2 f2(4)]);
tf4(1:2,:)=temp;
tf4(2,:)=tf4(2,:)/86400;
for j=1:f2(4)   %j
  %sub header in each output
  for i=1:7
    line3(i,j)={fgetl(fn)};
  end
  % data read
  if j==1
    temp=fscanf(fn, '%g %*s %*s %g %g %g %g %g %g ', [7 f3(4)]);
  %  xye only needs to be recorded at the first time step
    xyf(1:3,:)=temp([1,5:6],:);
    bcof4(1:3,:,j)=temp(2:4,:);
  else
    bcof4(1:3,:,j)=fscanf(fn, '%*g %*s %*s %g %g %g %*g %*g %*g', [3 f3(4)]);
    temp={fgetl(fn)};
  end
end   %j
fclose(fn);
temp=0;
fprintf(1,'Fourth .BCOF file reading finished\n');
end



%% ------------------read the Fourth .bcop----------------
if f2(3)~=0
temp=0;
nod=[char(f1{1,1}(1,1)),'.BCOP'];
fn=fopen(nod);
for i=1:12
  line=fgetl(fn);
end
temp=fscanf(fn, '%*s %g %g ', [2 f2(3)]);
% tbp(1,time steps) time steps
% tbp(2,time steps) actual time (days)
% tbp(3,time steps) sink suction rate (mm/day)
tbp4(1:2,:)=temp;
tbp4(2,:)=tbp4(2,:)/86400;           %tbp1(time step, real time (day),
for j=1:f2(3)   %j
  %sub header in each output
  for i=1:7
    line4(i,j)={fgetl(fn)};
  end
  % data read
  if j==1
    temp=fscanf(fn, '%g %*s %*s %g %g %g %*g %*g %g %g %*g', [6 f3(3)]);
  %  xye only needs to be recorded at the first time step
    xyp(:,:)=temp([1,5:6],:);
    p4(1:3,:,j)=temp(2:4,:);
    line=fgetl(fn);
  else
    p4(1:3,:,j)=fscanf(fn, '%*g %*s %*s %g %g %g %*g %*g %*g %*g %*g', [3 f3(3)]);
    temp={fgetl(fn)};
  end
     %b3=f(:,:,j);   %this line is just for checking
end   %j
fclose(fn);
temp=0;
fprintf(1,'Fourth .BCOP file reading finished\n');
end
%% ------------------read first bco.dat for evaporation rate opt--------------
if f2(8)~=0
temp=0;    
fn=fopen('BCO.DAT');
line=fgetl(fn);
temp=fscanf(fn, '%*g %*g %*g %*g %g %g %g %g %g %g ', [6 f3(4)]);  % NODE, X,Y,Z,XX,YY,HAREA,VAREA,FAREA,R
xyf(4:6,:)=temp(3:5,:); 
% xyf(1,source/sink node number) node sequence
% xyf(2,source/sink node number) x position
% xyf(3,source/sink node number) y position
% xyf(4,source/sink node number) area of each node in xy panel
% xyf(5,source/sink node number) area of node in yz panel (varea)
% xyf(6,source/sink node number) area of node in xy panel (farea)
xyr=temp([1:2,6],:);
% xyr(1, source/sink node number) is xx
% xyr(2, source/sink node number) is yy
% xyr(3, source/sink node number) is R in cylindrical coordinate

% how to vectorize it?
% calculating evaporation rate
% the disadvantage of this method is that the next node could also be affected by 
% the node below.
% so to some extent the result from .bcof is kind of useless
% instead, the best way of getting the accumulative evaporation rate is from et1 
%for i=1:f2(4)                          % time step increasement
%tf1(3,i)=sum(bcof1(1,1:6,i)./xyf(4,1:6));
%end
%tf1(3,:)=tf1(3,:)*86400/(f3(6)+1);      % f3(6) is the overall node on the surface

% further read about the evaporation rate
line=fgetl(fn);

% the format of %g can be less than the numbers in the [  ]. in that case, the data obtain will repeat using the pattern given by %g. 
temp=fscanf(fn, '%g', [(nnh+2) f2(8)]); % here using only one %g would be enough
% notice: temp here stores the evaporation rate at all time steps, which is important to obtain the precise
% result for the accumulative evaporation. however, et1 only stores the evaporation rate at perticular snapshot
% this is due to too large array size.

et4(1,:)=ta(2,:);
aet4(1,:)=ta(2,:);
for i=1:f2(1)  % loop for each snapshot
   if i==1
       et4(2:nnh+1,i)=-temp(3:nnh+2,ta(1,i))*3600*24*1000;   %3600*24*1000 changes the unit from m/s to mm/day
       aet4(2:nnh+1,i)=-temp(3:nnh+2,ta(1,i))*f4(3)*1000;   % unit (mm), 1000 is used to change the unit from m to mm
   else
       et4(2:nnh+1,i)=-temp(3:nnh+2,ta(1,i))*3600*24*1000;   % unit mm/day
       aet4(2:nnh+1,i)=aet4(2:nnh+1,i-1)-sum( temp(3:nnh+2,ta(1,i-1)+1:ta(1,i))  ,2) *f4(3)*1000;
   end
end
%avet4=sum(aet4(2:(f3(6)+2),:),1)/(f3(6)+1);
avet4=(xyf(4,1:nnh)*aet4(2:(f3(6)+2),:))/sum(xyf(4,1:nnh));
% et1=temp(2:nnh+2,1:f2(8));  % delete the first line
% et1(2:(f3(6)+2),:)=-et1(2:(f3(6)+2),:).*(3600*24*1000); %change m/s to mm/day

% -- calculate the accumulative evaporation rate, then store it in aet1, this is used in the figure of accumulative 
%  evaporation rate
% aet1(1,:) % duration of the time snapshot
% aet1(2,:) % accumulative evaporation rate from the whole surface, (mm) remember, this result is regardless of the area.



%aet1(1,:)=et1(1,:);
%for i=1:f2(1)   % time step loops
%   if i==1
%    aet1(2:(f3(6)+2),i)=et1(2:(f3(6)+2),i)*et1(1,i); % et1(1,:) is duration (day)
%   else
%    aet1(2:(f3(6)+2),i)=aet1(2:(f3(6)+2),i-1)+et1(2:(f3(6)+2),i)*(et1(1,i)-et1(1,i-1));
%   end
%end

fprintf(1,'Fourth bco.dat file reading finished\n');
end
%% -------------read Fourth qv.dat----------------------------
fn=fopen('QV.DAT');
   line=fgetl(fn);
for i=2:f2(2)-1
   line3(i)={fgetl(fn)};
   qvx4(:,:,i)=fscanf(fn, '%g %g ', [f3(6),f3(5)+1]);
   qvy4(:,:,i)=fscanf(fn, '%g %g %g ',[f3(6)+1,f3(5)]);
   %line=fgetl(fn);
end
%% -----------calculating the Fourth drying front location----------
if f2(10)~=0
    % ef(1,1:SWELE) is the time of the output (day)
    % ef(2:(f3(5)+2),1:SWELE) is the position of the drying front
    ef4=zeros(f3(6)+2,f2(1));  % initialize the size of ef
    ef4(1,:)=ta(2,:);   
    
    for k=1:(f3(6)+1)   % loop of node on x direction
    
    for i=1:f2(1)   % loop for 
      for j=1:f3(5)+1
          if a4(5,k*(f3(5)+1)-j+1,i)>=f2(10)     % warning: this check is from the top of the column to the bottom
              ef4(k+1,i)=a4(2,k*(f3(5)+1)-j+1,i);
              break
          end
      end
    end
    
    end
end

fprintf(1,'fourth qv.dat file reading finished\n');
cd ('..')
end

%% fifth
%% --------read the Fifth .nod file ----------
if char(f1{1,1}(7,1))~='#'
cd (char(f1{1,1}(7,1)))
if f2(2)~=0
nod=[char(f1{1,1}(1,1)),'.NOD'];
fn=fopen(nod);
%-how can I improve this ?   for header
for i=1:12
  line=fgetl(fn);
end
temp=fscanf(fn, '%*s %g %g %*s %*g %*s %*g %*s %*g', [2 f2(2)]);
ta(1:2,:)=temp(1:2,2:f2(2));
ta(2,:)=ta(2,:)/86400; %changing time from seconds to day
line=fgetl(fn);
for j=1:f2(2)
  %sub header in each output
  for i=1:5
    line1(i,j)={fgetl(fn)};
  end
  if j==1
      % jump the first round
      temp=fscanf(fn, '%*g %*g %*g %*g %g %g %*g %g %*g %*g %*g %*g', [3 f3(1)]);
      temp={fgetl(fn)};
      % it is funny that if I let temp to read the first line it is going
      % to be problematic, the algorithm of fscanf is design
  else
      a5([1:6 10:13],:,j-1)=fscanf(fn, '%*g %g %g %g %g %g %g %g %g %g %*g %g', [10 f3(1)]);
      line=fgetl(fn);   %if the last column is not captured, it
      %requires to use the previous line
      a5(13,:,j-1)=a5(13,:,j-1)-273.15; %change the temperature unit from kelven to celsius
      a5(7,:,j-1)=a5(3,:,j-1)/9.81./(1000+702.24*(a5(4,:,j-1)-0.0001))+a5(2,:,j-1);     % calculating the total head
  end

end %j
fclose(fn);
temp=0;
fprintf(1,'Fifth .NOD file reading finished\n');
end
%% -------------read Fifth .ele------------
if f2(1)~=0
temp=zeros([4,f3(2)]);
nod=[char(f1{1,1}(1,1)),'.ELE'];
fn=fopen(nod);
% head read
for i=1:(f2(1)+12)
  line=fgetl(fn);
end
for j=1:f2(1)   %j
  %sub header in each output
  for i=1:5
    line2(i,j)={fgetl(fn)};
  end
  % data read
  if j==1
temp=fscanf(fn, '%*g %g %g %g %g %g %g %g %g %g %g %g', [11 f3(2)]);
  %  xye only needs to be recorded at the first time step
    xye(:,:)=temp(1:2,:);
    b5(1:9,:,j)=temp(3:11,:);
    temp={fgetl(fn)};
  else
    b1(1:9,:,j)=fscanf(fn, '%*g %*g %*g %g %g %g %g %g %g %g %g %g', [9 f3(2)]);
    temp={fgetl(fn)};
  end
end   %j
fclose(fn);
temp=0;
fprintf(1,'Fifth .ELE file reading finished\n');
end

%% ------------------read fifth .bcof----------------
if f2(4)~=0
nod=[char(f1{1,1}(1,1)),'.BCOF'];
fn=fopen(nod);
for i=1:12
  line=fgetl(fn);
end
temp=fscanf(fn, '%*s %g %g ', [2 f2(4)]);
tf5(1:2,:)=temp;
tf5(2,:)=tf5(2,:)/86400;
for j=1:f2(4)   %j
  %sub header in each output
  for i=1:7
    line3(i,j)={fgetl(fn)};
  end
  % data read
  if j==1
    temp=fscanf(fn, '%g %*s %*s %g %g %g %g %g %g ', [7 f3(4)]);
  %  xye only needs to be recorded at the first time step
    xyf(1:3,:)=temp([1,5:6],:);
    bcof5(1:3,:,j)=temp(2:4,:);
  else
    bcof5(1:3,:,j)=fscanf(fn, '%*g %*s %*s %g %g %g %*g %*g %*g', [3 f3(4)]);
    temp={fgetl(fn)};
  end
end   %j
fclose(fn);
temp=0;
fprintf(1,'Fifth .BCOF file reading finished\n');
end
%% ------------------read the Fifth .bcop----------------
if f2(3)~=0
temp=0;
nod=[char(f1{1,1}(1,1)),'.BCOP'];
fn=fopen(nod);
for i=1:12
  line=fgetl(fn);
end
temp=fscanf(fn, '%*s %g %g ', [2 f2(3)]);
% tbp(1,time steps) time steps
% tbp(2,time steps) actual time (days)
% tbp(3,time steps) sink suction rate (mm/day)
tbp5(1:2,:)=temp;
tbp5(2,:)=tbp5(2,:)/86400;           %tbp1(time step, real time (day),
for j=1:f2(3)   %j
  %sub header in each output
  for i=1:7
    line4(i,j)={fgetl(fn)};
  end
  % data read
  if j==1
    temp=fscanf(fn, '%g %*s %*s %g %g %g %*g %*g %g %g %*g', [6 f3(3)]);
  %  xye only needs to be recorded at the first time step
    xyp(:,:)=temp([1,5:6],:);
    p5(1:3,:,j)=temp(2:4,:);
    line=fgetl(fn);
  else
    p5(1:3,:,j)=fscanf(fn, '%*g %*s %*s %g %g %g %*g %*g %*g %*g %*g', [3 f3(3)]);
    temp={fgetl(fn)};
  end
     %b3=f(:,:,j);   %this line is just for checking
end   %j
fclose(fn);
temp=0;
fprintf(1,'Fifth .BCOP file reading finished\n');
end
%% ------------------read Fifth bco.dat for evaporation rate opt--------------
if f2(8)~=0
temp=0;    
fn=fopen('BCO.DAT');
line=fgetl(fn);
temp=fscanf(fn, '%*g %*g %*g %*g %g %g %g %g %g %g ', [6 f3(4)]);  % NODE, X,Y,Z,XX,YY,HAREA,VAREA,FAREA,R
xyf(4:6,:)=temp(3:5,:); 
% xyf(1,source/sink node number) node sequence
% xyf(2,source/sink node number) x position
% xyf(3,source/sink node number) y position
% xyf(4,source/sink node number) area of each node in xy panel
% xyf(5,source/sink node number) area of node in yz panel (varea)
% xyf(6,source/sink node number) area of node in xy panel (farea)
xyr=temp([1:2,6],:);
% xyr(1, source/sink node number) is xx
% xyr(2, source/sink node number) is yy
% xyr(3, source/sink node number) is R in cylindrical coordinate

% how to vectorize it?
% calculating evaporation rate
% the disadvantage of this method is that the next node could also be affected by 
% the node below.
% so to some extent the result from .bcof is kind of useless
% instead, the best way of getting the accumulative evaporation rate is from et1 
%for i=1:f2(4)                          % time step increasement
%tf1(3,i)=sum(bcof1(1,1:6,i)./xyf(4,1:6));
%end
%tf1(3,:)=tf1(3,:)*86400/(f3(6)+1);      % f3(6) is the overall node on the surface

% further read about the evaporation rate
line=fgetl(fn);

% the format of %g can be less than the numbers in the [  ]. in that case, the data obtain will repeat using the pattern given by %g. 
temp=fscanf(fn, '%g', [(nnh+2) f2(8)]); % here using only one %g would be enough
% notice: temp here stores the evaporation rate at all time steps, which is important to obtain the precise
% result for the accumulative evaporation. however, et1 only stores the evaporation rate at perticular snapshot
% this is due to too large array size.

et5(1,:)=ta(2,:);
aet5(1,:)=ta(2,:);
for i=1:f2(1)  % loop for each snapshot
   if i==1
       et5(2:nnh+1,i)=-temp(3:nnh+2,ta(1,i))*3600*24*1000;   %3600*24*1000 changes the unit from m/s to mm/day
       aet5(2:nnh+1,i)=-temp(3:nnh+2,ta(1,i))*f4(3)*1000;   % unit (mm), 1000 is used to change the unit from m to mm
   else
       et5(2:nnh+1,i)=-temp(3:nnh+2,ta(1,i))*3600*24*1000;   % unit mm/day
       aet5(2:nnh+1,i)=aet5(2:nnh+1,i-1)-sum( temp(3:nnh+2,ta(1,i-1)+1:ta(1,i))  ,2) *f4(3)*1000;
   end
end
%avet5=sum(.*,1)/(f3(6)+1);
avet5=(xyf(4,1:nnh)*aet5(2:(f3(6)+2),:))/sum(xyf(4,1:nnh));
% et1=temp(2:nnh+2,1:f2(8));  % delete the first line
% et1(2:(f3(6)+2),:)=-et1(2:(f3(6)+2),:).*(3600*24*1000); %change m/s to mm/day

% -- calculate the accumulative evaporation rate, then store it in aet1, this is used in the figure of accumulative 
%  evaporation rate
% aet1(1,:) % duration of the time snapshot
% aet1(2,:) % accumulative evaporation rate from the whole surface, (mm) remember, this result is regardless of the area.



%aet1(1,:)=et1(1,:);
%for i=1:f2(1)   % time step loops
%   if i==1
%    aet1(2:(f3(6)+2),i)=et1(2:(f3(6)+2),i)*et1(1,i); % et1(1,:) is duration (day)
%   else
%    aet1(2:(f3(6)+2),i)=aet1(2:(f3(6)+2),i-1)+et1(2:(f3(6)+2),i)*(et1(1,i)-et1(1,i-1));
%   end
%end

fprintf(1,'Fifth bco.dat file reading finished\n');
end
%% -------------read first qv.dat----------------------------
fn=fopen('QV.DAT');
   line=fgetl(fn);
for i=2:f2(2)-1
   line3(i)={fgetl(fn)};
   qvx5(:,:,i)=fscanf(fn, '%g %g ', [f3(6),f3(5)+1]);
   qvy5(:,:,i)=fscanf(fn, '%g %g %g ',[f3(6)+1,f3(5)]);
   %line=fgetl(fn);
end
%% -----------calculating the first drying front location----------
if f2(10)~=0
    % ef(1,1:SWELE) is the time of the output (day)
    % ef(2:(f3(5)+2),1:SWELE) is the position of the drying front
    ef5=zeros(f3(6)+2,f2(1));  % initialize the size of ef
    ef5(1,:)=ta(2,:);   
    
    for k=1:(f3(6)+1)   % loop of node on x direction
    
    for i=1:f2(1)   % loop for 
      for j=1:f3(5)+1
          if a5(5,k*(f3(5)+1)-j+1,i)>=f2(10)     % warning: this check is from the top of the column to the bottom
              ef5(k+1,i)=a5(2,k*(f3(5)+1)-j+1,i);
              break
          end
      end
    end
    
    end
end

fprintf(1,'Fifth qv.dat file reading finished\n');
cd ('..')
end
%% -----getting the experiment data from LAB.DAT-------

if f2(8)~=0
    
fn=fopen('LAB.DAT');
line=fgetl(fn);
while  line(1)=='#'
  line=fgetl(fn);
end   
f6 = str2num(line)';   %#ok<*ST2NM>

if f6(1)~=0
 line=fgetl(fn);
 while  line(1)=='#'
   line=fgetl(fn);
 end
%  (N)umber of (D)ata for (M)oisture (C)ontent
 nds=str2num(line)'; 
 % (T)ime for (S)atureation from (LAB)otory
 tslab=zeros(max(nds),f6(1));
 % (S)atureation from (LAB)otory
 slab=zeros(max(nds),f6(1));
 for k=1:f6(1)
 tslab(1:nds(k),k)=fscanf(fn,'%g %g %g %g %g %g %g %g %g %g \n',[1,nds(k)])';
 slab(1:nds(k),k)=fscanf(fn,'%g %g %g %g %g %g %g %g %g %g \n',[1,nds(k)])';
 end
end

if f6(2)~=0
 line=fgetl(fn);
 while  line(1)=='#'
   line=fgetl(fn);
 end
%  (N)umber of (D)ata for (R)elative (H)umidity
 ndrh=str2num(line)'; 
 % (T)ime for (R)elative (H)umidity from (LAB)otory
  trhlab=zeros(max(ndrh),f6(2));
 % (R)elative (H)umidity from (LAB)otory
  rhlab=zeros(max(ndrh),f6(2));
 for k=1:f6(2)
 trhlab(1:ndrh(k),k)=fscanf(fn,'%g %g %g %g %g %g %g %g %g %g \n',[1,ndrh(k)])';
 rhlab(1:ndrh(k),k)=fscanf(fn,'%g %g %g %g %g %g %g %g %g %g \n',[1,ndrh(k)])';
 end
end

if f6(3)~=0
 line=fgetl(fn);
 while  line(1)=='#'
   line=fgetl(fn);
 end
%  (N)umber of (D)ata for (T)emperature
  ndt=str2num(line)'; 
 % (T)ime for  (T)emperature from (LAB)otory
  ttlab=zeros(max(ndt),f6(3));
 %  (T)emperaturefrom (LAB)otory
  tlab=zeros(max(ndt),f6(3));
 for k=1:f6(3)
 ttlab(1:ndt(k),k)=fscanf(fn,'%g %g %g %g %g %g %g %g %g %g \n',[1,ndt(k)])';
 tlab(1:ndt(k),k)=fscanf(fn,'%g %g %g %g %g %g %g %g %g %g \n',[1,ndt(k)])';
 end
end

if f6(4)~=0
 line=fgetl(fn);
 while  line(1)=='#'
   line=fgetl(fn);
 end
%  (N)umber of (D)ata for (A)ccumulative (E)vapora(T)ion
  ndaet=str2num(line)'; 
 % (T)ime for  (T)emperature from (LAB)otory
  taetlab=zeros(max(ndaet),f6(4));
 %  (T)emperaturefrom (LAB)otory
  aetlab=zeros(max(ndaet),f6(4));
 for k=1:f6(4)
 taetlab(1:ndaet(k),k)=fscanf(fn,'%g %g %g %g %g %g %g %g %g %g \n',[1,ndaet(k)])';
 aetlab(1:ndaet(k),k)=fscanf(fn,'%g %g %g %g %g %g %g %g %g %g \n',[1,ndaet(k)])';
 end
end

if f6(5)~=0
 line=fgetl(fn);
 while  line(1)=='#'
   line=fgetl(fn);
 end
%  (N)umber of (D)ata for (E)vapora(T)ion
  ndet=str2num(line)'; 
 % (T)ime for  (T)emperature from (LAB)otory
  tetlab=zeros(max(ndet),f6(5));
 %  (T)emperaturefrom (LAB)otory
  etlab=zeros(max(ndet),f6(5));
 for k=1:f6(5)
 tetlab(1:ndet(k),k)=fscanf(fn,'%g %g %g %g %g %g %g %g %g %g \n',[1,ndet(k)])';
 etlab(1:ndet(k),k)=fscanf(fn,'%g %g %g %g %g %g %g %g %g %g \n',[1,ndet(k)])';
 end
end

fprintf(1,'Lab.dat reading finished\n');
fclose(fn);
end
%% ------------------read bcop.dat for evaporation rate opt--------------
if f2(9)~=0
fn=fopen('BP.DAT');
line=fgetl(fn);
xyp(4,:)=fscanf(fn, '%*g %*g %*g %*g %g ', [1 f3(4)]);
for i=1:f2(4)  % overall time steps
 tbp1(3,i)=sum(p1(1,:,i)./xyp(4,:)./(1000+702.24*p1(2,:,i))*1000);    % et(kg/s)/area(m2)/rou (kg/m3)*1000 (mm/m)=mm/s (evaporation rate * node number) 
 tbp2(3,i)=sum(p2(1,:,i)./xyp(4,:)./(1000+702.24*p1(2,:,i))*1000);    %  p1(resultant source/sink of fluid, solute conc of fluid, resultant source/sink of solute)
 tbp3(3,i)=sum(p3(1,:,i)./xyp(4,:)./(1000+702.24*p1(2,:,i))*1000);
end
 tbp1(3,:)=tbp1(3,:)*86400/(f3(6)+1);   % f3(6)+1 mean how many nodes are there in one layer
 tbp2(3,:)=tbp2(3,:)*86400/(f3(6)+1);   % (kg/s/m2)*(86400 s/day)/1000(kg/m3)*(1000mm/m)
 tbp3(3,:)=tbp3(3,:)*86400/(f3(6)+1);
fclose(fn);
fprintf(1,'Data reading finished\n');
end
toc




% build0005 cylindrical 2012-09-26 .... change the bco reading so that the varea, farea, xx, yy and r readings are included.
% Build0001             2013-01-30 .... change the reading patterns for lab data

    

    

