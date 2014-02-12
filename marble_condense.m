function marble_condense()
load('all_states.mat');

count = 0;
total = 0;
new_id = 1;
left_colors = {};
right_colors = {};
color_threshold = 0.15;

marbles = repmat(struct('rows', [], 'cols', [], 'frame_list', []), 1, 20);

for frame = 2: 70
    c_state = all_states(:,frame);
    p_state = all_states(:, frame-1);
    
    for m = 1:length(c_state)
        if c_state(m).row == -1
            %We've looked at all the marbles in the current frame
            break;
        end
        %Assume new
        new = true;
        row = c_state(m).row;
        col = c_state(m).col;
        rg_distr = c_state(m).rg_distr;
        
        %If a marble is near the top left and right corners, it is probably
        %new
        if row < ((1/8) * 480) && frame < 35
            if col < ((1/2) * 640)
                %check to see if it's in left_colors already
                for j = 1:length(left_colors)
                    d = bhattacharyya(rg_distr, cell2mat(left_colors(j)));
                    if d < color_threshold
                        new = false;
                        break;
                    end
                end
                if new
                    left_colors(end+1) = {rg_distr};
                    c_state(m).id = new_id;
                    new_id = new_id + 1;
                end
            else
                %check to see if it's in right_colors already.
                for j = 1:length(right_colors)
                    d = bhattacharyya(rg_distr, cell2mat(right_colors(j)));
                    if d < color_threshold
                        new = false;
                        break;
                    end
                end
                if new
                    right_colors(end+1) = {rg_distr};
                    c_state(m).id = new_id;
                    new_id = new_id + 1;
                end
            end
        else
            new = false;
            
        end
        
        if ~new
            min_dist = 9999;
            min_bhat = 9999;
            min_b_idx = 0;
            min_d_idx = 0;
            for p = 1:length(p_state)
                if p_state(p).row == -1
                    %We've looked at all the marbles.
                    break;
                end
                temp_dist = norm([c_state(m).row c_state(m).col] - [p_state(p).row p_state(p).col]);
                if temp_dist < min_dist
                    min_d_idx = p;
                    min_dist = temp_dist;
                end
                temp_bhat = bhattacharyya(c_state(m).rg_distr, p_state(p).rg_distr);
                if temp_bhat < min_bhat
                    min_b_idx = p;
                    min_bhat = temp_bhat;
                end
            end
            if min_b_idx == min_d_idx
                %It's very likely that we've found a match
                id = min_b_idx;
                count = count + 1;
                c_state(m).id = p_state(id).id;
                
                %Place marble in the final marble struct array
                marbles(id).rows(end+1) = row;
                marbles(id).cols(end+1) = col;
                marbles(id).frame_list(end+1) = frame;
            else
                %For now, go with closest color
                c_state(m).id = min_b_idx;
                marbles(id).rows(end+1) = row;
                marbles(id).cols(end+1) = col;
                marbles(id).frame_list(end+1) = frame;
            end
        end
        total = total + 1;
        
    end
    all_states(:,frame) = c_state;
end
    count/total
    save('marbles.mat', 'marbles');
end




