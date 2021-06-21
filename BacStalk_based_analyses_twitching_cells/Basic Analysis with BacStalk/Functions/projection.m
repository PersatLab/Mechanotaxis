function [resultat] = projection(int_norm,dep_norm)
resultat=zeros(size(dep_norm,1),1);
for k=1:1:size(dep_norm,1)
    resultat(k)=dot(int_norm{k},dep_norm{k});    
end
end

