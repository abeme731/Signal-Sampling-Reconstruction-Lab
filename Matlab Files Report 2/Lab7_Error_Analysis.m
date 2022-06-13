clc, clear all, close all;
A = {'speechAudio.au'};
for k=1:length(A)
[y{k}, Fs{k}] = audioread(A{k});
end

for k = 1:length(A)
 z = double(y{k});
 max_value = max(y{k});
 min_value = min(y{k});
 range = max_value-min_value;
 shift=z-min_value;
 b = 1:8;% bits to encode new quantizing levels
 %Quantize not using quantiz                     good
 

 for i = 1:length(b)
 N=2^i;% number of new quantizing levels (2,4,8,16,32...256)
 delta = range/(N-1);%step size between two vels
 norm=shift/delta ;
 rounded=round(norm);
 unnorm=rounded*delta;
 quantized_audio=unnorm+min_value;
 %plot quantized signal----------------------- good
  fsf(10*k+1)=figure(10*k+1);
 set(fsf(10*k+1), 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);%fullscreen
 
 subplot(length(b)/2,2,i);
 plot(quantized_audio);
 title([num2str(i) ' bit quantized ' A{k} ' not using quantiz' ]);
 xlabel('Sample number'); ylabel('Quantized audio');
 axis tight;
 
 %error signal & histogram-------------------- safe
 E=quantized_audio-y{k};
 fsf(10*k+2)=figure(10*k+2);
 set(fsf(10*k+2), 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
 subplot(length(b)/2,2,i);
 hist(E,20);
        title([A{k} ' Error Histogram not using quantiz for b = ' num2str(i)]);
 xlabel('Error Magnitude'); ylabel('Sample instances');
 
 
 %autocorrelation for error signal and plot---------   good
 [r,lags]=xcorr(E,200,'unbiased');
 fsf(10*k+3)=figure(10*k+3);
 set(fsf(10*k+3), 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
 subplot(length(b)/2,2,i);
 plot(lags,r);
        title([A{k} ' Autocorrelation not using quantiz for b = ' num2str(b(i))]);
        
 xlabel('lag'); ylabel('Auto-correlation');
 axis tight;
 %cross-correlation and plot------------------ good
 [c,lags]=xcorr(E,quantized_audio,200,'unbiased');
 fsf(10*k+4)=figure(10*k+4);
 set(fsf(10*k+4), 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
 subplot(length(b)/2,2,i);
 plot(lags,c);
title([A{k} ' Cross-correlation using quantiz for b = ' num2str(i)]);

 xlabel('lag'); ylabel('Cross-correlation');
 axis tight;
 end

 
 %Quantize using quantiz                           ///good
 for i = 1:length(b)
 levels=2^i;
 minv=min(z);
 maxv=max(z);
 range=maxv-minv;
 delta=range/(levels);
 lowerpart=minv+delta;
 upperpart=maxv-delta;
 lowercode=minv+(delta/2);
 uppercode=maxv-(delta/2);
 [index,quants] = quantiz(z,lowerpart:delta:upperpart,lowercode:delta:uppercode);
 %plot quantized signal----------------------- //good
fsf(10*k+5)=figure(10*k+5);
        set(fsf(10*k+5), 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);

 subplot(length(b)/2,2,i);
 plot(quants);
 title([num2str(b(i)) ' bit quantized ' A{k} ' using quantiz' ]);
 xlabel('Sample number'); ylabel('Quantized audio');
 axis tight;
 
 
 %error signal & histogram--------------------
 E=quants'-y{k};
 fsf(10*k+6)=figure(10*k+6);
 set(fsf(10*k+6), 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
 subplot(length(b)/2,2,i);
 hist(E,20);
 title([A{k} ' Error Histogram using quantiz for b = ' num2str(b(i))]);

 xlabel('Error Magnitude'); ylabel('Sample instances');
 %autocorrelation for error signal and plot---------
 [r,lags]=xcorr(E,200,'unbiased');
 fsf(10*k+7)=figure(10*k+7);
 set(fsf(10*k+7), 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
 subplot(length(b)/2,2,i);
 plot(lags,r);
        title([A{k} ' Autocorrelation using quantiz for b = ' num2str(b(i))]);

 xlabel('sample lag'); ylabel('Auto-correlation');
 axis tight;
 %cross-correlation and plot------------------
 [c,lags]=xcorr(E,quants',200,'unbiased');
 fsf(10*k+8)=figure(10*k+8);
 set(fsf(10*k+8), 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
 subplot(length(b)/2,2,i);
 plot(lags,c);
 title([A{k} ' Cross-correlation using quantiz for b = ' num2str(i)]);
 xlabel('sample lag'); ylabel('Cross-correlation');
 axis tight;
 end
end