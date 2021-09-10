function  [unmatch_ind_1, unmatch_ind_2] = indexDependentPairs(subj_id_1, subj_id_2, index_1, index_2)

unmatch_pair_index = find(~(index_1 == index_2));

iter_1 = 1; iter_2 =1;unmatch_ind_1=[];unmatch_ind_2=[];
for ii = 1:length(unmatch_pair_index)
    id_1_ = find(unmatch_pair_index(ii) == subj_id_1);
    id_2_ = find(unmatch_pair_index(ii) == subj_id_2);
    
    if id_1_; unmatch_ind_1(iter_1) = id_1_;iter_1=iter_1+1;end
    if id_2_; unmatch_ind_2(iter_2) = id_2_;iter_2=iter_2+1;end
end