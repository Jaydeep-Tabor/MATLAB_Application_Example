clear;
close all;
clear variables;
clear global;
clc;

%%
% Load Library
myLib           = TEProteusLib();

%%
% Define IP Address for Target Proteus device descriptor
% VISA "Socket-Based" TCP-IP Device. Socket# = 5025
myLib.ip_addr         = '127.0.0.1'; % '127.0.0.1' = Local Host, your IP address here
myLib.pxi_slot        = 3; % Set 0 to select slot from attached modules
myLib.com_ifc         = myLib.COMM_IFC_LAN; %"LAN" = VISA or "DLL" = PXI
myLib.paranoia_level  = 2; % 0, 1 or 2

%%
% Instrument setup
% Open session
[inst, idnstr, slotNumber, serial] = myLib.ConnecToProteus();
% Report model
fprintf('Connected to: %s, slot: %d\n', idnstr(1), slotNumber(1));
% Reset AWG
inst.SendScpi('*CLS;*RST');

%%
% DATA CONFIG
prbs_seq        = myLib.PRBS_13;
% DATA_TYPE_BILVL_NRZ
% DATA_TYPE_BILVL_RZ
% DATA_TYPE_PAM4
% DATA_TYPE_PAM8
data_wfm_type   = myLib.DATA_TYPE_BILVL_NRZ;
baud_rate       = 10E6;
clk_div         = 1;

% PULSE_EDGE_LINEAR
% PULSE_EDGE_GAUSSIAN
edge_shape      = myLib.PULSE_EDGE_LINEAR;
rise_time       = 0.100E-9;

%%
% Channel configuration
data_ch         = 1;
data_segm       = 1;

% AWG Parameters
sample_rate     = 1.25E+9;
interp_factor   = 1;
signal_ampl     = 0.50;
granularity     = 32;
dac_resolution  = 16;

%%
seed            = [1,zeros(1, prbs_seq -1)];
num_of_bits     = clk_div * (2^prbs_seq - 1); % Even number for perfect clock
num_of_bits     = num_of_bits * myLib.GetSerialBitsPerSymbol(data_wfm_type);

% Sample Rate and DAC mode must be made consistent
if sample_rate / interp_factor > 2.5E9
    interp_factor   = 1;
    dac_resolution  = 8;
    granularity     = 64;
end

%%
% % Create AWG Setup Variable
awg_setup = myLib.CreateDefaultAwgSetup();

% Create Pulse Setup Variable
pulse_setup                 = myLib.CreateDefaultPulseSetup();

% AWG Parameters
awg_setup.sampling_rate     = sample_rate;
awg_setup.interpol          = interp_factor;
awg_setup.dac_resolution    = dac_resolution;
awg_setup.volt              = signal_ampl;
awg_setup.mode              = myLib.AWG_MODE_DIRECT;

% Basic Pulse Parameters
pulse_setup.prbs_seq        = prbs_seq;
pulse_setup.data_wfm_type   = data_wfm_type;
pulse_setup.pulse_type      = myLib.PULSE_TYPE_SQUARE;
pulse_setup.edge_shape      = edge_shape;
pulse_setup.pulse_width     = 1 / baud_rate; % 1 / Baud Rate
pulse_setup.rise_time       = rise_time;
pulse_setup.sampling_rate   = awg_setup.sampling_rate / awg_setup.interpol;
pulse_setup.granul          = 1;
pulse_setup.quality         = 2;

prbs_data                = myLib.GetStdPrbsData(    pulse_setup.prbs_seq,...
                                                    seed,...
                                                    num_of_bits);
toc;
fprintf('\nGetting Serial Data Waveform\n');
tic;
%%
% Waveform is calculated as a superposition of pulses for "1" bits in the
% data sequence
[   data_wfm_out,...
    sample_rate_out]    = myLib.GetSerialDataWfm(   prbs_data,...
                                                    pulse_setup);
toc;

% Calculate final DAC's sample rate to keep accurate timing 
awg_setup.sampling_rate = sample_rate_out * awg_setup.interpol;

fprintf('\nAdapting Waveform for downloading\n');
% The full DAC range is used
% The base waveform is repeated as many times as required so the overall
% number of samples is a multiple of the granularity
tic;
data_wfm_out                = myLib.NormalizeFull(data_wfm_out);
[data_wfm_out, num_reps]    = myLib.WfmAppendGranularity(data_wfm_out, granularity);
toc;

%%
% Waveform Downloading
% ********************
fprintf(1, '\nDOWNLOADING DATA WAVEFORM FOR CH%d\n', data_ch);
awg_setup.channel   = data_ch;
awg_setup.segment   = data_segm;

myLib.SendWfmToProteus( awg_setup,...
                        data_wfm_out,...
                        true);

%%
% Disconnect, close VISA handle and destroy handle  
myLib.DisconnectFromProteus();

fprintf('END\n');
clear myLib;
clear inst;
%close all;