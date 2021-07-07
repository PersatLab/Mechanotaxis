function [] = plotProfiles(Title, Legend, alpha, linewidth, dim, Colors, filled_plot, y_limit, k, varargin)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

k2 = [k, fliplr(k)];
for i=10:nargin
    hold on;
    plot(k, mean(varargin{i-9},dim), 'Color', Colors(i-9,:)/256,'LineWidth',linewidth);
end

for j=10:nargin
    top = mean(varargin{j-9},dim)+ std(varargin{j-9});
    bottom = mean(varargin{j-9},dim)- std(varargin{j-9});
    if (filled_plot)
        inBetween = [top, fliplr(bottom)];
        fill(k2, inBetween, Colors(j-9,:)/256,'FaceAlpha',alpha, 'EdgeColor', 'none');
    end
    plot(k, top, k, bottom, 'Color', Colors(j-9,:)/256, 'LineStyle', '--','LineWidth',linewidth-1);
end

legend(Legend, 'Location', 'Best');
ylim(y_limit);
xlabel('Normalized distance from midcell');
ylabel('fluorescence');
title(Title);

end

