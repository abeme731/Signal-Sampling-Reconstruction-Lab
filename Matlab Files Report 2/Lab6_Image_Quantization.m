clc, clear all, close all;
imgfls_name= {'skullImage.jpg'};
for imgfls_index=1:length(imgfls_name)
[imgfls_content{imgfls_index}, Fs{imgfls_index}] = imread(imgfls_name{imgfls_index}); 
    max_value = max(imgfls_content{imgfls_index}(:));
    min_value = min(imgfls_content{imgfls_index}(:));
    range = max_value - min_value;
    % Shift down the data to start at 0 instead of at min_value
    down_shifted=imgfls_content{imgfls_index}-min_value;
    % Number of bits used to encode the quantization levels
    encode_bits = 1:7;
    % Create a figure to plot the quantized images
    fsf(2*imgfls_index-1)=figure(2*imgfls_index-1);
    % Enlarge to fullscreen
    set(fsf(2*imgfls_index-1), 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
    % Quantization not using matlab's image imquantize function
    % run through the i loop for every value of b
    for encode_bit_index = 1:length(encode_bits)
        levels=2^encode_bit_index;
        step = range/(levels-1);
        % prepare the data to be quantized so it can be rounded
        % normalize by the step size
        % so every step contains data values of range 1
        down_range=down_shifted/step;
        % round to nearest integer
        % if in the middle go to higher integer
        rounded=round(down_range);
        % un-normalize by the step size
        up_range=rounded*step;
        % add back the minimum value to create the quantized image to N
        % levels
        quantized_image= up_range+min_value;
        % plot the quantized images 
        subplot((length(encode_bits)+2)/3,3,encode_bit_index);
        imshow(quantized_image);
        title([num2str(encode_bit_index) ' bit quantized ' imgfls_name{imgfls_index} ' not using quantiz']);
    end
    % plot the original image 
    subplot((length(encode_bits)+2)/3,3,length(encode_bits)+1);
    imshow(imgfls_content{imgfls_index});
    title(['Original ' imgfls_name{imgfls_index}]);
 
 
    % Quantization using matlab's imquantize function
    % Note that imquantize/multithresh allows only up to 20 levels.
    for encode_bit_index = 1 : 4
        numLevels = 2^(encode_bit_index);
        partition = multithresh(imgfls_content{imgfls_index}, numLevels-1);
        codebook = [partition max(imgfls_content{imgfls_index}(:))];
        [imquantized_image, index] = imquantize(imgfls_content{imgfls_index},partition,codebook);
        %plot quantized signal-----------------------
        fsf(2*imgfls_index)=figure(2*imgfls_index);
        % Enlarge figure to full screen.
        set(fsf(2*imgfls_index), 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
        subplot((length(encode_bits)+2)/3,3,encode_bit_index);
        imshow(imquantized_image);
        title([num2str(numLevels) ' levels quantized ' imgfls_name{imgfls_index} ' using imquantize']);
    end
    % plot the original image 
    subplot((length(encode_bits)+2)/3,3,4+1);
    imshow(imgfls_content{imgfls_index});
    title(['Original ' imgfls_name{imgfls_index}]);
end
