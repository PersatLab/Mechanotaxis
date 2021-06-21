function []=create_image_for_video(adresse,time,do_fluopoles,cell_prop,moving)
%% loop of every time
nbr_bact=size(cell_prop,1);
for t=1:1:time
%% Fluo with poles

if do_fluopoles
    this_image= imread(strcat(adresse,'\C1-data.tif'),t);

    figure
    imshow(imadjust(this_image))

        for nbr=1:1:nbr_bact
            n=find(t==cell_prop{nbr,7});   
            if ~isempty(n)
                poles=cell_prop{nbr,5}{n,1};
                hold on
                circle(poles(1,1), poles(1,2), poles(1,3),0);
                circle(poles(2,1), poles(2,2), poles(2,3),0);
            end
        end
    if moving
    folder=strcat(adresse,'\Movie\Fluo_with_poles_',num2str(t),'.tif');
    else
    folder=strcat(adresse,'\Movie\Non_Moving_Fluo_with_poles_',num2str(t),'.tif');
    end

    saveas(gcf,folder)
    close
end

%% Phase contract with contour
this_image=imadjust(imread(strcat(adresse,'\C0-data.tif'),t));

figure
imshow(this_image)

    for nbr=1:1:nbr_bact
        n=find(t==cell_prop{nbr,7});   
        if ~isempty(n)
            contour=cell_prop{nbr,8}{n,1};
            CM=cell_prop{nbr,3};
            hold on
            plot(contour(:,2),contour(:,1),'r');
            txt = num2str(cell_prop{nbr,1});
            text(contour(1,2),contour(1,1),txt)
            hold on
            plot(CM(:,1),CM(:,2),'g-')    
        end
    end
if moving
folder=strcat(adresse,'\Movie\PC_with_trajectory_',num2str(t),'.tif');
else
folder=strcat(adresse,'\Movie\Non_Moving_PC_with_trajectory_',num2str(t),'.tif');
end
saveas(gcf,folder)
close 
end
end
