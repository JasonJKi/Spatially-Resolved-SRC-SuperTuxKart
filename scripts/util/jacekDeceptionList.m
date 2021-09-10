function metadata_stk = jacekDeceptionList(metadata_stk)
dsubs_v1=[1 2 3 5 6 7 9 10 11 13 14 15 18];
dsubs_v2=[1 6 7 8 11 14 16 17 19 20]+18;
dsubs_v3=[1 6 9 12 13 17 20 23]+18+24;

deceived_list = [dsubs_v1 dsubs_v2 dsubs_v3];
subject_id = unique(metadata_stk.subject_id)';
for i = subject_id
    deception_status = ~isempty(find(deceived_list == i));
    subj_index  = find(metadata_stk.subject_id == i);
    metadata_stk.bci_deception_success(subj_index) = deception_status;
end

