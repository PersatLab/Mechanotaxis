function [poles] = poles_coordinate(Bact_info,t)
     skeleton=Bact_info{t,2}.CellMedialAxisCoordinates;
     cell_width=Bact_info{t,2}.CellWidth; 
     poles(1,1)=skeleton(2,2);
     poles(1,2)=skeleton(2,1);
     poles(2,1)=skeleton(end-1,2);
     poles(2,2)=skeleton(end-1,1);
     poles(1:2,3)=cell_width/1.8; % I found 1.8 is the optimum value
end