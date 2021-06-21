function [data_brut,BactID] = filtre_presence(data_brut,time,time_min)
% to delete cells not tracked longer enought
%% 1) measure how many time they appears
    maxTrackID=data_brut.frames(time).cells.maxTrackID;
    M_prescence=zeros(maxTrackID,time);
    for t=1:1:time
        data=data_brut.frames(t).cells;
        nbr_particules=size(data.Stats,1);
        TrackID=zeros(nbr_particules,1);
        for p=1:1:nbr_particules
        TrackID(p)=data.Stats(p).TrackID;
        end
        M_prescence(TrackID,t)=1;
    end
    nbr_prescence=zeros(maxTrackID,1);
    for t=1:1:time
        nbr_prescence=nbr_prescence+M_prescence(:,t);
    end

%% 2)delete the ones that appears less than time_min
    number_of_part_to_del=find(nbr_prescence<time_min);
    BactID(:,1)=find(nbr_prescence>=time_min);
    BactID(:,2)=nbr_prescence(BactID);

    % search the columns with 1, comme ca je connais a partir de quelle temps il y a la particule
    [~,B]=max(M_prescence,[],2);
    BactID(:,3)=B(BactID(:,1));

    %delete particule
    for i=1:1:size(number_of_part_to_del,1)
        tmp=number_of_part_to_del(i);
        data_brut=delete_particule(tmp,time,data_brut);
    end

end

