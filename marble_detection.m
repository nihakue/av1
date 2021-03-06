function [ratio, distance] = marble_detection (threshold, gain, headless)
%Default arguments
if nargin == 0
    headless = true;
    threshold = 1088.9;
    gain = .8444;
end

%Load model background image
Im1 = double(imread('SEQ1/1.jpg', 'jpg'));

%Import mask image and invert it becuase weird imread.
mask = ~imread('mask.bmp', 'bmp');

% Im1_c = chroma(Im1);
% Im2_c = chroma(Im2);
% Im3_c = chroma(Im3);
% 
% Imback = (Im1 + Im2 + Im3) / 3;

show_centroids = 1;
show_circum = 0;
show_images = 1;
show_groups = 0;
show_bb = 0;
pause_length = 0.3;

if headless
    show_centroids = 1;
    show_circum = 0;
    show_images = 1;
    show_groups = 0;
    show_bb = 0;
    pause_length = 0;
end


orange = [255/255 204/255 0];

Imback = double(Im1);
ImbackChroma = chroma(Imback);
[MR, MC, Dim] = size(Imback);
fore = zeros(MR,MC);
all_states = repmat(struct('row', -1, 'col', -1, 'rg_distr', -1, 'id', -1), 18, 71);



for i = 1 : 71
    %Load the frame
    Im = imread(['SEQ1/', int2str(i), '.jpg'], 'jpg');
    Imwork = double(Im);
    ImworkChroma = chroma(Imwork);
    
    %seperate the reds and greens for linear indexing
    reds = ImworkChroma(:,:,1);
    greens = ImworkChroma(:,:,2);
    
    %Get the state for current frame
    curr_state = all_states(:, i);
    
    
    %Background subtraction creates binary image
%     fore = (abs(Imwork(:,:,1)-Imback(:,:,1)) > sub_thresh) ...
%          | (abs(Imwork(:,:,2) - Imback(:,:,2)) > sub_thresh) ...
%          | (abs(Imwork(:,:,3) - Imback(:,:,3)) > sub_thresh);
     
     fore = (((ImworkChroma(:,:,3)./ImbackChroma(:,:,3)) < 0.87) ...
         | ((ImworkChroma(:,:,3)./ImbackChroma(:,:,3)) > 1.2))...
         .* mask;
     
     
    %Apply image morphology to clean up the groups
    forem = fore;
    forem = bwmorph(fore, 'dilate', 4);
    forem = bwmorph(forem, 'fill');
    labeled = bwlabel(forem, 4);
    stats = regionprops(labeled, 'Centroid', 'Area', 'PixelIdxList', 'BoundingBox');
    [N, W] = size(stats);
    
    
%Use K means clustering to differentiate between clumps of marbles
    for j = 1 : N
        curr_area = stats(j).Area;
        %Filter out non-marble sized groups
        if curr_area > 80
            if curr_area < threshold
                %Single marble, do nothing
            %We may have a situation where multiple marbles are
            %conjoined.
            
            %Case where number of marbles == 3
            elseif curr_area < (threshold * gain * 2)
                %first we find the pixels for the object in question
                [conj_row, conj_col] = find(labeled == j);
                %then we calculate the kmean clusters for the case where
                %there are 2 marbles
                km = kmeans([conj_row, conj_col], 2);
                %then we change their labels in the original bw matrix
                for k = 1 : length(conj_row)
                    if km(k) == 1
                        labeled(conj_row(k), conj_col(k)) = j;
                    else
                        labeled(conj_row(k), conj_col(k)) = N + 1;
                    end
                end
                N = N + 1;
            %Case where number of marbles == 3
            elseif curr_area < (threshold * gain * 3)
                %same as 2 case, just more clusters
                [conj_row, conj_col] = find(labeled == j);
                km = kmeans([conj_row, conj_col], 3);
                for k = 1: length(conj_row)
                    if km(k) == 1
                        labeled(conj_row(k), conj_col(k)) = j;
                    elseif km(k) == 2
                        labeled(conj_row(k), conj_col(k)) = N + 1;
                    elseif km(k) == 3
                        labeled(conj_row(k), conj_col(k)) = N + 2;
                    end
                end
                N = N + 2;
            %Case where number of marbles == 4
            elseif curr_area < (threshold * gain * 4)
            %same as 3 case, just more clusters (4)
            [conj_row, conj_col] = find(labeled == j);
            km = kmeans([conj_row, conj_col], 4);
            for k = 1: length(conj_row)
                if km(k) == 1
                    labeled(conj_row(k), conj_col(k)) = j;
                elseif km(k) == 2
                    labeled(conj_row(k), conj_col(k)) = N + 1;
                elseif km(k) == 3
                    labeled(conj_row(k), conj_col(k)) = N + 2;
                elseif km(k) == 4
                    labeled(conj_row(k), conj_col(k)) = N + 3;  
                end
            end
            N = N + 3;
            %Case where number of marbles == 5
            elseif curr_area < (threshold * gain * 5)
            %same as 4 case, just more clusters (5)
            [conj_row, conj_col] = find(labeled == j);
            km = kmeans([conj_row, conj_col], 5);
            for k = 1: length(conj_row)
                if km(k) == 1
                    labeled(conj_row(k), conj_col(k)) = j;
                elseif km(k) == 2
                    labeled(conj_row(k), conj_col(k)) = N + 1;
                elseif km(k) == 3
                    labeled(conj_row(k), conj_col(k)) = N + 2;
                elseif km(k) == 4
                    labeled(conj_row(k), conj_col(k)) = N + 3;  
                elseif km(k) == 5
                    labeled(conj_row(k), conj_col(k)) = N + 4;
                end
            end
            N = N + 4;
            end
        end
    end
    
    stats = regionprops(labeled, 'Centroid', 'Area', 'PixelIdxList', 'BoundingBox');
    centroids = zeros(18, 2);
    radii = zeros(18);
    
    %Now that marbles have been refined with k means, we can assign the
    %state vector.
    for j = 1 : N
        centroids(j,:) = stats(j).Centroid;
        radii(j) = sqrt(stats(j).Area/pi);
        %Because of matlab row/column and x/y confusion, provisionaly swap
        %place of centroid indices row/col to col/row
        curr_state(j).col = stats(j).Centroid(1);
        curr_state(j).row = stats(j).Centroid(2);
        curr_state(j).rg_distr = [reds(stats(j).PixelIdxList) greens(stats(j).PixelIdxList)];
    end
    
    all_states(:, i) = curr_state;
    %Drawing functions
    if ~headless
        figure(1)
        clf
        if show_images > 0
            imshow(Im);
            hold on
        else if show_groups
                imshow(forem)
                hold on
            end
        end

        if show_centroids > 0
            centroids_r = centroids(:,1);
            centroids_c = centroids(:,2);
            plot(centroids_r, centroids_c, 'r.');
        end

        if show_circum > 0
           for k = 1 : 18
               radius = radii(k);
               if radius == 0
                   continue
               end
               circle(centroids(k, 1), centroids(k, 2), radius/1.5, 'b');
           end
        end
        if show_bb > 0
            for b = 1 : length(stats)
                rectangle('Position', stats(b).BoundingBox, 'EdgeColor', 'w')
            end
        end
    end
    pause(pause_length);
end

[ratio, distance] = performance(all_states);
save('all_states.mat', 'all_states');
end