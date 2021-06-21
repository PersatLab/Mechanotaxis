function [masque]=mask(x,y,radii,xDim,yDim)

[xx,yy]=meshgrid(1:yDim,1:xDim);

masque=false(xDim,yDim);

masque=masque|hypot(xx-x,yy-y)<=radii;

end

