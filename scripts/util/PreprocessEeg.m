classdef PreprocessEeg < handle
    
    properties
        eeg
        eog
        fs
        location
        loc_filename 
        preprocess_properties
        eeg_unprocessed
        bad_channel_index
        
        num_samples
        num_channels
        mask
    end
    
    methods
        
        function this = PreprocessEeg(eeg, fs, loc_filename)
            eeg(isnan(eeg)) = 0; 
            this.eeg_unprocessed = eeg;
            this.eeg = eeg;
            [this.num_samples, this.num_channels] = size(eeg);
            this.fs = fs;
            this.mask = zeros(size(eeg));
            setLocation(this, loc_filename);
        end
        
        function downsample(this, target_fs)
            this.eeg = resample(this.eeg, target_fs,  this.fs);
            this.preprocess_properties.downsampled = true;
            this.preprocess_properties.original_fs = this.fs;
            this.fs = target_fs;
        end
        
        function driftLineFilter(this, coeff_length)
            % High pass and 60hz bandstop line noise
            this.eeg = filterEeg(this.eeg, this.fs, coeff_length);
            this.preprocess_properties.drift_line_filtered = true;
            this.eeg_unprocessed = this.eeg;
        end
        
        function driftFilter(this, coeff_length)
            % Remove drift noise by high passing over 2 herz
            [b,a]=butter(coeff_length, 1/(this.fs/2), 'high'); % drift removal
            this. eeg = this.zeropadFiltering(b, a, this.eeg, this.fs);
        end
        
        function lineNoiseFilter(this, coeff_length)
            if this.fs < 60
                disp('sampling rate is lower than line noise')
                return
            end
            % Create 60Hz bandstop filter to remove electrical noise.
            [b, a] = butter(coeff_length, [59 61] / (this.fs*2), 'stop'); % 60Hz line noise
            this. eeg = this.zeropadFiltering(b, a, this.eeg, this.fs);            
            this.preprocess_properties.line_noise_filtered = true;
        end
        
        function setLocation(this, loc_filename)
            this.location = readlocs(loc_filename);
            this.loc_filename = loc_filename;
        end
        
        function [mask] = rpcaFilter(this)
            eeg_ = this.eeg;
            eeg_(isnan(eeg_)) = 0;
            [this.eeg, mask] = inexact_alm_rpca(eeg_);
%             this.mask = (mask>0);
            this.preprocess_properties.rpca_filtered = true;
        end
        
        function removeBadChannels(this, bad_channel_index)
            
            bad_channel_index(find(bad_channel_index > this.num_channels)) = [];
            this.bad_channel_index = unique(bad_channel_index);
            
            bad_channels = zeros(size(this.eeg));
            bad_channels(:, this.bad_channel_index) = 1;
            this.eeg(:,this.bad_channel_index) = nan;
            this.mask = (this.mask |  isnan(this.eeg));
        end
        
        function meanSubtraction(this)
            channel_mean = mean(this.eeg, 2);
            this.eeg = this.eeg - repmat(channel_mean, 1, this.num_channels);
            this.preprocess_properties.mean_subtrated = true;
        end
        
        function offsetSubtraction(this)
            first_sample = this.eeg(1,:);
            this.eeg = this.eeg - repmat(first_sample, this.num_samples, 1);
            this.preprocess_properties.offset_subtracted = true;
        end
        
        function eyeArtefactFilter(this)
            this.eeg = regressOut(this.eeg',  this.eog')';
            this.preprocess_properties.eye_artefact_filtered = true;
        end
        
        function setEog(this, eog_index, virutal_eog)
            if virutal_eog
                setVirtualEog(this);
                return
            end
            this.eog = this.eeg(:,eog_index);
            eeg_index = [1:this.num_channels];
            eeg_index(eog_index) = [];
            this.eeg = this.eeg(:,eeg_index);
            this.num_channels = length(eeg_index);
            this.preprocess_properties.virtual_eog = false;
        end
        
        function setVirtualEog(this)
            virtualeog = zeros(this.num_channels, 4);
            virtualeog([1 34],1)=1;
            virtualeog([2 35],2)=1;
            virtualeog(1,3)=1;
            virtualeog(2,3)=-1;
            virtualeog(33,4)=1;
            virtualeog(36,4)=-1;
            this.eog = this.eeg * virtualeog;
            this.preprocess_properties.virtual_eog = true;
        end

        function [mask] = removeArtefactInTime(this, std_scale, num_iteration)
            [this.eeg, mask] = removeTimeSeriesArtifact(this.eeg, std_scale, num_iteration, this.fs);
            this.preprocess_properties.bad_samples_in_time_rejected.status = true;
            this.preprocess_properties.bad_samples_in_time_rejected.std_scale = std_scale;
            this.preprocess_properties.bad_samples_in_time_rejected.num_iteration = num_iteration;
            mask = isnan(this.eeg);
            this.mask = (this.mask | mask);
        end
        
        function fig = visualizeArtefacts(this, fig_num)
            fig = figure(fig_num);
            subplot(1,3,1); imagesc(this.eeg_unprocessed);  caxis([-50 50]); 
            subplot(1,3,2); imagesc(this.mask); 
            subplot(1,3,3); imagesc(this.eeg); caxis([-50 50]);
        end
        
        function  interpolateBadSamples(this)
%             figure(1);imagesc(this.mask)
            try 
            this.eeg = fillBadSamples_combo(this.eeg, this.mask, this.location, [], 1);
            catch
                try
                    disp('trying bad channel rejection')
                    this.eeg = fillBadChannels(this.eeg,bad_channel_index, this.location, 'interp');
%                     [eeg, mask] = removeTimeSeriesArtifact(this.eeg, 3, 2, this.fs);
%                     this.eeg = fillBadSamples_combo(this.eeg, mask, this.location, [], 1);
                catch
                    disp('interpolation does not work')
                    return
%                     disp('doing rpca')
%                     this.eeg = regressOut(this.eeg_unprocessed',  this.eog')';
%                     rpcaFilter(this);
                end
            end
        end
        
        function  interpolateBadChannels(this)
            this.eeg = fillBadChannels(this.eeg,this.bad_channel_index, this.location, 'interp');
        end

        function [mask] = removeArtefactInSpace(this, std_scale)
            [this.eeg, mask] = removeSpatialArtifact(this.eeg, std_scale);
            this.preprocess_properties.bad_samples_across_channels_rejected.status = true;
            this.preprocess_properties.bad_samples_across_channels_rejected.std_scale = std_scale;
            mask = isnan(this.eeg);
            this.mask = (this.mask | mask);
        end
        
        function [U, S, V,fig] = visualizeTopoplot(this, figure_num)
                fig= figure(figure_num);
                [U, S, V] = drawSVDTopoplot(this.eeg, this.loc_filename);
        end
        
        function [eeg_out] = outputData(this)
                eeg_out.timeseries = this.eeg;
                eeg_out.fs = this.fs;
                eeg_out.preprocss_properties = this.preprocess_properties;
        end
        
    end
    
    methods (Static)
        function x = zeropadFiltering(b, a, x, fs)
            zero_pad = zeros(5*fs, size(x,2)); % create 5 second zero padding
            x = filter(b, a,  [zero_pad; x]); % fitler EEG
            x =x(5*fs+1:end,:);
        end
    end
    
end


    