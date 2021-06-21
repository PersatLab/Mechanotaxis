function circle(x,y,r,binary)
%x and y are the coordinates of the center of the circle
%r is the radius of the circle
%0.01 is the angle step, bigger values will draw the circle faster but
%you might notice imperfections (not very smooth)
ang=0:0.01:2*pi; 
xp=r*cos(ang);
yp=r*sin(ang);

if binary %in blue
plot(x+xp,y+yp,'b','Linewidth',0.5);
else % in red
plot(x+xp,y+yp,'r','Linewidth',0.5);    
end

end