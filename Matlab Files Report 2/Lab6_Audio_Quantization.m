clc, clear all, close all;
audfls_name = {'musicaudio.au'};
for imgfls_index=1:length(audfls_name)
[audfls_content{imgfls_index}, Fs{imgfls_index}] = audioread(audfls_name{imgfls_index});
% to find the maximum value of a 2 dimensional array
    max_value = max(audfls_content{imgfls_index});
    min_value = min(audfls_content{imgfls_index});
    % Shift down the data to start at 0 instead of at min_value
    shift=audfls_content{imgfls_index}-min_value;
    range = max_value - min_value;
    encode_bits = 1:7; % number of bits needed to encode the number of quantization levels
    %Quantize not using the matlab 'quantiz' function
    fsf(2*imgfls_index-1)=figure(2*imgfls_index-1);
    set(fsf(2*imgfls_index-1), 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
    for encode_bit_index = 1:length(encode_bits)
        levels=2^encode_bit_index; %number of quantization levels
        step = range/(levels-1); %step size or interval between two quantization levels 
        % prepare the data to be quantized so it can be rounded
        % normalize by the step size
        % so every step contains data values of range 1
        down_range=shift/step;
        % round to nearest integer
        % if in the middle go to higher integer
        rounded=round(down_range);
        % un-normalize by the step size
        up_range=rounded*step;
        % add back the minimum value        
        quantized_audio=up_range+min_value;
        %plot quantized signal-----------------------
        subplot((length(encode_bits)+1)/2,2,encode_bit_index);
        plot(quantized_audio);
        title([num2str(encode_bit_index) ' bit quantized ' audfls_name{imgfls_index} ' not using quantiz' ]);
        xlabel('?'); ylabel('?');
        axis tight;
        if (imgfls_index==2 && encode_bit_index==4)%k is the audio file, i is the number of bits
            soundsc(quantized_audio,16000,16)
            % second argument is fs. 
            % may need to change, eg k=2 needs to be played at 16000
        end
    end
    subplot((length(encode_bits)+1)/2,2,length(encode_bits)+1);
    plot(audfls_content{imgfls_index});
    title([' Original ' audfls_name{imgfls_index}]);
    xlabel('?'); ylabel('?');
    axis tight;
    %Quantize using quantiz
    fsf(2*imgfls_index)=figure(2*imgfls_index);
    set(fsf(2*imgfls_index), 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
    for encode_bit_index = 1:length(encode_bits)
        levels=2^encode_bit_index;
        minv=min(audfls_content{imgfls_index});
        maxv=max(audfls_content{imgfls_index});
        range=maxv-minv;
        step=range/(levels);
        lowerpart=minv+step;
        upperpart=maxv-step;
        lowercode=minv+(step/2);
        uppercode=maxv-(step/2);
        [index,quants] = quantiz(audfls_content{imgfls_index},lowerpart:step:upperpart,lowercode:step:uppercode);
        %plot quantized signal-----------------------
        subplot((length(encode_bits)+1)/2,2,encode_bit_index);
        plot(quants);
        title([num2str(encode_bits(encode_bit_index)) ' bit quantized ' audfls_name{imgfls_index} ' using quantiz' ]);
        xlabel('?'); ylabel('?');
        axis tight;
        %{
        if (k==2 && i==4)%k is the audio file, i is the number of bits
            soundsc(quants,8000,16)
        end
        %}
    end
    subplot((length(encode_bits)+1)/2,2,length(encode_bits)+1);
    plot(audfls_content{imgfls_index});
    title([' Original ' audfls_name{imgfls_index}]);
    xlabel('?'); ylabel('?');
    axis tight;
end
