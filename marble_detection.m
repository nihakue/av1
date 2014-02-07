Im1 = double(imread('SEQ1/1.jpg', 'jpg'));
Im2 = double(imread('SEQ1/2.jpg', 'jpg'));
Im3 = double(imread('SEQ1/3.jpg', 'jpg'));
%Import mask image and inverse it becuase weird imread.
mask = ~imread('mask.bmp', 'bmp');

% Im1_c = chroma(Im1);
% Im2_c = chroma(Im2);
% Im3_c = chroma(Im3);
% 
% Imback = (Im1 + Im2 + Im3) / 3;

show_centroids = 1;
show_circum = 1;
show_images = 0;
show_groups = 1;
show_bb = 0;

sub_thresh = 18;

orange = [255/255 204/255 0];

Imback = double(Im1);
ImbackChroma = chroma(Imback);
[MR, MC, Dim] = size(Imback);
fore = zeros(MR,MC);
state = repmat(struct('x', -1, 'y', -1, 'area', -1, 'radius', -1, 'rg_distr', -1), 18, 71);



for i = 4 : 71
    %Load the frame
    Im = imread(['SEQ1/', int2str(i), '.jpg'], 'jpg');
    Imwork = double(Im);
    ImworkChroma = chroma(Imwork);
    
    
    %Background subtraction creates binary image
%     fore = (abs(Imwork(:,:,1)-Imback(:,:,1)) > sub_thresh) ...
%          | (abs(Imwork(:,:,2) - Imback(:,:,2)) > sub_thresh) ...
%          | (abs(Imwork(:,:,3) - Imback(:,:,3)) > sub_thresh);
     
     fore = (((ImworkChroma(:,:,3)./ImbackChroma(:,:,3)) < 0.8) ...
         | ((ImworkChroma(:,:,3)./ImbackChroma(:,:,3)) > 1.2))...
         .* mask;
     
     
    %Apply image morphology to clean up the groups
    forem = fore;
    forem = bwmorph(fore, 'dilate', 4);
    forem = bwmorph(forem, 'fill');
%     forem = bwmorph(fore, 'close', 4);
%     forem = bwmorph(forem, 'dilate', 4);
    labeled = bwlabel(forem, 8);
    stats = regionprops(labeled, ['basic']);
    [N, W] = size(stats);
    
    

    for j = 1 : N
        curr_area = stats(j).Area;
        %Filter out non-marble sized groups
        if curr_area > 60
            if curr_area < 900
                %Do nothing yet
            %We may have a situation where multiple marbles are
            %conjoined.    radii(j) = sqrt(curr_area/pi);
            %Case where number of marbles == 3
            elseif curr_area < 1700
                %first we find the pixels for the object in question
                [conj_row, conj_col] = find(labeled == j);
                %then we calculate the kmean clusters for the case where
                %there are 2 marbles
                km = kmeans([conj_row, conj_col], 2);
                %then we change their labels in the original bw matrix
                for k = 1 : length(conj_row)
                    labeled(conj_row(k), conj_col(k)) = km(k) + N;
                end
            %Case where number of marbles == 3
            elseif curr_area < 2400
                %same as 2 case, just more clusters
                [conj_row, conj_col] = find(labeled == j);
                km = kmeans([conj_row, conj_col], 3);
                for k = 1: length(conj_row)
                    labeled(conj_row(k), conj_col(k)) = km(k) + N;
                end
            end
        end
    end
    
    stats = regionprops(labeled, ['basic']);
    [N, W] = size(stats);
    centroids = zeros(length(stats), 2);
    radii = zeros(length(stats));
    
    for j = 1 : N
        centroids(j,:) = stats(j).Centroid;
        radii(j) = sqrt(stats(j).Area/pi);
    end
    
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
       for k = 1 : size(radii)
           radius = radii(k);
           if radius == 0
               continue
           end
           for c = -0.97 * radius: radius/20 : 0.97 * radius
               r = sqrt(radius^2-c^2);
               plot(centroids(k, 1) + c, centroids(k, 2) + r, 'Color', 'cyan', 'Marker', '.');
               plot(centroids(k, 1) + c, centroids(k, 2) - r, 'Color', 'cyan', 'Marker', '.');
           end
       end
    end
    if show_bb > 0
        for b = 1 : length(stats)
            rectangle('Position', stats(b).BoundingBox, 'EdgeColor', 'w')
        end
    end
    
        pause(0.3);
        
end
