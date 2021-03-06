function img_chroma = chroma( image )
%CHROMA Converts an RGB double image into a chromaticity array
%   Detailed explanation goes here
    Im_n = image(:,:,1) + image(:,:,2) + image(:,:,3);
    Im_cr = image(:,:,1)./Im_n;
    Im_cg = image(:,:,2)./Im_n;
    
    img_chroma = zeros(size(image));
    img_chroma(:,:,1) = Im_cr;
    img_chroma(:,:,2) = Im_cg;
    img_chroma(:,:,3) = Im_n/3;
    
    return;

end

