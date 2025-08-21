% This script demonstrates how to connect to a Tabor Electronics Proteus P9484M
% arbitrary waveform generator using the TEProteusLib library.
%
% To run this script:
% 1. Make sure the TEProteusLib.m and TEProteusInst.m files are in the same
%    directory as this script, or add the path to the files using the
%    addpath function.
% 2. Change the ip_addr variable to the actual IP address of your P9484M.
% 3. Run the script from the MATLAB command window or editor.
%
% The script will attempt to connect to the instrument and print a success
% message. If the connection fails, it will print an error message.

% Add the path to the TEProteusLib files if they are not in the current folder
% addpath('<path_to_TEProteusLib>');

% It is recommended to clear all variables and close all figures before starting
clear;
close all;
clc;

disp('Connecting to Proteus P9484M...');

try
    % Instantiate the TEProteusLib class
    proteus_lib = TEProteusLib();

    % Set the connection parameters
    proteus_lib.ip_addr = '192.168.1.150'; % Replace with the actual IP address of the P9484M
    proteus_lib.com_ifc = proteus_lib.COMM_IFC_LAN;
    proteus_lib.paranoia_level = 2; % Use high paranoia level for robust error checking

    % Connect to the instrument
    [inst, idn_str, slot_number, ~] = proteus_lib.ConnecToProteus();

    % Print the instrument information
    fprintf('Successfully connected to: %s, Slot: %d\n', idn_str, slot_number);

    % Disconnect from the instrument
    proteus_lib.DisconnectFromProteus();
    fprintf('Disconnected from the instrument.\n');

catch ME
    fprintf('Error connecting to the instrument: %s\n', ME.message);
end
