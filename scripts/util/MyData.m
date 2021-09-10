classdef MyData < handle
    
    properties
        % there are three different experimental recording sessions organized into
        % 3 different folders with same structure.
        data_level = {'raw', 'epoched', 'aligned'}

        raw_file_types = { 'video','eeg', 'eyelink', 'labstream','race_coordinates'};
        epoched_file_types = {'video','eeg','eyelink','optical_flow', 'photodiode_trigger','video_trigger'};
        aligned_file_types = {'eeg', 'eyelink', 'optical_flow', 'race_coordinates'};
        
        raw_data_dir;
        epoched_data_dir;
        aligned_data_dir;
        
        metadata;

        filenames;
        
        data_dir;
    end
    
    methods
        function this = MyData(data_dir)
            this.data_dir = data_dir;

            create_dir(this)
            read_excel(this)
%             select_session(session);
%             this.filenames = load_metadata();
        end
        
        function create_dir(this)
            for i = 1:length(this.raw_file_types)
                name = this.raw_file_types{i};
                this.raw_data_dir.(name) = [this.data_dir '/raw/' name];
            end
            for i = 1:length(this.epoched_file_types)
                name = this.epoched_file_types{i};
                this.epoched_data_dir.(name) = [this.data_dir '/epoched/' name];
            end
            for i = 1:length(this.aligned_file_types)
                name = this.aligned_file_types{i};
                this.aligned_data_dir.(name) = [this.data_dir '/aligned/' name];
            end
        end
        
        function read_excel(this)
            metadata_path = [this.data_dir '\metadata'];
            try
                load(metadata_path);
                this.metadata = metadata;
            catch
                [NUM,TXT,RAW]= xlsread(metadata_path);
                header = RAW(1,:);
                this.metadata = cell2table(RAW(2:end,:));
                this.metadata.Properties.VariableNames =  header;
                
                [NUM,TXT,RAW]= xlsread(metadata_path,2);
                metadata2 = RAW(2:end,:);
                this.metadata.old_filename = metadata2(:,7);
                metadata = this.metadata;
                save([this.data_dir '\metadata'], 'metadata')
            end
        end
        
        function save_metadata(this, metadata)
            this.metadata = metadata;
            save([this.data_dir '\metadata'], 'metadata');
        end
        
    end
    
end