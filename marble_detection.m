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
show_images = 1;
show_groups = 1;

sub_thresh = 18;

orange = [255/255 204/255 0];

Imback = double(Im1);
ImbackChroma = chroma(Imback);
[MR, MC, Dim] = size(Imback);
fore = zeros(MR,MC);
state = repmat(struct('x', -1, 'y', -1, 'area', -1, 'radius', -1, 'r', -1, 'g', -1, 'b', -1), 18, 71);



for i = 4 : 71
    %Load the frame
    Im = imread(['SEQ1/', int2str(i), '.jpg'], 'jpg');
    Imwork = double(Im);
    ImworkChroma = chroma(Imwork);
    
    rIm = Im(:,:,1);
    gIm = Im(:,:,2);
    bIm = Im(:,:,3);
    
    
    %Background subtraction creates binary image
%     fore = (abs(Imwork(:,:,1)-Imback(:,:,1)) > sub_thresh) ...
%          | (abs(Imwork(:,:,2) - Imback(:,:,2)) > sub_thresh) ...
%          | (abs(Imwork(:,:,3) - Imback(:,:,3)) > sub_thresh);
     
     fore = (((ImworkChroma(:,:,3)./ImbackChroma(:,:,3)) < 0.8) ...
         | ((ImworkChroma(:,:,3)./ImbackChroma(:,:,3)) > 1.2))...
         .* mask;
     
     
    %Apply image morphology to clean up the groups
    forem = fore;
    forem = bwmorph(fore, 'dilate', 2);
    forem = bwmorph(forem, 'fill');
%     forem = bwmorph(fore, 'erode', 4);
%     forem = bwmorph(forem, 'dilate', 4);
    labeled = bwlabel(forem, 8);
    stats = regionprops(labeled, ['basic']);
    [N, W] = size(stats);
    
    centroids = zeros(length(stats), 2);
    radii = zeros(length(stats), 1);
    
    
 %   centroids = zeros(length(stats), 2);
 %   radii = zeros(length(stats));

    c = 0;
    for j = 1 : N
        %Filter out non-marble sized groups
        if stats(j).Area > 60
            if stats(j).Area < 1500
                c = c+1;
                centroids(j,:) = stats(j).Centroid;
                radii(j) = sqrt(stats(j).Area/pi);
                
                state(c,i).x = centroids(j,1);
                state(c,i).y = centroids(j,2);
                state(c,i).radius = radii(j);
                state(c,i).area = stats(j).Area;
                
                index = floor(centroids(j,:));
                val = labeled(index(2),index(1));
                
                state(c,i).r = sum(rIm(labeled==val))/length(rIm(labeled==val));
                state(c,i).g = sum(gIm(labeled==val))/length(gIm(labeled==val));
                state(c,i).b = sum(bIm(labeled==val))/length(bIm(labeled==val));
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
%         pause(0.3);
end
