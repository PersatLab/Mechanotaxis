function [reversal,RMSD_total] = Reversals(cell_prop,BactID,Data_speed)
%% OUTPUT: 
    % reversals is a cell with 2 columns:
    % column1: TrackID of reversing cell
    % column2: v_dot_x (which is the projection vector)

%% variables
nbr_bact=size(BactID,1);
RMSD_total=[];
n=0;
%% loof over all the cells
for nbr=1:1:nbr_bact
    poles=cell_prop{nbr,5};
    CM=cell_prop{nbr,3};
    poles=label_the_poles(poles,CM);
    Speed=cell2mat(Data_speed{nbr,3}); % I take the speed vector which is filtered by speed_limit. Change to :cell2mat(Data_speed{nbr,6}) is not filtered speed
    time=size(poles,1);
    
    RMSD=root_mean_square_displacement(CM);
    RMSD_total=[RMSD_total,RMSD];
    
    tmp=1;
    scalar_product=0;
    while scalar_product==0  %% this is to define which pole is the initial leading pole
    vector_CM_pole=poles(tmp,1:2)-CM(tmp,1:2);
    scalar_product=dot(Speed(tmp,:),vector_CM_pole);
    tmp=tmp+1;
    end

    if scalar_product>0 %% if scalar product>0 I know the pole poles(:,1:2) is the initial leading 
    indice=[1,2];
    elseif scalar_product<0
    indice=[3,4];
    end

    v_dot_x=zeros(time,1);
    for t=2:1:time %% v_dot_x is the projection between the speed vector and the vector (CM-initial leading)
    vector_CM_pole=(poles(t,indice)-CM(t,1:2))/norm(poles(t,indice)-CM(t,1:2));
    v_dot_x(t)=dot(Speed(t,:),(vector_CM_pole));
    end
    
    sum_negative=sum(v_dot_x<0);
    sum_positive=sum(v_dot_x>0);

          
    if sum_positive>2 && sum_negative>2
    n=n+1;
    % save data in reversal which is the output
    reversal{n,1}=BactID(nbr,1);
    reversal{n,2}=v_dot_x;
    
    end
end
end
