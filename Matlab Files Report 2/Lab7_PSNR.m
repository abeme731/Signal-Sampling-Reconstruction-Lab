clc, clear all, close all;

A = {'boygeorgeAudio.au','goreAudio.au','musicAudio.au','speechAudio.au'};
for k=1:length(A)
[y{k}, Fs{k}] = audioread(A{k});
end
fsf=figure();
set(fsf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
for k=1:length(A)
 max_value = max(max(y{k}));
 min_value = min(min(y{k}));
 range = max_value-min_value;
 shift=y{k}-min_value;
 b = 1:7;
 %Quantize not using quantiz
 for i = 1:length(b)
 N=2^i;
 delta = range/(N-1);
 norm=shift/delta;
 rounded=round(norm);
 unnorm=rounded*delta;
 quantized=unnorm+min_value;
 %error signal---------------------------------
 quantized_audio=quantized;
 E=quantized_audio-y{k};
 %signal to noise ratio------------------------
 L1=length(quantized_audio);
 L2=length(E);
 Py=(1/L1)*sum(quantized_audio.^2);
 Pe=(1/L2)*sum(E.^2);
 PSNR=Py/Pe;
 distortion(i)=1/PSNR;
 Fs=8000;
 bit_rate(i)=Fs*i;
 end
 %plot distortion curve not using quantiz
 subplot(4,2,(2*k)-1);
 plot(bit_rate,distortion);
 title(['Distortion Curve not using quantiz on ',A{k}]);
 xlabel('bit rate (bits/s) - Fs(sample/s) * b(bits/sample)');
ylabel('Signal distortion');
 axis tight;
 %Quantize using quantiz
 for i = 1:length(b)
 levels=2^i;
 minv=min(y{k});
 maxv=max(y{k});
 range=maxv-minv;
 delta=range/(levels);
 lowerpart=minv+delta;
 upperpart=maxv-delta;
 lowercode=minv+(delta/2);
 uppercode=maxv-(delta/2);
 [index,quants] = quantiz(y{k},lowerpart:delta:upperpart,lowercode:delta:uppercode);
 %error signal---------------------------------
 E=quants'-y{k};
 %signal to noise ratio------------------------
 L1=length(quants');
 L2=length(E);
 Py=(1/L1)*sum(quants'.^2);
 Pe=(1/L2)*sum(E.^2);
 PSNR=Py/Pe;
 distortion(i)=1/PSNR;
 Fs=8000;
 bit_rate(i)=Fs*i;
 end
 %plot distortion curve using quantiz------------------
 subplot(4,2,2*k);
 plot(bit_rate,distortion);
 title(['Distortion Curve using quantiz on ',A{k}]);
 xlabel('bit rate (bits/s) - Fs(sample/s) * b(bits/sample)');
ylabel('Signal distortion');
 axis tight;
end