function [reversal] = Reversals_phase_contrast(cell_prop,BactID,Data_speed,scalar_limit)
%% variables
nbr_bact=size(BactID,1);
tot=[];
reversal=zeros(nbr_bact,6);
reversal(:,1)=BactID(:,1);
%% loof over all the cells
for nbr=1:1:nbr_bact

    poles=cell_prop{nbr,5};
    CM=cell_prop{nbr,3};
    poles=label_the_poles(poles,CM);
    Speed=cell2mat(Data_speed{nbr,5});
    time=size(poles,1);
    
    tmp=1;
    scalar_product=0;
    while scalar_product==0
    vector_CM_pole=poles(tmp,1:2)-CM(tmp,1:2);
    scalar_product=dot(Speed(tmp,:),vector_CM_pole);
    tmp=tmp+1;
    end

    if scalar_product>0
    indice=[1,2];
    elseif scalar_product<0
    indice=[3,4];
    end

    v_dot_x=zeros(time,1);
    for t=2:1:time
    vector_CM_pole=(poles(t,indice)-CM(t,1:2))/norm(poles(t,indice)-CM(t,1:2));
    v_dot_x(t)=dot(Speed(t,:),(vector_CM_pole));
    end
    t=1;

    sum_negative=sum(v_dot_x<-scalar_limit);
    sum_positive=sum(v_dot_x>scalar_limit);
    reversal(nbr,2)=sum_negative;
    reversal(nbr,3)=sum_positive;
    reversal(nbr,6)=min(sum_positive,sum_negative)/max(sum_positive,sum_negative);

    indice_negative=find(v_dot_x<-scalar_limit);
    indice_positive=find(v_dot_x>0);
    if ~isempty(indice_negative)
        indice=indice_negative(1);
        CM=cell_prop{nbr,3};
        positive_displacement=norm(CM(1,:)-CM(indice,:))*0.13;
        negative_displacement=norm(CM(indice,:)-CM(end,:))*0.13;

        reversal(nbr,4)=negative_displacement;
        reversal(nbr,5)=positive_displacement;

        if indice_negative(end)<indice_positive(end)
            reversal(nbr,6)=99;    
        elseif size(indice_negative,1)<3
            reversal(nbr,6)=100;
        end
    end
    tot=[tot; v_dot_x];
end

reversal(reversal(:,6)==0,:)=[];

% histogram(tot,10)
% grid on

end
