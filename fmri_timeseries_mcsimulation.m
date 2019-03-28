% monte carlo simulation of fmri timeseries based on SPM.mat

mc=100; % 100 repetitions are enough to get decent estimates for each condition
load('SPM.mat'); % place SPM.mat in the same directory or specify path
baseline=SPM.xX.X(1:end,1);
allactive(1:length(baseline),1)=SPM.xX.X(1:end,2);
allactive(1:length(baseline),2)=SPM.xX.X(1:end,3);
original_hrf_timeseries=sum(allactive,2);
% plot(baseline,'g'); hold on, plot(allactive(1:length(baseline),1),'b'); hold on, plot(allactive(1:length(baseline),1),'k'); hold on, plot(hrf_timeseries,'r')

% adjust for new design - this must be entered manually
start_1st_baseline=12-6;
end_1st_baseline=12;
start_1st_nfblock=24-6;
end_1st_nfblock=24;
cycle_length=27;

% simulation of the BOLD signal 
psc_vector=(0.5:0.1:1); % range from 0.5...1 percent signal change
noise_factor_vector=(0.3:0.1:1.9); % noise levels in range of 0.3...1.9
for v=1:length(psc_vector)
    psc=psc_vector(v);
    for w=1:length(noise_factor_vector)
        noise_factor=noise_factor_vector(w);
        for repetitions=1:mc
            hrf_timeseries=original_hrf_timeseries;
            % scaling with psc level (if psc==1 we have the original psc level from the original SPM.mat)
            for i=1:length(hrf_timeseries)
                hrf_timeseries(i)=hrf_timeseries(i)*psc;
            end
            % figure, plot(hrf_timeseries,'b')
            
            % blockwise change of individual performance (necessary to create some variance and probably more realistic)
            for j=1:length(hrf_timeseries)
                if hrf_timeseries(j)>0
                    begin=j;
                    break,
                end
            end
            periods=floor(length(hrf_timeseries)/cycle_length)+1;
            performance_levels(1:periods)=1+0.25.*randn(periods,1);
            trials=1;
            for j=1:length(hrf_timeseries)
                if j<=trials*cycle_length+begin & j>(trials-1)*cycle_length+begin
                    hrf_timeseries(j)=hrf_timeseries(j)*performance_levels(trials);
                end
                if j==trials*cycle_length+begin
                    trials=trials+1;
                end
            end
            % hold on, plot(hrf_timeseries,'b')
            
            % shift the time series to a realistic mean value and scale it accordingly
            timeseries_mean=700+randi(300,1,1);
            for k=1:length(hrf_timeseries)
                shifted_timeseries(k)=timeseries_mean+hrf_timeseries(k)*timeseries_mean/100;
            end
            % hold on, plot(shifted_timeseries,'b')
            
            % add drift
            drift_direction=randn;
            drift=(20+5*randn)/1000;                           
            for l=1:length(shifted_timeseries)
                drift_magnitude=l*drift;
                if drift_direction>0
                    drifting_signal(l)=shifted_timeseries(l)+drift_magnitude;
                elseif drift_direction<0
                    drifting_signal(l)=shifted_timeseries(l)-drift_magnitude;
                end
            end
            % hold on, plot(drifting_signal,'b')
            
            % add gauss-distributed noise to the hrf function
            noise_magnitude=std(hrf_timeseries);
            noise=(noise_magnitude*noise_factor).*randn(length(hrf_timeseries),1);          
            for m=1:length(drifting_signal)
                noisy_signal(m)=drifting_signal(m)+noise(m);
            end
            % hold on, plot(noisy_signal,'b')
            
            % and some noise spikes 
            final_signal=noisy_signal;
            spike_number=round(7+1.5.*randn);                   
            spike_volumes=randi(length(hrf_timeseries)-1,1,spike_number);
            
            % the spikes get a minimum distance of one volume
            spike_volumes=sort(spike_volumes);
            for z=1:length(spike_volumes)-1
                if spike_volumes(z)==spike_volumes(z+1)-1
                    spike_volumes(z+1)=spike_volumes(z+1)+1;
                elseif spike_volumes(z)==spike_volumes(z+1)
                    spike_volumes(z+1)=spike_volumes(z+1)+1;
                end
            end
            
            spike_magnitude=(2+randi(3,1,spike_number))*noise_magnitude;
            for n=1:length(spike_volumes)
                spike_direction=randn;
                if spike_direction<0
                    final_signal(spike_volumes(n))=noisy_signal(spike_volumes(n))-spike_magnitude(n);
                elseif spike_direction>0
                    final_signal(spike_volumes(n))=noisy_signal(spike_volumes(n))+spike_magnitude(n);
                end
            end
            % hold on, plot(final_signal,'b')
            
            % place your signal filters and quality measures here to determine their efficacy
        end
    end
end
