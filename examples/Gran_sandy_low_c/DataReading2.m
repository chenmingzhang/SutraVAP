clear all
fclose('all');


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
f2=fscanf(fn,['%f' ' '],[1,9]);
line=fgetl(fn);
f3=fscanf(fn,['%f' ' '],[1,9]);
line=fgetl(fn);
f4=fscanf(fn,['%f' ' '],[1,3]);
line=fgetl(fn);
f5=fscanf(fn,['%f' ' '],[1,16]);
if f2(7)~=0
line=fgetl(fn);
v=fscanf(fn, '%g', [1 f3(1)]);
end
fclose(fn);
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
% ta(1,:) is the time step
% ta(2,:) is the time (s) of this time step
ta=zeros(2,f2(2)-1);
a1=zeros([13,f3(1),f2(2)]);
a2=zeros([13,f3(1),f2(2)]);
a3=zeros([13,f3(1),f2(2)]);
% xye(1,elementnumber) is the x posity of the element (centrinod of the
% element)
% xye(2,elementnumber) is the y posity of the element (centrinod of the
% element)
% b(1,nodenumber,timestep) is the x velocity of the element
% b(2,nodenumber,timestep) is the y velocity of the element
% b(3,nodenumber,timestep) is the x flux density of the element
% b(4,nodenumber,timestep) is the y flux density of the element
% b(5,nodenumber,timestep) is the relative hydraulic conductivity of the element
b1=zeros([5,f3(2),f2(1)]);
b2=zeros([5,f3(2),f2(1)]);
b3=zeros([5,f3(2),f2(1)]);
% line1 is the header of .nod file
line1=cell(5,f2(2));
% line2 is the header of .ele file
line2=cell(5,f2(1));
% line3 is the header of pv.dat file
line3=cell(1,f2(2)-1);


% the following matrices is applied by bcof reading
% f(1,source/sink nodenumber, timestep) is water sink
% f(2,source/sink nodenumber, timestep) is solute concentration of water sink
% f(3,source/sink nodenumber, timestep) is solute concentration
bcof1=zeros([3,f3(4),f2(4)]);
bcof2=zeros([3,f3(4),f2(4)]);
bcof3=zeros([3,f3(4),f2(4)]);
% xyf(1,source/sink node number) node sequence
% xyf(2,source/sink node number) x position
% xyf(3,source/sink node number) y position
% xyf(4,source/sink node number) area of each node
xyf=zeros([4,f3(4)]);
% tf(1,time steps) time steps
% tf(1,time steps) actual time (days)
% tf(2,time steps) evaporation rate (mm/day)
tf1=zeros([3,f2(4)]);
tf2=zeros([3,f2(4)]);
tf3=zeros([3,f2(4)]);

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
p1=zeros([3,f3(3),f2(3)]);
p2=zeros([3,f3(3),f2(3)]);
p3=zeros([3,f3(3),f2(3)]);
xyp=zeros([3,f3(3)]);

% et is used in bco.dat
% et(1,:) is the time (day)
% et(2:end,:) is the evaporation rate (m/s) at each node
% this method is more precise to calc the et rate
et1=zeros([f3(6)+2,(f2(2)-1)]);
et2=zeros([f3(6)+2,(f2(2)-1)]);
et3=zeros([f3(6)+2,(f2(2)-1)]);

% qvx qvy are the vapor flux, their directions are along the element boundaries. see notebook p121 of year 2011
% warning: both matrices has been transposed due to the reading sequence using fscanf command
qvy1=zeros([f3(6)+1,f3(5),f2(2)-1]);
qvx1=zeros([f3(6),f3(5)+1,f2(2)-1]);
qvy2=zeros([f3(6)+1,f3(5),f2(2)-1]);
qvx2=zeros([f3(6),f3(5)+1,f2(2)-1]);
qvy3=zeros([f3(6)+1,f3(5),f2(2)-1]);
qvx3=zeros([f3(6),f3(5)+1,f2(2)-1]);
%% --------read the first .nod file ----------
if char(f1{1,1}(3,1))~='#'
cd (char(f1{1,1}(3,1)))
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
    temp=fscanf(fn, '%*g %g %g %g %g %g %g %g', [7 f3(2)]);
  %  xye only needs to be recorded at the first time step
    xye(:,:)=temp(1:2,:);
    b1(1:5,:,j)=temp(3:7,:);
    temp={fgetl(fn)};
  else
    b1(1:5,:,j)=fscanf(fn, '%*g %*g %*g %g %g %g %g %g', [5 f3(2)]);
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
fn=fopen('BCO.DAT');
line=fgetl(fn);
xyf(4,:)=fscanf(fn, '%*g %*g %*g %*g %g ', [1 f3(4)]);
% how to vectorize it?
% calculating evaporation rate
% the disadvantage of this method is that the next node could also be affected by 
% the node below.
for i=1:f2(4)                          % time step increasement
% tf(3,i)=sum(f(1,:,i)./xyf(4,:));
tf1(3,i)=sum(bcof1(1,1:6,i)./xyf(4,1:6));
end
tf1(3,:)=tf1(3,:)*86400/(f3(6)+1);      % f3(6) is the overall node on the surface
end
% further read about the evaporation rate
line=fgetl(fn);
et1(:,:)=fscanf(fn, '%*g %g %g %g %g ', [(f3(6)+2) (f2(2)-1)]);
et1(2:(f3(6)+2),:)=-et1(2:(f3(6)+2),:).*(3600*24*1000); %change m/s to mm/day
fprintf(1,'First bco.dat file reading finished\n');

%% -------------read first qv.dat----------------------------
fn=fopen('QV.DAT');
   line=fgetl(fn);
for i=2:f2(2)-1
   line3(i)={fgetl(fn)};
   qvx1(:,:,i)=fscanf(fn, '%g %g ', [f3(6),f3(5)+1]);
   qvy1(:,:,i)=fscanf(fn, '%g %g %g ',[f3(6)+1,f3(5)]);
   line=fgetl(fn);
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
%% -------------read second .ele------------
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
    temp=fscanf(fn, '%*g %g %g %g %g %g %g %g', [7 f3(2)]);
  %  xye only needs to be recorded at the first time step
    xye(:,:)=temp(1:2,:);
    b2(1:5,:,j)=temp(3:7,:);
    temp={fgetl(fn)};
  else
    b2(1:5,:,j)=fscanf(fn, '%*g %*g %*g %g %g %g %g %g', [5 f3(2)]);
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
fprintf(1,'Second .BCOF file reading finished\n');
end
%% ------------------read the Second .bcop----------------
if f2(3)~=0
temp=0;
nod=[char(f1{1,1}(1,1)),'.BCOP'];
fn=fopen(nod);
for i=1:12
  line=fgetl(fn);
end
temp=fscanf(fn, '%*s %g %g ', [2 f2(3)]);
tbp2(1:2,:)=temp;
tbp2(2,:)=tbp2(2,:)/86400;
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
fprintf(1,'Second .BCOP file reading finished\n');
end
%% ------------------read Second bco.dat for evaporation rate opt--------------
if f2(8)~=0
fn=fopen('BCO.DAT');
line=fgetl(fn);
xyf(4,:)=fscanf(fn, '%*g %*g %*g %*g %g ', [1 f3(4)]);
% how to vectorize it?
% calculating evaporation rate
% the disadvantage of this method is that the next node could also be affected by 
% the node below.
for i=1:f2(4)                          % time step increasement
% tf(3,i)=sum(f(1,:,i)./xyf(4,:));
tf2(3,i)=sum(bcof2(1,1:6,i)./xyf(4,1:6));
end
tf2(3,:)=tf2(3,:)*86400/(f3(6)+1);      % f3(6) is the overall node on the surface
end
% further read about the evaporation rate
line=fgetl(fn);
et2(:,:)=fscanf(fn, '%*g %g %g %g %g ', [(f3(6)+2) (f2(2)-1)]);
et2(2:(f3(6)+2),:)=-et2(2:(f3(6)+2),:).*(3600*24*1000); %change m/s to mm/day
fprintf(1,'Second bco.dat file reading finished\n');
%% -------------read Second qv.dat----------------------------
fn=fopen('QV.DAT');
   line=fgetl(fn);
for i=2:f2(2)-1
   line3(i)={fgetl(fn)};
   qvx2(:,:,i)=fscanf(fn, '%g %g ', [f3(6),f3(5)+1]);
   qvy2(:,:,i)=fscanf(fn, '%g %g %g ',[f3(6)+1,f3(5)]);
   line=fgetl(fn);
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
%% -------------read Third .ele------------
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
    temp=fscanf(fn, '%*g %g %g %g %g %g %g %g', [7 f3(2)]);
  %  xye only needs to be recorded at the first time step
    xye(:,:)=temp(1:2,:);
    b3(1:5,:,j)=temp(3:7,:);
    temp={fgetl(fn)};
  else
    b3(1:5,:,j)=fscanf(fn, '%*g %*g %*g %g %g %g %g %g', [5 f3(2)]);
    temp={fgetl(fn)};
  end
end   %j
fclose(fn);
temp=0;
fprintf(1,'Third .ELE file reading finished\n');
end
%% ------------------read Third.bcof----------------
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
%% ------------------read the Third .bcop----------------
if f2(3)~=0
temp=0;
nod=[char(f1{1,1}(1,1)),'.BCOP'];
fn=fopen(nod);
for i=1:12
  line=fgetl(fn);
end
temp=fscanf(fn, '%*s %g %g ', [2 f2(3)]);
tbp3(1:2,:)=temp;
tbp3(2,:)=tbp3(2,:)/86400;
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
fprintf(1,'Third .BCOP file reading finished\n');
end
%% ------------------read Third bco.dat for evaporation rate opt--------------
if f2(8)~=0
fn=fopen('BCO.DAT');
line=fgetl(fn);
xyf(4,:)=fscanf(fn, '%*g %*g %*g %*g %g ', [1 f3(4)]);
% how to vectorize it?
% calculating evaporation rate
% the disadvantage of this method is that the next node could also be affected by 
% the node below.
for i=1:f2(4)                          % time step increasement
% tf(3,i)=sum(f(1,:,i)./xyf(4,:));
tf3(3,i)=sum(bcof3(1,1:6,i)./xyf(4,1:6));
end
tf2(3,:)=tf3(3,:)*86400/(f3(6)+1);      % f3(6) is the overall node on the surface
end
% further read about the evaporation rate
line=fgetl(fn);
et3(:,:)=fscanf(fn, '%*g %g %g %g %g ', [(f3(6)+2) (f2(2)-1)]);
et3(2:(f3(6)+2),:)=-et3(2:(f3(6)+2),:).*(3600*24*1000); %change m/s to mm/day
fprintf(1,'Third bco.dat file reading finished\n');
%% -------------read Third qv.dat----------------------------
fn=fopen('QV.DAT');
   line=fgetl(fn);
for i=2:f2(2)-1
   line3(i)={fgetl(fn)};
   qvx3(:,:,i)=fscanf(fn, '%g %g ', [f3(6),f3(5)+1]);
   qvy3(:,:,i)=fscanf(fn, '%g %g %g ',[f3(6)+1,f3(5)]);
   line=fgetl(fn);
end
fprintf(1,'Third qv.dat file reading finished\n');
cd ('..')
end
%% -----getting the experiment data from LAB.DAT-------

if f2(8)~=0
    %f6(1) number of saturation data
    %f6(2) number of concentration data
    %f6(3) number of temperature data
    %f6(4) number of evaporation data
    %f6(5) number of gw uptake data
    f6=zeros(5);
    temp=0;
    fn=fopen('LAB.DAT');
line=fgetl(fn);
while  line(1)=='#'
  line=fgetl(fn);
end   
    f6=fscanf(fn, '%g %g %g %g %g', [5 1]);
    line=fgetl(fn);
%  ------salinity --------
    if f6(1)~=0
      slab=zeros(2,30,f6(1));
    for i=1:f6(1)
        for j=1:5
         ln(i,j)={fgetl(fn)};
        end
        temp=str2double(ln(i,4));
        slab(1:2,1:temp,i)=fscanf(fn, '%g %g', [2 temp]);
    end
    end
% concentration    
    if f6(2)~=0
      clab=zeros(2,30,f6(2));
          for i=1:f6(2)
        for j=1:5
         ln2(i,j)={fgetl(fn)};
        end
        temp=str2double(ln2(i,4));
        clab(1:2,1:temp,i)=fscanf(fn, '%g %g', [2 temp]);
    end
    end
% temperature
    if f6(3)~=0
      tlab=zeros(2,30,f6(2));
      for i=1:f6(3)                   
        for j=1:5
         ln3(i,j)={fgetl(fn)};         % 5 lines of headers, one of the lines is due to the enter symbol
        end
        temp=str2double(ln3(i,4));      % no of data in this dataset
        tlab(1:2,1:temp,i)=fscanf(fn, '%g %g', [2 temp]);   % getting the depth (m) and concentration (-) data
        %tlab(1,:,i)=tlab(1,:,i)-273.15; % changing the unit from kelvin to Celsius
    end
    end


% surface evaporation
   if f6(4)~=0
    for i=1:5
    ln(i)={fgetl(fn)};
    end
    temp=str2double(ln(4));
    eslab=fscanf(fn, '%g %g', [2 temp]);
   end
% ground evaporation
   if f6(5)~=0
    for i=1:5
    ln(i)={fgetl(fn)};
    end
    temp=str2double(ln(4));
    eglab=fscanf(fn, '%g %g', [2 temp]);
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
end

fprintf(1,'Data reading finished\n');


    

    

