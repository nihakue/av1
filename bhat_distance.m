function [ b_distance ] = bhat_distance( rg1, rg2 )
%BHAT_DISTANCE Given two red/green matrices, calculate their distributions
%and Bhattacharyya distance
%Returns the Bhattacharyya distance between them.

%Define the bin centers so that they are uniform accross comparisons
x_vals = 64;
% dx = x_vals(2) - x_vals(1);

% %First we flatten the red green pixel arrays to a 1d array
% 
r1 = rg1(:,1);
g1 = rg1(:,2);
r2 = rg2(:,1);
g2 = rg2(:,2);

%Create histograms

r1_h = hist(r1, x_vals);
r2_h = hist(r2, x_vals);
g1_h = hist(g1, x_vals);
g2_h = hist(g2, x_vals);

%Normalize histograms by dividing their values by 
%the total area of the distribution

r1_h = r1_h ./ (sum(r1_h));
r2_h = r2_h ./ (sum(r2_h));
g1_h = g1_h ./ (sum(g1_h));
g2_h = g2_h ./ (sum(g2_h));

% bar(r1_h);
% bar(r2_h);
% bar(g1_h);
% bar(g2_h);

%Compare using the Bhattycharrya formula
%First for the reds
b_distance = -log(sum(sqrt((r1_h .* g1_h) .* (r2_h .* g2_h))));
% bhat_greens = -log(sum(sqrt(g1_h .* g2_h)));

return;



end

