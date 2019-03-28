This script enables you to create artificial fMRI timeseries data for a whole run with signal and noise levels of your choosing. The script contains the usual noise types one encounters in fMRI (especially on older scanners): signal drift, gaussian noise and spikes. 
Thus, you can test for instance how well your data processing pipeline detects an existing signal, how prone it is to false alarms in case of a given noise type, how well your filter settings suppress the noise, how much the filters also cut off from the signal, etc.  

If desired, i can also upload another version that doesn't involve an SPM.mat file.
