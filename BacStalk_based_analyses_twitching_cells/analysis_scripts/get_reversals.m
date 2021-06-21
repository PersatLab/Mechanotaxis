function [reversal,RMSD_total] = get_reversals(cell_prop,BactID,Data_speed)
%% OUTPUT: 
    % reversals is a cell with 3 columns:
    % column1: TrackID of reversing cell
    % column2: v_dot_x (which is the projection vector between displacement (or speed) vector and cell orientation vector (CM to initial leading pole))
    % column3: RMSD (not used in the end)

%% variables
nbr_bact=size(BactID,1);
RMSD_total=[];
n=0;
%% loop over all the cell tracks
for nbr=1:1:nbr_bact
    poles=[];
    poles_tmp=cell_prop{nbr,5};
    CM=cell_prop{nbr,3};
    [poleA,poleB]=label_the_poles(poles_tmp,CM);
    poles(:,1:2)=poleA(:,1:2);  poles(:,5)=poleA(:,3);
    poles(:,3:4)=poleB(:,1:2);  poles(:,6)=poleB(:,3);
    
    Speed=cell2mat(Data_speed{nbr,3}); % I take the speed vector which is filtered by speed_limit. Change to cell2mat(Data_speed{nbr,6}) for non-filtered speed
    time=size(poles,1);
    
    RMSD=root_mean_square_displacement(CM);
    RMSD_total=[RMSD_total,RMSD];
    
    tmp=1;
    scalar_product=0;
    while scalar_product==0  % this is to define which pole is the initial leading pole
        vector_CM_pole=poles(tmp,1:2)-CM(tmp,1:2);
        scalar_product=dot(Speed(tmp,:),vector_CM_pole);
        tmp=tmp+1;
    end

    if scalar_product>0 %% if scalar product>0 I know the pole poles(:,1:2) is the initial leading 
    indice=[1,2];
    elseif scalar_product<0
    indice=[3,4];
    end
    
    for j=1:1:time
       l=norm(Speed(j,:));
       Speed(j,:)=Speed(j,:)/l;
       if isnan(Speed(j,:))
           Speed(j,:)=[0,0];
       end
    end

    v_dot_x=zeros(time,1);
    for t=2:1:time % v_dot_x is the projection between the speed vector and the vector (CM - initial leading pole)
    vector_CM_pole=(poles(t,indice)-CM(t,1:2))/norm(poles(t,indice)-CM(t,1:2));
    v_dot_x(t)=dot(Speed(t,:),(vector_CM_pole));
    end
    
    sum_negative=sum(v_dot_x<0);
    sum_positive=sum(v_dot_x>0);

          
   if sum_positive>0 && sum_negative>0
     n=n+1;
    % save data in reversal which is the output
    reversal{n,1}=BactID(nbr,1);
    reversal{n,2}=v_dot_x;
    reversal{n,3}=RMSD;
    
     end
end
end
