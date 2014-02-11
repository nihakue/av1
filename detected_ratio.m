function detected_ratio( state )
%DETECTED_RATIO Summary of this function goes here
%   Detailed explanation goes here
    load('gtSeq1.mat');
    detected_count = 0;
    count_total = 0;
    
    %start from those marbles which come from left
    
    for i = 1 : 71
        for marblenum=1:size(new_marbles_comingFromRight,2)       % loop over the individual marbles coming from the right
            frameList=new_marbles_comingFromRight(marblenum).frame_numbers(:);  % set of frame this marble appears in
            if ~isempty(frameList)
                last_frame=max(frameList);
                first_frame=min(frameList);
                for frame=first_frame:last_frame   % loop over all frames in list
                    index_a=find(frameList(:)==frame); % get index in full framelist for current frame
                    gt_cr=new_marbles_comingFromRight(marblenum).row_of_centers(index_a); % x left most pixel
                    gt_cc=new_marbles_comingFromRight(marblenum).col_of_centers(index_a); % y of left most pixel
                    if frame == i
                        dist_gt_det= sqrt((gt_cc-state(i).x)^2+(gt_cr-state(i).y)^2); %calculate the distance
                        if dist_gt_det <= 10
                            detected_count = detected_count + 1; %increase by 1 if the detected marble is within 10 pixels
                        end
                        count_total = count_total + 1; %increase by 1 everytime a marble is detected
                    end
                    
                end
            end
        end
        
        %start from those marbles which come from left
        
        for marblenum=1:size(new_marbles_comingFromLeft,2)       % loop over the individual marbles coming from the Left
            frameList=new_marbles_comingFromLeft(marblenum).frame_numbers(:);  % set of frame this marble appears in
            if ~isempty(frameList)
                last_frame=max(frameList);
                first_frame=min(frameList);
                for frame=first_frame:last_frame   % loop over all frames in list
                    index_a=find(frameList(:)==frame); % get index in full framelist for current frame
                    gt_cr=new_marbles_comingFromLeft(marblenum).row_of_centers(index_a); % x left most pixel
                    gt_cc=new_marbles_comingFromLeft(marblenum).col_of_centers(index_a); % y of left most pixel
                    if frame == i
                        dist_gt_det= sqrt((gt_cc-state(i).x)^2+(gt_cr-state(i).y)^2); %calculate the distance
                        if dist_gt_det <= 10
                            detected_count = detected_count + 1; %increase by 1 if the detected marble is within 10 pixels
                        end
                        count_total = count_total + 1; %increase by 1 everytime a marble is detected
                    end
                    
                end
            end
        end
    end
    
   ratio = detected_count/count_total;
   
   return;

end

