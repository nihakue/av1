function trajectories( )
%TRAJECTORIES Plots the trajectories and evaluates their accuracy against
%the ground truth

load('marbles.mat');
load('gtSeq1.mat');

figure(2)   % figure to show all trajectories
current_frame=imread('SEQ1/1.jpg', 'jpg');
imshow(current_frame);
hold on;

num_detects = zeros(20, 1);
all_rows=zeros(20,200);
all_cols=zeros(20,200);
color_list=['wrgbykmc'];

%Loop through the marble IDs
for m = 1: size(marbles, 2)
    frames = marbles(m).frame_list;
    if ~isempty(frames)
        for f = min(frames):max(frames)
            if isempty(find(frames == f))
                continue;
            end
                %Loop through frames this marble appeared in
                index_a = find(frames(:)==f); % get index in full framelist for current frame
                num_detects(m)=num_detects(m)+1;
                %Again we switch row and columns because images and sad
                %:(
            col = marbles(m).cols(index_a);
            row = marbles(m).rows(index_a);
            all_rows(num_detects(m))=col(1); 
            all_cols(num_detects(m))=row(1);
        end
        plot(all_rows(1:num_detects(m)),all_cols(1:num_detects(m)),[color_list(mod(m,8)+1) '*-'])
    end
end
end