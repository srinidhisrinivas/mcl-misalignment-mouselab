
%% Reading files
scarce_file_name = 'misalignment_bic_frames_run2/misaligned_bicall.csv';
control_file_name = 'misalignment_bic_frames_run2/control_bicall.csv';

scarce_bicall_orig = readtable(scarce_file_name);
scarce_bicall = table2array(scarce_bicall_orig(2:end,2:end));

control_bicall_orig = readtable(control_file_name);
control_bicall = table2array(control_bicall_orig(2:end,2:end));

all_bicall = [scarce_bicall;control_bicall];

%% Performing model selection
[calpha,cexp_r,cxp,cpxp,cbor] = spm_BMS(control_bicall);
[salpha,sexp_r,sxp,spxp,sbor] = spm_BMS(scarce_bicall);
[alpha,exp_r,xp,pxp,bor] = spm_BMS(all_bicall);

%% Extracting model names
mc = control_bicall_orig.Properties.VariableNames(2:end);
models = strings(size(mc));
[models{:}] = mc{:};

%% Sorting by exp_r

row_headers = reshape(["Model", "exp_r", "xp", "", "Model", "exp_r", "xp"],7,1);

[cexp_r_sort, cexp_r_idx] = sort(cexp_r,'descend');
cordered_models = models(cexp_r_idx);
cxp_sort = cxp(cexp_r_idx);
line_break = strings(size(cxp_sort));
cBMS_results = [cordered_models;cexp_r_sort;cxp_sort;line_break];
[cxp_sort, cxp_idx] = sort(cxp,'descend');
cordered_models = models(cxp_idx);
cexp_r_sort = cexp_r(cxp_idx);
cBMS_results = [cBMS_results;cordered_models;cexp_r_sort;cxp_sort];
cBMS_results = [row_headers cBMS_results];

[sexp_r_sort, sexp_r_idx] = sort(sexp_r,'descend');
sordered_models = models(sexp_r_idx);
sxp_sort = sxp(sexp_r_idx);
sBMS_results = [sordered_models;sexp_r_sort;sxp_sort;line_break];
[sxp_sort, sxp_idx] = sort(sxp,'descend');
sordered_models = models(sxp_idx);
sexp_r_sort = sexp_r(sxp_idx);
sBMS_results = [sBMS_results;sordered_models;sexp_r_sort;sxp_sort];
sBMS_results = [row_headers sBMS_results];

[exp_r_sort, exp_r_idx] = sort(exp_r,'descend');
ordered_models = models(exp_r_idx);
xp_sort = xp(exp_r_idx);
all_results = [ordered_models;exp_r_sort;xp_sort;line_break];
[xp_sort, xp_idx] = sort(xp,'descend');
ordered_models = models(xp_idx);
exp_r_sort = exp_r(xp_idx);
all_results = [all_results;ordered_models;exp_r_sort;xp_sort];
all_results = [row_headers all_results];

%% Family comparison - PR 
data = struct;
family_names = {"No PR", "PR"};
    
part = [1,1,2,2];
data.partition = part;
data.names = family_names;
data.infer = "RFX";

[cfamily, cmodel] = spm_compare_families(control_bicall, data);
[sfamily, smodel] = spm_compare_families(scarce_bicall, data);
[afamily, amodel] = spm_compare_families(all_bicall, data);
%% Family comparison - Heuristic 
data = struct;
family_names = {"No Heuristic", "Heuristic"};
    
data.partition = [1,2,1,2];
data.names = family_names;
data.infer = "RFX";

[cfamily, cmodel] = spm_compare_families(control_bicall, data);
[sfamily, smodel] = spm_compare_families(scarce_bicall, data);
[afamily, amodel] = spm_compare_families(all_bicall, data);