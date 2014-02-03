Im1 = double(imread('SEQ1/1.jpg', 'jpg'));
Im2 = double(imread('SEQ1/2.jpg', 'jpg'));
Im3 = double(imread('SEQ1/3.jpg', 'jpg'));

% Im1_c = chroma(Im1);
% Im2_c = chroma(Im2);
% Im3_c = chroma(Im3);
% 
% Imback = (Im1 + Im2 + Im3) / 3;

show_centroids = 1;
show_circum = 0;
show_images = 1;
show_groups = 0;
sub_thresh = 15;

Imback = Im1;
[MR, MC, Dim] = size(Imback);
fore = zeros(MR,MC);

for i = 4 : 71
    %Load the image
    Im = imread(['SEQ1/', int2str(i), '.jpg'], 'jpg');
    Imwork = double(Im);
    
    %Background subtraction
    fore = (abs(Imwork(:,:,1)-Imback(:,:,1)) > sub_thresh) ...
         | (abs(Imwork(:,:,2) - Imback(:,:,2)) > sub_thresh) ...
         | (abs(Imwork(:,:,3) - Imback(:,:,3)) > sub_thresh);
     
     
    %Apply image morphology to clean up the groups
    forem = bwmorph(fore, 'erode', 4);
    forem = bwmorph(forem, 'dilate', 4);
    labeled = bwlabel(forem, 8);
    stats = regionprops(labeled, ['basic']);
    [N, W] = size(stats);

    balls = stats;
    centroids = zeros(size(stats), 2);
    radii = zeros(size(stats), 1);

    for i = 1 : N
        %Filter out non-marble sized groups
        if stats(i).Area > 100
            if stats(i).Area < 1000
                stats(i).Area
                centroids(i,:) = stats(i).Centroid;
                radii(i) = sqrt(stats(i).Area/pi);
            end
        end
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
       for i = 1 : size(radii)
           radius = radii(i);
           if radius == 0
               continue
           end
           for c = -0.97 * radius: radius/20 : 0.97 * radius
               r = sqrt(radius^2-c^2);
               plot(centroids(i, 1) + c, centroids(i, 2) + r, 'g.');
               plot(centroids(i, 1) + c, centroids(i, 2) - r, 'g.');
           end
       end
    end
        pause(0.3);
end
