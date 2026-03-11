% waterfall_ftz_white.m
% X = Frequency (Hz), Y = Time (s), Z = Amplitude (dB) — Bright/Light Theme
clear; clc; close all
%% ===== Global Parameter =====
wavPath     = '/Users/kevinni/Desktop/Y3Lab/Waves\ on\ string/waterfall/txt/noise.txt'; % Path to audio (Dialog pops up if not found)
t_start     = 0.0;                % s
t_end       = 40.0;               % s
FMIN        = 50;                 % Hz
FMAX        = 5000;               % Hz
FS_TARGET   = 48000;
NFFT        = 4096;               % 4096/8192/16384
HOP         = 64;                 % 64/128/256
brightRange = 80;               
cmapName    = 'turbo';           
view_az     = 10; view_el = 13;   % View angles
%% ====================
%% ---- Read Data ----
if ~exist(wavPath,'file')
    [fn,fp]=uigetfile({'*.wav;*.m4a;*.mp3','Audio Files'},'Select Audio File');
    if isequal(fn,0), error('No audio file selected'); end
    wavPath=fullfile(fp,fn);
end
info=audioinfo(wavPath); fs_file=info.SampleRate;
t_start=max(0,t_start); t_end=min(t_end,info.Duration);
if t_end<=t_start, error('t_end must be greater than t_start'); end
[x,fs]=audioread(wavPath,[floor(t_start*fs_file)+1, ceil(t_end*fs_file)]);
if size(x,2)>1, x=mean(x,2); end
x=x-mean(x); x=x/(max(abs(x))+1e-12);
if fs~=FS_TARGET
    t_old=(0:length(x)-1)'/fs; t_new=(0:round(length(x)*FS_TARGET/fs)-1)'/FS_TARGET;
    x=interp1(t_old,x,t_new,'linear'); fs=FS_TARGET;
end
%% ---- STFT ----
WIN=0.5-0.5*cos(2*pi*(0:NFFT-1)'/NFFT);
hop=HOP;
numFrames=max(1,1+floor((length(x)-NFFT)/hop));
if numFrames<2, error('Insufficient frames: decrease HOP or decrease NFFT.'); end
idx=bsxfun(@plus,(1:NFFT)',0:hop:(numFrames-1)*hop);
frames=x(idx).*WIN;
Sfull=fft(frames,NFFT,1); keep=1:floor(NFFT/2)+1; S=Sfull(keep,:);
f=(keep-1)'*(fs/NFFT);
t=((0:numFrames-1)*hop+NFFT/2)/fs + t_start;
mag=abs(S)+1e-12; magDB=20*log10(mag);
fmask=(f>=FMIN)&(f<=FMAX);
f_sel=f(fmask); magDB=magDB(fmask,:);
peakDB=max(magDB(:));
lowDB = peakDB - brightRange;     
magDB = max(magDB, lowDB);
%% ---- Figure Plot----
[Fgrid,Tgrid]=meshgrid(f_sel,t);
Agrid = magDB.';  % [nt x nf]
set(0,'DefaultFigureColor','w');
figure('Color','w','Position',[100 100 1180 760]);
h = surf(Fgrid, Tgrid, Agrid, Agrid, ...
    'FaceColor','interp', ...
    'FaceAlpha',1.0);
colormap(cmapName);           
caxis([lowDB, peakDB]);
hcb=colorbar; ylabel(hcb,'Amplitude (dB)');
hcb.Color = 'k';           
hcb.Label.Color = 'k'; 
xlabel('f / Hz','Interpreter','tex');
ylabel('t / s','Interpreter','tex');
zlabel('Amplitude (dB)','Interpreter','tex');
title('Waterfall (X=f, Y=t, Z=|H| in dB)', 'Color','k');
xlim([FMIN FMAX]);
ylim([t_start t_end]);
zlim([lowDB peakDB]);
set(gca,'YDir','reverse');
grid on; box on; set(gca,'GridLineStyle',':');
set(h,'EdgeColor','none');  
pbaspect([16 9 6]);            
set(gca,'XScale','log'); 
view(view_az, view_el);
%% ===== Save Data =====
saveDir = '/Users/kevinni/Desktop/Y3Lab/WavesOnString/txt';  
if ~exist(saveDir, 'dir')
    mkdir(saveDir);
    fprintf('📁 Directory created: %s\n', saveDir);
end
% Change filename here!
customName = '4_1over3_1.txt';   % ← Rename as needed, e.g., 'test_5N.txt'
% Construct full path
txtPath = fullfile(saveDir, customName);
% Write to file
fid = fopen(txtPath, 'w');
fprintf(fid, '%% Waterfall Data Export\n');
fprintf(fid, '%% Columns: f(Hz)\tt(s)\tAmplitude(dB)\n');
for i = 1:length(f_sel)
    for j = 1:length(t)
        fprintf(fid, '%.6f\t%.6f\t%.6f\n', f_sel(i), t(j), Agrid(j,i));
    end
end
fclose(fid);
fprintf('✅ Data saved as TXT: %s\n', txtPath);