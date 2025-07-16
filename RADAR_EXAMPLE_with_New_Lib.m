% Pulse Radar Demo with DUC and DDC
% It generates a pulsed RF signal using the DUC and optimizes waveform
% memory usage using sequencing. It captures multiple frames of the RF 
% waveform directly or using the DDC (Digital Down Converter). DUC/DDC
% can be synchronized and TX to RX phase drift can be shown in either case.
% It shows all the acquisitions (acquisition # cbe selected usiong an slide
% control).
clear;
close all;
clear variables;
clear global;
clc;

proteus_lib = TEProteusLib();

% Main Settings
% *************
awg_channel         = proteus_lib.AWG_CHAN_CH01;
dig_channel         = proteus_lib.DIG_CHAN_ONE;
carrier_frequency   = 1E9;
acq_time_factor     = 2;
num_of_frames       = 100;

% *************

% CREATE PROTEUS OBJECTS
awg_setup   = proteus_lib.CreateDefaultAwgSetup();
dig_setup   = proteus_lib.CreateDefaultDigSetup();

% Define IP Address for Target Proteus device descriptor
% VISA "Socket-Based" TCP-IP Device. Socket# = 5025
proteus_lib.ip_addr         = '169.254.181.21'; %'192.168.10.48'; % '127.0.0.1' = Local Host, your IP address here
proteus_lib.pxi_slot        = 2; % Set 0 to select slot from attached modules
proteus_lib.com_ifc         = proteus_lib.COMM_IFC_LAN; %"LAN" = VISA or "DLL" = PXI
proteus_lib.paranoia_level  = 2; % 0, 1 or 2

% Instrument setup
[inst, idnstr, slotNumber, serial] = proteus_lib.ConnecToProteus();
% inst handler required to use TEProteusInst.m functions directly

% Report model
fprintf('Connected to: %s, slot: %d\n', idnstr(1), slotNumber(1));

% Reset AWG
inst.SendScpi('*CLS;*RST');

% DDC and DUC activation
% ======================
use_ddc             = true;     % true = DDC on, false = DDC off
sync_nco            = true;     % true = Coherent acq
get_coherence       = true;     % true = get coherence (only when DDC on)
%=======================

use_dtr_trigger     = true;     % Digitizer will be triggered by AWG
adc_granularity     = 48;

% AWG Settings
awg_setup.mode              = proteus_lib.AWG_MODE_DUC;
awg_setup.iq_mode           = proteus_lib.AWG_IQ_MODE_ONE;
awg_setup.interpol          = proteus_lib.AWG_INTERPOL_X8;
awg_setup.granularity       = 32;
awg_setup.min_segment       = 64;
awg_setup.dac_resolution    = proteus_lib.AWG_DAC_MODE_16;
awg_setup.sampling_rate     = 9E9;
awg_setup.channel           = awg_channel;
awg_setup.segment           = 1;
awg_setup.volt              = 0.45;
awg_setup.cfr1              = carrier_frequency;
awg_setup.six_db1           = true;

if awg_setup.iq_mode == proteus_lib.AWG_IQ_MODE_HALF            % Values must be corrected for proper calculations when mode = HALF
    awg_setup.granularity   = 64;
    awg_setup.min_segment   = 128;
    awg_setup.interpol      = proteus_lib.AWG_INTERPOL_X8;
end

% Digitizer Settings

dig_setup.ch_state(1)           = proteus_lib.DIG_CHAN_DISABLE;
dig_setup.ch_state(2)           = proteus_lib.DIG_CHAN_DISABLE;
dig_setup.ch_state(dig_channel) = proteus_lib.DIG_CHAN_ENABLE;
dig_setup.cfr(dig_channel)      = awg_setup.cfr1;

switch awg_setup.channel
    case proteus_lib.AWG_CHAN_CH01
        dig_setup.trg_src(dig_channel) = proteus_lib.DIG_TRG_DTR_CH1;

    case proteus_lib.AWG_CHAN_CH02
        dig_setup.trg_src(dig_channel) = proteus_lib.DIG_TRG_DTR_CH2;

    case proteus_lib.AWG_CHAN_CH03
        dig_setup.trg_src(dig_channel) = proteus_lib.DIG_TRG_DTR_CH3;

    case proteus_lib.AWG_CHAN_CH04
        dig_setup.trg_src(dig_channel) = proteus_lib.DIG_TRG_DTR_CH4;
end

if use_ddc
    dig_setup.ddc           = proteus_lib.DIG_MODE_COMPLEX;
    dig_setup.adc_resol     = proteus_lib.DIG_ADC_RESOL_COMPLEX;
else
    dig_setup.mode          = proteus_lib.DIG_MODE_REAL;
    dig_setup.adc_resol     = proteus_lib.DIG_ADC_RESOL_REAL;
end

if sync_nco
    dig_setup.clk_src       = proteus_lib.DIG_CLK_SRC_DIG;
else
    dig_setup.clk_src       = proteus_lib.DIG_CLK_SRC_AWG;
end

dig_setup.sampling_rate     = 2.7E9;
% The Carrier Frequency for the ADC must be an integer submultiple (x1, x2,
% x4, x8) of the AWG sampling rate. Four (4) is selected in this case.
if sync_nco
    dig_setup.sampling_rate = awg_setup.sampling_rate / 4;
end

dig_setup.rng(dig_channel)  = proteus_lib.DIG_RNG_500MV;
dig_setup.num_of_frames     = num_of_frames;
dig_setup.pre_trigger       = 50;

if dig_setup.ddc == proteus_lib.DIG_MODE_COMPLEX
    dig_setup.ddc_decim     = proteus_lib.DIG_DDC_DECIM_X16;       % This is the decimation factor for DDC
else
    dig_setup.ddc_decim     = proteus_lib.DIG_DDC_DECIM_NONE; % This is the decimation factor for Direct
    get_coherence           = false;    % If no DDC, coherence cannot be analyzed
    sync_nco                = true;
end

fprintf('RADAR DEMO STARTS\n');

% RF Pulse Parameters
pulse_setup = proteus_lib.CreateDefaultPulseSetup();
% PULSE_TYPE_SQUARE
% PULSE_TYPE_TRAPEZOIDAL
% PULSE_TYPE_GAUSSIAN
% PULSE_TYPE_CHIRP_UP
% PULSE_TYPE_CHIRP_DOWN
% PULSE_TYPE_BARKER_CODE  
% PULSE_TYPE_FRANK_CODE
% PULSE_TYPE_P1_CODE
% PULSE_TYPE_P2_CODE
% PULSE_TYPE_P3_CODE
% PULSE_TYPE_P4_CODE
 
pulse_setup.pulse_type          = proteus_lib.PULSE_TYPE_FRANK_CODE;
pulse_setup.edge_shape          = proteus_lib.PULSE_EDGE_GAUSSIAN;
pulse_setup.polyphase_code      = 4; %proteus_lib.PULSE_BARKER_13;
pulse_setup.pulse_width         = 10.0E-6;  % Pulse Width
pulse_setup.freq_offset         = 0.0E6;
pulse_setup.bandwidth           = 20.0E6;
pulse_setup.rise_time           = 0.1E-6;
pulse_setup.pulse_rep_freq      = 1E3;  % PRI
num_of_pulses                   = 1;        % Num of pulses in the sequence
% Delay for each digitizer channel
delay                           = 0.0E-06;  % ADC Trigger Delay set to zero



% Frame length calculation for ADC according to pulse width amd pretrigger
% setting.
dig_setup.frame_length = dig_setup.sampling_rate * pulse_setup.pulse_width * acq_time_factor;
dig_setup.frame_length = dig_setup.frame_length / dig_setup.ddc_decim;
if dig_setup.ddc == proteus_lib.DIG_MODE_COMPLEX
    dig_setup.frame_length = 2 * dig_setup.frame_length;
end
dig_setup.frame_length = ceil(dig_setup.frame_length / adc_granularity) * adc_granularity;

% Pulse RF Signal Calculation and Download

% The final waveform will be generated by a sequence specified in a
% task list as follows:
%
%   Task #      segment             num of repetitions
% _________________________________________________________

%   TASK1       pulse_section       0 or 1
%   TASK2       pulse_section       repeat_pulse_section - 1
%   TASK3       trans_section       0 or 1
%   TASK4       off_section         repeat_off_section
%
% Depending on the characteristics of the pulsed waveform any of the
% Tasks listed above may or not exist. If repeat_pulse_section = 1,
% then TASK3 will not exists. If repeat_pulse_section = 0, neither task
% nor task 2 will exist and Task 3 will become the first task in the
% list carrying the full pulse. this only happens when duration of the
% pulse is lower than the minimum segment length. Task 3 may not exist
% if the overall length of the waveform is a multiple of the minimum
% segment length and the length of the pulse is also a multiple of it.
% Task 4 may bot exist in case Task1, 2 and 3 already implements the
% complete waveform.     

[   myWfm,...
    map_wfm,...
    task_list] = proteus_lib.GetPulseWfms(  awg_setup,...
                                            pulse_setup);

awg_setup.wfm_map = map_wfm;
% Download all segments, build task list, set up DDC, and activate task list

if awg_setup.iq_mode == proteus_lib.AWG_IQ_MODE_HALF
    result = proteus_lib.SendIqmHalfListToProteus(  awg_setup,...
                                                    myWfm,...
                                                    task_list);
   
elseif awg_setup.iq_mode == proteus_lib.AWG_IQ_MODE_ONE

    result = proteus_lib.SendIqmOneListToProteus(   awg_setup,...
                                                    myWfm,...
                                                    task_list);     
end

% -------------------------------------
% Operate the ADC with direct functions
% -------------------------------------    

%DIGITIZER SECTION 

% Coherent operation of NCOs in DUC and DDC activation if required
if sync_nco
    inst.SendScpi(':DIG:DDC:CLKS AWG');
end
% Get all frames from digitizer
fprintf('Acquired Waveforms Upload to Computer Starts\n');
%tic;

acq_wfm = proteus_lib.GetWfmFromProteusDig(    dig_setup);

fprintf('Acquired Waveforms Upload to Computer Ends\n'); 

% fprintf('Frame Headers Upload to Computer Starts\n');
% tic;
% [   trg_loc,...
%     gate_addr,...
%     min_adc,...
%     max_adc,...
%     time_stamp] = proteus_lib.GetHeaderData(dig_channel, dig_setup.num_of_frames);
% toc;
% 
% read_hdr = proteus_lib.GetHeaderData2(dig_channel, dig_setup.num_of_frames);
% fprintf('Frame Headers Upload to Computer Ends\n');

% formatting of wfm data
acq_wfm = proteus_lib.InterleavedToComplex(acq_wfm);
acq_wfm = proteus_lib.SamplesToFrames(acq_wfm, dig_setup.frame_length);

acq_wfm = conj(acq_wfm);

% Coherence processing
% One phase value is obtained for each frame so evolution can be observed
phase1 = zeros(1, dig_setup.num_of_frames);

for i = 1:dig_setup.num_of_frames
    %for each acquisition, complex IQ waveforms are extracted
    samples1 = acq_wfm(i,:);
    % Relative amplitude of the I and Q pulses are obtained by integration
    I1 = sum(real(samples1));
    Q1 = sum(imag(samples1));
    % 4 quadrant arctangent is applied to the areas of teh I and Q pulses
    phase1(i) = atan2(Q1,I1);    
end
phase1 = unwrap(phase1);
phase1 = 180.0 * phase1 / pi;

itemToShow = dig_setup.num_of_frames;

% Span for spectrum graph
if pulse_setup.pulse_type == proteus_lib.PULSE_TYPE_CHIRP_UP
    span = 4* pulse_setup.bandwidth;
else
    span = 20.0 / pulse_setup.pulse_width;
end
% Show data for first frame
ShowResults(    proteus_lib,...
                dig_setup.ddc,...
                acq_wfm,...
                get_coherence,...
                phase1,...
                1,...
                dig_setup.cfr(dig_channel),...
                span,...
                dig_setup.ddc_decim,...
                dig_setup.sampling_rate);

drawnow;

% ---------------------------------------------------------------------
% End of the example
% ---------------------------------------------------------------------

fprintf('\nRADAR DEMO COMPLETED\n');

% GUI to access all the information about all frames is generated
fig = uifigure('Position',[100 100 350 100]);    
% Frame is selected using an slider control
sld = uislider(fig,...
    'Position',[10 75 300 3],...
    'Limits', [1 itemToShow],...
    'ValueChangedFcn',@(sld,event) ShowResults( proteus_lib,...
                                                dig_setup.ddc,...
                                                acq_wfm,...
                                                get_coherence,...
                                                phase1,...
                                                sld.Value,...
                                                dig_setup.cfr(dig_channel),...
                                                span,...
                                                dig_setup.ddc_decim,...
                                                dig_setup.sampling_rate));
                

% Disconnect, close VISA handle and destroy handle  
proteus_lib.DisconnectFromProteus();

clear inst;



% *******************************************************************
% *                          FUNCTIONS                              *
% *******************************************************************

function ShowResults(   obj,...
                        useDdc,...
                        acqWfm,...
                        showCoh,...
                        phase1,...
                        itemToShow,...
                        cFreq,...
                        span,...
                        ddcFactor,...
                        samplingRateDig)

    itemToShow = round(itemToShow);
    numOfFrames = length(acqWfm(:,1));
    
    if itemToShow < 1
        itemToShow = 1;
    end    
    
    if itemToShow > numOfFrames
        itemToShow = numOfFrames;
    end

    if useDdc == obj.DIG_MODE_REAL        
    else
        cFreq = abs(obj.GetNcoFreq(cFreq, samplingRateDig, false));
    end
    
    samples1 = acqWfm(itemToShow,:);

    if useDdc == obj.DIG_MODE_REAL    
        samples1 = samples1(1:ddcFactor:length(samples1));
    end

    if showCoh
        tiledlayout(1,3);
    else
        tiledlayout(1,2);
    end
    
    % Top plot
    ax1 = nexttile;
    xData = 0:(length(samples1) - 1);
    %xData = xData - preTrig;
    xData = xData / samplingRateDig;
    if useDdc
        xData = xData * ddcFactor;
    end    
    xData = xData * 1e+06;    
    
    if useDdc == obj.DIG_MODE_COMPLEX
        plot(ax1, xData, real(samples1), xData, imag(samples1));
    else
        dc_level = mean(samples1);
        plot(ax1, xData, samples1 - dc_level);
    end

    if useDdc
        title(ax1,sprintf('CH1 I/Q Wfm # %d, Length: %d', itemToShow, length(samples1)));
    else        
        title(ax1,sprintf('CH1 RF Wfm # %d, Length: %d', itemToShow, length(samples1)));
    end
   
    %xlabel('Samples')
    xlabel('microseconds') 
    ylabel('ADC Levels') 
    if useDdc
        ylim([-8192 8192]); % 15 bits
    else
        ylim([-2048 2048]); % 12Bits
    end

    xlim([xData(1) xData(length(xData))]);
    grid(ax1,'on')
    
    % Mid plot
    ax3 = nexttile;
    pSpec = abs(fft(conj(samples1)));
    if useDdc == obj.DIG_MODE_COMPLEX
        pSpec = circshift(pSpec,round(length(pSpec) /2));
        startF = - span/2;
        stopF = startF + span;
        
        xData = 0:(length(samples1) - 1);
        xData = xData * samplingRateDig / (length(samples1) * ddcFactor);
        xData = xData - samplingRateDig / (2 * ddcFactor);%xData(ceil(length(pSpec) /2));
        
        xData1 = xData(find(xData >= startF & xData <= stopF));
        pSpec = pSpec(find(xData >= startF & xData <= stopF));
        pSpec = 20 * log10(pSpec / max(pSpec));
        
        xData1 = xData1 / 1e+06 + cFreq / 1e+06;
    else    
        startF = cFreq - span/2;
        stopF = startF + span;
        
        xData = 0:(length(samples1) - 1);
        xData = xData * samplingRateDig / length(samples1);
        
        xData1 = xData(find(xData >= startF & xData <= stopF));
        pSpec = pSpec(find(xData >= startF & xData <= stopF));
        pSpec = 20 * log10(pSpec / max(pSpec));
        
        xData1 = xData1 / 1e+06;
    end
    
    plot(ax3, xData1, pSpec);
    
    title(ax3,'CH1 Waveform Spectrum');    
    xlabel('MHz') 
    ylabel('dB') 
    grid(ax3,'on')
    
    if showCoh
        % Phase drift and coherence plot
        ax5 = nexttile;
    
        graph_3 = plot(ax5, phase1);

        title(ax5,sprintf('CH1 Coherence Drift = %f, Degrees pp', max(phase1) - min(phase1)));       
        xlabel('# of Acquisition') 
        ylabel('Degrees') 
        grid(ax5,'on')
        datatip(graph_3, itemToShow, phase1(itemToShow)); %,'DataIndex',5);
    end    
end

function [trg_loc, gate_addr, min_adc, max_adc, time_stamp] = GetHeaderData2(inst, channel)

    inst.SendScpi(sprintf(':DIG:CHAN %d', channel));

    inst.SendScpi(':DIG:DATA:TYPE HEAD');
    header_raw = inst.ReadBinaryData(':DIG:DATA:READ?', 'uint8');

    num_of_frames = round(length(header_raw) / 88);

    trg_loc =       uint32(zeros(1, num_of_frames));
    gate_addr =     uint32(zeros(1, num_of_frames));
    min_adc =       uint32(zeros(1, num_of_frames));
    max_adc =       uint32(zeros(1, num_of_frames));
    time_stamp =    uint64(zeros(1, num_of_frames));

    base_pointer = 0;

    for frame = 1:num_of_frames
        for k = 1:4
            trg_loc(frame) = trg_loc(frame) + uint32(header_raw(base_pointer + k)) * uint32(256)^(k-1);
        end

        raw_level = uint32(0);

        for k = 9:12
            raw_level = raw_level + uint32(header_raw(base_pointer + k)) * uint32(256)^(k-9);
        end

        min_adc(frame) = raw_level;

        raw_level = uint32(0);

        for k = 13:16
            raw_level = raw_level + uint32(header_raw(base_pointer + k)) * uint32(256)^(k-13);
        end

        max_adc(frame) = raw_level;  

        time_stamp(frame) = 0;

        for k = 17:24
            time_stamp(frame) = time_stamp(frame) + uint64(header_raw(base_pointer + k)) * uint64(256)^(k-17);
        end
        
        base_pointer = base_pointer + 88;
    end
end