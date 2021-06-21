function [pole_A, pole_B]=label_the_poles(poles,CM,varargin) 
%% 2 options for the function
    %option 1: [pole_A, pole_B]=label_the_poles_2(poles,CM) for PHASE CONTRAST ONLY
    %option 2: [pole_A, pole_B]=label_the_poles_2(poles,CM,int,int_max) for FLUORESCENCE
    
    %OUTPUT: Pole A: 3 or 5 colums matrix depending on the option
            %column 1: X coordinate of pole center
            %column 2: Y coordinate of pole center
            %column 3: initial number of pole I think (MJK) 
            %column 4: if option 2: corresponding mean intensity
            %column 5: if option 2: corresponding max intensity
time=size(CM,1);

if(nargin>2)
    intensity=1;
    int=varargin{1};
    int_max=varargin{2};
else 
    intensity=0;
end

pole_i=poles{1}(1,1:2);
%poles coordinate
pole_A(1,1:2)=pole_i;
pole_B(1,1:2)=poles{1}(2,1:2);

%poles position 1 or 2
pole_A(1,3)=1;
pole_B(1,3)=2;

if intensity
    %poles intensity
    pole_A(1,4)=int{1}(1,1);
    pole_B(1,4)=int{1}(1,2);

    %poles max intensity
    pole_A(1,5)=int_max{1}(1,1);
    pole_B(1,5)=int_max{1}(1,2);
end

for t=2:1:time
    delta_CM=CM(t,:)-CM(t-1,:);    
    pole_2=poles{t}(1,1:2);
    pole_3=poles{t}(2,1:2);
    
     d2=norm(pole_i+delta_CM-pole_2);
     d3=norm(pole_i+delta_CM-pole_3);
     
     if d2<d3 %c'est pole_2
         pole_A(t,1:2)=pole_2;
         pole_B(t,1:2)=pole_3;
         
         pole_A(t,3)=1;
         pole_B(t,3)=2;
         
         if intensity
         pole_A(t,4)=int{t}(1,1);
         pole_B(t,4)=int{t}(1,2);
         
         pole_A(t,5)=int_max{t}(1,1);
         pole_B(t,5)=int_max{t}(1,2);
         end
         pole_i=pole_2;
     else
         pole_A(t,1:2)=pole_3;
         pole_B(t,1:2)=pole_2;
         
         pole_A(t,3)=2;
         pole_B(t,3)=1;
         
         if intensity
         pole_A(t,4)=int{t}(1,2);
         pole_B(t,4)=int{t}(1,1);
         
         pole_A(t,5)=int_max{t}(1,2);
         pole_B(t,5)=int_max{t}(1,1);
         end
         pole_i=pole_3; 
     end
end