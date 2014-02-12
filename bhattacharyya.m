function b_distance = bhattacharyya( rg1, rg2 )
%BHAT_DISTANCE Given two red/green matrices, calculate their distributions
%and Bhattacharyya distance
%Returns the Bhattacharyya distance between them.

%Define the bin centers so that they are uniform accross comparisons
x_vals = linspace(0, 1, 32);
bins = {x_vals};
rg1_hist = hist3(rg1, [bins bins]);
rg2_hist = hist3(rg2, [bins bins]);

%Normalize to make a probability distribution
rg1_hist = rg1_hist ./ sum(sum(rg1_hist));
rg2_hist = rg2_hist ./ sum(sum(rg2_hist));

%Compute the Bhattacharyya distace
b_distance = -log(sum(sum(sqrt(rg1_hist .* rg2_hist))));

return;
    
end

