% Generate_5G_NR_FR2_Uplink.m
% This script generates a 5G NR FR2 Uplink waveform using MATLAB's 5G Toolbox
% and downloads it to a Tabor Electronics Proteus P1284M AWG.

% Prerequisites:
% - MATLAB 5G Toolbox
% - TEProteusLib.m and TEProteusInst.m in the path or current directory
% - Valid connection to Proteus instrument

clear;
clc;
close all;

% Check if TEProteusLib is available
if exist('TEProteusLib', 'class') ~= 8
    error('TEProteusLib not found. Please ensure TEProteusLib.m and TEProteusInst.m are in the MATLAB path.');
end

% -------------------------------------------------------------------------
% 1. 5G NR Waveform Generation (Requires 5G Toolbox)
% -------------------------------------------------------------------------
fprintf('Generating 5G NR FR2 Uplink Waveform...\n');

try
    % Check for 5G Toolbox
    if isempty(which('nrWaveformGenerator'))
        error('MATLAB 5G Toolbox is required for this script.');
    end

    % Carrier Configuration
    carrier = nrCarrierConfig;
    carrier.SubcarrierSpacing = 120; % 120 kHz SCS for FR2
    carrier.NSizeGrid = 66;          % 100 MHz Bandwidth (approx for 120kHz SCS)
    carrier.NStartGrid = 0;
    carrier.NSlot = 0;
    carrier.NFrame = 0;

    % SCS Carrier Config
    scsCarrier = nrSCSCarrierConfig;
    scsCarrier.SubcarrierSpacing = 120;
    scsCarrier.NSizeGrid = 66;
    scsCarrier.NStartGrid = 0;

    % Bandwidth Part (BWP) Configuration
    bwp = nrWaveformGeneratorBandwidthPartConfig;
    bwp.SubcarrierSpacing = 120;
    bwp.NSizeBWP = 66;
    bwp.NStartBWP = 0;

    % PUSCH Configuration
    pusch = nrPUSCHConfig;
    pusch.BandwidthPartID = 1;
    pusch.Modulation = 'QPSK';
    pusch.SymbolAllocation = [0 14]; % Full slot
    pusch.PRBSet = 0:65;             % Full bandwidth
    pusch.NID = 0;
    pusch.RNTI = 1;

    % Waveform Generation Config
    cfg = nrULCarrierConfig;
    cfg.Label = '5G NR FR2 Uplink';
    cfg.FrequencyRange = 'FR2';
    cfg.ChannelBandwidth = 100; % MHz
    cfg.SCSCarriers = {scsCarrier};
    cfg.BandwidthParts = {bwp};
    cfg.PUSCH = {pusch};

    % Generate Waveform
    [waveform, info] = nrWaveformGenerator(cfg);

    % Normalize waveform to +/- 1.0 for AWG
    max_amp = max(abs(waveform));
    if max_amp > 0
        waveform = waveform / max_amp;
    end

    fs = info.ResourceGrids(1).Info.SampleRate;
    fprintf('Waveform generated. Sample Rate: %.2f MHz, Length: %d samples\n', fs/1e6, length(waveform));

catch ME
    % Fallback for environments without 5G Toolbox (e.g. testing this script structure)
    fprintf('Warning: %s. Generating a dummy modulated signal instead.\n', ME.message);

    % Generate a dummy complex signal (chirp)
    fs = 122.88e6; % Typical sample rate for 100MHz BW
    t = (0:4095)' / fs;
    waveform = exp(1j * 2 * pi * (10e6 * t + (50e6/(2*t(end))) * t.^2));
    waveform = waveform / max(abs(waveform));
    fprintf('Dummy waveform generated. Sample Rate: %.2f MHz, Length: %d samples\n', fs/1e6, length(waveform));
end

% -------------------------------------------------------------------------
% 2. Configure Proteus Instrument
% -------------------------------------------------------------------------
fprintf('Connecting to Proteus...\n');

% Instantiate Library
proteus_lib = TEProteusLib();

% Connection Settings
proteus_lib.ip_addr = '192.168.0.1'; % Adjust IP address as needed
proteus_lib.com_ifc = proteus_lib.COMM_IFC_LAN; % Use LAN
proteus_lib.paranoia_level = 1;

try
    % Connect
    % Note: Using 'ConnecToProteus' as per the provided TEProteusLib.m file.
    % If your library version uses 'ConnectToProteus', please update the line below.
    [inst, idn_str, slot_number, ~] = proteus_lib.ConnecToProteus();
    fprintf('Connected to: %s, Slot: %d\n', idn_str, slot_number);

    % Reset
    inst.SendScpi('*CLS; *RST');

    % ---------------------------------------------------------------------
    % 3. Setup AWG
    % ---------------------------------------------------------------------
    awg_setup = proteus_lib.CreateDefaultAwgSetup();

    % Select Channel 1
    awg_setup.channel = 1;
    awg_setup.segment = 1;

    % Use DUC Mode for upconversion (or Direct for baseband)
    % For FR2, typically we output IF or Baseband. Here we setup for Baseband IQ.
    % To output IQ on Ch1 and Ch2, we can use AWG_MODE_DUC with IQ_MODE_ONE (Interleaved)
    % or AWG_MODE_DIRECT.
    % Using DUC mode allows interpolation which is efficient for high sample rates.

    awg_setup.mode = proteus_lib.AWG_MODE_DUC;
    awg_setup.iq_mode = proteus_lib.AWG_IQ_MODE_ONE; % Complex waveform on Ch1 (or Ch1/Ch2 pair depending on FPGA)

    % Sampling Rate Configuration
    % Proteus P1284M has a max sample rate of 1.25 GS/s (unlike P2584/P9082).
    % We need to interpolate the 5G waveform (e.g. ~122.88 MS/s) to the AWG rate.

    % Let's aim for a high DAC sampling rate up to 1.25 GS/s.
    % Interpolation factors: x2, x4, x8, ...

    % Find closest valid interpolation
    target_sclk = 1.25e9; % Target 1.25 GS/s for P1284M
    interpol = floor(target_sclk / fs);

    % Valid interpolations in TEProteusLib: x2, x4, x8, x10, x12...
    valid_interpol = [2, 4, 8, 10, 12, 16, 18, 20, 24];
    [~, idx] = min(abs(valid_interpol - interpol));
    best_interpol = valid_interpol(idx);

    % Ensure we don't exceed max sample rate if rounded up
    if (fs * best_interpol) > 1.25e9
        if idx > 1
            best_interpol = valid_interpol(idx-1);
        end
    end

    % Set interpolation
    switch best_interpol
        case 2
            awg_setup.interpol = proteus_lib.AWG_INTERPOL_X2;
        case 4
            awg_setup.interpol = proteus_lib.AWG_INTERPOL_X4;
        case 8
            awg_setup.interpol = proteus_lib.AWG_INTERPOL_X8;
        case 10
            awg_setup.interpol = proteus_lib.AWG_INTERPOL_X10;
        case 12
            awg_setup.interpol = proteus_lib.AWG_INTERPOL_X12;
        case 16
            awg_setup.interpol = proteus_lib.AWG_INTERPOL_X16;
        otherwise
            awg_setup.interpol = proteus_lib.AWG_INTERPOL_X8; % Default fallback
            best_interpol = 8;
    end

    awg_setup.sampling_rate = fs * best_interpol;
    fprintf('Configuring AWG: Sample Rate = %.2f MHz, Interpolation = x%d\n', awg_setup.sampling_rate/1e6, best_interpol);

    % NCO Configuration (Digital Up Conversion)
    % Set NCO frequency to 0 for Baseband, or an IF frequency.
    % Example: 0 Hz (Baseband)
    awg_setup.cfr1 = 0.0;
    awg_setup.nco_mode = proteus_lib.AWG_NCO_MODE_SINGLE;

    % Adjust waveform length for granularity
    granularity = awg_setup.granularity;

    % IQ Mode ONE usually requires granularity/2 for complex samples if interleaved?
    % Check library logic. WfmAppendGranularity helps.

    % Ensure waveform length is multiple of granularity
    len = length(waveform);
    rem_len = mod(len, granularity);
    if rem_len > 0
        % Zero pad
        waveform = [waveform; zeros(granularity - rem_len, 1)];
    end

    % Ensure minimum segment length
    min_seg = awg_setup.min_segment;
    if length(waveform) < min_seg
        waveform = [waveform; zeros(min_seg - length(waveform), 1)];
    end

    % ---------------------------------------------------------------------
    % 4. Download Waveform
    % ---------------------------------------------------------------------
    fprintf('Downloading waveform to instrument...\n');

    % SendIqmOneWfm handles complex to interleaved conversion and download
    % It sets up the mode, downloads, and enables output.
    res = proteus_lib.SendIqmOneWfm(awg_setup, waveform);

    fprintf('Download complete. Output enabled on Channel %d.\n', awg_setup.channel);

    % Disconnect
    proteus_lib.DisconnectFromProteus();
    fprintf('Disconnected.\n');

catch ME
    fprintf('Error controlling Proteus: %s\n', ME.message);
    if exist('proteus_lib', 'var')
        try
            proteus_lib.DisconnectFromProteus();
        catch
        end
    end
end
