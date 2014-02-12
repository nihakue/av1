function performance(all_states)
%PERFORMANCE Summary of this function goes here
%   Detailed explanation goes here
    gt=load('gtSeq1.mat');
    detected_count = 0;
    count_total = 0;
    
    right_coming_frames=gt.new_marbles_comingFromRight
 
    for marblenum=1:size(right_coming_frames,2)      % loop over the individual marbles coming from the right
        frameList=right_coming_frames(marblenum).frame_numbers(:);
        if ~isempty(frameList)
        
            for p = 1 : length(frameList)
                gt_m_array=[right_coming_frames(marblenum).row_of_centers(p) right_coming_frames(marblenum).col_of_centers(p)]
                    
                    for k =1:18                     
                       dt_m_array=all_states(k,frameList(p)).centroid
                       dis_m_centroid=norm(dt_m_array-gt_m_array)
                       if dis_m_centroid<=10
                           detected_count = detected_count+1;
                       end
                          count_total = count_total+1;
                    end
            end
        end
        
    end
    
    
    left_coming_frames=gt.new_marbles_comingFromLeft
 
    for marblenum=1:size(left_coming_frames,2)      % loop over the individual marbles coming from the right
        frameList=left_coming_frames(marblenum).frame_numbers(:);
        if ~isempty(frameList)
          for p = 1 : length(frameList)
                gt_m_array=[left_coming_frames(marblenum).row_of_centers(p) left_coming_frames(marblenum).col_of_centers(p)]
                    for k =1:18
                       dt_m_array=all_states(k,frameList(p)).centroid
                       dis_m_centroid=norm(dt_m_array-gt_m_array)
                       if dis_m_centroid<=10
                           detected_count = detected_count+1;
                       end
                          count_total = count_total+1;
                    end
           end
        end
        
    end
    
    ratio=detected_count/count_total;
    
    return ;
end