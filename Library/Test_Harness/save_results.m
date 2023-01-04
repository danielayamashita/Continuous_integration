
time_now = clock;

filename = ['Spectrum_Analysis_'...
num2str(time_now(1))...
num2str(time_now(2))...
num2str(time_now(3))...
num2str(time_now(4))...
num2str(time_now(5))...
num2str(ceil(time_now(6)))];

mdlWks = get_param('Tesys_system_mil','ModelWorkspace');
save(mdlWks,[filename,'_1'])

mdlWks = get_param('DSPV','ModelWorkspace');
save(mdlWks,[filename,'_2'])

clearvars -except out filename

mil_param = load([filename '_1' '.mat' ]);
model_param = load([filename '_2' '.mat']);
save(filename)


delete(['./'  filename '_1.mat'])
delete(['./' filename '_2.mat'])