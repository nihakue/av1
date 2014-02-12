load('all_states.mat');

count = 0;
total = 0;
new_id = 1;

for i = 22: 70
    c_state = all_states(:,i);
    p_state = all_states(:, i-1);
    
    for m = 1:length(c_state)
        if c_state(m).row == -1
            continue;
        end
        min_dist = 9999;
        min_bhat = 10;
        min_b_idx = 0;
        min_d_idx = 0;
        for p = 1:length(p_state)
            if p_state(p).row == -1
                continue;
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
            count = count + 1;
            c_state(m).id = p_state(min_b_idx).id
        end
        total = total + 1;
        
    end
    all_states(:,i) = c_state;
end

count/total
