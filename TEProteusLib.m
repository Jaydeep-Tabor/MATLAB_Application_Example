% the Free Software Foundation, either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>. 
% =========================================================================
% Author: Joan Mercade
% Date: April 11, 2024
% Version: 1.0.1
% $Revision: 0001 $

%> @file TEProteusLib.m
%> @brief MATLAB Class Library fo Proteus
% ======================================================================
%> @brief Set of MATLAB functions to control AWG and Digitizer functionality in Proteus.
%
%> Functions include instrument control, data formating, waveform calculation, and processing functionality.

% ======================================================================

classdef TEProteusLib < handle
    properties
        %> Communication API, either 0(COMM_IFC_LAN), or 1(COMM_IFC_DLL)
        com_ifc         = 0; 
        %> IP Address to access the Proteus unit when controlled through COMM_IFC_LAN
        %> '127.0.0.1' = Local Host, your IP address here
        ip_addr         = '127.0.0.1';
        %> PXI Slot # to access the Proteus unit when controlled through COMM_IFC_DLL
        %> 0 means that the user will type this number at runtime
        pxi_slot        = 0; 
        %> Debugging level at runtime (0:low, 1:normal, 2:high) 
        paranoia_level  = 2; 
        %> Handle for administration session
        admin           = 0;
        %> Handle for instrument communication
        inst            = 0;
        %> Verbose functions
        lib_verbose = false;
    end

%**************************************************************************

    properties (Constant=true)
        %> COMMUNICATION IFC
        COMM_IFC_LAN            = 0;
        COMM_IFC_DLL            = 1;

        %> PARANOIA LEVEL
        PARANOIA_LVL_LOW        = 0;
        PARANOIA_LVL_NORMAL     = 1;
        PARANOIA_LVL_HIGH       = 2;

        %> PROTEUS MODEL
        PROTEUS_P1282M          = 0;
        PROTEUS_P1282D          = 1;
        PROTEUS_P1282B          = 2;
        PROTEUS_P1284M          = 3;
        PROTEUS_P1284D          = 4;
        PROTEUS_P1284B          = 5;
        PROTEUS_P1288D          = 6;
        PROTEUS_P1288B          = 7
        PROTEUS_P12812D         = 8;
        PROTEUS_P12812B         = 9;
        PROTEUS_P2582M          = 10;
        PROTEUS_P2582D          = 11;
        PROTEUS_P2582B          = 12;
        PROTEUS_P2584M          = 13;
        PROTEUS_P2584D          = 14;
        PROTEUS_P2584B          = 15;
        PROTEUS_P2588D          = 16;
        PROTEUS_P2588B          = 17;
        PROTEUS_P25812D         = 18;
        PROTEUS_P25812B         = 19;
        PROTEUS_P9482M          = 20;
        PROTEUS_P9482D          = 21;
        PROTEUS_P9482B          = 22;
        PROTEUS_P9484M          = 23;
        PROTEUS_P9484D          = 24;
        PROTEUS_P9484B          = 25;
        PROTEUS_P9488D          = 26;
        PROTEUS_P9488B          = 27;
        PROTEUS_P94812D         = 28;
        PROTEUS_P94812B         = 29;
        PROTEUS_P9082M          = 30;
        PROTEUS_P9082D          = 31;
        PROTEUS_P9082B          = 32;
        PROTEUS_P9084D          = 33;
        PROTEUS_P9084B          = 34;
        PROTEUS_P9086D          = 35;
        PROTEUS_P9086B          = 36;

        % PROTEUS OPTIONS
        PROTEUS_OPT_STRINGS     =[  "4M1"; "4M2"; "4M3"; "4M4";...
                                    "8M1"; "8M2"; "8M3"; "8M4";...
                                    "16M1"; "16M2"; "16M3";...
                                    "DO1"; "DO2"; "DO3"; "DO4";...
                                    "DC1"; "DC2"; "DC3"; "DC4";...
                                    "DJ1"; "DJ2"; "DJ3";...
                                    "LVTTL1"; "LVTTL2"; "LVTTL3";...
                                    "MKR1"; "MKR2"; "MKR3";...
                                    "LTJ1"; "LTJ2"; "LTJ3"; "LTJ4";...
                                    "G1"; "G2"; "G3"; "G4";...
                                    "DUC"; "TRG"; "AWT"; "STM";...
                                    "FPGA_PROG"; "SHELL_CORE"];

        PROTEUS_OPT_4M1         = 1;
        PROTEUS_OPT_4M2         = 2;
        PROTEUS_OPT_4M3         = 3;
        PROTEUS_OPT_4M4         = 4;
        PROTEUS_OPT_8M1         = 5;
        PROTEUS_OPT_8M2         = 6;
        PROTEUS_OPT_8M3         = 7;
        PROTEUS_OPT_8M4         = 8;
        PROTEUS_OPT_16M1        = 9;
        PROTEUS_OPT_16M2        = 10;
        PROTEUS_OPT_16M3        = 11;
        PROTEUS_OPT_DO1         = 12;
        PROTEUS_OPT_DO2         = 13;
        PROTEUS_OPT_DO3         = 14;
        PROTEUS_OPT_DO4         = 15;
        PROTEUS_OPT_DC1         = 16;
        PROTEUS_OPT_DC2         = 17;
        PROTEUS_OPT_DC3         = 18;
        PROTEUS_OPT_DC4         = 19;
        PROTEUS_OPT_DJ1         = 20;
        PROTEUS_OPT_DJ2         = 21;
        PROTEUS_OPT_DJ3         = 22;
        PROTEUS_OPT_LVTTL1      = 23;
        PROTEUS_OPT_LVTTL2      = 24;
        PROTEUS_OPT_LVTTL3      = 25;
        PROTEUS_OPT_MKR1        = 26;
        PROTEUS_OPT_MKR2        = 27;
        PROTEUS_OPT_MKR3        = 28;
        PROTEUS_OPT_LTJ1        = 29;
        PROTEUS_OPT_LTJ2        = 30;
        PROTEUS_OPT_LTJ3        = 31;
        PROTEUS_OPT_LTJ4        = 32;
        PROTEUS_OPT_G1          = 33;
        PROTEUS_OPT_G2          = 34;
        PROTEUS_OPT_G3          = 35;
        PROTEUS_OPT_G4          = 36;
        PROTEUS_OPT_DUC         = 37;
        PROTEUS_OPT_TRG         = 38;
        PROTEUS_OPT_AWT         = 39;
        PROTEUS_OPT_STM         = 40;
        PROTEUS_OPT_PROG        = 41;
        PROTEUS_OPT_SHELL       = 42;
        
        %> MISCELLANEOUS
        BINARY_CHUNK_XFER_SIZE  = 2^30;  % Binary-Data Xfer Chunk Size (bytes)
        WAIT_PAUSE_SEC          = 0.02;          % Waiting pause (seconds)
        DLL_PATH                = 'C:\\Windows\\System32\\TEPAdmin.dll';

        %> FILE FORMATS
        FILE_FMT_BINARY         = 0;
        FILE_FMT_CSV            = 1;
        FILE_FMT_MATLAB         = 2;
        FILE_FMT_89600          = 3;
        FILE_FMT_XSERIES        = 4;
        % TIME LAYOUT IN FILES
        FILE_TIME_IMPLICIT      = 0;
        FILE_TIME_EXPLICIT      = 1;
        % COMPLEX LAYOUT IN FILES
        FILE_COMPLEX_REAL       = 0;
        FILE_COMPLEX_IMPLICIT   = 1;
        FILE_COMPLEX_EXPLICIT   = 2;

        %> RESAMPLING CONSTANTS
        RESAMP_QUALITY          = 10; %4.8; %4.8
        RESAMP_FILTER_RES       = 50000; %50000
        RESAMP_BW_FRACTION      = 1.0; %0.98;

        %> TASK LIST INDEX CONSTANTS
        TASK_MATRIX_WIDTH       = 15;
        TASK_SEGMENT_PTR        = 1;
        TASK_TYPE               = 2;
        TASK_LOOPS              = 3;
        TASK_LOOPS_SEQ          = 4;
        TASK_NEXT               = 5;
        TASK_DTR_FLAG           = 6;
        TASK_ENABLE_EVENT       = 7;
        TASK_ABORT_EVENT        = 8;
        TASK_IDLE_MODE          = 9;
        TASK_IDLE_LVL           = 10;
        TASK_JUMP_MODE          = 11;
        TASK_DELAY              = 12;
        TASK_NEXT2              = 13;
        TASK_KEEP               = 14;
        TASK_DEST               = 15;
        % TASK DESTINATION CHOICES
        TASK_DEST_NEXT          = 0;
        TASK_DEST_FBTRG         = 1;
        TASK_DEST_TRG           = 2;
        TASK_DEST_NTSEL         = 3;
        TASK_DEST_SCENARIO      = 4;
        TASK_DEST_DSP           = 5;
        TASK_DEST_DSIG          = 6;
        % TASK IDLE MODE
        TASK_IDLE_MODE_DC       = 0;
        TASK_IDLE_MODE_FIRST    = 1;
        TASK_IDLE_MODE_CURRENT  = 2;
        %> TASK JUMP MODE
        TASK_JUMP_MODE_EVENT    = 0;
        TASK_JUMP_MODE_IMMED    = 1;
        %> TASK KEEP MODE
        TASK_KEEP_OFF           = 0;
        TASK_KEEP_ON            = 1;
        %> TASK TYPE
        TASK_TYPE_SINGLE        = 0;
        TASK_TYPE_START         = 1;
        TASK_TYPE_SEQ           = 2;
        TASK_TYPE_END           = 3;
        %> TASK LIST ENABLE/DISABLE EVENTS
        TASK_EVENT_NONE         = 0;
        TASK_EVENT_TRG1         = 1;
        TASK_EVENT_TRG2         = 2;
        TASK_EVENT_CPU          = 3;
        TASK_EVENT_INT          = 4;

        %> MARKER MODE
        AWG_MKR_MODE_TWO        = 2;
        AWG_MKR_MODE_FOUR       = 4;
        AWG_MKR_MODE_EIGHT      = 8;
        %> AWG MODE
        AWG_MODE_DIRECT         = 0;
        AWG_MODE_DUC            = 1;
        AWG_MODE_NCO            = 2;
        %> AWG CHANNEL
        AWG_CHAN_ALL            = 0;
        AWG_CHAN_CH01           = 1;
        AWG_CHAN_CH02           = 2;
        AWG_CHAN_CH03           = 3;
        AWG_CHAN_CH04           = 4;
        AWG_CHAN_CH05           = 5;
        AWG_CHAN_CH06           = 6;
        AWG_CHAN_CH07           = 7;
        AWG_CHAN_CH08           = 8;
        AWG_CHAN_CH09           = 9;
        AWG_CHAN_CH10           = 10;
        AWG_CHAN_CH11           = 11;
        AWG_CHAN_CH12           = 12;
        %> IQ_MODE
        AWG_IQ_MODE_HALF        = 0;
        AWG_IQ_MODE_ONE         = 1;
        AWG_IQ_MODE_TWO         = 2;
        %> INTERPOLATION FACTORS
        AWG_INTERPOL_X1         = 1;
        AWG_INTERPOL_X2         = 2;
        AWG_INTERPOL_X4         = 4;
        AWG_INTERPOL_X6         = 6;
        AWG_INTERPOL_X8         = 8;
        AWG_INTERPOL_X10        = 10;
        AWG_INTERPOL_X12        = 12;
        AWG_INTERPOL_X16        = 16;
        AWG_INTERPOL_X18        = 18;
        AWG_INTERPOL_X20        = 20;
        AWG_INTERPOL_X24        = 24;
        %> INTERPOLATION FILTERS
        AWG_INT_FILTER_0        = 1;
        AWG_INT_FILTER_1        = 2;
        AWG_INT_FILTER_0_5X     = 3;
        AWG_INT_FILTER_2        = 4;
        AWG_INT_FILTER_0_3X     = 5;
        AWG_INT_FILTER_3        = 6;
        AWG_INT_FILTER_1_3X     = 7;
        AWG_INT_FILTER_INVSINC  = 8;
        AWG_INT_FILTER_NOFILTER = 9;
        %> NCO MODE
        AWG_NCO_MODE_SINGLE     = 1;
        AWG_NCO_MODE_DUAL       = 2;
        %> DAC MODE
        AWG_DAC_MODE_8          = 8;
        AWG_DAC_MODE_16         = 16;
        %> AWG TRIGGER MODE
        AWG_TRG_MODE_CONT       = 0;
        AWG_TRG_MODE_TRIG       = 1;
        % TRIGGER SLOPE
        AWG_TRG_SLOPE_NEG       = 0;
        AWG_TRG_SLOPE_POS       = 1;
        %> CPU TRIGGER MODE
        AWG_CPU_TRG_LOCAL       = 0;
        AWG_CPU_TRG_GLOBAL      = 1;

        %> DIGITIZER SELECTION
        DIG_SEL_ONE             = 1;
        DIG_SEL_TWO             = 2;
        %> DIGITIZER CHANNEL
        DIG_CHAN_ALL            = 0;
        DIG_CHAN_ONE            = 1;
        DIG_CHAN_TWO            = 2;
        %> DIGITIZER CHANNEL ENABLE
        DIG_CHAN_DISABLE        = 0;
        DIG_CHAN_ENABLE         = 1;
        %> DIGITIZER ACQ MODE
        DIG_ACQ_MODE_SINGLE     = 1;
        DIG_ACQ_MODE_DUAL       = 2;
        %> DIGITIZER RANGES
        DIG_RNG_250MV           = 1;
        DIG_RNG_400MV           = 2;
        DIG_RNG_500MV           = 3;
        %> DIGITIZER GRANULARITY
        DIG_GRANUL_SINGLE       = 96;
        DIG_GRANUL_DUAL         = 48;
        DIG_GRANUL_AVG          = 20;
        %> DIGITIZER DDC STATE
        DIG_MODE_REAL           = 0;
        DIG_MODE_COMPLEX        = 1;
        %> DDC BINDING
        DIG_DDC_BIND_OFF        = 0;
        DIG_DDC_BIND_ON         = 1;
        %> DDC DECIMATION
        DIG_DDC_DECIM_NONE      = 1;
        DIG_DDC_DECIM_X4        = 4;
        DIG_DDC_DECIM_X16       = 16;
        %> ADC RESOLUTION
        DIG_ADC_RESOL_REAL      = 12;
        DIG_ADC_RESOL_COMPLEX   = 15;
        %> CLK SOURCE
        DIG_CLK_SRC_DIG         = 0;
        DIG_CLK_SRC_AWG         = 1;
        %> TRIGGER SOURCE
        DIG_TRG_CPU             = 0;
        DIG_TRG_EXT             = 1;
        DIG_TRG_CH1             = 2;
        DIG_TRG_CH2             = 3;
        DIG_TRG_DTR_CH1         = 4;
        DIG_TRG_DTR_CH2         = 5;
        DIG_TRG_DTR_CH3         = 6;
        DIG_TRG_DTR_CH4         = 7;
        DIG_TRG_MR1             = 8;
        DIG_TRG_MF1             = 9;
        DIG_TRG_MR2             = 10;
        DIG_TRG_MF2             = 11;
        %> TRIGGER TYPE
        DIG_TRG_TYPE_EDGE       = 0;
        DIG_TRG_TYPE_GATE       = 1;
        DIG_TRG_TYPE_WEDGE      = 2;
        DIG_TRG_TYPE_WGATE      = 3;
        DIG_TRG_TYPE_CUSTOM     = 4;
        %> TRIGGER SLOPE
        DIG_TRG_EDGE_NEG        = 0;
        DIG_TRG_EDGE_POS        = 1;
        %> TRIGGER TIME CONDITION
        DIG_TRG_COND_SHORTER    = 0;
        DIG_TRG_COND_GREATER    = 1;
        %> DIGITIZER MARKER MODE STATE
        DIG_MKR_OFF             = 0;
        DIG_MKR_ON              = 1;
        %> DIGITIZER AVERAGING
        DIG_AVG_OFF             = 0;
        DIG_AVG_ON              = 1;
        %> DIGITIZER DATA TYPE
        DIG_DATA_TYPE_FRAMES    = 0;
        DIG_DATA_TYPE_HEADERS   = 1;
        DIG_DATA_TYPE_BOTH      = 2;
        % DIGITIZER DATA SELECT
        DIG_DATA_SEL_ALL        = 0;
        DIG_DATA_SEL_FRAMES     = 1;
        DIG_DATA_SEL_CHUNK      = 2;
        %> DIGITIZER DATA SELECT
        DIG_DATA_FMT_U16        = 0;
        DIG_DATA_FMT_SINGLE     = 1;
        DIG_DATA_FMT_DOUBLE     = 2;
        %> DIGITIZER INIT STATE
        DIG_INIT_OFF            = 0;
        DIG_INIT_ON             = 1;
        %> DIGITIZER EQUIVALENT TIME MODE
        DIG_ET_MODE_NORMAL      = 0;
        DIG_ET_MODE_EYE_DIAG    = 1;
        %> EYE DIAGRAM SIZES FOR COLOR GRADED
        DIG_ET_EYE_BINS         = 1000;
        DIG_ET_EYE_LVLS         = 1000;
        %> MINIMUM JITTER IN EYE SEARCH ITERATIONS
        DIG_ET_JIT_SEARCH_ITER  = 10;
        %> FRAME HEADERS ADC
        DIG_FRAME_HDR_TOT_SIZE  = 88;
        DIG_FRAME_HDR_TRG_LOC   = 1;
        DIG_FRAME_HDR_GATE_ADDR = 2;
        DIG_FRAME_HDR_MIN_ADC   = 3;
        DIG_FRAME_HDR_MAX_ADC   = 4;
        DIG_FRAME_HDR_TIMESTAMP = 5;
        %> FRAME HEADERS FIELD SIZE
        DIG_FRAME_HDR_FLD_SIZE  = [4, 4, 4, 4, 8];

        %> PULSE TYPE
        PULSE_TYPE_SQUARE       = 0;
        PULSE_TYPE_TRAPEZOIDAL  = 1;
        PULSE_TYPE_GAUSSIAN     = 2;
        PULSE_TYPE_NMR_FID      = 3;
        PULSE_TYPE_CHIRP_UP     = 4;
        PULSE_TYPE_CHIRP_DOWN   = 5;
        PULSE_TYPE_CHIRP_UPDOWN = 6;
        PULSE_TYPE_CHIRP_DOWNUP = 7;
        PULSE_TYPE_BARKER_CODE  = 8;
        PULSE_TYPE_FRANK_CODE   = 9;
        PULSE_TYPE_P1_CODE      = 10;
        PULSE_TYPE_P2_CODE      = 11;
        PULSE_TYPE_P3_CODE      = 12;
        PULSE_TYPE_P4_CODE      = 13;
        PULSE_TYPE_FILE         = 14;
        %> PULSE EDGE SHAPE
        PULSE_EDGE_LINEAR       = 0;
        PULSE_EDGE_EXPONENTIAL  = 1;
        PULSE_EDGE_GAUSSIAN     = 2;
        PULSE_EDGE_COSINE       = 3;
        %> PULSE JITTER_CATEGORIES
        PULSE_JITTER_CAT_SINE   = 1;
        PULSE_JITTER_CAT_RAND   = 2;
        PULSE_JITTER_CAT_SSC    = 3;
        PULSE_JITTER_CAT_MTONE  = 4;
        %> PULSE RANDOM JITTER PROFILE
        PULSE_JITTER_RND_GAUSS  = 0;
        PULSE_JITTER_RND_UNIF   = 1;
        %> PULSE SSC JITTER PROFILE
        PULSE_JITTER_SSC_TRIAN  = 0;
        PULSE_JITTER_SSC_SAWT   = 1;
        %> PULSE JITTER UNIT
        PULSE_JITTER_UNIT_UI    = 0;
        PULSE_JITTER_UNIT_SEC   = 1;
        %> BARKER CODE PULSES
        PULSE_BARKER_02         = 0;
        PULSE_BARKER_02_BIS     = 1;
        PULSE_BARKER_03         = 2;
        PULSE_BARKER_04         = 3;
        PULSE_BARKER_04_BIS     = 4;
        PULSE_BARKER_05         = 5;
        PULSE_BARKER_07         = 6;
        PULSE_BARKER_11         = 7;
        PULSE_BARKER_13         = 8;
        %> BARKER CODES SEQUENCES
        PULSE_BARKER_02_SEQ     = [+1, -1];
        PULSE_BARKER_02_BIS_SEQ = [+1, +1];
        PULSE_BARKER_03_SEQ     = [+1, +1, -1];
        PULSE_BARKER_04_SEQ     = [+1, +1, -1, +1];
        PULSE_BARKER_04_BIS_SEQ = [+1, +1, +1, -1];
        PULSE_BARKER_05_SEQ     = [+1, +1, +1, -1, +1];
        PULSE_BARKER_07_SEQ     = [+1, +1, +1, -1, -1, +1];
        PULSE_BARKER_11_SEQ     = [+1, +1, +1, -1, -1, -1, +1, -1, -1, +1, -1];
        PULSE_BARKER_13_SEQ     = [+1, +1, +1, +1, +1, -1, -1, +1, +1, -1, +1, -1, +1];


        %> ANALOG MODULATION SCHEME
        MOD_ANALOG_AM           = -1;
        MOD_ANALOG_FM           = -2;
        MOD_ANALOG_PM           = -3;
        %> DIGITAL MODULATION SCHEME
        MOD_SCHEME_QPSK         = 1;
        MOD_SCHEME_QAM16        = 2;
        MOD_SCHEME_QAM32        = 3;
        MOD_SCHEME_QAM64        = 4;
        MOD_SCHEME_QAM128       = 5;
        MOD_SCHEME_QAM256       = 6;
        MOD_SCHEME_QAM512       = 7;
        MOD_SCHEME_QAM1024      = 8;
        %> BASEBAND RAISED-COSINE FILTER TYPE
        MOD_BB_FILTER_NORMAL    = 0;
        MOD_BB_FILTER_SQRT      = 1;

        %> MULTI-TONE PHASE DISTRIBUTION
        MTONE_PHASE_CONSTANT    = 0;
        MTONE_PHASE_RANDOM      = 1;
        MTONE_PHASE_NEWMAN      = 2;
        MTONE_PHASE_RUDIN       = 3;

        %> PRBS SEQUENCES
        PRBS_RND                = 1;
        PRBS_2                  = 2;
        PRBS_3                  = 3;
        PRBS_4                  = 4;
        PRBS_5                  = 5;
        PRBS_6                  = 6;
        PRBS_7                  = 7;
        PRBS_8                  = 8;
        PRBS_9                  = 9;
        PRBS_10                 = 10;
        PRBS_11                 = 11;
        PRBS_12                 = 12;
        PRBS_13                 = 13;
        PRBS_14                 = 14;
        PRBS_15                 = 15;
        PRBS_16                 = 16;
        PRBS_17                 = 17;
        PRBS_18                 = 18;
        PRBS_19                 = 19;
        PRBS_20                 = 20;
        PRBS_21                 = 21;
        PRBS_22                 = 22;
        PRBS_23                 = 23;
        PRBS_24                 = 24;
        PRBS_25                 = 25;
        PRBS_26                 = 26;
        PRBS_27                 = 27;
        PRBS_28                 = 28;
        PRBS_29                 = 29;
        PRBS_30                 = 30;
        PRBS_31                 = 31;
        PRBS_32                 = 32;
        PRBS_33                 = 33;
        PRBS_34                 = 34;
        PRBS_35                 = 35;
        PRBS_36                 = 36;
        PRBS_37                 = 37;
        PRBS_38                 = 38;
        PRBS_39                 = 39;

        %> DATA WFM TYPE
        DATA_TYPE_BILVL_NRZ     = 0;
        DATA_TYPE_BILVL_RZ      = 1;
        DATA_TYPE_PAM4          = 2;
        DATA_TYPE_PAM8          = 3;
        DATA_TYPE_PAM3          = 4;
        DATA_TYPE_PAM5          = 5;   

        % SCOPE TRIGGER SLOPE
        SCOPE_TRG_SLOPE_NEG     = 0;
        SCOPE_TRG_SLOPE_POS     = 1;
    end

%**************************************************************************
    methods % public methods
%**************************************************************************

        function obj = TEProteusLib()
            obj.com_ifc         = obj.COMM_IFC_DLL;
            obj.paranoia_level  = obj.PARANOIA_LVL_LOW; % Paranoia level (0:low, 1:normal, 2:high)
        end

%**************************************************************************

        % UTILITY METHODS

        function [str] = netStrToStr(obj, netStr)
            try
                str = convertCharsToStrings(char(netStr));
            catch        
                str = '';
            end
        end

%**************************************************************************

        function default_awg_setup = CreateDefaultAwgSetup(obj)
            % Creation of default contents for AWG set up informartion
            % parameters specified by awg_setup struct. Fields:
            %   mode = AWG Mode, DIR, DUC, NCO
            %   iq_mode = half, one , two
            %   cfr = carrier frequencies (vector)
            %   phase = carrier initial phase (vector)
            %   six_db = true = on (vector)
            %   channel = target channel #
            %   segment = target segment #
            %   wfm_map = size for each waveform in myWfm, 0 = one wfm
            %   dac_resolution = DAC resolution (8 or 16 bit)
            %   volt = Voltage peak-to-peak. < 0 = MAX
            %   offset = DC Offset
            %   sampling_rate = AWG sampling rate
            %   interpol = interpolation factor
            %   output_state = 1, output ON, 0, output OFF
            %   report_time = 1, report download time, 0, do not report
            default_awg_setup.sel_module    = 1;
            default_awg_setup.mode          = obj.AWG_MODE_DIRECT;
            default_awg_setup.iq_mode       = obj.AWG_IQ_MODE_ONE;
            default_awg_setup.nco_mode      = obj.AWG_NCO_MODE_SINGLE;
            default_awg_setup.interpol      = obj.AWG_INTERPOL_X1;
            default_awg_setup.granularity   = 32;
            default_awg_setup.min_segment   = 128;
            default_awg_setup.cfr1          = 0.0;
            default_awg_setup.phase1        = 0.0;
            default_awg_setup.six_db1       = true;
            default_awg_setup.cfr2          = 0.0;
            default_awg_setup.phase2        = 0.0;
            default_awg_setup.six_db2       = true;
            default_awg_setup.channel       = 1;
            default_awg_setup.segment       = 1;
            default_awg_setup.wfm_map       = 0;
            default_awg_setup.dac_resolution= obj.AWG_DAC_MODE_16;
            default_awg_setup.volt          = 0.0;
            default_awg_setup.offset        = 0.0;
            default_awg_setup.mkr_mode      = obj.AWG_MKR_MODE_TWO;
            default_awg_setup.mkr1_state    = 1;
            default_awg_setup.mkr1_volt     = 0.5;
            default_awg_setup.mkr1_offset   = 0.0;
            default_awg_setup.mkr1_skew     = 0.0;
            default_awg_setup.mkr2_state    = 1;
            default_awg_setup.mkr2_volt     = 0.5;
            default_awg_setup.mkr2_offset   = 0.0;
            default_awg_setup.mkr2_skew     = 0.0;
            default_awg_setup.mkr3_state    = 1;
            default_awg_setup.mkr3_volt     = 0.5;
            default_awg_setup.mkr3_offset   = 0.0;
            default_awg_setup.mkr3_skew     = 0.0;
            default_awg_setup.mkr4_state    = 1;
            default_awg_setup.mkr4_volt     = 0.5;
            default_awg_setup.mkr4_offset   = 0.0;
            default_awg_setup.mkr4_skew     = 0.0;
            default_awg_setup.sampling_rate = 1E9;            
            default_awg_setup.dtr_delay     = 0.0;
            default_awg_setup.output_state  = 1;
            default_awg_setup.report_time   = 1;
            default_awg_setup.trg_mode      = obj.AWG_TRG_MODE_CONT;
            default_awg_setup.trg_src       = obj.TASK_EVENT_CPU;
            default_awg_setup.trg_slope     = obj.AWG_TRG_SLOPE_POS;
            default_awg_setup.trg_lvl       = 0.0;
            default_awg_setup.trg_count     = 1;
            default_awg_setup.trg_idle_mode = obj.TASK_IDLE_MODE_DC;
            default_awg_setup.trg_idle_lvl  = 32768;


            default_awg_setup.cpu_trg_mode  = obj.AWG_CPU_TRG_LOCAL;
        end

%**************************************************************************

        function default_dig_setup = CreateDefaultDigSetup(obj)
            default_dig_setup.mode          =   obj.DIG_ACQ_MODE_DUAL;
            default_dig_setup.ddc           =   obj.DIG_MODE_REAL;
            default_dig_setup.adc_resol     =   obj.DIG_ADC_RESOL_REAL;
            default_dig_setup.ddc_decim     =   obj.DIG_DDC_DECIM_NONE;
            default_dig_setup.ddc_bind      =   obj.DIG_DDC_BIND_OFF;
            default_dig_setup.granul        =   obj.DIG_GRANUL_DUAL;
            default_dig_setup.clk_src       =   obj.DIG_CLK_SRC_DIG;
            default_dig_setup.mkr           =   obj.DIG_MKR_OFF;
            default_dig_setup.avg           =   obj.DIG_AVG_OFF;

            default_dig_setup.ch_state      = [ obj.DIG_CHAN_ENABLE,...
                                                obj.DIG_CHAN_ENABLE];            
            default_dig_setup.rng           = [ obj.DIG_RNG_500MV,...
                                                obj.DIG_RNG_500MV];
            default_dig_setup.trg_src       = [ obj.DIG_TRG_CH1,...
                                                obj.DIG_TRG_CH1];
            default_dig_setup.dtr_src       = [ obj.DIG_TRG_DTR_CH1,...
                                                obj.DIG_TRG_DTR_CH1];
            default_dig_setup.trg_slope     = [ obj.DIG_TRG_EDGE_POS,...
                                                obj.DIG_TRG_EDGE_POS];
            default_dig_setup.trg_type      = [ obj.DIG_TRG_TYPE_EDGE,...
                                                obj.DIG_TRG_TYPE_EDGE];
            default_dig_setup.trg_cond      = [ obj.DIG_TRG_COND_GREATER,...
                                                obj.DIG_TRG_COND_GREATER];

            default_dig_setup.frame_length  =   2^10;            
            default_dig_setup.num_of_frames =   1;
            default_dig_setup.acq_timeout   =   180.0;
            default_dig_setup.pre_trigger   =   0;
            default_dig_setup.sampling_rate =   2.7E9;
            default_dig_setup.num_avgs      =   1;            
            default_dig_setup.trg_holdoff   =   0.0;

            default_dig_setup.offset        =   [0.0, 0.0];
            default_dig_setup.trg_lvl       =   [0.0, 0.0];
            default_dig_setup.cfr           =   [1E9, 1E9];
            default_dig_setup.phase         =   [0.0, 0.0];
            default_dig_setup.trg_width     =   [0.0, 0.0];
            default_dig_setup.trg_delay     =   [0.0, 0.0];
        end

%**************************************************************************

        function default_mod_setup = CreateDefaultModSetup(obj) 

            default_mod_setup.mod_type          = obj.MOD_SCHEME_QPSK;
            default_mod_setup.carrier_freq      = 1.0E6;
            default_mod_setup.modul_freq        = 1E3;
            default_mod_setup.num_of_mod_cycles = 1;
            default_mod_setup.modul_index       = 0.0; % AM: index(%), FM: Dev(Hz), PM: Peak Phase (º)
            default_mod_setup.num_of_symbols    = 2^10;
            default_mod_setup.symbol_rate       = 1.0E6;
            default_mod_setup.sample_rate       = 1.0E9;
            default_mod_setup.filter_type       = obj.MOD_BB_FILTER_SQRT;
            default_mod_setup.roll_off          = 0.35;
            default_mod_setup.oversampling      = 2;
            default_mod_setup.decimation        = 2;
        end

%**************************************************************************

        function default_mtone_setup = CreateDefaultMtoneSetup(obj) 

            default_mtone_setup.num_of_tones    = 10;
            default_mtone_setup.spacing         = 1.0E6;
            default_mtone_setup.phase_distr     = obj.MTONE_PHASE_NEWMAN;
            default_mtone_setup.offset_tone     = 0;
            default_mtone_setup.num_of_repeats  = 2;
            default_mtone_setup.notch_start     = 0;
            default_mtone_setup.notch_size      = 0;
            default_mtone_setup.oversampling    = 2;
        end
        
%**************************************************************************

        function default_pulse_setup = CreateDefaultPulseSetup(obj) 

            default_pulse_setup.prbs_seq        = obj.PRBS_10;
            default_pulse_setup.data_wfm_type   = obj.DATA_TYPE_BILVL_NRZ;
            default_pulse_setup.pulse_width     = 1E-6; % Tau for FID
            default_pulse_setup.pulse_rep_freq  = 1E+3;
            default_pulse_setup.freq_offset     = 0.0;
            default_pulse_setup.initial_phase   = 0.0;
            default_pulse_setup.pulse_type      = obj.PULSE_TYPE_SQUARE;
            default_pulse_setup.edge_shape      = obj.PULSE_EDGE_LINEAR;
            default_pulse_setup.rise_time       = 0.0;
            default_pulse_setup.time_offset     = 0.0;
            default_pulse_setup.sampling_rate   = 0;
            default_pulse_setup.bandwidth       = 0.0;
            default_pulse_setup.granul          = 32;
            default_pulse_setup.quality         = 4;  
            default_pulse_setup.timing_res      = 100.0E-15;
            default_pulse_setup.jit_enable      = [false, false, false];
            default_pulse_setup.jit_unit        = obj.PULSE_JITTER_UNIT_SEC;
            default_pulse_setup.jit_sine_freq   = 1E6;
            default_pulse_setup.jit_sine_ampl   = 1E-12;
            default_pulse_setup.jit_sine_phase  = 0.0;
            default_pulse_setup.jit_rnd_freq    = 1E6;
            default_pulse_setup.jit_rnd_ampl    = 1E-12;
            default_pulse_setup.jit_ssc_freq    = 1E3;
            default_pulse_setup.jit_ssc_dev     = 100.0; %ppm
            default_pulse_setup.jit_mtone_tones = 2; 
            default_pulse_setup.jit_mtone_space = 100E3;
            default_pulse_setup.jit_mtone_ampl  = 0.01;
            default_pulse_setup.trg_src         = obj.TASK_EVENT_NONE;
            default_pulse_setup.trg_delay       = 0.0;   

            default_pulse_setup.polyphase_code  = 1;
            
            default_pulse_setup.file_fmt        = obj.FILE_FMT_CSV;
            default_pulse_setup.file_name       = "";
            default_pulse_setup.in_sample_rate  = 5E3;
            default_pulse_setup.in_wfm_fraction = 100.0; % in %
            default_pulse_setup.in_wfm_offset   = 0.0; % in %
            default_pulse_setup.time_fmt        = obj.FILE_TIME_IMPLICIT;
            default_pulse_setup.complex_fmt     = obj.FILE_COMPLEX_IMPLICIT;
        end

%**************************************************************************

        function default_eq_time_setup = CreateDefaultEqTimeSetup(obj)
        
        
            default_eq_time_setup.mode          = obj.DIG_ET_MODE_NORMAL;
            default_eq_time_setup.clk_int       = false;
            default_eq_time_setup.all_edges     = false;
            default_eq_time_setup.clk_div       = 2;
            default_eq_time_setup.size          = 1e-9;
            default_eq_time_setup.delay         = 0.0;
            default_eq_time_setup.sampling_rate = 2.7e9;
            default_eq_time_setup.unit_interval = 1E-9;
        end

%**************************************************************************

        function default_infiniium_setup = CreateDefaultInfiniiumSetup(obj)
            default_infiniium_setup.chan_scope  = 1;
            default_infiniium_setup.volt_pp     = 1.0;
            default_infiniium_setup.time_window = 1E-6;
            default_infiniium_setup.sample_rate = 20E9;
            default_infiniium_setup.trg_channel = 3;
            default_infiniium_setup.trg_lvl     = 0.0;
            default_infiniium_setup.trg_slope   = obj.SCOPE_TRG_SLOPE_POS;
            default_infiniium_setup.trig_pos    = 50.0;
        end

%**************************************************************************

        function value = GetActualElement(obj, my_array, my_idx)
            % Get the element value after the cyclic index for any array.
            % Input data:
            % my_array = Array to process
            % my_idx = boundless array index
            % It returns:
            % value = data corresonsing to the mod(my_idx,
            % length(my_array)) 

            array_size  = length(my_array);
            my_idx      = mod(my_idx - 1, array_size) + 1;
            value       = my_array(my_idx);
        end

%**************************************************************************

        function [out_wfm, num_of_reps] = WfmAppendGranularity(obj, wfm, granul)

            final_length    = lcm(length(wfm),int32(granul));

            num_of_reps     = final_length / length(wfm);

            out_wfm         = obj.WfmRepeat(wfm, num_of_reps);            
        end

%**************************************************************************

        function out_wfm = WfmRepeat(obj, wfm, num_of_reps)   

            num_of_reps = int32(num_of_reps);
            out_wfm     = repmat(wfm,1,num_of_reps);
        end

%**************************************************************************
        function out_wfm = WfmRepeatForMinSize(obj, wfm, min_size)   

            num_of_reps = ceil(min_size / length(wfm));
            out_wfm     = repmat(wfm,1,num_of_reps);
        end


%**************************************************************************

        function out_wfm = WfmExpand(obj, wfm, expand_factor)   

            expand_factor   = int32(expand_factor);
            out_wfm         = zeros(1, length(wfm) * expand_factor);
            
            for i = 1:expand_factor
                out_wfm(i:expand_factor:end) = wfm;
            end
        end

%**************************************************************************

        function out_wfm =WfmCompress(obj, wfm, compress_factor)   
            
            compress_factor = int32(compress_factor);
            out_wfm         = wfm(1:compress_factor:end);            
        end

%**************************************************************************

        function out_wfm = Interleave(obj, wfm_1, wfm_2)   

            wfm_length          = length(wfm_1);
            if length(wfm_2) < wfm_length
                wfm_length      = length(wfm_2);
            end           
    
            out_wfm             = uint8(zeros(1, 2 * wfm_length));            
            out_wfm(1:2:end)    = wfm_1;
            out_wfm(2:2:end)    = wfm_2;
        end

%**************************************************************************

        function out_wfm = ComplexToInterleaved(obj, wfm_iq)
            % Complex Waveform data is converted to interleaved data to be
            % downloaded to the Proteus Wfm Memory while in IQ Mode
            % wfm_iq = Input complex data (if real, imag samples = 0.0)
            % It returns:
            % out_wfm: I/Q interleaved data. Size = 2 x size(wfmIq)
            
            wfm_length                          = length(wfm_iq);
            out_wfm                             = zeros(1, 2 * wfm_length);
            % Odd samples = I samples
            out_wfm(1:2:(2 * wfm_length - 1))   = real(wfm_iq);
            % Even samples = Q samples
            out_wfm(2:2:(2 * wfm_length))       = imag(wfm_iq);
        end

%**************************************************************************

        function out_wfm = InterleavedToComplex(obj, wfm_iq)
            % I/Q Interleaved Waveform data is converted to complex data to
            % be used in computations.
            % wfm_iq = Input interleaved data. Length must be even.
            % It returns:
            % out_wfm: I/Q Complex data. Size = size(wfmIq) / 2
            
            wfm_length  = length(wfm_iq);
            % Complex sample building
            out_wfm     = double(wfm_iq(2:2:wfm_length)) +...
                1.0i * double(wfm_iq(1:2:wfm_length));
        end

%**************************************************************************

        function out_wfm = ComplexToInterleavedTwo(obj, wfm_1, wfm_2)
            % This function formats data for two I/Q streams to be downloaded
            % to a single segment in Proteus to be generated in the IQM Mode 'TWO'
            % All waveforms must be properly normalized together to the unity circle range.
            % All waveforms must have the same length   
        
            % Formatting requires to go through the following steps:
            %   1) quantize samples to 16-bit unsigned integers
            %   2) swap the LSB and MSB as MSBs will be sent first for this mode
            %   3) convert the uint16 array to an uint8 array of twice the size
            % Final wfm is MSB, LSB, MSB, LSB,...
            wfm_i_1     = typecast(swapbytes(uint16(obj.Quantization(real(wfm_1), 16, 1))),'uint8'); 
            wfm_q_1     = typecast(swapbytes(uint16(obj.Quantization(imag(wfm_1), 16, 1))),'uint8');
            wfm_i_2     = typecast(swapbytes(uint16(obj.Quantization(real(wfm_2), 16, 1))),'uint8');
            wfm_q_2     = typecast(swapbytes(uint16(obj.Quantization(imag(wfm_2), 16, 1))),'uint8');
            % Sequence MSBI1, MSBQ1, MSBQ2, MSBI2, LSBI1, LSBQ1, LSBQ2, LSBI2
            % This is done in three interleaving steps
            out_wfm_i   = obj.Interleave(wfm_i_1, wfm_q_2);
            out_wfm     = obj.Interleave(wfm_q_1, wfm_i_2);
            out_wfm     = obj.Interleave(out_wfm_i, out_wfm); 
        
            % Format as 16 bit integers as this is how waveforms are transferred
            out_wfm = uint16(out_wfm(1:2:length(out_wfm))) + 256 * uint16(out_wfm(2:2:length(out_wfm)));
        end

%**************************************************************************

        function framed_acq = SamplesToFrames(obj, framed_acq, frame_length)
            % Converts a single vector containing multiple equal-length
            % frames to a NxM array where N is the number of frames and M
            % is the number of samples per frame. It works with real and
            % complex data.
            % framed_acq: Input raw waveform data
            % frame_length: Samples per frame
            % It returns:
            % framed_acq = Ouput NxM array

            % Number of frames is always an integer number. Incomplete
            % frames at the end are just discarded.
            num_of_frames   = floor(length(framed_acq) / frame_length);
            % Just complete frames are preserved
            framed_acq      = framed_acq(1:num_of_frames * frame_length);
            % An MxN array is created
            framed_acq      = reshape(framed_acq, frame_length, num_of_frames);
            % The final NxM array is created by transposing the array
            framed_acq      = framed_acq';
        end

%**************************************************************************

        function [x_coord, y_coord, z_flag] = ReadPlt(obj, fileName,interpol, plot_flag)
            % Import waveform data for XYZ display from .plt files (HPGL
            % format). X and Y data is normalized so it always go from -1.0
            % to +1.0 to use all the DAC range.
            % It supports just PU and PD commands with single pair of
            % associated coordinates.
            % filename = .plt file name
            % interpol = Interpolation factor for output data (integer)
            % It returns:
            % x_coord = Output X values
            % y_coord = Output y values
            % z_flag = Z axis (brightness) control.
            
            numOfElements   = 0;
            x_coord         = double.empty;
            y_coord         = double.empty;
            z_flag          = double.empty;
        
            fid = fopen(fileName,'rt');
            while true
                thisline = fgetl(fid);
                if ~ischar(thisline) 
                    break; 
                end  %end of file
                
                thisline = upper(thisline);
                
                if contains(thisline, 'PU') 
                    thisline        = strrep(thisline, 'PU', '');
                    thisline        = strrep(thisline, ';', '');
                    currentCoord    = sscanf(thisline, '%f');
                    
                    if numOfElements == 0
                        numOfElements           = numOfElements + 1;
                        x_coord                 = currentCoord(1);
                        y_coord                 = currentCoord(2);
                        z_flag                  = 1;
                        numOfElements           = numOfElements + 1;
                        x_coord(numOfElements)  = currentCoord(1);
                        y_coord(numOfElements)  = currentCoord(2);
                        z_flag(numOfElements)   = -1;
                    else
                        numOfElements           = numOfElements + 1;
                        x_coord(numOfElements)  = x_coord(numOfElements - 1);
                        y_coord(numOfElements)  = y_coord(numOfElements - 1);
                        z_flag(numOfElements)   = 1;
                        numOfElements           = numOfElements + 1;
                        x_coord(numOfElements)  = currentCoord(1);
                        y_coord(numOfElements)  = currentCoord(2);
                        z_flag(numOfElements)   = 1;   
                        numOfElements           = numOfElements + 1;
                        x_coord(numOfElements)  = currentCoord(1);
                        y_coord(numOfElements)  = currentCoord(2);
                        z_flag(numOfElements)   = -1;  
                    end           
                end
                
                if contains(thisline, 'PD') 
                    thisline                = strrep(thisline, 'PD', '');
                    thisline                = strrep(thisline, ';', '');
                    currentCoord            = sscanf(thisline, '%f'); 
                    
                    numOfElements = numOfElements + 1;
                    x_coord(numOfElements)  = currentCoord(1);
                    y_coord(numOfElements)  = currentCoord(2);
                    z_flag(numOfElements)   = -1;
                end        
            end
            
            numOfElements           = numOfElements + 1;
            x_coord(numOfElements)  = x_coord(numOfElements - 1);
            y_coord(numOfElements)  = y_coord(numOfElements - 1);
            z_flag(numOfElements)   = 1;
            
            fclose(fid);   
            
            xMin    = min(x_coord);
            xMax    = max(x_coord);
            yMin    = min(y_coord);
            yMax    = max(y_coord);
            
            x_coord = -1.0 + 2.0 * (x_coord - xMin) / (xMax - xMin);
            y_coord = -1.0 + 2.0 * (y_coord - yMin) / (yMax - yMin);
            
            xBase   = 1: length(x_coord);
            xInter  = 1: 1/interpol : (length(x_coord) - 1/interpol);
            
            x_coord = interp1(xBase,x_coord, xInter);
            y_coord = interp1(xBase,y_coord, xInter); 
            z_flag  = -interp1(xBase,z_flag, xInter);

            if plot_flag
                obj.Plot_xyz(x_coord, y_coord, z_flag);
            end
        end

%**************************************************************************

        function Plot_xyz(obj, x_coord, y_coord, z_flag)
            % Shows graph to validate .plt imported values
            % x_coord = Input X values
            % y_coord = Input y values
            % z_flag = Z axis (brightness) control

            new_figure_flag = false;
            hold_flag       = true;
        
            current_x       = double.empty;
            current_y       = double.empty;
        
            for current_point = 1:length(x_coord)
                if new_figure_flag
                    current_x       = double.empty;
                    current_y       = double.empty;
                    new_figure_flag = false;
                end
        
                if z_flag(current_point) == 1 && current_point < length(x_coord)
                    current_x       = [current_x, x_coord(current_point)];
                    current_y       = [current_y, y_coord(current_point)];            
                else
                    if current_point == length(x_coord) && z_flag(current_point) == 1
                        current_x   = [current_x, x_coord(current_point)];
                        current_y   = [current_y, y_coord(current_point)];                      
                    end                    

                    plot(current_x, current_y, 'color','blue');
                    if hold_flag
                        hold;
                        hold_flag   = false;                
                    end
                    new_figure_flag = true;
                end
            end
        end

%***********************************************************************

        function sample_stored = SaveIqToCsvFile89600(obj, file_name, wfm_iq, sample_rate)

            sample_stored   = length(wfm_iq);
        
            try
                file_id     = fopen(file_name, 'w');
        
                fprintf(file_id, 'XStart, %6.8f\n', 0.0);
                fprintf(file_id, 'XDelta, %e\n', 1/sample_rate);
                fprintf(file_id, 'XDomain, %d\n', 2);
                fprintf(file_id, 'Y,\n');
                for i=1:sample_stored
                    fprintf(file_id, '%6.8f, %6.8f\n', real(wfm_iq(i)), imag(wfm_iq(i)));
                end
                fclose(file_id);
            catch
                sample_stored = 0;        
            end
        end

%***********************************************************************

        function sample_stored = SaveIqToCsvFileXseries(obj, file_name, wfm_iq, center_frequency, sample_rate)

            sample_stored   = length(wfm_iq);
        
            try
                file_id     = fopen(file_name, 'w');
        
                % Header
                fprintf(file_id, 'InputZoom, TRUE\n');
                fprintf(file_id, 'InputCenter, %12.8f\n', center_frequency);
                fprintf(file_id, 'InputRefImped, %d\n', 50);
                fprintf(file_id, 'XStart, %6.8f\n', 0.0);
                fprintf(file_id, 'XDelta, %e\n', 1/sample_rate);
                fprintf(file_id, 'XDomain, %d\n', 2);
                fprintf(file_id, 'XUnit, Sec\n');
                fprintf(file_id, 'YUnit, V\n');        
                dt          = string(datetime('now','TimeZone','local',...
                                    'Format','MM/dd/yyyy HH:mm:ss a'));
                fprintf(file_id, 'TimeString, %s\n', dt);
                fprintf(file_id, 'Y\n');
                % Data as I,Q pairs        
                fprintf(file_id, '%6.8f, %6.8f\n', real(wfm_iq), imag(wfm_iq));
                
                fclose(file_id);
            catch
                sample_stored = 0;        
            end
        end

%***********************************************************************       

        function [wfm_iq, center_frequency, sample_rate] = LoadCsvFileXseries(obj, file_name)

            center_frequency            = 0.0;
            sample_rate                 = 0.0;        
            y_flag                      = false;      
            
            fid                         = fopen(file_name, 'rt');
        
            while true
                thisline                = fgetl(fid);
                if ~ischar(thisline) 
                    break; 
                end  %end of file
                
                thisline = upper(thisline);
        
                if contains(thisline, 'INPUTCENTER') 
                    thisline            = strrep(thisline, 'INPUTCENTER', '');
                    thisline            = strrep(thisline, ',', '');
                    center_frequency    = sscanf(thisline, '%f');
                end
        
                if contains(thisline, 'XDELTA') 
                    thisline            = strrep(thisline, 'XDELTA', '');
                    thisline            = strrep(thisline, ',', '');
                    sample_rate = sscanf(thisline, '%f');
                    if sample_rate ~= 0.0
                        sample_rate     = 1.0 / sample_rate;
                    end
        
                end
            
                if strcmp(thisline, 'Y')
                    y_flag              = true;
                    break;            
                end
            end
        
            num_of_elem                 = 0;
        
            if y_flag
                while true
                    thisline            = fgetl(fid);
                    if ~ischar(thisline) 
                        break; 
                    end  %end of file
                
                    num_of_elem         = num_of_elem + 1;
                    current_sample      = sscanf(thisline, '%f, %f');
                    current_sample      = current_sample(1) +...
                        1i * current_sample(2);
                    wfm_iq(num_of_elem) = current_sample;
                end
            end        
            fclose(fid);    
        end

%***********************************************************************        

        function [x_values, y_values, papr] = CCDF (obj, wfm, num_of_bins)
        %CCDF Compleementary Cumulative Distribution Function
        %   iqWfm can be real or imaginary waveform
        %   numOfBins is the size of the output arrays
        %   xValues holds the power respect the average power in dB
        %   yValues holds the percentage of time spent by the signalover this
        %   power level   
            % Calculate power waveform
            wfm         = wfm .* conj(wfm);    
            % Convert to dB relative to mean power
            wfm         = 10 * (log10(wfm) - log10(mean(wfm)));
            % PAPR (Crest Factor) is the maximum value in the vector
            papr        = max(wfm);   
            
            %CCDF is calculated here
            x_values    = 0 : (papr / (num_of_bins - 1)) : papr;
            y_values    = 100 / length(wfm) * sum(x_values' <= wfm, 2); % CCDF as a percentage
        end

%***********************************************************************        

        function PlotCcdf (obj, ax1, wfm)

            [x_values, y_values, papr] = obj.CCDF (wfm, 100);
        
            semilogy(ax1, x_values, y_values);    
            title(ax1,sprintf('CCDF, PAPR = %f', papr));       
            xlabel('dB') 
            ylabel('%') 
        end

%**************************************************************************
%**************************************************************************
        % PROCESSING METHODS
%**************************************************************************

        function [  shifted_wfm,...
                    final_carrier_freq] = ShiftFreq(    obj,...
                                                        wfm, ...
                                                        frequency, ...
                                                        initial_phase,...
                                                        sample_rate,...
                                                        adjust_carrier)            
            
            if adjust_carrier
                freq_res        = sample_rate / length(wfm);
                frequency       = round(frequency / freq_res) * freq_res;
            end

            shifted_wfm         = 1:length(wfm);
            shifted_wfm         = shifted_wfm - 1;
            shifted_wfm         = shifted_wfm / sample_rate;

            shifted_wfm         = exp(1i * 2.0 * pi * frequency *...
                shifted_wfm + initial_phase * pi / 180.0);
            shifted_wfm         = shifted_wfm .* wfm;

            final_carrier_freq  = frequency;
        end

%**************************************************************************

        function iq_pulse = GetIqPulse( obj,...
                                        pulse_setup)

            switch pulse_setup.pulse_type

                case obj.PULSE_TYPE_TRAPEZOIDAL
                    iq_pulse = obj.GetTrapezoidalPulse( pulse_setup.pulse_width, ...
                                                        pulse_setup.edge_shape, ...
                                                        pulse_setup.rise_time,...
                                                        pulse_setup.sampling_rate, ...                                                    
                                                        1, ...
                                                        pulse_setup.granul, ...
                                                        pulse_setup.quality);

                case obj.PULSE_TYPE_GAUSSIAN
                    iq_pulse = obj.GetGaussPulse(       pulse_setup.pulse_width,...
                                                        pulse_setup.sampling_rate,...
                                                        pulse_setup.quality,...
                                                        1,...
                                                        pulse_setup.granul);

                case obj.PULSE_TYPE_NMR_FID
                    iq_pulse = obj.GetFidPulse(         pulse_setup.pulse_width, ...
                                                        pulse_setup.sampling_rate, ...
                                                        pulse_setup.quality, ...
                                                        pulse_setup.granul);

                case obj.PULSE_TYPE_CHIRP_UP            
                    iq_pulse = obj.GetIqChirp(          pulse_setup.pulse_width, ...
                                                        pulse_setup.bandwidth, ...
                                                        pulse_setup.sampling_rate, ...
                                                        pulse_setup.granul);

                case obj.PULSE_TYPE_CHIRP_DOWN            
                    iq_pulse = obj.GetIqChirp(          pulse_setup.pulse_width, ...
                                                        -pulse_setup.bandwidth, ...
                                                        pulse_setup.sampling_rate, ...
                                                        pulse_setup.granul);

                case {  obj.PULSE_TYPE_BARKER_CODE,...
                        obj.PULSE_TYPE_FRANK_CODE,...
                        obj.PULSE_TYPE_P1_CODE,...
                        obj.PULSE_TYPE_P2_CODE,...
                        obj.PULSE_TYPE_P3_CODE,...
                        obj.PULSE_TYPE_P4_CODE}
                    iq_pulse = obj.GetPolyPhasePulse(   pulse_setup.pulse_type,...
                                                        pulse_setup.polyphase_code,...
                                                        pulse_setup.sampling_rate, ...
                                                        pulse_setup.pulse_width, ...
                                                        pulse_setup.granul);
                
            end

            iq_pulse = obj.ShiftFreq(                   iq_pulse, ...
                                                        pulse_setup.freq_offset, ...
                                                        0.0,...
                                                        pulse_setup.sampling_rate,...
                                                        false);

            

        end

%**************************************************************************


        function test_signal = GetFilePulse(             obj,...
                                                        file_name,...
                                                        file_fmt,...
                                                        time_layout,...
                                                        complex_layout,...
                                                        pulse_duration,...
                                                        pulse_offset,...
                                                        input_sample_rate,...
                                                        output_sample_rate,...                                                    
                                                        min_samples,...
                                                        granularity)

            load(file_name);
            
            %file_pulse = readmatrix(file_name);

            input_wfm_length    = length(test_signal);            
            start_sample        = round(pulse_offset *  input_wfm_length / 100.0) + 1;
            stop_sample         = start_sample + round(pulse_duration *  input_wfm_length / 100.0); 
            stop_sample         = stop_sample - 1;

            test_signal          = test_signal(start_sample:stop_sample);
            % pulse_duration      = length(test_signal) / input_sample_rate;
            % output_wfm_length   = floor(pulse_duration * output_sample_rate);
            % test_signal         = obj.ResamplingDirect(     test_signal, ...
            %                                                 output_wfm_length, ...
            %                                                 true);

            % Adjust Granularity
            while length(test_signal) < min_samples || mod(length(test_signal), granularity) > 0
                test_signal = [test_signal, complex(0.0)];
            end
        end

        function trapeze_pulse = GetTrapezoidalPulse(   obj,...
                                                        t_50, ...
                                                        edge_shape, ...
                                                        rise_time,...
                                                        sample_rate, ...                                                    
                                                        min_samples, ...
                                                        granularity, ...
                                                        quality)
            quality             = round(quality);
            
            switch edge_shape
                case obj.PULSE_EDGE_LINEAR
                    edge_total_t    = rise_time / 0.8;
                    half_ampl_t     = edge_total_t * 0.5;
                    pulse_length    = t_50 + 2 * half_ampl_t;                    
                    pulse_length    = ceil(pulse_length * sample_rate);
                    trapez_pulse    = zeros(1, pulse_length);

                    for current_sample = 0:(pulse_length - 1)
                        current_time                    = current_sample / sample_rate;

                        if current_time < edge_total_t
                            trapez_pulse...
                                (current_sample + 1)    = current_time / edge_total_t;                            

                        elseif current_time < t_50
                            trapez_pulse...
                                (current_sample + 1)    = 1.0;

                        elseif current_time <= (t_50 + edge_total_t)
                            trapez_pulse...
                                (current_sample + 1)    = 1 - (current_time - t_50) / edge_total_t; 
                        end
                    end

                case obj.PULSE_EDGE_EXPONENTIAL
                    tau                 = - rise_time / log(0.1 / 0.9);
                    half_ampl_t         = -tau * log(0.5);
                    num_of_taus         = quality;
                    pulse_length        = t_50 + num_of_taus * tau;
                    pulse_length        = ceil(pulse_length * sample_rate);
                    trapez_pulse        = zeros(1, pulse_length);
                    
                    for current_sample = 0:(pulse_length - 1)
                        current_time                    = current_sample / sample_rate;

                        if current_time < (t_50 + half_ampl_t)
                            trapez_pulse...
                                (current_sample + 1)    = 1 - exp(-current_time / tau);

                        elseif current_time <= (t_50 + num_of_taus * tau)
                            trapez_pulse...
                                (current_sample + 1)    = ( 1 - exp(-(t_50 + half_ampl_t) / tau)) * exp(-(current_time - t_50 - half_ampl_t) / tau);
                        end
                    end

                case obj.PULSE_EDGE_GAUSSIAN
                    alfa            = pi^2 * (0.35 / rise_time)^2 / log(2);                    
                    imp_resp_width  = (log(4) / alfa) ^0.5;

                    impulse_resp    = obj.GetGaussPulse(   imp_resp_width, ...
                                                            quality * sample_rate, ...
                                                            4, ...
                                                            1, ...
                                                            1);
                    impulse_resp    = impulse_resp / sum(impulse_resp);

                    pulse_length    = round(t_50 * quality * sample_rate);
                    trapez_pulse    =  double(ones(1, pulse_length));
                    trapez_pulse    = conv(trapez_pulse, impulse_resp);
                    trapez_pulse    = trapez_pulse(1:quality:end);

                case obj.PULSE_EDGE_COSINE
                    omega           = 4.0 * asin(0.8) / rise_time;
                    half_ampl_t     = pi / omega;
                    edge_total_t    = 2 * half_ampl_t;
                    pulse_length    = t_50 + edge_total_t;
                    pulse_length    = ceil(pulse_length * sample_rate);
                    trapez_pulse    = zeros(1, pulse_length);

                    for current_sample = 0:(pulse_length - 1)
                        current_time                            = current_sample / sample_rate;

                        if current_time < edge_total_t
                            trapez_pulse(current_sample + 1)    = 0.5 - 0.5 * cos(omega / 2 * current_time);

                        elseif current_time < t_50
                            trapez_pulse(current_sample + 1)    = 1.0;

                        elseif current_time <=(t_50 + edge_total_t)
                            trapez_pulse(current_sample + 1)    = 0.5 + 0.5 * cos(omega / 2 * (current_time - t_50));
                        end
                    end
            end          
                  
            final_length        = ceil(length(trapez_pulse) / granularity) * granularity;
            
            while final_length < min_samples
                final_length    = final_length + granularity;
            end
        
            trapeze_pulse                           = zeros(1, final_length);
            trapeze_pulse(1:length(trapez_pulse))   = trapez_pulse;
        end


%**************************************************************************

        function gauss_pulse = GetGaussPulse(   obj,...
                                                t_50, ...
                                                sample_rate, ...
                                                pulse_length, ...
                                                min_samples, ...
                                                granularity)
        
            pulse_length        = pulse_length * t_50;
            pulse_length        = pulse_length * sample_rate;
            pulse_length        = ceil(pulse_length);
        
            if mod(pulse_length, 2) == 0
                pulse_length    = pulse_length + 1;
            end
        
            a                   =  t_50 / (2 * ((-log(0.5))  ^ 0.5));
        
            isol_gauss_pulse    = (-(pulse_length - 1) / 2):((pulse_length - 1) / 2);
            
            isol_gauss_pulse    = isol_gauss_pulse / sample_rate;
        
            isol_gauss_pulse    = exp(-isol_gauss_pulse .^2 / a ^ 2);
        
            final_length        = ceil(length(isol_gauss_pulse) / granularity) * granularity;
            
            while final_length < min_samples
                final_length    = final_length + granularity;
            end
        
            gauss_pulse         = zeros(1, final_length);
            gauss_pulse(1:length(isol_gauss_pulse))...
                                = isol_gauss_pulse;
        end

%**************************************************************************

        function iq_chirp = GetIqChirp( obj,...
                                        chirp_duration, ...
                                        chirp_bw, ...
                                        sample_rate, ...
                                        granularity)
        
            num_samples = floor(chirp_duration * sample_rate);
            iq_chirp    = 0:(num_samples- 1);
            iq_chirp    = iq_chirp - num_samples/ 2;
            iq_chirp    = iq_chirp / sample_rate;
           
            inst_freq   = iq_chirp * chirp_bw / chirp_duration;
            % As phase change with t^2, instantaneous frequency is multiplied by pi and not 2pi
            iq_chirp    = exp(1i * pi * inst_freq .* iq_chirp);
            
            num_samples = ceil(chirp_duration * sample_rate / granularity) * granularity;
            iq_chirp    = [iq_chirp, zeros(1,num_samples - length(iq_chirp))];            
        end 

%**************************************************************************

        function fid_pulse = GetFidPulse(   obj,...
                                            tau, ...
                                            sample_rate, ...
                                            pulse_length, ...
                                            granularity)

            pulse_length    = pulse_length * tau;
            pulse_length    = pulse_length * sample_rate;
            pulse_length    = ceil(pulse_length);
            final_length    = ceil(pulse_length / granularity) * granularity;         
        
            fid_pulse       = 0:(final_length - 1);
            fid_pulse       = fid_pulse / sample_rate; 
            
            fid_pulse       = exp(-fid_pulse / tau);
        end

%**************************************************************************

        function [  myWfm,...
                    map_wfm,...
                    task_list] = GetFreqHopWfms(    obj,...
                                                    awg_setup,...
                                                    freq_hop,...
                                                    hop_list)
            % freq_hop.central_freq       = 800E6;
            % freq_hop.carrier_spacing    = 10E3;
            % freq_hop.num_of_carriers    = 20;
            % freq_hop.hop_duration       = 1E-3;
            % freq_hop.num_of_hops        = 1000;

            % Non-Repeating Random Frequency Hoping Sequence
            carrier_hop = zeros(1, freq_hop.num_of_hops); 

            if ~exist('hop_list','var')
                for hop = 1:freq_hop.num_of_hops
                    carrier_hop(hop) = round(rand * freq_hop.num_of_carriers - 0.5); 
                    carrier_hop(carrier_hop < 0) = 0;
                    carrier_hop(carrier_hop > (freq_hop.num_of_carriers - 1)) = freq_hop.num_of_carriers - 1;
    
                    if hop > 1
                        while carrier_hop(hop) == carrier_hop(hop - 1)
                            carrier_hop(hop) = round(rand * (freq_hop.num_of_carriers + 1));
                        end
                    end
                end

                carrier_hop = carrier_hop + 1;

            else
                for hop = 1:freq_hop.num_of_hops
                    carrier_hop(hop) =  obj.GetActualElement(hop_list, hop);
                end
            end

            actual_sampling_rate = awg_setup.sampling_rate / awg_setup.interpol;

            segment_length = actual_sampling_rate * freq_hop.hop_duration;
            segment_length = floor(segment_length / awg_setup.granularity) * awg_setup.granularity;
            
            num_of_cycles = 0: (freq_hop.num_of_carriers - 1); 
            num_of_cycles = num_of_cycles - (freq_hop.num_of_carriers - 1) / 2;

            if mod(freq_hop.num_of_carriers, 2) == 0
                num_of_cycles = 2 * num_of_cycles;
                basic_num_of_cycles = round(freq_hop.hop_duration * freq_hop.carrier_spacing / 2);                
            else
                basic_num_of_cycles = round(freq_hop.hop_duration * freq_hop.carrier_spacing);
            end

            num_of_cycles = num_of_cycles * basic_num_of_cycles;

            % % Non-Repeating Random Frequency Hoping Sequence
            % carrier_hop = zeros(1, freq_hop.num_of_hops);            
            % 
            % for hop = 1:freq_hop.num_of_hops
            %     carrier_hop(hop) = round(rand * freq_hop.num_of_carriers - 0.5); 
            %     carrier_hop(carrier_hop < 0) = 0;
            %     carrier_hop(carrier_hop > (freq_hop.num_of_carriers - 1)) = freq_hop.num_of_carriers - 1;
            % 
            %     if hop > 1
            %         while carrier_hop(hop) == carrier_hop(hop - 1)
            %             carrier_hop(hop) = round(rand * (freq_hop.num_of_carriers + 1));
            %         end
            %     end
            % end
            % 
            % carrier_hop = carrier_hop + 1;

            myWfm = zeros(1, segment_length * freq_hop.num_of_carriers);
            x_data = 0: (segment_length - 1);
            for current_carrier = 1:freq_hop.num_of_carriers
                initial_sample = (current_carrier - 1) * segment_length + 1;
                final_sample = initial_sample + segment_length - 1;
                myWfm(initial_sample:final_sample) = exp(1i * 2 * pi * num_of_cycles(current_carrier) * x_data / segment_length);
            end 

            map_wfm = zeros(1, freq_hop.num_of_carriers);
            map_wfm = map_wfm + segment_length;

             % ********************TASK LIST*********************
            task_list = uint32(zeros(freq_hop.num_of_hops, obj.TASK_MATRIX_WIDTH));
            for current_task = 1:freq_hop.num_of_hops
                task_list(current_task, obj.TASK_SEGMENT_PTR)  = carrier_hop(current_task);
                task_list(current_task, obj.TASK_TYPE)         = obj.TASK_TYPE_SINGLE;
                task_list(current_task, obj.TASK_LOOPS)        = 1;
                if current_task == freq_hop.num_of_hops
                    task_list(current_task, obj.TASK_NEXT)         = 1;
                else
                    task_list(current_task, obj.TASK_NEXT)         = current_task + 1;   
                end
                task_list(current_task, obj.TASK_ENABLE_EVENT) = obj.TASK_EVENT_NONE;
                task_list(current_task, obj.TASK_ABORT_EVENT)  = obj.TASK_EVENT_NONE;
                if current_task == 1
                    task_list(current_task, obj.TASK_DTR_FLAG)      = 1;
                else
                    task_list(current_task, obj.TASK_DTR_FLAG)      = 0;
                end
            end

        end

%**************************************************************************

        function polyphase_pulse = GetPolyPhasePulse(   obj,...
                                                        intra_modulation,...
                                                        code_number,...
                                                        sample_rate, ...
                                                        pulse_length, ...
                                                        granularity)

            pulse_length    = pulse_length * sample_rate;
            pulse_length    = ceil(pulse_length);
            final_length    = ceil(pulse_length / granularity) * granularity;         
        
            t_pulse         = 0:(final_length - 1);
            t_pulse         = t_pulse / sample_rate;

            switch intra_modulation
                case obj.PULSE_TYPE_BARKER_CODE
                    code_iq = obj.GetBarkerCode(code_number);

                case obj.PULSE_TYPE_FRANK_CODE
                    code_iq = obj.GetFrankCode(code_number);

                case obj.PULSE_TYPE_P1_CODE
                    code_iq = obj.GetP1Code(code_number);

                case obj.PULSE_TYPE_P2_CODE
                    code_iq = obj.GetP2Code(code_number);

                case obj.PULSE_TYPE_P3_CODE
                    code_iq = obj.GetP3Code(code_number);

                case obj.PULSE_TYPE_P4_CODE
                    code_iq = obj.GetP4Code(code_number);
            end

            polyphase_pulse = zeros(1,final_length);
            num_of_chips    = length(code_iq);

            for current_chip = 1:num_of_chips
                start_chip = (current_chip - 1) * double(pulse_length) / num_of_chips;
                stop_chip = start_chip + pulse_length / num_of_chips;
                start_chip = round(start_chip) + 1;
                stop_chip = round(stop_chip) + 1;
                polyphase_pulse(start_chip:stop_chip) = code_iq(current_chip);
            end 
            a = 1;
        end

%**************************************************************************

        function code_iq = GetBarkerCode(obj, barker_code)
            switch barker_code
                case obj.PULSE_BARKER_02
                    code_iq = obj.PULSE_BARKER_02_SEQ;

                case obj.PULSE_BARKER_02_BIS
                    code_iq = obj.PULSE_BARKER_02_BIS_SEQ;

                case obj.PULSE_BARKER_03
                    code_iq = obj.PULSE_BARKER_03_SEQ;

                case obj.PULSE_BARKER_04
                    code_iq = obj.PULSE_BARKER_04_SEQ;

                case obj.PULSE_BARKER_04_BIS
                    code_iq = obj.PULSE_BARKER_04_BIS_SEQ;

                case obj.PULSE_BARKER_05
                    code_iq = obj.PULSE_BARKER_05_SEQ;

                case obj.PULSE_BARKER_07
                    code_iq = obj.PULSE_BARKER_07_SEQ;

                case obj.PULSE_BARKER_11
                    code_iq = obj.PULSE_BARKER_11_SEQ;

                case obj.PULSE_BARKER_13
                    code_iq = obj.PULSE_BARKER_13_SEQ;

                otherwise
                    code_iq = obj.PULSE_BARKER_13_SEQ;
            end        
        end

%**************************************************************************

        function code_iq = GetFrankCode(obj, frank_code)
            frank_code = floor(frank_code);

            code_iq = zeros(frank_code, frank_code);

            for current_row = 1:frank_code
                for current_column = 1:frank_code
                    code_iq(current_row, current_column) = (current_row - 1) * (current_column - 1);
                end
            end

            delta_angle = 2 * pi / frank_code;

            code_iq = delta_angle * code_iq;
            code_iq = reshape(code_iq', 1, frank_code * frank_code);
            code_iq = exp(1i * code_iq);                
        end

%**************************************************************************

        function code_iq = GetP1Code(obj, p1_code)
            p1_code = floor(p1_code);

            code_iq = zeros(p1_code, p1_code);

            for current_row = 1:p1_code
                for current_column = 1:p1_code
                    code_iq(current_row, current_column) =...
                        (p1_code + 1 - 2 * current_column) * ( p1_code * (current_column - 1) + (current_row - 1));
                end
            end

            delta_angle = -pi / p1_code;

            code_iq = delta_angle * code_iq;
            %code_iq = mod(code_iq, 2*pi);
            code_iq = reshape(code_iq', 1, p1_code * p1_code);
            code_iq = exp(1i * code_iq);             
        end

%**************************************************************************

        function code_iq = GetP2Code(obj, p2_code)
            p2_code = floor(p2_code);

            code_iq = zeros(p2_code, p2_code);

            for current_row = 1:p2_code
                for current_column = 1:p2_code
                    code_iq(current_row, current_column) =...
                        (p2_code + 1 - 2 * current_row) * (p2_code + 1 - 2 * current_column);
                end
            end

            delta_angle = pi / (2 * p2_code);

            code_iq = delta_angle * code_iq;
            %code_iq = mod(code_iq, 2*pi);
            code_iq = reshape(code_iq', 1, p2_code * p2_code);
            code_iq = exp(1i * code_iq);
        
        end

%**************************************************************************

        function code_iq = GetP3Code(obj, p3_code)
            p3_code = floor(p3_code);

            code_iq = zeros(1, p3_code);

            for current_column = 1:p3_code
                code_iq(current_column) = (current_column - 1)^2;
            end

            delta_angle = pi / p3_code;
            code_iq = delta_angle * code_iq;
            code_iq = exp(1i * code_iq);        
        end

%**************************************************************************

        function code_iq = GetP4Code(obj, p4_code)
            p4_code = floor(p4_code);

            code_iq = zeros(1, p4_code);

            for current_column = 1:p4_code
                code_iq(current_column) = (current_column - 1) * (current_column - 1 - p4_code);
            end

            delta_angle = pi / p4_code;
            code_iq = delta_angle * code_iq;
            code_iq = exp(1i * code_iq);        
        end

%**************************************************************************

        function [  myWfm,...
                    map_wfm,...
                    task_list] = GetPulseWfms(  obj,...
                                                awg_setup,...
                                                pulse_setup)

            % This function calculates a baseband pulse and creates an optimal
            % segmentation of the waveform and the corresponding task list to generate
            % the overall pulsed waveform. These requires one, two or three segments.
            % There may be a ON segment, an OFF segment, and a Transition segment.
        
            % Baseband waveform sample rate
            actual_sampling_rate    = awg_setup.sampling_rate / awg_setup.interpol;
            % Actual Granularity and Minimum Segment Length for complex wfms
            awg_granularity         = awg_setup.granularity / 2;
            min_segment_length      = awg_setup.min_segment / 2;
            % Duration of one complete cycle
            total_duration          = 1.0 / pulse_setup.pulse_rep_freq;
            
            % Wfm length in samples rounde to the actual granularity
            awg_wfm_length          = total_duration * actual_sampling_rate;
            while (awg_wfm_length / min_segment_length) > 1E6
                min_segment_length  = min_segment_length + awg_granularity;
            end
            awg_wfm_length          = awg_granularity * floor(awg_wfm_length / awg_granularity);
        
            % I/Q complex pulse
            % =================
            % Pulse length is samples

            pulse_setup.sampling_rate = actual_sampling_rate;

            switch pulse_setup.pulse_type               

                case obj.PULSE_TYPE_SQUARE
                    pulse_length            = round(pulse_setup.pulse_width * actual_sampling_rate);  
                    % Number of segments with minimum segment length
                    repeat_pulse_section    = floor(pulse_length / min_segment_length);
                    % Pulse segment is "all 1s"
                    pulse_section           = complex(ones(1, min_segment_length));

                case obj.PULSE_TYPE_TRAPEZOIDAL
                    pulse_section = obj.GetTrapezoidalPulse(    pulse_setup.pulse_width, ...
                                                                pulse_setup.edge_shape, ...
                                                                pulse_setup.rise_time,...
                                                                pulse_setup.sampling_rate, ...                                                    
                                                                min_segment_length, ...
                                                                awg_granularity, ...
                                                                pulse_setup.quality);
                    pulse_length            = length(pulse_section);
                    repeat_pulse_section    = 1;
                    pulse_section           = complex(pulse_section);

                case obj.PULSE_TYPE_GAUSSIAN
                    pulse_section = obj.GetGaussPulse(          pulse_setup.pulse_width,...
                                                                actual_sampling_rate,...
                                                                pulse_setup.quality,...
                                                                min_segment_length,...
                                                                awg_granularity);
                    
                    pulse_length            = length(pulse_section);
                    repeat_pulse_section    = 1;
                    pulse_section           = complex(pulse_section);
                    
                case obj.PULSE_TYPE_NMR_FID
                    pulse_section = obj.GetFidPulse(            pulse_setup.pulse_width, ...
                                                                actual_sampling_rate, ...
                                                                pulse_setup.quality, ...
                                                                awg_granularity);
                    
                    pulse_length            = length(pulse_section);
                    repeat_pulse_section    = 1;
                    pulse_section           = complex(pulse_section);

                case obj.PULSE_TYPE_CHIRP_UP
                    pulse_section = obj.GetIqChirp(             pulse_setup.pulse_width, ...
                                                                pulse_setup.bandwidth, ...
                                                                actual_sampling_rate, ...
                                                                awg_granularity);
                    pulse_length            = length(pulse_section);
                    repeat_pulse_section    = 1;
                  
                case obj.PULSE_TYPE_CHIRP_DOWN
                    pulse_section = obj.GetIqChirp(             pulse_setup.pulse_width, ...
                                                                pulse_setup.bandwidth, ...
                                                                actual_sampling_rate, ...
                                                                awg_granularity);
                    pulse_section           = complex(pulse_section);
                    pulse_section           = conj(pulse_section);
                    pulse_length            = length(pulse_section);
                    repeat_pulse_section    = 1;

                case {  obj.PULSE_TYPE_BARKER_CODE,...
                        obj.PULSE_TYPE_FRANK_CODE,...
                        obj.PULSE_TYPE_P1_CODE,...
                        obj.PULSE_TYPE_P2_CODE,...
                        obj.PULSE_TYPE_P3_CODE,...
                        obj.PULSE_TYPE_P4_CODE}
                    pulse_section = obj.GetPolyPhasePulse(  pulse_setup.pulse_type,...
                                                            pulse_setup.polyphase_code,...
                                                            pulse_setup.sampling_rate, ...
                                                            pulse_setup.pulse_width, ...
                                                            pulse_setup.granul);
                    pulse_section           = complex(pulse_section);
                    pulse_section           = conj(pulse_section);
                    pulse_length            = length(pulse_section);
                    repeat_pulse_section    = 1;
          

                case obj.PULSE_TYPE_FILE
                    pulse_section = obj.GetFilePulse(           pulse_setup.file_name,...
                                                                pulse_setup.file_fmt,...
                                                                pulse_setup.time_fmt,...
                                                                pulse_setup.complex_fmt,...
                                                                pulse_setup.in_wfm_fraction,...
                                                                pulse_setup.in_wfm_offset,...
                                                                pulse_setup.in_sample_rate,...
                                                                actual_sampling_rate,...                                                    
                                                                min_segment_length,...
                                                                awg_granularity);
                    pulse_length            = length(pulse_section);
                    repeat_pulse_section    = 1;

            end    

            if pulse_setup.pulse_type ~= obj.PULSE_TYPE_SQUARE

                pulse_section = obj.ShiftFreq(  pulse_section, ...
                                                pulse_setup.freq_offset, ...
                                                pulse_setup.initial_phase ,...
                                                actual_sampling_rate,...
                                                false);
            end
        
            % I/Q interval between pulses
            % ===========================   
            % Total length for the all zeros section in samples
            off_section_length  = awg_wfm_length - pulse_length;
            % Number of segments with minimum segment length
            repeat_off_section  = floor(off_section_length / min_segment_length);
            % Pulse segment is "all 1s"
            off_section         = complex(zeros(1, min_segment_length));
        
            % I/Q transition segment
            % ======================
            if pulse_setup.pulse_type == obj.PULSE_TYPE_SQUARE
                % Total length for the transition section in samples
                trans_section_length    = awg_wfm_length -...
                    min_segment_length * (repeat_pulse_section + repeat_off_section);
                % Number of ones in the transition section
                ones_in_trans_section   = pulse_length -...
                        repeat_pulse_section * min_segment_length;
            else
                % Total length for the transition section in samples
                trans_section_length    = awg_wfm_length -...
                    min_segment_length * repeat_off_section - pulse_length;
                % Number of ones in the transition section
                ones_in_trans_section   = 0;
            end
            
            trans_section   = double.empty;
            % Transition segment calculation
            if trans_section_length ~= 0 
                trans_section = complex(zeros(1, trans_section_length));
                if ones_in_trans_section ~= 0
                    trans_section(1:ones_in_trans_section) = complex(1.0);
                end
                % Transition length must be corrected in case its length is shorter
                % than the minimum segment length by adding either a pulse or an
                % off segment so the number of reps must be edited
                if trans_section_length < min_segment_length 
                    if repeat_off_section > 0
                        trans_section           = [trans_section, off_section];
                        repeat_off_section      = repeat_off_section - 1;
                        trans_section_length    = trans_section_length + min_segment_length;
                    elseif repeat_pulse_section > 0
                        trans_section           = [pulse_section, trans_section];
                        repeat_pulse_section    = repeat_pulse_section - 1;
                    end
                end
            end
            % Meaning of fields in task array
            %   1               pointer_to_segment
            %   2               task_type: 0: Single, 1: StartSeq, 2: InSeq, 3: EndSeq
            %   3               num_of_loops_task
            %   4               num_of_loops_seq
            %   5               next_task
            %   6               dtr_trig_flag: 0: dtr trigger off, 1: dtr trigger on
            %   7               enable_event
            %   8               abort event
        
            % The number of waveforms may be one, two, or three
            % The number of tasks may be one, two, three, o four
            num_of_wfms     = 0;
            myWfm           = complex(double.empty);
            map_wfm         = uint32.empty;
            num_of_tasks    = 0;
        
            if repeat_pulse_section > 0
                num_of_wfms = num_of_wfms + 1;        
                myWfm       = [myWfm, pulse_section];                
                map_wfm     = [map_wfm, length(pulse_section)];
             
                % If there must be more than one repetition of the pulse segment,
                % there must be an additional task so the DTR trigger happens only
                % once in a waveform cycle.
                if repeat_pulse_section == 1
                    num_of_tasks = num_of_tasks + 1;
                else
                    num_of_tasks = num_of_tasks + 2;
                end
            end
            if length(trans_section) >= 1
                num_of_wfms     = num_of_wfms + 1;
                myWfm           = [myWfm, trans_section];
                map_wfm         = [map_wfm, trans_section_length];
                num_of_tasks    = num_of_tasks + 1;
            end
            if repeat_off_section > 0
                num_of_wfms     = num_of_wfms + 1;
                myWfm           = [myWfm, off_section];
                map_wfm         = [map_wfm, min_segment_length];
                num_of_tasks    = num_of_tasks + 1;
            end

            if pulse_setup.trg_src == obj.TASK_EVENT_TRG1 ||...
                    pulse_setup.trg_src == obj.TASK_EVENT_TRG2
                num_of_tasks = num_of_tasks + 1;
            end
            % Task list two dimensional array is created
            task_list       = uint32(zeros(num_of_tasks, obj.TASK_MATRIX_WIDTH)); 
            % And then populated for proper sequencing, pulse timing, PRI, and
            % continuous geneation
            task_pointer    = 1;
            segment_pointer = 1;

            if pulse_setup.trg_src == obj.TASK_EVENT_TRG1 ||...
                    pulse_setup.trg_src == obj.TASK_EVENT_TRG2
                % The off segment may be repeated zero or more times
                task_list(task_pointer, obj.TASK_SEGMENT_PTR)   = length(map_wfm);
                task_list(task_pointer, obj.TASK_TYPE)          = 0;
                task_list(task_pointer, obj.TASK_LOOPS)         = 1;
                task_list(task_pointer, obj.TASK_NEXT)          = task_pointer + 1;
                task_list(task_pointer, obj.TASK_DTR_FLAG)      = 0; 
                task_list(task_pointer, obj.TASK_ENABLE_EVENT)  = pulse_setup.trg_src;
                task_list(task_pointer, obj.TASK_ABORT_EVENT)   = obj.TASK_EVENT_NONE;

                task_pointer    = task_pointer + 1;
            end            

            if repeat_pulse_section > 0
                % Pulse segment is always generated once in the first task
                task_list(task_pointer, obj.TASK_SEGMENT_PTR)   = segment_pointer;
                task_list(task_pointer, obj.TASK_TYPE)          = 0;
                task_list(task_pointer, obj.TASK_LOOPS)         = 1;            
                task_list(task_pointer, obj.TASK_NEXT)          = task_pointer + 1;
                task_list(task_pointer, obj.TASK_DTR_FLAG)      = 1; 
                task_list(task_pointer, obj.TASK_ENABLE_EVENT)  = obj.TASK_EVENT_NONE;
                task_list(task_pointer, obj.TASK_ABORT_EVENT)   = obj.TASK_EVENT_NONE;
                task_pointer = task_pointer + 1;
                % If number of repetitions is larger than one, the second task must
                % be added with the number of repetitions - 1 as task #1 takes care
                % of the first repetition
                if repeat_pulse_section > 1
                    task_list(task_pointer, obj.TASK_SEGMENT_PTR)   = segment_pointer;
                    task_list(task_pointer, obj.TASK_TYPE)          = 0;
                    task_list(task_pointer, obj.TASK_LOOPS)         = repeat_pulse_section - 1;
                    task_list(task_pointer, obj.TASK_NEXT)          = task_pointer + 1;
                    task_list(task_pointer, obj.TASK_DTR_FLAG )     = 0;
                    task_list(task_pointer, obj.TASK_ENABLE_EVENT)  = obj.TASK_EVENT_NONE;
                    task_list(task_pointer, obj.TASK_ABORT_EVENT)   = obj.TASK_EVENT_NONE;
                    task_pointer = task_pointer + 1;
                end
                segment_pointer = segment_pointer + 1;
            end           
        
            if length(trans_section) >= 1
                task_list(task_pointer, obj.TASK_SEGMENT_PTR)   = segment_pointer;
                task_list(task_pointer, obj.TASK_TYPE)          = 0;
                task_list(task_pointer, obj.TASK_LOOPS)         = 1;
                task_list(task_pointer, obj.TASK_NEXT)          = task_pointer + 1;
                % Transition segments may be repeated zero or one time. When there
                % is no pulse segment, the transition segment will be generated
                % first and it has to generate the DTR trigger
                if repeat_pulse_section == 0
                    task_list(task_pointer, obj.TASK_DTR_FLAG)  = 1;
                else
                    task_list(task_pointer, obj.TASK_DTR_FLAG)  = 0;
                end
                
                task_list(task_pointer, obj.TASK_ENABLE_EVENT)  = obj.TASK_EVENT_NONE;
                task_list(task_pointer, obj.TASK_ABORT_EVENT)   = obj.TASK_EVENT_NONE;
        
                task_pointer    = task_pointer + 1;
                segment_pointer = segment_pointer + 1;
            end

            % TASK_SEGMENT_PTR        = 1;
            % TASK_TYPE               = 2;
            % TASK_LOOPS              = 3;
            % TASK_LOOPS_SEQ          = 4;
            % TASK_NEXT               = 5;
            % TASK_DTR_FLAG           = 6;
            % TASK_ENABLE_EVENT       = 7;
            % TASK_ABORT_EVENT        = 8;
        
            if repeat_off_section > 0
                % The off segment may be repeated zero or more times
                task_list(task_pointer, obj.TASK_SEGMENT_PTR)   = segment_pointer;
                task_list(task_pointer, obj.TASK_TYPE)          = 0;
                task_list(task_pointer, obj.TASK_LOOPS)         = repeat_off_section;
                task_list(task_pointer, obj.TASK_NEXT)          = 1;
                task_list(task_pointer, obj.TASK_DTR_FLAG)      = 0; 
                task_list(task_pointer, obj.TASK_ENABLE_EVENT)  = obj.TASK_EVENT_NONE;
                task_list(task_pointer, obj.TASK_ABORT_EVENT)   = obj.TASK_EVENT_NONE;
            end
            % The last task always point yo task # 1
            task_list(task_pointer, obj.TASK_NEXT) = 1;
        
        end

%*************************************************************************%
%                            NMR FUNCTIONS                                %
%*************************************************************************%

        function [  time_corrected_signal,...
                    shift_factor] = RmnCoarseDelayCorrection(   obj,...
                                                                test_signal)
            % Delay correction
            stop_sample     = length(test_signal);
            start_sample    = stop_sample - round(length(test_signal) * 10/100);          
            threshold       = max(abs(real(test_signal))) / 4;            
            shift_factor    = 0;
            
            while abs(test_signal(shift_factor + 1)) < threshold && shift_factor <= stop_sample
                shift_factor = shift_factor + 1;
            end
        
            time_corrected_signal = circshift(test_signal,-shift_factor);
        end

%**************************************************************************

        function [  phase_corrected_data,...
                    time_correction,...
                    final_phase_correction] = RmnFineCorrection(    obj,...
                                                                    spectrum_data,...
                                                                    target_phase_resolution)

            xData = 0:(length(spectrum_data) -1);
            xData = xData - length(spectrum_data) / 2;
            xData = xData / length(spectrum_data);
            xData = 2.0 * pi * xData;

            abs_min_ratio           = 0.0;
            time_correction         = 0.0;
            final_phase_correction  = 0.0;
            init_flag               = true;
            phase_corrected_data    = spectrum_data;
            % imag_avg                = double.empty;
            % ratio_vs_offset         = double.empty;

            for sample_offset = -2:0.05:2
                test_spectrum_data = spectrum_data .* exp(-1i * sample_offset * xData);
                [   test_spectrum_data,...
                    phase_correction,...
                    min_ratio]  = obj.RmnPhaseCorrection(   test_spectrum_data,...
                                                            target_phase_resolution);
                % ratio_vs_offset = [ratio_vs_offset, min_ratio];
                % imag_avg = [imag_avg, mean(imag(test_spectrum_data))];
                if init_flag || min_ratio < abs_min_ratio
                    init_flag               = false;
                    abs_min_ratio           = min_ratio;
                    phase_corrected_data    = test_spectrum_data;
                    time_correction         = sample_offset;
                    final_phase_correction  = phase_correction;
                end
                plot(real(test_spectrum_data));
                drawnow;
                pause(1);
            end
            %a = 1;
        end

%**************************************************************************

        function [  phase_corrected_data,...
                    final_phase_correction,...
                    min_ratio]  = RmnPhaseCorrection(   obj,...
                                                        spectrum_data,...
                                                        target_phase_resolution)
        
            if ~exist('target_phase_resolution','var')
             % third parameter does not exist, so default it to something
              target_phase_resolution = 0.1;
            end
        
            % Phase Correction
            final_phase_correction  = 0.0;
            init_flag               = true;    
            min_ratio               = 1.0;        
            phase_resolution        = 1.0;
            start_phase             = -180.0;
            stop_phase              = 180.0;
        
            while phase_resolution >= target_phase_resolution
            
                for phase_correction = start_phase:phase_resolution:stop_phase   
                    
                    pSpec = exp(1i*phase_correction / 180) * spectrum_data;    
                    pSpec = real(pSpec);
                
                    num_sample_pos = sum(pSpec(pSpec > 0.0)); %.^2);
                    num_sample_neg = -sum(pSpec(pSpec < 0.0));%.^2);
                
                    if num_sample_pos > num_sample_neg
                        current_ratio = num_sample_neg / num_sample_pos;
                    else
                        current_ratio = num_sample_pos / num_sample_neg;
                    end
                
                    if init_flag || current_ratio < min_ratio
                        init_flag               = false;
                        min_ratio               = current_ratio;
                        final_phase_correction  = phase_correction;
                    end   
                end
        
                init_flag   = true;
                start_phase = final_phase_correction - phase_resolution; 
                stop_phase  = final_phase_correction + phase_resolution;
        
                phase_resolution = phase_resolution / 10.0;
            end
          
            phase_corrected_data = exp(1i*final_phase_correction / 180) * spectrum_data;
        end


%**************************************************************************        
        
        function [  rmn_spec,...
                    delay_corr,...
                    phase_corr] = RmnGetSpectrum(   obj,...
                                                    test_data,...
                                                    sample_rate,...
                                                    target_phase_resolution)
            
            if ~exist('target_phase_resolution','var')
             % third parameter does not exist, so default it to something
              target_phase_resolution = 0.1;
            end
        
            % Delay correction
            [   test_data,...
                shift_factor]   = obj.RmnCoarseDelayCorrection(test_data);
            delay_corr          = shift_factor / sample_rate; 
        
            spectrum_data       = fft(test_data);
            spectrum_data       = fftshift(spectrum_data);
            spectrum_data       = spectrum_data / max(abs(spectrum_data));

            [   rmn_spec,...
                time_correction,...
                phase_corr] = RmnFineCorrection(    obj,...
                                                    spectrum_data,...
                                                    target_phase_resolution);
           
            delay_corr = delay_corr + time_correction / sample_rate;                  
        end

%*************************************************************************%
%                         INTERPOLATION EMULATOR                          %
%*************************************************************************%

        function [filters, filter_size] = GetProteusFilters(obj)
        
            filters     = zeros(8, 59);
            filter_size = zeros(1, 8);
        
            filters(obj.AWG_INT_FILTER_0,:) = [6,0,-19,0,47,0,-100,0,192,0,...
                -342,0,572,0,-914,0,1409,0,-2119,0,3152,0,-4729,0,7420,0,...
                -13334,0,41527,65536,41527,0,-13334,0,7420,0,-4729,0,3152,...
                0,-2119,0,1409,0,-914,0,572,0,-342,0,192,0,-100,0,47,0,-19,0,6];
            filter_size(obj.AWG_INT_FILTER_0)           = 59;
            filters(obj.AWG_INT_FILTER_1,1:23) = [-12,0,84,0,-336,0,1006,0,...
                -2691,0,10141,16384,10141,0,-2691,0,1006,0,-336,0,84,0,-12];
            filter_size(obj.AWG_INT_FILTER_1)           = 23;
            filters(obj.AWG_INT_FILTER_0_5X,1:39) =[-6,-22,-51,-89,-117,...
                -106,-18,171,449,745,930,841,338,-618,-1892,-3147,-3872,...
                -3500,-1564,2121,7336,13430,19426,24231,26904,-618,338,841,...
                930,745,449,171,-18,-106,-117,-89,-51,-22,-6];
            filter_size(obj.AWG_INT_FILTER_0_5X)        = 50;
            filters(obj.AWG_INT_FILTER_2,1:11) = [29,0,-214,0,1209,2048,...
                1209,0,-214,0,29];
            filter_size(obj.AWG_INT_FILTER_2)           = 11;
            filters(obj.AWG_INT_FILTER_0_3X,1:30) = [-14,-61,-125,-95,181,...
                681,972,347,-1475,-3519,-3528,707,9337,19445,26299,26299,...
                19445,9337,707,-3528,-3519,-1475,347,972,681,181,-95,-125,-61,-14];
            filter_size(obj.AWG_INT_FILTER_0_3X)        = 30;
            filters(obj.AWG_INT_FILTER_3,1:11) = [3,0,-25,0,150,256,150,0,-25,0,3];
            filter_size(obj.AWG_INT_FILTER_3)           = 11;
            filters(obj.AWG_INT_FILTER_1_3X,1:20) = [25,88,22,-576,-1764,...
                -2263,491,8139,18625,26365,26365,18625,8139,491,-2263,-1764,...
                -576,22,88,25];
            filter_size(obj.AWG_INT_FILTER_1_3X)        = 20;
            filters(obj.AWG_INT_FILTER_INVSINC,1:9) = [1,-4,13,-50,592,-50,...
                13,-4,1];
            filter_size(obj.AWG_INT_FILTER_INVSINC)     = 9;
            filters(obj.AWG_INT_FILTER_NOFILTER,1)      = 1;
            filter_size(obj.AWG_INT_FILTER_NOFILTER)    = 1;
        end

%**************************************************************************
        
function filter_sequence = GetIntFilterSeq(obj, interpol_factor, flag_invsinc)
            filter_sequence = int16.empty;
        
            switch interpol_factor
                case obj.AWG_INTERPOL_X1
                    filter_sequence = [ obj.AWG_INT_FILTER_NOFILTER];
                case obj.AWG_INTERPOL_X2
                    filter_sequence = [ obj.AWG_INT_FILTER_0];
                case obj.AWG_INTERPOL_X4
                    filter_sequence = [ obj.AWG_INT_FILTER_0,...
                                        obj.AWG_INT_FILTER_1];
                case obj.AWG_INTERPOL_X6
                    filter_sequence = [ obj.AWG_INT_FILTER_0,...
                                        obj.AWG_INT_FILTER_0_3X];            
                case obj.AWG_INTERPOL_X8
                    filter_sequence = [ obj.AWG_INT_FILTER_0,...
                                        obj.AWG_INT_FILTER_1,...
                                        obj.AWG_INT_FILTER_2];
                case obj.AWG_INTERPOL_X10
                    filter_sequence = [ obj.AWG_INT_FILTER_0,...
                                        obj.AWG_INT_FILTER_0_5X];
                case obj.AWG_INTERPOL_X12
                    filter_sequence = [ obj.AWG_INT_FILTER_0,...
                                        obj.AWG_INT_FILTER_1,...
                                        obj.AWG_INT_FILTER_0_3X];
                case obj.AWG_INTERPOL_X16
                    filter_sequence = [ obj.AWG_INT_FILTER_0,...
                                        obj.AWG_INT_FILTER_1,...
                                        obj.AWG_INT_FILTER_2,...
                                        obj.AWG_INT_FILTER_3];
                case obj.AWG_INTERPOL_X18
                    filter_sequence = [ obj.AWG_INT_FILTER_0,...
                                        obj.AWG_INT_FILTER_0_3X,...
                                        obj.AWG_INT_FILTER_1_3X];
                case obj.AWG_INTERPOL_X20
                    filter_sequence = [ obj.AWG_INT_FILTER_0,...
                                        obj.AWG_INT_FILTER_1,...
                                        obj.AWG_INT_FILTER_0_5X];
                case obj.AWG_INTERPOL_X24
                    filter_sequence = [ obj.AWG_INT_FILTER_0,...
                                        obj.AWG_INT_FILTER_1,...
                                        obj.AWG_INT_FILTER_2,...
                                        obj.AWG_INT_FILTER_0_3X];
            end

            if flag_invsinc
                filter_sequence = [filter_sequence, obj.AWG_INT_FILTER_INVSINC];
            end
        end

%**************************************************************************
        
        function filter_interpolation = GetIntFilterIntFactor(obj, filter_index)
            
            filter_interpolation = 1;
        
            switch filter_index
                case obj.AWG_INT_FILTER_0
                    filter_interpolation = 2;
        
                case obj.AWG_INT_FILTER_1
                    filter_interpolation = 2;
        
                case obj.AWG_INT_FILTER_2
                    filter_interpolation = 2;
        
                case obj.AWG_INT_FILTER_3
                    filter_interpolation = 2;
        
                case obj.AWG_INT_FILTER_0_5X
                    filter_interpolation = 5;
        
                case obj.AWG_INT_FILTER_0_3X
                    filter_interpolation = 3;
        
                case obj.AWG_INT_FILTER_1_3X
                    filter_interpolation = 3;
        
                case obj.AWG_INT_FILTER_INVSINC
                    filter_interpolation = 1;

                 case obj.AWG_INT_FILTER_NOFILTER
                    filter_interpolation = 1;
            end
        end

%**************************************************************************
        
        function out_vector = ZeroPadding(obj, in_vector, exp_factor)
            out_vector = zeros(1, exp_factor * length(in_vector));
            out_vector(1:exp_factor:end) = in_vector;
        end

%**************************************************************************
        
        function interpol_filter = GetInterpolFilter(obj, interpol_factor, flag_invsinc)
        
            [filters, filter_size]  = obj.GetProteusFilters();
            filter_sequence         = obj.GetIntFilterSeq(interpol_factor, flag_invsinc);
        
            num_of_steps            = length(filter_sequence);
        
            interpol_filter         = filters(filter_sequence(1),1:filter_size(filter_sequence(1)));
        
            for step = 2:num_of_steps
                interpol_filter     = obj.ZeroPadding(interpol_filter, GetIntFilterIntFactor(obj, filter_sequence(step)));
                current_filter      = filters(filter_sequence(step), 1:filter_size(filter_sequence(step)));
                interpol_filter     = conv(current_filter,interpol_filter);
            end
        
            interpol_filter         = interpol_filter / sum(interpol_filter);
            interpol_filter         = interpol_filter * interpol_factor;
        end

%**************************************************************************        

        function interpol_wfm = ProteusInterpolation(obj, interpol_factor, wfm, flag_invsinc)

            % Get Interpolation Filters and zero-padding
            wfm             = obj.ZeroPadding(wfm, interpol_factor);
            interpol_filter = obj.GetInterpolFilter(interpol_factor, flag_invsinc);            
            interpol_wfm    = cconv(wfm, interpol_filter, length(wfm));
        end

%**************************************************************************

        function granularity = GetGranularity(obj, model, options, dac_mode)
            % It gets the granularity in samples for the target Proteus
            % unit depending on the model, options, and DAC operation mode
            % model = string with model name (as returned by the
            % IdentifyModel function).
            % options = sstring vector with the options for the target
            % Proteus (as returned by the GetProteusOptions function).
            % dacMode = Current operational mode for the DAC in the target
            % Proteus, as returned by the GetDacResolution function.

            flagLowG    = false;        
            granularity = 32;
        
            if contains(model, 'P258')
                granularity     = 32;    
                if flagLowG
                    granularity = 16;
                end
            elseif contains(model, 'P128')
                granularity     = 32;    
                if flagLowG
                    granularity = 16;
                end
            elseif contains(model, 'P948')
                if dac_mode == 16
                    granularity = 32;    
                    if flagLowG
                        granularity = 16;
                    end
                else
                    granularity = 64;    
                    if flagLowG
                        granularity = 32;
                    end
                end
            elseif contains(model, 'P908')
                granularity     = 64;    
                if flagLowG
                    granularity = 32;
                end
            end
        end

%**************************************************************************

        function num_of_channels = GetNumOfChannels(obj, model)
            % Gets the number of addressable channels for a given Proteus
            % model.
            % model = string with model name (as returned by the
            % IdentifyModel function).
            % It retruns:
            % num_of_channels = number of AWG channels available for the
            % Proteus device.

            num_of_channels     = 4;
            
            if contains(model, 'P9082') ||...
                    contains(model, 'P9482') ||...
                    contains(model, 'P2582')
                num_of_channels = 2;            
            elseif contains(model, 'P9086') ||...
                    contains(model, 'P9486') ||...
                    contains(model, 'P1286') ||...
                    contains(model, 'P2586')
                num_of_channels = 6;            
            elseif contains(model, 'P9488') ||...
                    contains(model, 'P1288') ||...
                    contains(model, 'P2588')
                num_of_channels = 8;             
            elseif  contains(model, 'P94812') ||...
                    contains(model, 'P12812') ||...
                    contains(model, 'P25812')
                num_of_channels = 12;            
            end
        end

%**************************************************************************

        function [chanList, segmList] = GetChannels(obj, model, sampleRate)

            if  contains(model, 'P9484') ||...
                contains(model, 'P2584') ||...
                contains(model, 'P1284')
                if sampleRate <= 2.5E9
                    chanList = [1 2 3 4];
                    segmList = [1 2 1 2];
                else
                    chanList = [1 3];
                    segmList = [1 1];
                end
        
            elseif  contains(model, 'P9482') ||...
                    contains(model, 'P2582') ||...
                    contains(model, 'P1282')
                if sampleRate <= 2.5E9
                    chanList = [1 2];
                    segmList = [1 2];
                else
                    chanList = [1];
                    segmList = [1];
                end
        
            elseif  contains(model, 'P9488') ||...
                    contains(model, 'P2588') ||...
                    contains(model, 'P1288')
                if sampleRate <= 2.5E9
                    chanList = [1 2 3 4 5 6 7 8];
                    segmList = [1 2 1 2 1 2 1 2];
                else
                    chanList = [1 3 5 7];
                    segmList = [1 1 1 1];
                end
        
            elseif  contains(model, 'P94812') ||...
                    contains(model, 'P25812') ||...
                    contains(model, 'P12812')
                if sampleRate <= 2.5E9
                    chanList = [1 2 3 4 5 6 7 8 9 10 11 12];
                    segmList = [1 2 1 2 1 2 1 2 1 2 1 2];
                else
                    chanList = [1 3 5 7 9 11];
                    segmList = [1 1 1 1 1 1];
                end
        
            elseif contains(model, 'P9082')        
                chanList = [1 2];
                segmList = [1 1];
        
            elseif contains(model, 'P9084')        
                chanList = [1 2 3 4];
                segmList = [1 1 1 1];
        
            elseif contains(model, 'P9086')        
                chanList = [1 2 3 4 5 6];
                segmList = [1 1 1 1 1 1];
            end
        end

%**************************************************************************

        function quant_wfm = Quantization (obj, wfm, dac_res, min_lvl)
            % Normalized (-1.0/+1.0) waveform quantization for any DAC
            % resolution.
            % wfm = input waveform to quantize
            % dac_res = DAC resolution in bits (integer)
            % min_lvl = minimum usable DAC level. 0 meand all levels.
            % Select 1 for symmetrical, no DC, quantized waveforms.
            % It returns:
            % quant_wfm = quantized waveform as unsigened 16-bit integers
 
            max_lvl     = 2 ^ dac_res - 1;  
            num_of_lvls = max_lvl - min_lvl + 1;
            
            quant_wfm   = round((num_of_lvls .* (wfm + 1) - 1) ./ 2);
            quant_wfm   = quant_wfm + min_lvl;
            
            quant_wfm(quant_wfm > max_lvl) = max_lvl;
            quant_wfm(quant_wfm < min_lvl) = min_lvl;
            quant_wfm   = uint16(quant_wfm);
        
        end

%**************************************************************************

        function quant_wfm = Quantization2 (obj, wfm, min_lvl, max_lvl)
            % Normalized (-1.0/+1.0) waveform quantization for any integer
            % number of levels.
            % wfm = input waveform to quantize            
            % min_lvl = minimum usable DAC level.
            % max_lvl = minimum usable DAC level.
            % It returns:
            % quant_wfm = quantized waveform as unsigened 16-bit integers 
             
            num_of_lvls = max_lvl - min_lvl + 1;
            
            quant_wfm   = round((num_of_lvls .* (wfm + 1) - 1) ./ 2);
            quant_wfm   = quant_wfm + min_lvl;
            
            quant_wfm(quant_wfm > max_lvl) = max_lvl;
            quant_wfm(quant_wfm < min_lvl) = min_lvl;
            quant_wfm   = uint16(quant_wfm);        
        end       

%**************************************************************************

        function out_wfm = Normalize(obj, wfm)
            % Normalization to peak modulus. It works with waveform
            % data. It normalizes waveform data to the -1.0 to +1.0
            % range while keeping the realitive DC level.
            % is appropriated for IQ baseband generation.
            % wfm: Raw waveform to normalize
            
            % It returns:
            % out_wfm: Normalized waveform           
            
            max_peak    = max(abs(wfm));   
            out_wfm     = wfm / max_peak;
        end

%**************************************************************************

        function out_wfm = NormalizeFull(obj, wfm)
            % Normalization to peak modulus. It works with waveform
            % data. It normalizes waveform data to the -1.0 to +1.0
            % range without keeping the relative DC level.
            % is appropriated for maximum amplitude
            % wfm: Raw waveform to normalize
            
            % It returns:
            % out_wfm: Normalized waveform           
            
            max_peak = max(wfm); 
            min_peak = min(wfm);
            if max_peak > min_peak
                out_wfm = 2 / (max_peak - min_peak) * wfm;
                out_wfm = out_wfm - (max_peak + min_peak) / (max_peak - min_peak); 
            else
                out_wfm = wfm;
            end
        end

%**************************************************************************

        function [out_i_wfm,  out_q_wfm] = NormalIq(obj, i_wfm, q_wfm)
            % Normalization to peak modulus. It works with real I and Q
            % data. It normalizes together I and Q to teh -1.0 to +1.0
            % range while keeping the relative amplitude.
            % is appropriated for IQ baseband generation.
            % i_wfm: I raw waveform to normalize
            % q_wfm: Q raw waveform to normalize
            % It returns:
            % out_i_wfm: I Normalized waveform
            % out_q_wfm: Q Normalized waveform
            
            max_peak    = max([max(abs(i_wfm)), max(abs(q_wfm))]);   
            out_i_wfm   = i_wfm / max_peak;
            out_q_wfm   = q_wfm / max_peak;
        end

%**************************************************************************

%**************************************************************************

function wfm_out = NormalIqComplex(obj, wfm_in)
            % Normalization to peak modulus. It works with real I and Q
            % data. It normalizes together I and Q to teh -1.0 to +1.0
            % range while keeping the relative amplitude.
            % is appropriated for IQ baseband generation.
            % i_wfm: I raw waveform to normalize
            % q_wfm: Q raw waveform to normalize
            % It returns:
            % out_i_wfm: I Normalized waveform
            % out_q_wfm: Q Normalized waveform
            
            max_peak    = max([max(abs(real(wfm_in))), max(abs(imag(wfm_in)))]); 
            if max_peak > 0.0
                wfm_out   = wfm_in / max_peak;
            else
                wfm_out   = wfm_i;
            end            
        end

%**************************************************************************

        function [out_i_wfm,  out_q_wfm] = NormalIqHalf(obj, wfm)
            % Normalization to peak modulus. It works with complex
            % data. It normalizes to the unity circle (radius = 1.0) and it
            % is appropriated for the IQM HALF.
            % wfm: raw waveform to normalize           
            % It returns:
            % out_i_wfm: I Normalized waveform
            % out_q_wfm: Q Normalized waveform
            
            max_peak    = max(abs(wfm));   
            out_i_wfm   = real(wfm) / max_peak;
            out_q_wfm   = imag(wfm) / max_peak;
        end

%**************************************************************************

function [out_i_wfm,  out_q_wfm] = NormalIqHalfPlus(obj, wfm, interpol_factor, flag_invsinc)
            % Normalization to peak modulus. It works with complex
            % data. It normalizes to the unity circle (radius = 1.0) and it
            % is appropriated for the IQM HALF.
            % wfm: raw waveform to normalize           
            % It returns:
            % out_i_wfm: I Normalized waveform
            % out_q_wfm: Q Normalized waveform
            
            wfm = obj.ProteusInterpolation(interpol_factor, wfm, flag_invsinc);

            max_peak    = max(abs(wfm));   
            out_i_wfm   = real(wfm) / max_peak;
            out_q_wfm   = imag(wfm) / max_peak;
        end        

%**************************************************************************

        function out_wfm = NormalIqOne(obj, wfm)
            % Normalization to peak modulus. It works with real and complex
            % data. It normalizes to the unity circle (radius = 1.0) and it
            % is appropriated for the IQM ONE or HALF(when waveform is
            % complex)
            % wfm: raw waveform to normalize
            % It returns:
            % out_wfm: Normalized waveform

            max_peak    = max(abs(wfm));
            out_wfm     = wfm / max_peak;  
        end

%**************************************************************************

function out_wfm = NormalIqOnePlus(obj, wfm, interpol_factor, flag_invsinc)
            % Normalization to peak modulus. It works with real and complex
            % data. It normalizes to the unity circle (radius = 1.0) and it
            % is appropriated for the IQM ONE or HALF(when waveform is
            % complex)
            % wfm: raw waveform to normalize
            % It returns:
            % out_wfm: Normalized waveform

            wfm         = obj.ProteusInterpolation(interpol_factor, wfm, flag_invsinc);

            max_peak    = max(abs(wfm));
            out_wfm     = wfm / max_peak;  
        end

%**************************************************************************

        function [out_wfm_1,  out_wfm_2] = NormalIqTwo(obj, wfm_1, wfm_2)
            % Normalization to peak modulus. It works with real and complex
            % data. It normalizes to the unity circle (radius = 1.0) and it
            % is appropriated for the IQM TWO.
            % wfm_1: raw waveform for DUC #1 to normalize
            % wfm_2: raw waveform for DUC #2 to normalize
            % It returns:
            % out_wfm_1: Normalized waveform for DUC #1
            % out_wfm_2: Normalized waveform for DUC #2

            max_peak    = max(abs(wfm_1) + abs(wfm_2));   
            out_wfm_1   = wfm_1 / max_peak;
            out_wfm_2   = wfm_2 / max_peak;
        end

%**************************************************************************

function [out_wfm_1,  out_wfm_2] = NormalIqTwoPlus(obj, wfm_1, wfm_2, interpol_factor, flag_invsinc)
            % Normalization to peak modulus. It works with real and complex
            % data. It normalizes to the unity circle (radius = 1.0) and it
            % is appropriated for the IQM TWO.
            % wfm_1: raw waveform for DUC #1 to normalize
            % wfm_2: raw waveform for DUC #2 to normalize
            % It returns:
            % out_wfm_1: Normalized waveform for DUC #1
            % out_wfm_2: Normalized waveform for DUC #2

            wfm_1       = obj.ProteusInterpolation(interpol_factor, wfm_1, flag_invsinc);
            wfm_2       = obj.ProteusInterpolation(interpol_factor, wfm_2, flag_invsinc);

            max_peak    = max(abs(wfm_1) + abs(wfm_2));   
            out_wfm_1   = wfm_1 / max_peak;
            out_wfm_2   = wfm_2 / max_peak;
        end        

%**************************************************************************

        function nco_freq = GetNcoFreq( obj,...
                                        carrier_freq, ...
                                        sampling_rate, ...
                                        remove_second_nyquist)
            % This function maps any frequency to its image in the first or
            % second Nyquist Zone.
            % carrier_freq = Target carrier frequency
            % sampling_rate = DAC/ADC Sampling Rate
            % remove_second_nyquist = Second Nyquist Zone excluded when it
            % is set to 'true'
            % It returns:
            % nco_freq: The frequency to be set in teh target NCO

            nco_freq = abs(carrier_freq);
            nco_freq = mod(nco_freq, sampling_rate);
        
            if remove_second_nyquist
                if nco_freq > sampling_rate / 2
                    nco_freq = sampling_rate - nco_freq;
                end
            end
        end

%**************************************************************************

        function mkr_data = FormatMkr2(obj, dac_mode, mkr_1, mkr_2)
            % This function formats marker data for modes using two markers
            % per channel. The output array can be downloaded to Proteus.
            % The size of the output is equal to the longest input array.
            % Undefined states are set to "0"
            % dac_mode: If != 16 it is handled as 8-bits.
            % mkr_1: Logical states for marker #1
            % mkr_2: Logical states for marker #2
            % It returns:
            % mkr_data: formated marker data. Size is half for 16-bit mode

            % % mkr_1 goes to bit 0 and mkr_2 goes to bit 1 in a 4-bit Nibble
            if length(mkr_1) >= length(mkr_2)
                mkr_data = mkr_1;
                mkr_data(1:length(mkr_2)) = mkr_data(1:length(mkr_2)) + 2 * mkr_2;
            else
                mkr_data = 2 * mkr_2;
                mkr_data(1:length(mkr_1)) = mkr_data(1:length(mkr_1)) + mkr_1;
            end            
           
            % For DAC Mode 8, just one Nibble per Byte is sent
            % For DAC Mode 16, two consecutive nibbles are multiplexed in one byte
            if dac_mode == 16
                mkr_data = mkr_data(1:2:end) + 16 * mkr_data(2:2:end);
            end
        end     

%**************************************************************************

        function mkr_data = FormatMkr4(obj, dac_mode, mkr_1, mkr_2, mkr_3, mkr_4)
            % This function formats marker data for modes using four markers
            % per channel. The output array can be downloaded to Proteus.
            % The size of the output is equal to the longest input array.
            % Undefined states are set to "0"
            % dac_mode: If != 16 it is handled as 8-bits.
            % mkr_1: Logical states for marker #1
            % mkr_2: Logical states for marker #2
            % mkr_3: Logical states for marker #1
            % mkr_4: Logical states for marker #2
            % It returns:
            % mkr_data: formated marker data. Size is half for 16-bit mode
            
            % Size for the final marker data
            mkr_size = max([length(mkr_1),length(mkr_2),length(mkr_2),length(mkr_2)]);
            %Creation of output data
            mkr_data = uint8(zeros(1, mkr_size));
            % Add the contribution of each marker
            % mkr_1 goes to bit 0 and mkr_2 goes to bit 1 in a 4-bit Nibble
            % mkr_3 goes to bit 2 and mkr_4 goes to bit 3 in a 4-bit Nibble
            mkr_data(1:length(mkr_1)) = mkr_1;
            mkr_data(1:length(mkr_2)) = 2 * mkr_2;
            mkr_data(1:length(mkr_3)) = 4 * mkr_3;
            mkr_data(1:length(mkr_4)) = 8 * mkr_4;
            % For DAC Mode 8, just one Nibble per Byte is sent
            % For DAC Mode 16, two consecutive nibbles are multiplexed in one byte
            if dac_mode == 16
                mkr_data = mkr_data(1:2:end) + 16 * mkr_data(2:2:end);
            end
        end

%**************************************************************************

        function resampling_filter = GetResamplingFilter(   obj,...
                                                            num_of_convolution_samples, ...
                                                            resolution_of_filter, ...
                                                            bw_fraction)
            % Creation of sinc lookup table
            % The num_of_convolution_samples paramters controls the quality of the
            % resampling filter in terms of roll-off and attenuation at the stop
            % band. The more, the better quality, the longer calculation time.
            % resolution_of_filter sets the number of values per sample time to be included in
            % the look-up table. The more, the better quality, the longer
            % calculation time.
            % bw_fraction reduces de BW of the filter to avoid aliasing problems caused
            % by the roll-off of the resampling filter.
            % A resampling filter object is created with the lookup table for it
            % (just one side as it is symmetrical) and all the associated
            % parameters.
            resampling_filter.num_of_samples    = num_of_convolution_samples;
            resampling_filter.resolution        = resolution_of_filter;
            resampling_filter.bw_fraction       = bw_fraction;
            sinc_length                         = floor(num_of_convolution_samples * resolution_of_filter / bw_fraction);
            resampling_filter.filter            = 0:(sinc_length);  
            resampling_filter.filter            = resampling_filter.filter / resolution_of_filter;
            resampling_filter.filter            = resampling_filter.filter * bw_fraction;
            % Basic filter shape is ideal low pass filter (sinc)
            resampling_filter.filter            = sinc(resampling_filter.filter);
            % Flattop window is applied to improve flatness and stop band rejection
            %windowed_filter = blackmanharris(2 * sinc_length);
            windowed_filter                     = hamming(2 * sinc_length);
            windowed_filter                     = windowed_filter(sinc_length:end);
            resampling_filter.filter            = resampling_filter.filter .* windowed_filter';
        end

 %*************************************************************************  

        function output_wfm = Resampling(   obj,...
                                            input_wfm, ...
                                            output_wfm_length, ...
                                            is_circular, ...                                       
                                            resampling_filter) 
            % This funtion resamples the input waveform (inWfm) to generate a new
            % waveform with a new length (outWl). New length can be longer (upsampling)
            % or shorter (downsampling) than the original one. The new waveform can be
            % selfconsistent for loop generation (isCirc == true) or not for singe shot
            % generation.
        
            input_wfm           = single(input_wfm);
            input_wfm_length    = length(input_wfm);
            % Sampling rate ratio (>1.0, upsampling)
            sampling_ratio      = double(output_wfm_length) / double(input_wfm_length);
            
            % The parameters of the resampling filter are part of the associated
            % object
            convolution_length          = resampling_filter.num_of_samples;
            filter_resolution           = resampling_filter.resolution;
            resampling_filter.filter    = single(resampling_filter.filter);
            resampling_filter_length    = length(resampling_filter.filter);
            bw_fraction                 = resampling_filter.bw_fraction;
            % For undersampling filter, the amplitude of the resampling filter must
            % be corrected by the relative BW
            if sampling_ratio < 1.0
                % The distance for samples in the input (measured in samples of the
                % output) must be corrected for undersampling as well in order to
                % preserve SFDR
                convolution_length          = floor(convolution_length / (sampling_ratio * bw_fraction));
                resampling_filter.filter    = single(resampling_filter.filter * (sampling_ratio * bw_fraction));
            else
                convolution_length          = floor(resampling_filter.num_of_samples / bw_fraction);
            end
            
            % Output waveform is initialized to "all zeros"
            output_wfm = single(zeros(1, output_wfm_length));  
            % Convolution loop for each output sample
            if sampling_ratio >= 1.0
                mult_factor1 = bw_fraction * filter_resolution;
            else
                mult_factor1 = bw_fraction * filter_resolution * sampling_ratio;
            end
        
            for i = 1:output_wfm_length
                % Index for the central sample to process in the input wfm
                central_sample      = (i - 1) / sampling_ratio;
                central_sample_int  = round(central_sample);
                % Contribution for all the participating samples form the input is
                % accumulated on the current output sample
                start_conv_sample   = central_sample_int - convolution_length;
                stop_conv_sample    = central_sample_int + convolution_length;
                        
                for j = start_conv_sample:stop_conv_sample
                    % Actual fractional distance to the input sample
                    % Distance is converted to a relative integer index to the
                    % resampling filter (lookup table) 
                    time_distance   = round(mult_factor1 * abs(central_sample - j));           
                    
                    input_wfm_index = j;
        
                    % If convolution is circular the initial samples are used at
                    % the end and the end samples are used at the beginning.            
                    if is_circular && (input_wfm_index >= input_wfm_length || input_wfm_index < 0)
                        input_wfm_index = mod(input_wfm_index, input_wfm_length);
                    end
        
                    input_wfm_index = input_wfm_index + 1;
        
                    % If the pointer to the resampling filter is within the limits
                    % of the lookup table, the contribution of the input sample is
                    % added to the current output sample
                    if time_distance < resampling_filter_length && ...
                            input_wfm_index >=1 && ...
                            input_wfm_index <= input_wfm_length && ...
                            input_wfm(input_wfm_index) ~= 0.0
        
                        output_wfm(i) = output_wfm(i) +...
                            input_wfm(input_wfm_index) * ...
                            resampling_filter.filter(time_distance + 1);
                    end
                end
            end     
        end

%**************************************************************************

        function [  dac_resolution,...
                    sampling_rate,...
                    interpol,...
                    output_wfm] = GetResampledWfm(  obj,...
                                                    awg_setup,...
                                                    sample_rate_bb_in,...
                                                    input_wfm)
            [   dac_resolution,...
                sampling_rate,...
                interpol,...
                wfm_length_out] = obj.GetOptInterParam( awg_setup,...
                                                        sample_rate_bb_in,...
                                                        length(input_wfm));

            output_wfm          = obj.ResamplingDirect( input_wfm, ...
                                                        wfm_length_out, ...
                                                        true);
        end


%**************************************************************************

        function output_wfm = ResamplingDirect( obj,...
                                                input_wfm, ...
                                                output_wfm_length, ...
                                                is_circular)

            resampling_filter   = obj.GetResamplingFilter(  obj.RESAMP_QUALITY, ...
                                                            obj.RESAMP_FILTER_RES, ...
                                                            obj.RESAMP_BW_FRACTION);
            output_wfm          = obj.Resampling(   input_wfm, ...
                                                    output_wfm_length, ...
                                                    is_circular,...
                                                    resampling_filter);
        end

 %**************************************************************************

        function [  dac_resolution,...
                    sampling_rate,...
                    interpol,...
                    wfm_length_out] = GetOptInterParam( obj,...
                                                        awg_setup,...
                                                        sample_rate_bb_in,...
                                                        wfm_length_in)

            dac_resolution    = obj.AWG_DAC_MODE_16;
            interpol          = obj.AWG_INTERPOL_X1;
            sampling_rate     = awg_setup.sampling_rate;
            
            % DAC Mode setup, sample rate, and interpolation setup
            if awg_setup.mode  == obj.AWG_MODE_DIRECT
                if sampling_rate > 2.5E9
                    dac_resolution= obj.AWG_DAC_MODE_8;
                elseif sampling_rate <= 2.5E9 && sampling_rate > 2.25E9
                    sampling_rate = sampling_rate * 2;
                    interpol      = obj.AWG_INTERPOL_X2; 
                elseif sampling_rate <= 2.25E9 && sampling_rate > 1.125E9
                    sampling_rate = sampling_rate * 4;
                    interpol      = obj.AWG_INTERPOL_X4;
                elseif sampling_rate <= 1.125E9
                    sampling_rate = sampling_rate * 8;
                    interpol      = obj.AWG_INTERPOL_X8;
                end

            elseif awg_setup.mode  == obj.AWG_MODE_DUC && awg_setup.iq_mode == obj.AWG_IQ_MODE_ONE
                if sampling_rate <= 1.125E9
                    sampling_rate = sampling_rate * 8;
                    interpol      = obj.AWG_INTERPOL_X8;                    
                elseif sampling_rate > 1.125E9 && sampling_rate <= 2.5E9
                    sampling_rate = sampling_rate * 4;
                    interpol      = obj.AWG_INTERPOL_X4; 
                elseif sampling_rate > 2.5E9 && sampling_rate <= 5E9
                    sampling_rate = sampling_rate * 2;
                    interpol      = obj.AWG_INTERPOL_X2;
                elseif sampling_rate > 5E9
                    interpol      = obj.AWG_INTERPOL_X8;
                end

            elseif awg_setup.mode  == obj.AWG_MODE_DUC && awg_setup.iq_mode == obj.AWG_IQ_MODE_HALF
                if sampling_rate <= 2.25E9
                    sampling_rate = sampling_rate * 4;
                    interpol      = obj.AWG_INTERPOL_X4;                    
                elseif sampling_rate > 2.25E9 && sampling_rate <= 4.5E9
                    sampling_rate = sampling_rate * 2;
                    interpol      = obj.AWG_INTERPOL_X2;                 
                elseif sampling_rate > 4.5E9
                    interpol      = obj.AWG_INTERPOL_X4;
                end

            elseif awg_setup.mode  == obj.AWG_MODE_DUC && awg_setup.iq_mode == obj.AWG_IQ_MODE_TWO
            
            
            end

            % Resampling must be carrier out for the DUC baseband sampling rate
            sampling_rate   = sampling_rate / interpol;

            %Calculation of lenght of the interpolated waveform
            wfm_length_out  = floor(wfm_length_in * sampling_rate /...
                (sample_rate_bb_in * awg_setup.granularity)) * awg_setup.granularity;
            % Get the actual sample rates for acurate timing/symbol rate
            sampling_rate   = sample_rate_bb_in * wfm_length_out / wfm_length_in;
            sampling_rate   = sampling_rate * interpol;            
        end

%**************************************************************************

        function out_wfm = BoxcarDecimation(obj, input_wfm, decimation, sample_ratio)
        
            out_sample = 1;
        
            out_wfm = zeros(1, floor(length(input_wfm) / decimation));
        
            final_sample = length(input_wfm) - decimation * sample_ratio;
            integration_size = decimation * sample_ratio - 1;
        
            for current_sample = 1:decimation:final_sample 
                out_wfm(out_sample) = sum(input_wfm(current_sample:(current_sample + integration_size)));
                out_sample = out_sample + 1;
            end
            out_wfm = out_wfm / integration_size;
        end

%**************************************************************************
        % INSTRUMENT CONTROL METHODS 
%**************************************************************************

        function [  inst,...            
                    modelName,...
                    sId,...
                    serial_num] = ConnecToProteus(obj)

            % Connection to target Proteus
            % connStr is the slot # as an integer(0 for manual selection) or IP adress
            % as an string
            % Paranoia Level add additional checks for each transfer. 0 = no checks.
            % 1 = send OPC?, 2 = send SYST:ERROR?
            
            % It returns
            % inst: handler for the selected instrument  
            % modelName: vector of strings with model name for selected instrument (i.e. "P9484")
            % sId: vector with slot number for selected instrument. When slot # == 0
            % serial_number: vector with serial numbers for the modules
            % the function shows a list of the connected modules and the
            % user can select one from the list by typing the slot #.
                
            % pid = feature('getpid');
            % fprintf(1,'\nProcess ID %d\n',pid);
            
            %dll_path = 'C:\\Windows\\System32\\TEPAdmin.dll';  
            obj.admin   = 0;
            sId         = 0;            
            if obj.com_ifc == obj.COMM_IFC_LAN
                try            
                    connStr     = strcat('TCPIP::',obj.ip_addr,'::5025::SOCKET');
                    inst        = TEProteusInst(connStr, obj.paranoia_level);
                    obj.inst    = inst;
                    res         = inst.Connect();
                    assert (res == true);
                    [modelName,...
                    sId,... 
                    serial_num] = obj.IdentifyModel();
                catch ME
                    rethrow(ME)
                end   
            else
                asm             = NET.addAssembly(obj.DLL_PATH);
            
                import TaborElec.Proteus.CLI.*
                import TaborElec.Proteus.CLI.Admin.*
                import System.*
                
                obj.admin       = CProteusAdmin(@OnLoggerEvent);
                rc              = obj.admin.Open();
                assert(rc == 0);   
                
                try
                    slotIds     = obj.admin.GetSlotIds();
                    numSlots    = length(size(slotIds));
                    assert(numSlots > 0);

                    connStr     = obj.pxi_slot;
                    
                    % If there are multiple slots, let the user select one ..
                    sId         = slotIds;
                    if numSlots > 1
                        if obj.pxi_slot == 0
                            fprintf('\n%d slots were found\n', numSlots);
                            
                            for n = 1:numSlots
                                sId(n)      = slotIds(n);
                                slotInfo    = obj.admin.GetSlotInfo(sId(n));
                                if ~slotInfo.IsSlotInUse
                                    modelName = slotInfo.ModelName;
                                    if slotInfo.IsDummySlot && connStr == 0
                                        fprintf(' * Slot Number:%d Model %s [Dummy Slot].\n', sId, modelName);
                                    elseif connStr == 0
                                        fprintf(' * Slot Number:%d Model %s.\n', sId(n), modelName);
                                    end
                                end
                            end
                        end
                        pause(0.1);
                        if connStr == 0
                            choice = input('Enter SlotId ');
                            fprintf('\n');
                        else
                            choice = connStr;
                        end                
                        sId         = uint32(choice);
                        slotInfo    = obj.admin.GetSlotInfo(sId);
                        serial_num  = slotInfo.SerialNumber;
                        modelName   = slotInfo.ModelName;
                        modelName   = strtrim(obj.netStrToStr(modelName));
                    end
                    
                    % Connect to the selected instrument ..
                    should_reset    = true;
                    inst            = obj.admin.OpenInstrument(sId, should_reset);
                    obj.inst        = inst;
                    instId          = inst.InstrId;
                    
                catch ME
                    obj.admin.Close();
                    rethrow(ME) 
                end    
            end
        end  

%**************************************************************************

        function DisconnectFromProteus(obj)
            if obj.com_ifc == obj.COMM_IFC_LAN
                obj.inst.Disconnect();
            else
                obj.admin.CloseInstrument(obj.inst.InstrId);    
                obj.admin.Close();
            end
        end

%**************************************************************************

        function SelectModule(obj, module_number)
            obj.inst.SendScpi([':INST:ACT ' num2str(module_number)]);
        end

%**************************************************************************

        function [model, slot, serial] = IdentifyModel(obj)
            % It gets the model and slot number for all the Proteus devices
            % accessed through the same handle
            % inst = Instrument Handle
            % It Returns:
            % model = vector of strings with all the model number
            % slot = vector of uint8 with all the slots
            % serial = vector of uint32 with serial number for all modules
            idnStr  = obj.inst.SendScpi('*IDN?');
            idnStr  = strtrim(obj.netStrToStr(idnStr.RespStr));
            idnStr  = split(idnStr, [",", "-", " "]);
        
            model   = string.empty;
            slot    = uint8.empty;
            serial  = uint32.empty;
        
            for k = 1:length(idnStr)
                if contains(idnStr(k), "P")
                   model    = [model, idnStr(k)];
                   serial   = [serial, uint32(str2double(idnStr(k + 1)))];
                end
                if contains(idnStr(k), "slot")
                   slot     = [slot, uint8(str2double(idnStr(k + 1)))];
                end
            end    
        end

%**************************************************************************    

        function options = GetProteusOptions(obj)
            % Get all the options available in a Proteus unit
            % inst = Instrument handle
            % It returns:
            % Options = a vector of strings with all the alphanumeric codes for
            % the installed options
            optStr  = obj.inst.SendScpi('*OPT?');  
            optStr  = strtrim(obj.netStrToStr(optStr.RespStr));
            options = split(optStr, ',');  
        end

%**************************************************************************    

        function options_state = GetProteusOptionsState(obj)
            % Get all the options available in a Proteus unit
            % inst = Instrument handle
            % It returns:
            % Options = a vector of strings with all the alphanumeric codes for
            % the installed options
            optStr  = obj.inst.SendScpi('*OPT?');  
            optStr  = strtrim(obj.netStrToStr(optStr.RespStr));
            options = split(optStr, ',');

            options_state = false(1, length(obj.PROTEUS_OPT_STRINGS));

            for current_option = 1:length(options)
                for opt_num = 1:length(obj.PROTEUS_OPT_STRINGS)
                    if upper(options(current_option)) == upper(obj.PROTEUS_OPT_STRINGS(opt_num))
                        options_state (opt_num) = true;
                    end    
                end
            end
        end

%**************************************************************************

        function dacRes = GetDacResolution(obj)  
            % Get the current DAC resolution for the taget Proteus
            % inst = Instrument handle
            % It returns:
            % dacRes = Current DAC sample resolution. Either 8 or 16.
    
            dacRes = obj.inst.SendScpi(':TRAC:FORM?');
            dacRes = strtrim(obj.netStrToStr(dacRes.RespStr));
        
            if contains(dacRes, 'U8')
                dacRes = 8;
            else
                dacRes = 16;
            end
        end

%**************************************************************************

        function [min_sr, max_sr] = GetAwgSamplingRateRange(obj)
            % Get the maximum and minimum sample rate for the target Proteus
            % device.
            % inst = Instrument Handle
            % It returns:
            % min_sr = Minimum settable sample rate in Hz
            % max_sr = Maximum settable sample rate in Hz        
    
            min_sr = obj.inst.SendScpi(':FREQ:RAST MIN?');  
            min_sr = strtrim(obj.netStrToStr(min_sr.RespStr));
            min_sr = str2double(min_sr);
            max_sr = obj.inst.SendScpi(':FREQ:RAST MAX?');  
            max_sr = strtrim(obj.netStrToStr(max_sr.RespStr));
            max_sr = str2double(max_sr);
        end

%**************************************************************************    

        function [min_volt, max_volt] = GetAwgVoltageRange(obj)
            % Get the maximum and minimum voltage range for the target Proteus
            % device.
            % inst = Instrument Handle
            % It returns:
            % min_volt = Minimum settable voltage in volts
            % max_volt = Maximum settable voltage in volts        
    
            min_volt = obj.inst.SendScpi(':SOUR:VOLT MIN?');  
            min_volt = strtrim(obj.netStrToStr(min_volt.RespStr));
            min_volt = str2double(min_volt);
            max_volt = obj.inst.SendScpi(':SOUR:VOLT MAX?');  
            max_volt = strtrim(obj.netStrToStr(max_volt.RespStr));
            max_volt = str2double(max_volt);
        end

%**************************************************************************

        function TaskListSetup( obj,...
                                awg_setup,...
                                task_list)

            % This function defines a complete Task List based in the definitons
            % defined by the taskList integer uint32 array. The array is NxM, where N
            % is the number of entries in the task list being defined and M is the
            % number of fields specifying the parameters of each tasks. This is the
            % defintion of the fields:
            %
            %   Number          Description         
            % ________________________________________
            %
            %   1               pointer_to_segment
            %   2               task_type: 0: Single, 1: StartSeq, 2: InSeq, 3: EndSeq
            %   3               num_of_loops_task
            %   4               num_of_loops_seq
            %   5               next_task
            %   6               dtr_trig_flag: 0: dtr trigger off, 1: dtr trigger on
            %   7               use enable task event
            %   8               use abort task event

            % TASK_SEGMENT_PTR        = 1;
            % TASK_TYPE               = 2;
            % TASK_LOOPS              = 3;
            % TASK_LOOPS_SEQ          = 4;
            % TASK_NEXT               = 5;
            % TASK_DTR_FLAG           = 6;
            % TASK_ENABLE_EVENT       = 7;
            % TASK_ABORT_EVENT        = 8;

            segm_multiplier = 1;

            if awg_setup.mode == obj.AWG_MODE_DUC && awg_setup.iq_mode == obj.AWG_IQ_MODE_HALF
                segm_multiplier = 2;
            end

            channel = awg_setup.channel;
            segment = awg_setup.segment;
            
            num_of_tasks = size(task_list, 1);
            for chan = 0:(segm_multiplier - 1)
                % Select Channel
                obj.inst.SendScpi(sprintf(':INST:CHAN %d', channel + chan));  
                % The Task Composer is configured to handle a certain number of task
                % entries
                obj.inst.SendScpi(sprintf(':TASK:COMP:LENG %d', num_of_tasks)); 
            
                % Then, each task is defined
                for task_number = 1:num_of_tasks 
                    % Task to be defined is selected
                    obj.inst.SendScpi(sprintf(':TASK:COMP:SEL %d', task_number));
                    % The type of task is defined.
                    switch task_list(task_number, obj.TASK_TYPE)
                        case obj.TASK_TYPE_SINGLE
                            obj.inst.SendScpi(':TASK:COMP:TYPE SING');
                        case obj.TASK_TYPE_START
                            obj.inst.SendScpi(':TASK:COMP:TYPE STAR');
                        case obj.TASK_TYPE_SEQ
                            obj.inst.SendScpi(':TASK:COMP:TYPE SEQ');
                        case obj.TASK_TYPE_END
                            obj.inst.SendScpi(':TASK:COMP:TYPE END');
                    end
                           
                    % The action to take after completing the task is defined. NEXT is the
                    % default so sending this command is not mandatory
                    obj.inst.SendScpi(':TASK:COMP:DEST NEXT');
                    % Assigns segment for task in the sequence        
                    obj.inst.SendScpi(sprintf(':TASK:COMP:SEGM %d',...
                        segment + (task_list(task_number, 1) - 1) * segm_multiplier + chan));
                    % Assigns task to generate next in the sequence
                    obj.inst.SendScpi(sprintf(':TASK:COMP:NEXT1 %d', task_list(task_number, 5)));  
            
                    % Set the Trigger for Digitizer  
                    switch task_list(task_number, obj.TASK_DTR_FLAG)
                        case 0
                            %inst.SendScpi(':TASK:COMP:DTR NONE');
                            % remove previous and activate below for older FPGA
                            obj.inst.SendScpi(':TASK:COMP:DTR OFF');
                        otherwise
                            %inst.SendScpi(':TASK:COMP:DTR AWG');
                            % remove previous and activate below for older FPGA
                            obj.inst.SendScpi(':TASK:COMP:DTR ON');            
                    end  
    
                    switch task_list(task_number, obj.TASK_ENABLE_EVENT)
                        case obj.TASK_EVENT_TRG1
                            obj.inst.SendScpi(':TASK:COMP:ENAB TRG1');
                        case obj.TASK_EVENT_TRG2
                            obj.inst.SendScpi(':TASK:COMP:ENAB TRG2');
                        case obj.TASK_EVENT_CPU
                            obj.inst.SendScpi(':TASK:COMP:ENAB CPU');
                        case obj.TASK_EVENT_INT
                            obj.inst.SendScpi(':TASK:COMP:ENAB INT');
                    end
    
                    switch task_list(task_number, obj.TASK_ABORT_EVENT)
                        case obj.TASK_EVENT_TRG1
                            obj.inst.SendScpi(':TASK:COMP:ABOR TRG1');
                        case obj.TASK_EVENT_TRG2
                            obj.inst.SendScpi(':TASK:COMP:ABOR TRG2');
                        case obj.TASK_EVENT_CPU
                            obj.inst.SendScpi(':TASK:COMP:ABOR CPU');
                        case obj.TASK_EVENT_INT
                            obj.inst.SendScpi(':TASK:COMP:ABOR INT');
                    end

                    switch task_list(task_number, obj.TASK_IDLE_MODE)
                        case obj.TASK_IDLE_MODE_DC
                            obj.inst.SendScpi(':TASK:COMP:IDLE DC');
                        case obj.TASK_IDLE_MODE_FIRST
                            obj.inst.SendScpi(':TASK:COMP:IDLE FIRS');
                        case obj.TASK_IDLE_MODE_CURRENT
                            obj.inst.SendScpi(':TASK:COMP:IDLE CURR');                        
                    end

                    obj.inst.SendScpi(sprintf(':TASK:COMP:IDLE:LEV %d', task_list(task_number, obj.TASK_IDLE_LVL)));
            
                    % Num of loops for the current sequence
                    if task_list(task_number, obj.TASK_TYPE) == obj.TASK_TYPE_SEQ
                        obj.inst.SendScpi(sprintf(':TASK:COMP:SEQ %d', task_list(task_number, obj.TASK_LOOPS_SEQ)));
                    end
            
                    %  Num of loops for the current task
                    obj.inst.SendScpi(sprintf(':TASK:COMP:LOOP %d', task_list(task_number, obj.TASK_LOOPS)));
                end   
            
                % The task table created with the Composer is written to the actual task
                % table of teh selected channel
                obj.inst.SendScpi(':TASK:COMP:WRIT');
                if obj.lib_verbose
                    fprintf(1, 'SEQUENCE CREATED!\n');
                end
                % Select Task Mode for generation    
                % Start in task #1 (#1 is the default)    trg_src
                obj.inst.SendScpi(':FUNC:MODE TASK');
            end
            obj.inst.SendScpi(sprintf(':INST:CHAN %d', channel)); 
        end

%**************************************************************************

        function SetExtTriggerAwg(obj, trg_src, trg_lvl, trg_slope, idl_lvl)
        
            switch trg_src
                case obj.TASK_EVENT_TRG1        
                    obj.inst.SendScpi(':TRIG:SELECT TRG1');      
                    
                case obj.TASK_EVENT_TRG2        
                    obj.inst.SendScpi(':TRIG:SELECT TRG2');           
            end
        
            obj.inst.SendScpi([':TRIG:LEV ' num2str(trg_lvl)]);
            if trg_slope == obj.AWG_TRG_SLOPE_NEG
                obj.inst.SendScpi(':TRIG:SLOP NEG');
            else
                obj.inst.SendScpi(':TRIG:SLOP POS');
            end

            obj.inst.SendScpi([':TRIG:IDLE:LEV ' num2str(idl_lvl)]);
        
            obj.inst.SendScpi(':TRIG:STAT ON');
        
        end

%**************************************************************************

        function SetupProteusAwgMode(   obj,...
                                        awg_setup)
        % Setup AWG channel and segment and set up output
        % parameters specified by awg_setup struct. Fields:
        %   mode = AWG Mode, DIR, DUC, NCO
        %   iq_mode = half, one , two
        %   cfr = carrier frequencies (vector)
        %   phase = carrier initial phase (vector)
        %   six_db = true = on (vector)
        %   dac_resolution = DAC resolution (8 or 16 bit)
        %   volt = Voltage peak-to-peak. < 0 = MAX
        %   offset = DC Offset
        %   sampling_rate = AWG sampling rate
        %   interpol = interpolation factor

            obj.SelectModule(awg_setup.sel_module);        
            % obj.inst.SendScpi(sprintf(':INST:ACT %d', awg_setup.sel_module));
            obj.inst.SendScpi(sprintf(':INST:CHAN %d', awg_setup.channel));
            % Sample rate 

            if awg_setup.sampling_rate / awg_setup.interpol <= 2.5E9
                obj.inst.SendScpi([':FREQ:RAST ' num2str(2.5E9)]);

                switch awg_setup.interpol
                    case obj.AWG_INTERPOL_X2
                        obj.inst.SendScpi(':SOUR:INT X2');

                    case obj.AWG_INTERPOL_X4
                        obj.inst.SendScpi(':SOUR:INT X4');

                    case obj.AWG_INTERPOL_X8
                        obj.inst.SendScpi(':SOUR:INT X8');

                    otherwise
                        obj.inst.SendScpi(':SOUR:INT NONE');
                end
            end

            switch awg_setup.mode
                case obj.AWG_MODE_DIRECT
                    obj.inst.SendScpi(':SOUR:MODE DIR');
                case obj.AWG_MODE_DUC
                    obj.inst.SendScpi(':SOUR:MODE DUC');
                    switch awg_setup.iq_mode
                        case obj.AWG_IQ_MODE_HALF
                            obj.inst.SendScpi(':IQM HALF');
                            
                        case obj.AWG_IQ_MODE_ONE
                            obj.inst.SendScpi(':IQM ONE');                            

                        case obj.AWG_IQ_MODE_TWO
                            obj.inst.SendScpi(':IQM TWO');                             
                    end

                case obj.AWG_MODE_NCO
                    obj.inst.SendScpi(':SOUR:MODE NCO');                   
            end
            %obj.inst.SendScpi(':TRAC:DEL:ALL');              

            obj.inst.SendScpi([':FREQ:RAST ' num2str(awg_setup.sampling_rate)]);        

            switch awg_setup.trg_src 
                case obj.TASK_EVENT_NONE
                    obj.inst.SendScpi(':TRIG:SOUR:ENAB NONE');

                case obj.TASK_EVENT_CPU
                    obj.inst.SendScpi(':TRIG:SOUR:ENAB CPU');

                case obj.TASK_EVENT_TRG1
                    obj.inst.SendScpi(':TRIG:SOUR:ENAB TRG1');
                    obj.SetExtTriggerAwg(   awg_setup.trg_src,...
                                            awg_setup.trg_lvl,...
                                            awg_setup.trg_slope,...
                                            awg_setup.trg_idle_lvl);

                case obj.TASK_EVENT_TRG2 
                    obj.inst.SendScpi(':TRIG:SOUR:ENAB TRG2');
                    obj.SetExtTriggerAwg(   awg_setup.trg_src,...
                                            awg_setup.trg_lvl,...
                                            awg_setup.trg_slope,...
                                            awg_setup.trg_idle_lvl);                   

                case obj.TASK_EVENT_INT
                    obj.inst.SendScpi(':TRIG:SOUR:ENAB INT');               
            end

            obj.inst.SendScpi(sprintf(':TRIG:COUN %d ', awg_setup.trg_count));

            if awg_setup.trg_mode == obj.AWG_TRG_MODE_CONT
                obj.inst.SendScpi(':INIT:CONT:STAT 1');

            elseif awg_setup.trg_mode == obj.AWG_TRG_MODE_TRIG
                obj.inst.SendScpi(':INIT:CONT:STAT 0');
            end

            if awg_setup.cpu_trg_mode == obj.AWG_CPU_TRG_GLOBAL
                obj.inst.SendScpi(':TRIG:CPU:MODE GLOBAL');

            elseif awg_setup.cpu_trg_mode == obj.AWG_CPU_TRG_LOCAL
                obj.inst.SendScpi(':TRIG:CPU:MODE LOCAL');
            end

            switch awg_setup.mode            

                case obj.AWG_MODE_DUC
                    switch awg_setup.iq_mode
                        case obj.AWG_IQ_MODE_HALF
                            obj.inst.SendScpi(sprintf(':INST:CHAN %d', awg_setup.channel + 1));
                            obj.inst.SendScpi(sprintf(':NCO:CFR1 %f', obj.GetActualElement(awg_setup.cfr1, 1)));
                            obj.inst.SendScpi(sprintf(':NCO:PHAS1 %f', obj.GetActualElement(awg_setup.phase1, 1)));
                            obj.inst.SendScpi(sprintf(':NCO:SIXD1 %d', obj.GetActualElement(awg_setup.six_db1, 1)));
                            obj.inst.SendScpi(sprintf(':INST:CHAN %d', awg_setup.channel));
                            obj.inst.SendScpi(sprintf(':NCO:CFR1 %f', obj.GetActualElement(awg_setup.cfr1, 1)));
                            obj.inst.SendScpi(sprintf(':NCO:PHAS1 %f', obj.GetActualElement(awg_setup.phase1, 1)));
                            obj.inst.SendScpi(sprintf(':NCO:SIXD1 %d', obj.GetActualElement(awg_setup.six_db1, 1)));

                        case obj.AWG_IQ_MODE_ONE
                            obj.inst.SendScpi(sprintf(':INST:CHAN %d', awg_setup.channel));
                            obj.inst.SendScpi(sprintf(':NCO:CFR1 %f', obj.GetActualElement(awg_setup.cfr1, 1)));
                            obj.inst.SendScpi(sprintf(':NCO:PHAS1 %f', obj.GetActualElement(awg_setup.phase1, 1)));
                            obj.inst.SendScpi(sprintf(':NCO:SIXD1 %d', obj.GetActualElement(awg_setup.six_db1, 1)));

                        case obj.AWG_IQ_MODE_TWO
                            obj.inst.SendScpi(sprintf(':INST:CHAN %d', awg_setup.channel));
                            obj.inst.SendScpi(sprintf(':NCO:CFR1 %f', obj.GetActualElement(awg_setup.cfr1, 1)));
                            obj.inst.SendScpi(sprintf(':NCO:PHAS1 %f', obj.GetActualElement(awg_setup.phase1, 1)));
                            obj.inst.SendScpi(sprintf(':NCO:SIXD1 %d', obj.GetActualElement(awg_setup.six_db1, 1)));
                            obj.inst.SendScpi(sprintf(':NCO:CFR2 %f', obj.GetActualElement(awg_setup.cfr2, 1)));
                            obj.inst.SendScpi(sprintf(':NCO:PHAS2 %f', obj.GetActualElement(awg_setup.phase2, 1)));
                            obj.inst.SendScpi(sprintf(':NCO:SIXD2 %d', obj.GetActualElement(awg_setup.six_db2, 1)));
                    end

                case obj.AWG_MODE_NCO
                    obj.inst.SendScpi(sprintf(':INST:CHAN %d', awg_setup.channel));
                    obj.inst.SendScpi(sprintf(':NCO:CFR1 %f', obj.GetActualElement(awg_setup.cfr1, 1)));
                    obj.inst.SendScpi(sprintf(':NCO:PHAS1 %f', obj.GetActualElement(awg_setup.phase1, 1)));
            end
        end

%**************************************************************************

        function SetupProteusAwgChannel(obj, awg_setup)
        % Setup AWG channel and segment and set up output
        % parameters specified by awg_setup struct. Fields:
        %   mode = AWG Mode, DIR, DUC, NCO
        %   channel = target channel #
        %   segment = target segment #
        %   dac_resolution = DAC resolution (8 or 16 bit)
        %   volt = Voltage peak-to-peak. < 0 = MAX
        %   offset = DC Offset
        %   sampling_rate = AWG sampling rate
        %   interpol = interpolation factor

            obj.inst.SendScpi(sprintf(':INST:CHAN %d', awg_setup.channel));

            obj.inst.SendScpi(sprintf(':SOUR:FUNC:MODE:SEGM %d', awg_setup.segment));
            % Output voltage set to voltage
            if awg_setup.volt >= 0
                obj.inst.SendScpi([':SOUR:VOLT ' num2str(awg_setup.volt)]); 
            else
                obj.inst.SendScpi(':SOUR:VOLT MAX');   
            end
            % if awg_setup.mode == obj.AWG_MODE_DUC
            %     obj.inst.SendScpi(sprintf(':NCO:SIXD1 %d', obj.GetActualElement(awg_setup.six_db1, 1)))
            % end
            % Activate outpurt and start generation
            if awg_setup.output_state
                obj.inst.SendScpi(':OUTP ON'); 
            else
                obj.inst.SendScpi(':OUTP OFF');
            end

            if awg_setup.mode == obj.AWG_MODE_DUC && awg_setup.iq_mode == obj.AWG_IQ_MODE_HALF
                obj.inst.SendScpi(sprintf(':INST:CHAN %d', awg_setup.channel + 1));
                obj.inst.SendScpi(sprintf(':SOUR:FUNC:MODE:SEGM %d', awg_setup.segment + 1));
                % Output voltage set to voltage
                if awg_setup.volt >= 0
                    obj.inst.SendScpi([':SOUR:VOLT ' num2str(awg_setup.volt)]); 
                else
                    obj.inst.SendScpi(':SOUR:VOLT MAX');   
                end

                % obj.inst.SendScpi(sprintf(':NCO:SIXD1 %d', obj.GetActualElement(awg_setup.six_db1, 1)))
                % Activate outpurt and start generation
                if awg_setup.output_state
                    obj.inst.SendScpi(':OUTP ON'); 
                else
                    obj.inst.SendScpi(':OUTP OFF');
                end
                obj.inst.SendScpi(sprintf(':INST:CHAN %d', awg_setup.channel));
            end
        end

%**************************************************************************

        function result = SendListToProteus(obj,...                
                                            awg_setup,...
                                            myWfm,...
                                            task_list,...
                                            initialize)

            result = obj.SendWfmToProteus(  awg_setup,...
                                            myWfm,...
                                            initialize);

            obj.TaskListSetup(  awg_setup,...
                                task_list);  
        end

%**************************************************************************

        function result = SendWfmToProteus_old( obj,...                
                                                awg_setup,...
                                                myWfm,...
                                                initialize)
        % Download waveform to target channel and segment and set up output
        % parameters specified by awg_setup struct. Fields:
        %   mode = AWG Mode, DIR, DUC, NCO
        %   channel = target channel #
        %   segment = target segment #
        %   wfm_map = size for each waveform in myWfm, 0 = one wfm
        %   dac_resolution = DAC resolution (8 or 16 bit)
        %   volt = Voltage peak-to-peak. < 0 = MAX
        %   offset = DC Offset
        %   sampling_rate = AWG sampling rate
        %   interpol = interpolation factor
        %   output_state = 1, output ON, 0, output OFF
        %   report_time = 1, report download time, 0, do not report
        % Input parameters:
        % inst = instrument handle
        % awg_setup = AWG settings
        % myWfm = normalized (-1.0/+1.0) waveform vector
        % initialize = 1, apply settings, 2, do not apply
        % It returns:
        % result = length of downloaded waveform in samples
             
            %Select Channel
            if initialize                
                obj.SetupProteusAwgMode(awg_setup);     
            end

            obj.inst.SendScpi(sprintf(':INST:CHAN %d', awg_setup.channel));

            if awg_setup.dac_resolution == obj.AWG_DAC_MODE_16  
                    obj.inst.SendScpi(':TRAC:FORM U16');
            else
                    obj.inst.SendScpi(':TRAC:FORM U8');
            end            
                          
            num_of_wfm = length(awg_setup.wfm_map);
            if num_of_wfm == 1
                if awg_setup.wfm_map == 0
                    awg_setup.wfm_map = length(myWfm);
                end
            end

            init_wfm = 1;

            segm_multiplier = 1;

            if awg_setup.mode == obj.AWG_MODE_DUC && awg_setup.iq_mode == obj.AWG_IQ_MODE_HALF
                segm_multiplier = 2;
            end

            for wfm_number = 0:(num_of_wfm - 1)
                %obj.inst.SendScpi(sprintf(':INST:CHAN %d', awg_setup.channel)); 
                current_length  = awg_setup.wfm_map(wfm_number + 1);
                obj.inst.SendScpi(sprintf(':TRAC:DEF %d, %d', awg_setup.segment + wfm_number * segm_multiplier, current_length));        
                % select segmenT as the the programmable segment
                obj.inst.SendScpi(sprintf(':TRAC:SEL %d', awg_setup.segment + wfm_number * segm_multiplier));
            
                % format Wfm for download
                final_wfm       = init_wfm + current_length - 1;
                current_wfm     = myWfm(init_wfm:final_wfm);
                init_wfm        = final_wfm + 1;
        
                switch awg_setup.mode
                    case obj.AWG_MODE_DIRECT
                        current_wfm = obj.Quantization(current_wfm, awg_setup.dac_resolution, 0);

                    case obj.AWG_MODE_DUC
                        switch awg_setup.iq_mode
                            case obj.AWG_IQ_MODE_HALF 
                                current_wfm_imag = obj.Quantization(imag(current_wfm), awg_setup.dac_resolution, 1);
                                current_wfm = obj.Quantization(real(current_wfm), awg_setup.dac_resolution, 1);                               

                            case obj.AWG_IQ_MODE_ONE
                                current_wfm = obj.Quantization(current_wfm, awg_setup.dac_resolution, 1);
                        end
                end
                
                % Download the binary data to segment   
                prefix = ':TRAC:DATA 0,';
            
                if awg_setup.dac_resolution == obj.AWG_DAC_MODE_16
                    current_wfm = uint16(current_wfm);
                    current_wfm = typecast(current_wfm, 'uint8');                    
                else
                    current_wfm = uint8(current_wfm);                    
                end
                dataLength = length(current_wfm);
                if awg_setup.report_time
                    fprintf('AWG Download Time for Wfm # %d, %d bytes:\n', wfm_number + 1, dataLength);
                    tic;
                end
                res = obj.inst.WriteBinaryData(prefix, current_wfm);

                if awg_setup.mode == obj.AWG_MODE_DUC && awg_setup.iq_mode == obj.AWG_IQ_MODE_HALF                    
                    %obj.inst.SendScpi(sprintf(':INST:CHAN %d', awg_setup.channel + 1));
                    obj.inst.SendScpi(sprintf(':TRAC:DEF %d, %d', awg_setup.segment + wfm_number * segm_multiplier + 1, current_length));        
                    % select segmenT as the the programmable segment
                    obj.inst.SendScpi(sprintf(':TRAC:SEL %d', awg_setup.segment + wfm_number * segm_multiplier + 1));
                    current_wfm_imag = uint16(current_wfm_imag);
                    current_wfm_imag = typecast(current_wfm_imag, 'uint8');
                    res = obj.inst.WriteBinaryData(prefix, current_wfm_imag);
                end

                if awg_setup.report_time
                    toc;
                end
                %assert(res.ErrCode == 0);
            end

            obj.inst.SendScpi(sprintf(':INST:CHAN %d', awg_setup.channel));
        
            if initialize                
                obj.SetupProteusAwgChannel(awg_setup);
            end
            
            result = length(myWfm);
        end

%**************************************************************************

        function final_wfm = GetHalfModeInterleavedWfm(obj, wfm_map, myWfm)

            num_of_wfm = length(wfm_map);
            if num_of_wfm == 1
                if wfm_map == 0
                    wfm_map = length(myWfm);
                end               
            end
            final_wfm_end = sum(wfm_map);
            final_wfm_end = 2 * final_wfm_end;

            final_wfm = zeros(1, final_wfm_end);

            init_sample = 1;
            init_pointer = 1;

            for current_wfm = 1:num_of_wfm
                end_sample = init_sample + wfm_map(current_wfm) - 1;
                final_wfm(init_pointer:(init_pointer + wfm_map(current_wfm) - 1)) = real(myWfm(init_sample:end_sample));
                init_pointer = init_pointer + wfm_map(current_wfm);
                final_wfm(init_pointer:(init_pointer + wfm_map(current_wfm) - 1)) = imag(myWfm(init_sample:end_sample));
                init_pointer = init_pointer + wfm_map(current_wfm);
                init_sample = init_sample + wfm_map(current_wfm);
            end                   
        end

%**************************************************************************

        function result = SendWfmToProteus( obj,...                
                                            awg_setup,...
                                            myWfm,...
                                            initialize)
        % Download waveform to target channel and segment and set up output
        % parameters specified by awg_setup struct. Fields:
        %   mode = AWG Mode, DIR, DUC, NCO
        %   channel = target channel #
        %   segment = target segment #
        %   wfm_map = size for each waveform in myWfm, 0 = one wfm
        %   dac_resolution = DAC resolution (8 or 16 bit)
        %   volt = Voltage peak-to-peak. < 0 = MAX
        %   offset = DC Offset
        %   sampling_rate = AWG sampling rate
        %   interpol = interpolation factor
        %   output_state = 1, output ON, 0, output OFF
        %   report_time = 1, report download time, 0, do not report
        % Input parameters:
        % inst = instrument handle
        % awg_setup = AWG settings
        % myWfm = normalized (-1.0/+1.0) waveform vector
        % initialize = 1, apply settings, 2, do not apply
        % It returns:
        % result = length of downloaded waveform in samples
             
            %Select Channel
            if initialize                
                obj.SetupProteusAwgMode(awg_setup);     
            end

            obj.inst.SendScpi(sprintf(':INST:CHAN %d', awg_setup.channel));

            if awg_setup.dac_resolution == obj.AWG_DAC_MODE_16  
                    obj.inst.SendScpi(':TRAC:FORM U16');
            else
                    obj.inst.SendScpi(':TRAC:FORM U8');
            end 
                          
            num_of_wfm = length(awg_setup.wfm_map);
            if num_of_wfm == 1
                if awg_setup.wfm_map == 0
                    awg_setup.wfm_map = length(myWfm);
                end
            end  

            if awg_setup.mode == obj.AWG_MODE_DUC && awg_setup.iq_mode == obj.AWG_IQ_MODE_HALF 
                myWfm = obj.GetHalfModeInterleavedWfm(awg_setup.wfm_map, myWfm);
            end

            segm_multiplier = 1;

            % Download all wfms

            current_length = length(myWfm);

            obj.inst.SendScpi(sprintf(':TRAC:DEF %d, %d', awg_setup.segment, current_length));        
            % select segmenT as the the programmable segment
            obj.inst.SendScpi(sprintf(':TRAC:SEL %d', awg_setup.segment));

            switch awg_setup.mode
                case obj.AWG_MODE_DIRECT
                    current_wfm = obj.Quantization(myWfm, awg_setup.dac_resolution, 0);

                case obj.AWG_MODE_DUC
                    if awg_setup.iq_mode ~= obj.AWG_IQ_MODE_TWO
                        current_wfm = obj.Quantization(myWfm, awg_setup.dac_resolution, 1);
                    else
                        current_wfm = myWfm;
                    end
                    if awg_setup.iq_mode == obj.AWG_IQ_MODE_HALF 
                        segm_multiplier = 2;                          
                    end                
            end

            % Download the binary data to segment   
            prefix = ':TRAC:DATA 0,';
        
            if awg_setup.dac_resolution == obj.AWG_DAC_MODE_16
                current_wfm = uint16(current_wfm);
                current_wfm = typecast(current_wfm, 'uint8');                    
            else
                current_wfm = uint8(current_wfm);                    
            end
            dataLength = length(current_wfm);
            if awg_setup.report_time && obj.lib_verbose
                fprintf('AWG Download Time for All Wfms, %d # of samples:\n', dataLength);
                tic;
            end

            obj.inst.WriteBinaryData(prefix, current_wfm); 

            if awg_setup.report_time && obj.lib_verbose
                toc;
            end

            for wfm_number = 0:(num_of_wfm - 1)
                current_length  = awg_setup.wfm_map(wfm_number + 1);
                current_segment = awg_setup.segment + wfm_number * segm_multiplier;
                obj.inst.SendScpi(sprintf(':TRAC:DEF %d, %d', current_segment, current_length));        
                % select segmenT as the the programmable segment
 
                if awg_setup.mode == obj.AWG_MODE_DUC && awg_setup.iq_mode == obj.AWG_IQ_MODE_HALF 
                    obj.inst.SendScpi(sprintf(':TRAC:DEF %d, %d', current_segment + 1, current_length));        
                end                
            end
        
            if initialize                
                obj.SetupProteusAwgChannel(awg_setup);
            end
            
            result = length(myWfm);
        end

%**************************************************************************

        function result = SendMkrToProteus(obj, awg_setup, myMkr)
            % Download the binary data to segment   
            prefix = ':MARK:DATA 0,';
            obj.inst.WriteBinaryData(prefix, myMkr); 
            result = length(myMkr);
            
            if      awg_setup.mkr_mode == obj.AWG_MKR_MODE_TWO ||...
                    awg_setup.mkr_mode == obj.AWG_MKR_MODE_FOUR||...
                    awg_setup.mkr_mode == obj.AWG_MKR_MODE_EIGHT

                obj.inst.SendScpi(':MARK:SEL 1');         %Marker1
                obj.inst.SendScpi([':MARK:VOLT:PTOP ' num2str(awg_setup.mkr1_volt)]);      %Vpp
                obj.inst.SendScpi([':MARK:VOLT:OFFS ' num2str(awg_setup.mkr1_offset)]);      %DC Offset
                if awg_setup.mkr1_state == 1
                    obj.inst.SendScpi(':MARK ON');
                else
                    obj.inst.SendScpi(':MARK OFF');
                end
                obj.inst.SendScpi(':MARK:SEL 2');         %Marker1
                obj.inst.SendScpi([':MARK:VOLT:PTOP ' num2str(awg_setup.mkr2_volt)]);      %Vpp
                obj.inst.SendScpi([':MARK:VOLT:OFFS ' num2str(awg_setup.mkr2_offset)]);      %DC Offset
                if awg_setup.mkr2_state == 1
                    obj.inst.SendScpi(':MARK ON');
                else
                    obj.inst.SendScpi(':MARK OFF');
                end
            end

            if      awg_setup.mkr_mode == obj.AWG_MKR_MODE_FOUR||...
                    awg_setup.mkr_mode == obj.AWG_MKR_MODE_EIGHT

                obj.inst.SendScpi(':MARK:SEL 3');         %Marker1
                obj.inst.SendScpi([':MARK:VOLT:PTOP ' num2str(awg_setup.mkr3_volt)]);      %Vpp
                obj.inst.SendScpi([':MARK:VOLT:OFFS ' num2str(awg_setup.mkr3_offset)]);      %DC Offset
                if awg_setup.mkr3_state == 1
                    obj.inst.SendScpi(':MARK ON');
                else
                    obj.inst.SendScpi(':MARK OFF');
                end
                obj.inst.SendScpi(':MARK:SEL 4');         %Marker1
                obj.inst.SendScpi([':MARK:VOLT:PTOP ' num2str(awg_setup.mkr4_volt)]);      %Vpp
                obj.inst.SendScpi([':MARK:VOLT:OFFS ' num2str(awg_setup.mkr4_offset)]);      %DC Offset
                if awg_setup.mkr4_state == 1
                    obj.inst.SendScpi(':MARK ON');
                else
                    obj.inst.SendScpi(':MARK OFF');
                end
            end
        end

%**************************************************************************

        function result = SendIqmOneListToProteus(  obj,...                
                                                    awg_setup,...
                                                    myWfm,...
                                                    task_list)

            result = obj.SendIqmOneWfm( awg_setup,...
                                        myWfm);

            obj.TaskListSetup(awg_setup, task_list);
        end

%**************************************************************************

        function result = SendIqmOneWfm(    obj,...                
                                            awg_setup,...                                            
                                            myWfm)        
            % format Wfm
            myWfm = obj.NormalIqOne(myWfm);
            myWfm = obj.ComplexToInterleaved(myWfm); 
            if length(awg_setup.wfm_map) > 1
                awg_setup.wfm_map = 2 * awg_setup.wfm_map;
            end
            % Transfer to AWG, including quantization
            if obj.lib_verbose
                fprintf(1, sprintf('DOWNLOADING WAVEFORM: %d samples\n', length(myWfm))); 
            end
            result = obj.SendWfmToProteus( awg_setup,...
                                            myWfm,...
                                            true);            
            if obj.lib_verbose
                fprintf(1, 'WAVEFORM DOWNLOADED!\n');
            end
            clear myWfm;           
        end

%**************************************************************************

        function result = SendIqmHalfListToProteus( obj,...                
                                                    awg_setup,...
                                                    myWfm,...
                                                    task_list)

            result = obj.SendIqmHalfWfm(    awg_setup,...
                                            myWfm);

            % obj.TaskListSetup(awg_setup, task_list);
            % awg_setup.channel = awg_setup.channel + 1;
            % if task_list(2,1) == task_list(1,1)
            %     task_list(2,1) = task_list(1,1) + 2;
            % end
            % task_list(1,1) = task_list(1,1) + 2;
            obj.TaskListSetup(awg_setup, task_list);
        end

%**************************************************************************

        function result = SendIqmHalfWfm(   obj,...                
                                            awg_setup,...                                            
                                            myWfm)

            myWfm = obj.NormalIqOne(myWfm);           
                   
            % Channel I is 2N - 1 and Channel Q is 2N
            % If channel is even, then base channle number is corrected
            if mod(awg_setup.channel, 2) == 0
                 awg_setup.channel = awg_setup.channel - 1;
            end

            % Waveform Downloading
            % ******************** 
            % fprintf(1, 'DOWNLOADING WAVEFORM Q\n');
            % awg_setup.channel = awg_setup.channel + 1;
            % awg_setup.segment = awg_setup.segment + 2; 
            % %obj.inst.SendScpi(sprintf(':INST:CHAN %d', awg_setup.channel));
            % result = obj.SendWfmToProteus(  awg_setup,...
            %                                 imag(myWfm),...
            %                                 false); % FALSE
            if obj.lib_verbose
                fprintf(1, 'DOWNLOADING WAVEFORMS I/Q\n');
            end
            % awg_setup.channel = awg_setup.channel - 1;
            % awg_setup.segment = awg_setup.segment - 2;
            result = obj.SendWfmToProteus(  awg_setup,...
                                            myWfm,...
                                            true);                      
            if obj.lib_verbose
                fprintf(1, 'WAVEFORMS DOWNLOADED!\n');
            end
            clear myWfm;          
        end

%**************************************************************************

        function result = SendIqmTwoListToProteus(  obj,...                
                                                    awg_setup,...
                                                    myWfm1,...
                                                    myWfm2,...
                                                    task_list)

            if length(awg_setup.wfm_map) > 1
                awg_setup.wfm_map = 4 * awg_setup.wfm_map;
            end

            result = obj.SendIqmTwoWfm( awg_setup,...
                                        myWfm1,...
                                        myWfm2);

            obj.TaskListSetup(awg_setup, task_list);
        end

%**************************************************************************

        function result = SendIqmTwoWfm(    obj,...                
                                            awg_setup,...
                                            myWfm1,...
                                            myWfm2)
    
            [myWfm1,  myWfm2]   = obj.NormalIqTwo(myWfm1, myWfm2);    
            myWfm               = obj.ComplexToInterleavedTwo(myWfm1, myWfm2); 

            result              = obj.SendWfmToProteus( awg_setup,...
                                                        myWfm,...
                                                        true);           
            
            if obj.lib_verbose
                fprintf(1, 'WAVEFORM DOWNLOADED!\n');
            end
            clear myWfm;           
        end

%**************************************************************************

        function SetNco(    obj,...
                            awg_setup)

            % Select Channel
            obj.inst.SendScpi(sprintf(':INST:CHAN %d', awg_setup.channel)); 
            if obj.lib_verbose
                fprintf(1, 'SETTING SAMPLING CLOCK\n');
            end
            % The two below commands will keep Proteus in th 16-bit mode
            % Otherwise, for sample rates > 2.5GS/s, even-numbered channels
            % will not be active
            obj.inst.SendScpi([':FREQ:RAST ' num2str(2.5E9)]); 
            obj.inst.SendScpi(':SOUR:INT X8');
            % DAC Mode set to 'NCO'       
            obj.inst.SendScpi(':MODE NCO'); 
            
            if awg_setup.nco_mode == obj.AWG_NCO_MODE_DUAL
                obj.inst.SendScpi(':NCO:MODE DUAL');
            else
                obj.inst.SendScpi(':NCO:MODE SINGLE');
            end
            
            obj.inst.SendScpi([':FREQ:RAST ' num2str(awg_setup.sampling_rate)]);
            % 'NCO' Settings
            obj.inst.SendScpi(sprintf(':NCO:CFR1 %f', awg_setup.cfr1));
            obj.inst.SendScpi(sprintf(':NCO:PHAS1 %f', awg_setup.phase1));
            % if apply6db
            if awg_setup.six_db1
                obj.inst.SendScpi(':NCO:SIXD1 ON');   
            else
                obj.inst.SendScpi(':NCO:SIXD1 OFF');    
            end

            if awg_setup.nco_mode == obj.AWG_NCO_MODE_DUAL
                % 'NCO' Settings
                obj.inst.SendScpi(sprintf(':NCO:CFR2 %f', awg_setup.cfr2));
                obj.inst.SendScpi(sprintf(':NCO:PHAS2 %f', awg_setup.phase2));
                % if apply6db
                if awg_setup.six_db2
                    obj.inst.SendScpi(':NCO:SIXD2 ON');   
                else
                    obj.inst.SendScpi(':NCO:SIXD2 OFF');    
                end
            end

            % Output voltage 
            if awg_setup.volt > 0.0
                obj.inst.SendScpi(sprintf(':SOUR:VOLT %f', awg_setup.volt));
            else
                obj.inst.SendScpi(':SOUR:VOLT MAX');
            end
            % Activate outpurt and start generation
            if awg_setup.output_state
                obj.inst.SendScpi(':OUTP ON');
            else
                obj.inst.SendScpi(':OUTP OFF');
            end
        end

%**************************************************************************
        % DIGITIZER METHODS
%**************************************************************************

        function SetupProteusDigMode(   obj,...
                                        dig_setup)
            % ----------
            % ADC Config
            % It supports up to two channels with different setups
            % ----------
        
            % Set the ADC mode and set the channel mapping
            if dig_setup.mode == obj.DIG_ACQ_MODE_DUAL
                obj.inst.SendScpi(':DIG:MODE DUAL');  
                num_of_channels = 2;
            elseif dig_setup.mode == obj.DIG_ACQ_MODE_SINGLE
                obj.inst.SendScpi(':DIG:MODE SINGLE');
                num_of_channels = 1;
                % Only Channel 1 in Single mode
            end 

            % Free Acquistion Memory and Set sampling rate
            obj.inst.SendScpi(':DIG:ACQ:FREE');    
            obj.inst.SendScpi(sprintf(':DIG:FREQ %g', dig_setup.sampling_rate));

            % DDC activation
            % Calculate actual frame length depending on the DDC mode
            actual_frame_len = dig_setup.frame_length;
            actual_pretrig = round(dig_setup.pre_trigger * actual_frame_len / 100);
            actual_pretrig = round(actual_pretrig / dig_setup.granul) * dig_setup.granul;
            if dig_setup.ddc == obj.DIG_MODE_COMPLEX      
                obj.inst.SendScpi(':DIG:DDC:MODE COMP');
                actual_pretrig = 2 * actual_pretrig;
                actual_frame_len = 2 * actual_frame_len;
                for channel = 1:num_of_channels
                    % NCO frequency mapped to the first and second NZ
                    ddc_freq = obj.GetNcoFreq(  dig_setup.cfr(channel), ...
                                                dig_setup.sampling_rate, ...
                                                false);                    
                    obj.inst.SendScpi(sprintf(':DIG:DDC:CFR%d %f', channel, abs(ddc_freq)));                    
                end
            else
                obj.inst.SendScpi(':DIG:DDC:MODE REAL');
            end

            % Setup frames layout. Common to both ADC channels.    
            obj.inst.SendScpi(sprintf(':DIG:ACQ:DEF %d, %d',...
                dig_setup.num_of_frames, actual_frame_len));

            % Pretrigger for DDC must be set to double as acquisions are made
            % by IQ pair of samples   
            obj.inst.SendScpi(sprintf(':DIG:PRET %d', actual_pretrig));

            for channel = 1:2
                % Select digitizer channel:
                obj.inst.SendScpi(sprintf(':DIG:CHAN %d', channel));
                % Set the voltage-range of the selected channel
                switch dig_setup.rng(channel)
                    case obj.DIG_RNG_250MV
                        obj.inst.SendScpi(':DIG:CHAN:RANG LOW');
                    case obj.DIG_RNG_400MV
                        obj.inst.SendScpi(':DIG:CHAN:RANG MED');
                    case obj.DIG_RNG_500MV
                        obj.inst.SendScpi(':DIG:CHAN:RANG HIGH');
                end
                %Enable acquisition in the selected channel
                if dig_setup.ch_state(channel) == obj.DIG_CHAN_ENABLE
                    obj.inst.SendScpi(':DIG:CHAN:STATE ENAB');
                elseif dig_setup.ch_state(channel) == obj.DIG_CHAN_DISABLE
                    obj.inst.SendScpi(':DIG:CHAN:STATE DIS');
                end                
                
                % Set channel 1 of the digitizer as its trigger source
                % If DTR trigger, it is directed to the designated AWG channel
                
                switch dig_setup.trg_src(channel)
                    case obj.DIG_TRG_CPU
                        obj.inst.SendScpi(':DIG:TRIG:SOURCE CPU');

                    case obj.DIG_TRG_EXT
                        obj.inst.SendScpi(':DIG:TRIG:SOUR EXT');
                        obj.inst.SendScpi(':DIG:TRIG:SOUR EDGE');
                        obj.inst.SendScpi(sprintf(':DIG:TRIG:SELF %f',...
                            dig_setup.trg_lvl(channel)));

                        switch dig_setup.trg_slope(1)
                            case obj.DIG_TRG_EDGE_NEG
                                obj.inst.SendScpi(':DIG:TRIG:SLOP NEG');

                            case obj.DIG_TRG_EDGE_POS
                                obj.inst.SendScpi(':DIG:TRIG:SLOP POS');
                        end

                        obj.inst.SendScpi(sprintf(':DIG:TRIG:DEL %f',...
                            dig_setup.trg_delay(channel)));

                    case obj.DIG_TRG_CH1
                        obj.inst.SendScpi(':DIG:TRIG:SOUR CH1');
                        obj.inst.SendScpi(sprintf(':DIG:TRIG:SELF %f',...
                            dig_setup.trg_lvl(channel)));
                        switch dig_setup.trg_slope(channel)
                            case obj.DIG_TRG_EDGE_NEG
                                obj.inst.SendScpi(':DIG:TRIG:SLOP NEG');

                            case obj.DIG_TRG_EDGE_POS
                                obj.inst.SendScpi(':DIG:TRIG:SLOP POS');
                        end                           

                    case obj.DIG_TRG_CH2
                        obj.inst.SendScpi(':DIG:TRIG:SOUR CH2');
                        obj.inst.SendScpi(sprintf(':DIG:TRIG:SELF %f',...
                            dig_setup.trg_lvl(channel)));
                        switch dig_setup.trg_slope(channel)
                            case obj.DIG_TRG_EDGE_NEG
                                obj.inst.SendScpi(':DIG:TRIG:SLOP NEG');

                            case obj.DIG_TRG_EDGE_POS
                                obj.inst.SendScpi(':DIG:TRIG:SLOP POS');
                        end

                    case obj.DIG_TRG_DTR_CH1
                        obj.inst.SendScpi(':INST:CHAN 1');
                        obj.inst.SendScpi(sprintf(':DIG:TRIG:AWG:TDEL %f',...
                            dig_setup.trg_delay(channel)));
                        obj.inst.SendScpi(':DIG:TRIG:SOURCE TASK1');

                    case obj.DIG_TRG_DTR_CH2
                        obj.inst.SendScpi(':INST:CHAN 2');
                        obj.inst.SendScpi(sprintf(':DIG:TRIG:AWG:TDEL %f',...
                            dig_setup.trg_delay(channel)));
                        obj.inst.SendScpi(':DIG:TRIG:SOURCE TASK2');

                    case obj.DIG_TRG_DTR_CH3
                        obj.inst.SendScpi(':INST:CHAN 3');
                        obj.inst.SendScpi(sprintf(':DIG:TRIG:AWG:TDEL %f',...
                            dig_setup.trg_delay(channel)));
                        obj.inst.SendScpi(':DIG:TRIG:SOURCE TASK3');

                    case obj.DIG_TRG_DTR_CH4
                        obj.inst.SendScpi(':INST:CHAN 4');
                        obj.inst.SendScpi(sprintf(':DIG:TRIG:AWG:TDEL %f',...
                            dig_setup.trg_delay(channel)));
                        obj.inst.SendScpi(':DIG:TRIG:SOURCE TASK4');

                    case obj.DIG_TRG_MR1
                        obj.inst.SendScpi(':DIG:TRIG:SOURCE MR1');

                    case obj.DIG_TRG_MF1
                        obj.inst.SendScpi(':DIG:TRIG:SOURCE MF1');

                    case obj.DIG_TRG_MR2
                        obj.inst.SendScpi(':DIG:TRIG:SOURCE MR2');

                    case obj.DIG_TRG_MF2  
                        obj.inst.SendScpi(':DIG:TRIG:SOURCE MF2');
                end        
                % ***** SEE IF THIS MAY BE DONE FOR EACH CHANNEL
                % Select which frames are filled with captured data 
                %(all frames in this example)
                obj.inst.SendScpi(':DIG:ACQ:FRAM:CAPT:ALL');            
                % Delete all wfm memory
                obj.inst.SendScpi(':DIG:ACQ:ZERO:ALL');                         
            end
            % Get ADC wfm format. For informative purposes
            % resp = inst.SendScpi(':DIG:DATA:FORM?');
            % resp = strtrim(netStrToStr(resp.RespStr));
            % Stop the digitizer
            obj.inst.SendScpi(':DIG:INIT OFF');
        end

%***********************************************************

        function num_of_acq_frames = AcquireWfm(    obj,...
                                                    dig_setup)
            obj.inst.SendScpi(':DIG:INIT ON');
            
            num_of_acq_frames   = 0;

            % Identify Digitizer channels to acquire
            active_channels     = [false, false];
            completion_flag     = [true, true];

            if dig_setup.ch_state(1) == obj.DIG_CHAN_ENABLE
                active_channels(1)  = true;
                completion_flag(1)  = false;
            end
            if dig_setup.mode == obj.DIG_ACQ_MODE_DUAL
                if dig_setup.ch_state(2) == obj.DIG_CHAN_ENABLE
                    active_channels(2)  = true;  
                    completion_flag(2)  = false;
                end
            end

            if active_channels(1)
                current_channel = 1;
            elseif active_channels(2)
                current_channel = 2;
            end

            if (active_channels(1) && dig_setup.trg_src(1) == obj.DIG_TRG_CPU) ||...
                (active_channels(2) && dig_setup.trg_src(2) == obj.DIG_TRG_CPU)
                obj.inst.SendScpi(':DIG:TRIG:IMM');
            end

            loop_counter = 0;
            num_of_loops = ceil(dig_setup.acq_timeout / 0.1);

            obj.inst.SendScpi(':TRIG:IMM');

            % Get acquisition status CSV string from Proteus for selected
            % channel
            while (~completion_flag(1) || ~completion_flag(2)) && loop_counter < num_of_loops
                % Select channel                
                obj.inst.SendScpi(sprintf(':DIG:CHAN %d', current_channel));
                %obj.inst.SendScpi(':DIG:TRIG:IMM');
                resp = obj.inst.SendScpi(':DIG:ACQ:FRAM:STAT?');
                resp = strtrim(obj.netStrToStr(resp.RespStr));
                resp = strtrim(resp);
                items = split(resp, ',');
                items = str2double(items);
                % If item 2 in the CSV string is '1', then all frames have been
                % captured
                if length(items) >= 3 && items(2) == 1
                    completion_flag(current_channel) = true;
                end
                % This is just to give some information when trigger times out
                if mod(loop_counter, 10) == 0 && obj.lib_verbose               
                    fprintf('%d. %s Time:\n', fix(loop_counter / 10), resp);                                
                end
                pause(0.1);
                loop_counter = loop_counter + 1;
                if active_channels(1) && active_channels(2)
                    if current_channel == 1
                        current_channel = 2;
                    else
                        current_channel = 1;
                    end
                end
            end

            obj.inst.SendScpi(':DIG:INIT OFF');

            if completion_flag(1) && completion_flag(2)
                num_of_acq_frames = dig_setup.num_of_frames;
            end            
        end

%******************************************************

        function acq_wfm = GetDigWfm(   obj,...
                                        dig_setup)

            acq_wfm             = int16.empty;
            length_multiplier   = 1;
            if dig_setup.ddc == obj.DIG_MODE_COMPLEX
                length_multiplier = 2;
            end

            if  dig_setup.ch_state(1) == obj.DIG_CHAN_ENABLE && ...
                dig_setup.ch_state(2) == obj.DIG_CHAN_ENABLE
                acq_wfm = int16(zeros(2, dig_setup.num_of_frames * dig_setup.frame_length * length_multiplier));
                if  dig_setup.ch_state(1) == obj.DIG_CHAN_ENABLE || ...
                    dig_setup.ch_state(2) == obj.DIG_CHAN_ENABLE
                    acq_wfm = int16(zeros(1, dig_setup.num_of_frames * dig_setup.frame_length * length_multiplier));
                end
            end

            tic;
            index_ptr = 0;
            for current_channel = 1:2
                if (current_channel == 1 && dig_setup.ch_state(1) == obj.DIG_CHAN_ENABLE) ||...
                        (current_channel == 2 && dig_setup.ch_state(2) == obj.DIG_CHAN_ENABLE)
                    index_ptr = index_ptr + 1;
                    % Select channel
                    obj.inst.SendScpi(sprintf(':DIG:CHAN %d', current_channel));
                    % Define what we want to read 
                    % (frames data, frame-header, or both).
                    % In this example we read the frames-data
                    obj.inst.SendScpi(':DIG:DATA:TYPE FRAM');
                    obj.inst.SendScpi(':DIG:DATA:SEL ALL');
            
                    % Read binary block
                    % Get the size in bytes of the acquisition
                    resp = obj.inst.SendScpi(':DIG:DATA:SIZE?');
                    resp = strtrim(obj.netStrToStr(resp.RespStr));
                    num_bytes = uint64(str2double(resp));
                    % upload time will be shown so transfer rate can be compared
                    if obj.lib_verbose
                        fprintf('ADC Upload Time for %d bytes:\n', num_bytes);                    
                        tic;
                    end
                    if obj.com_ifc == obj.COMM_IFC_LAN
                        if dig_setup.ddc == obj.DIG_MODE_COMPLEX 
                            %tic;
                            % DDC data is formatted as 15-bit in a 32-bit unsigned
                            % integer
                            samples = obj.inst.ReadBinaryData(':DIG:DATA:READ?', 'uint32');              
                            %toc;
                            samples = int16(samples) - 16384; % Set zero level
                            % Convert to complex I + jQ samples
                            %samples = obj.InterleavedToComplex(samples);
                            % Invert spectrum if ddcFreq < 0.0
                            if dig_setup.cfr(current_channel) < 0.0
                                samples(2:2:end) = -samples(2:2:end);
                            end
                        else
                            %tic;
                            % Direct ADC data is formated as 12-bit samples in 16-bit
                            % unsigned integers
                            samples = obj.inst.ReadBinaryData(':DIG:DATA:READ?', 'uint16');     
                            %toc;
                            samples = int16(samples) - 2048; % Set zero level
                        end
                    else
                        % For the PXI library, downloads can only handlw 8 or 16-bit
                        % unsigned.
                        if dig_setup.ddc == obj.DIG_MODE_COMPLEX
                            % For DDC, because read format is UINT16 we divide byte
                            % number by 2
                            wavlen = floor(num_bytes / 2);        
                            % allocate NET array
                            netArray = NET.createArray('System.UInt16', wavlen);
                            % read the captured frame
                            %tic;
                            res = obj.inst.ReadMultipleAdcFrames(   current_channel - 1,...
                                                                    1, ...
                                                                    dig_setup.num_of_frames, ...
                                                                    netArray);
                            %toc;
                         
                            assert(res == 0);
                            % Each 32 sample is now 2 contiguous 16-bit samples
                            samples = uint16(netArray);
                            % As the first 16-bit samples in the pair is "all zeros"
                            % they can be discarded by taking one very two bytes
                            samples = samples(1:2:length(samples));
                            
                            % cast to matlab vector
                            samples = int16(samples) - 16384; % Set zero level
                            % Convert to complex I + jQ samples
                            %samples = obj.InterleavedToComplex(samples);
                            % Invert spectrum if ddcFreq < 0.0
                            if dig_setup.cfr(current_channel) < 0.0
                                samples(2:2:end) = -samples(2:2:end);
                            end                
                            % deallocate the NET array
                            delete(netArray);
                        else
                            wavlen = floor(num_bytes / 2);
                    
                            % allocate NET array
                            netArray = NET.createArray('System.UInt16', wavlen);
                            % read the captured frame
                            %tic
                            res = obj.inst.ReadMultipleAdcFrames(   current_channel - 1,...
                                                                    1, ...
                                                                    dig_setup.num_of_frames, ...
                                                                    netArray);
                            %res = obj.inst.ReadMultipleAdcFrames(0, 1, numberOfFrames, netArray);
                            %toc
                            assert(res == 0);
                            
                            samples = uint16(netArray);
                            % cast to matlab vector
                            samples = int16(samples) - 2048;
                                            
                            % deallocate the NET array
                            delete(netArray);
                        end            
                    end
                    toc;
                    acq_wfm(index_ptr, :) = samples;
                end                   
            end
            % Ouput data is formatted as a two dimensions array with A x F
            % rows (A = number of acquisitions, F = number of Frames) and
            % FrameLem columns
            %fprintf('Formatting time for %d frames:\n', numberOfFrames);            
        end

%**************************************************************************

        function [  trg_loc,...
                    gate_addr,...
                    min_adc,...
                    max_adc,...
                    time_stamp] = GetHeaderData(obj, channel, num_of_frames)
        
            obj.inst.SendScpi(sprintf(':DIG:CHAN %d', channel));
        
            obj.inst.SendScpi(':DIG:DATA:TYPE HEAD');
            if obj.com_ifc == obj.COMM_IFC_LAN
                header_raw = obj.inst.ReadBinaryData(':DIG:DATA:READ?', 'uint8');
            else
                % % allocate NET array
                % netArray = NET.createArray('System.UInt16', 44 * num_of_frames);
                % res = obj.inst.ReadBinaryData(':DIG:DATA:READ?', netArray, 44 * num_of_frames);
                % header_raw = uint16(netArray);
                % % deallocate the NET array
                % delete(netArray);
            end
        
            %num_of_frames = round(length(header_raw) / 88);
        
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

%**************************************************************************

        function [  read_hdr] = GetHeaderData2(obj, channel, num_of_frames)
        
            obj.inst.SendScpi(sprintf(':DIG:CHAN %d', channel));
        
            obj.inst.SendScpi(':DIG:DATA:TYPE HEAD');
            if obj.com_ifc == obj.COMM_IFC_LAN
                header_raw = obj.inst.ReadBinaryData(':DIG:DATA:READ?', 'uint8');
            else
                % % allocate NET array
                % netArray = NET.createArray('System.UInt16', 44 * num_of_frames);
                % res = obj.inst.ReadBinaryData(':DIG:DATA:READ?', netArray, 44 * num_of_frames);
                % header_raw = uint16(netArray);
                % % deallocate the NET array
                % delete(netArray);
            end

            actual_num_of_frames = floor(length(header_raw) / obj.DIG_FRAME_HDR_TOT_SIZE);
            if num_of_frames > actual_num_of_frames
                num_of_frames = actual_num_of_frames;
            end
        
            base_pointer = 0;

            read_hdr = uint64(zeros(num_of_frames, length(obj.DIG_FRAME_HDR_FLD_SIZE)));
        
            for frame = 1:num_of_frames
                field_pointer = 0;
                for field = 1:length(obj.DIG_FRAME_HDR_FLD_SIZE)
                    raw_value = uint64(0);
                    for k = 1:obj.DIG_FRAME_HDR_FLD_SIZE(field)
                        raw_value = raw_value + uint64(header_raw(base_pointer + field_pointer + k)) * uint64(256)^(k-1);
                    end

                    read_hdr(frame, field) = raw_value;

                    field_pointer = field_pointer + obj.DIG_FRAME_HDR_FLD_SIZE(field);                   
                end
                base_pointer = base_pointer + obj.DIG_FRAME_HDR_TOT_SIZE;
            end
        end

%**************************************************************************

        function [  out_wfm,...
                    out_hdr,... 
                    out_mkr] = GetWfmFromProteusDig(    obj,...
                                                        dig_setup)
            
            % Creation of output arrays
            obj.SetupProteusDigMode(dig_setup);
            out_hdr             = uint16.empty;
            out_mkr             = uint8.empty;            
            num_of_acq_frames   = obj.AcquireWfm(dig_setup);
            out_wfm             = obj.GetDigWfm(dig_setup);
            a = 1;
        end

%**************************************************************************

        function [scaled_wfm, max_y, min_y] = ScaleAdcWfm(  obj,...
                                                            dig_setup,...
                                                            raw_wfm, ...
                                                            use_dac_lvl)
        
            num_of_wfms     = size(raw_wfm, 1);
            num_of_samples  = size(raw_wfm, 2);
            scaled_wfm      = zeros(num_of_wfms, num_of_samples);
        
            for wfm = 1:num_of_wfms
                switch dig_setup.rng(wfm)
                    case obj.DIG_RNG_250MV
                        actual_v_range = 0.25 / 2;
            
                    case obj.DIG_RNG_400MV
                        actual_v_range = 0.4 / 2;
            
                    case obj.DIG_RNG_500MV
                        actual_v_range = 0.5 / 2;
                end
        
                actual_v_offset = dig_setup.offset(wfm);
        
                if dig_setup.avg == obj.DIG_AVG_ON
                    word_length_norm = 1;
                    if (12 + floor(log2(dig_setup.num_avgs))) > 28
                        word_length_norm = 12 + floor(log2(dig_setup.num_avgs)) - 28;
                        word_length_norm = 2^word_length_norm;
                    end
                    scaled_wfm(wfm, :) = double(int32(raw_wfm) - 134217728);
                    scaled_wfm(wfm, :) = scaled_wfm(wfm, :) / dig_setup.num_avgs;
                    scaled_wfm(wfm, :) = scaled_wfm(wfm, :) * word_length_norm;
                    max_y = 2048; % * avg_settings.num_of_avg;            
                else
                    if dig_setup.ddc == obj.DIG_MODE_COMPLEX
                        max_y = 16384;                
                    else
                        max_y = 2048;               
                    end
        
                    scaled_wfm(wfm, :) = double(raw_wfm(wfm, :) - max_y);            
                end
        
                if use_dac_lvl
                    min_y = -max_y;
                else
                    scaled_wfm(wfm, :)  = scaled_wfm(wfm, :) + max_y;
                    scaled_wfm(wfm, :)  = scaled_wfm(wfm, :) * actual_v_range / max_y;
                    scaled_wfm(wfm, :)  = scaled_wfm(wfm, :) + actual_v_offset;
                    max_y               = actual_v_offset + actual_v_range;
                    min_y               = actual_v_offset - actual_v_range;
                end
            end
        end

%**************************************************************************
%                       OTHER INSTRUMENTATION METHODS                     *
%**************************************************************************
        function [scope_session, idn_str] = ConnectToInfiniium( obj,...
                                                                connStr)
            %fprintf('\nConnecting to Scope\n');
            % VISA session opened to the spectrum analyer.Use the right device
            % descritor for the interface and address being used.
            %connStr = 'TCPIP0::192.168.1.57::hislip0::INSTR';
            scope_session                   = visa('NI', connStr);
            scope_session.OutputBufferSize  = 10000000;
            scope_session.InputBufferSize   = 10000000;
            scope_session.Timeout           = 100.0;
            scope_session.ByteOrder         = 'littleEndian';
            fopen(scope_session);
            %pause(1);
            fprintf(scope_session, '%s', '*IDN?');
            idn_str                          = fscanf(scope_session);            
        end

%**************************************************************************

        function  DisconnectFromInfiniium(      obj,...
                                                scope_session)
            fclose(scope_session);
        end


%**************************************************************************

        function SetInfiniiumScope( obj,...
                                    scope_session,...
                                    scope_settings)
        
            %----------------------------------------------------------------------
            % Set up Scope
            %----------------------------------------------------------------------
            if obj.lib_verbose
                fprintf('Scope Set-Up for Measurements\n');
            end
            fprintf(scope_session, '%s', '*RST');
        
            fprintf(scope_session, '%s', '*OPC?');
            res = fscanf(scope_session);
        
            % Activate selected channels
            for current_channel = 1:4
                fprintf(scope_session, '%s', [':CHAN' num2str(current_channel) ':DISP OFF']);        
            end
            for current_channel = 1:length(scope_settings.chan_scope)
                fprintf(scope_session, '%s', [':CHAN' num2str(scope_settings.chan_scope(current_channel)) ':DISP ON']);
                fprintf(scope_session, '%s', '*OPC?');
                res = fscanf(scope_session);       
        
                % Set vertical scale     
                init_volt_div = obj.GetActualElement(scope_settings.volt_pp, current_channel);
                init_volt_div = init_volt_div / 8.0;
        
                fprintf(scope_session, '%s', [':CHAN' num2str(scope_settings.chan_scope(current_channel)) ':SCAL ' num2str(init_volt_div)]);
                fprintf(scope_session, '%s', '*OPC?');
                res = fscanf(scope_session);
            end
        
            % Set Time Base        
            timeBase = scope_settings.time_window / 10.0;
        
            fprintf(scope_session, '%s', [':TIM:SCAL ' num2str(timeBase)]);
            fprintf(scope_session, ':TIM:REF CENT');    
            fprintf(scope_session, '%s', '*OPC?');
            res = fscanf(scope_session);
        
            xPos = (scope_settings.trig_pos - 50.0) * timeBase / 10.0;
        
            fprintf(scope_session, '%s', [':TIM:POS ' num2str(xPos)]);    
            fprintf(scope_session, '%s', '*OPC?');
            res = fscanf(scope_session);     
        
            % Set trigger source, level    
        
            fprintf(scope_session, '%s', [':TRIG:EDGE:SOUR CHAN' num2str(scope_settings.trg_channel)]);
            if scope_settings.trg_slope == obj.SCOPE_TRG_SLOPE_POS
                fprintf(scope_session, ':TRIG:EDGE:SLOP POS'); 
            else
                fprintf(scope_session, ':TRIG:EDGE:SLOP NEG');
            end
            fprintf(scope_session, '%s', [':TRIG:LEV CHAN ' num2str(scope_settings.trg_channel) ',' num2str(scope_settings.trg_lvl)]); 
            holdTime = 1E-6;
            fprintf(scope_session, '%s', [':TRIG:HOLD ' num2str(holdTime)]);    
            fprintf(scope_session, '%s', '*OPC?');
            res = fscanf(scope_session);        
        end
        
%**************************************************************************

        function waveform = GetInfiniiumWfm(    obj,...
                                                scope_session,...
                                                scope_settings)
                                
            displayed_points = scope_settings.time_window * scope_settings.sample_rate;            
    
            % Set acquisition parameters
            fprintf(scope_session,':STOP');
            % Specify data from Channel
            fprintf(scope_session,[':WAVEFORM:SOURCE CHAN' num2str(scope_settings.chan_scope(1))]); 
            % Set timebase to main
            fprintf(scope_session,':TIMEBASE:MODE MAIN');
            % Set up acquisition type and count. 
            fprintf(scope_session,':ACQUIRE:TYPE NORMAL');
            fprintf(scope_session,':ACQUIRE:COUNT 1');
            % Specify 5000 points at a time by :WAV:DATA?
            fprintf(scope_session,':WAV:POINTS:MODE RAW');
            fprintf(scope_session,[':WAV:POINTS ' num2str(displayed_points)]);
            % Now tell the instrument to digitize channel1
            fprintf(scope_session,[':DIGITIZE CHAN' num2str(scope_settings.chan_scope(1))]);
            % Wait till complete
            operationComplete = str2double(query(scope_session,'*OPC?'));
            while ~operationComplete
                operationComplete = str2double(query(scope_session,'*OPC?'));
            end
    
            % Get the data back as a WORD (i.e., INT16), other options are ASCII and BYTE
            fprintf(scope_session,':WAVEFORM:FORMAT WORD');
            % Set the byte order on the instrument as well
            fprintf(scope_session,':WAVEFORM:BYTEORDER LSBFirst');
            % Get the preamble block
            preambleBlock = query(scope_session,':WAVEFORM:PREAMBLE?');
    
            % Now send commmand to read data
            fprintf(scope_session,':WAV:DATA?');
            % read back the BINBLOCK with the data in specified format and store it in
            % the waveform structure. FREAD removes the extra terminator in the buffer
            waveform.RawData = binblockread(scope_session,'int16'); fread(scope_session,1);
            % Read back the error queue on the instrument
        %     instrumentError = query(ViSessn,':SYSTEM:ERR?');
        %     while ~isequal(instrumentError,['+0,"No error"' char(10)])
        %         disp(['Instrument Error: ' instrumentError]);
        %         instrumentError = query(ViSessn,':SYSTEM:ERR?');
        %     end      
    
            % Maximum value storable in a INT16
            maxVal = 2^16; 
            %  split the preambleBlock into individual pieces of info
            preambleBlock = regexp(preambleBlock,',','split');
            % store all this information into a waveform structure for later use
            waveform.Format         = str2double(preambleBlock{1});     % This should be 1, since we're specifying INT16 output
            waveform.Type           = str2double(preambleBlock{2});
            waveform.Points         = str2double(preambleBlock{3});
            waveform.Count          = str2double(preambleBlock{4});      % This is always 1
            waveform.XIncrement     = str2double(preambleBlock{5});     % in seconds
            waveform.XOrigin        = str2double(preambleBlock{6});    % in seconds
            waveform.XReference     = str2double(preambleBlock{7});
            waveform.YIncrement     = str2double(preambleBlock{8}); % V
            waveform.YOrigin        = str2double(preambleBlock{9});
            waveform.YReference     = str2double(preambleBlock{10});
            waveform.VoltsPerDiv    = (maxVal * waveform.YIncrement / 8);      % V
            waveform.Offset         = ((maxVal/2 - waveform.YReference) * waveform.YIncrement + waveform.YOrigin);         % V
            waveform.SecPerDiv      = waveform.Points * waveform.XIncrement/10 ; % seconds
            waveform.Delay          = ((waveform.Points/2 - waveform.XReference) * waveform.XIncrement + waveform.XOrigin); % seconds
            
            % Generate X & Y Data            
            waveform.YData          = (waveform.YIncrement.*(waveform.RawData - waveform.YReference)) + waveform.YOrigin;            
            %wfm                     = waveform.YData;
            %x_delta                 = waveform.XIncrement;
            %sec_div                 = waveform.SecPerDiv;                                
        end


%**************************************************************************
%                 EQUIVALENT TIME ACQUISITION METHODS
%**************************************************************************

        function filtered_clock = ClockFilter(  obj,...
                                                clk_wfm, ...
                                                cutoff_freq, ...
                                                sampling_rate)
        
            filter_length   = 20 * (sampling_rate/cutoff_freq);
            filter_length   = round(filter_length);
            if mod(filter_length, 2) == 0
                filter_length = filter_length + 1;
            end
            lp_filter       = -floor(filter_length / 2):floor(filter_length / 2);
            lp_filter       = sinc(2 * cutoff_freq / sampling_rate * lp_filter);
            
            lp_filter       = lp_filter / sum(lp_filter);
            
            filtered_clock  = cconv(clk_wfm,lp_filter,length(clk_wfm));
        end

%**************************************************************************

        function interp_clock = ClockInterp(    obj,...
                                                input_clock, ...
                                                interp_factor)
        
            interp_clock = zeros(1, interp_factor * (length(input_clock) - 1) + 1);
            
            for i = 0: (length(input_clock) - 2)
                for j = 0:(interp_factor - 1)
                    interp_clock(interp_factor * i + j + 1) = input_clock(i + 1) + j *...
                        (input_clock(i + 2) - input_clock(i + 1))/interp_factor;            
                end        
            end
            
            interp_clock(length(interp_clock)) = input_clock(length(input_clock));
        end

%**************************************************************************

        function x_cross = GetCrossing(obj, y_1, y_2, y_3, y_cross)
        
            y_1     = double(y_1);
            y_2     = double(y_2);
            y_3     = double(y_3);
        
            a       = (y_1 + y_3 - 2*y_2) / 2;
            b       = (y_3 - y_1) / 2;
            c       = y_2;
            
            c       = c - y_cross;    
            e       = sqrt(b * b - 4 * a * c);    
            x_cross = (- b + e) / (2 * a) ;
            
            if abs(x_cross) > 1.0
                x_cross = (- b - e) / (2 * a);        
            end   
        end

%**************************************************************************

        function [eye_x, eye_y] = GetEquivalentTimeAcq( obj,...
                                                        data_wfm, ...
                                                        clk_wfm, ...
                                                        eq_time_setup)
        
            % Zero cross detection for clock waveform
            x_values = double.empty;
            
            for i = 2:(length(clk_wfm) - 1)
                if (clk_wfm(i) <= 0.0 && clk_wfm(i + 1) >= 0.0)
                    x_cross = obj.GetCrossing(clk_wfm(i - 1), clk_wfm(i), clk_wfm(i + 1), 0.0); 
                    x_values = [x_values, (i + x_cross)]; 
                elseif (clk_wfm(i) >= 0.0 && clk_wfm(i + 1) <= 0.0) && eq_time_setup.all_edges
                    x_cross = obj.GetCrossing(clk_wfm(i - 1), clk_wfm(i), clk_wfm(i + 1), 0.0); 
                    x_values = [x_values, (i + x_cross)];  
                end
            end
            
            % Interpolation of clock edges
            if eq_time_setup.clk_int
                x_values = obj.ClockInterp(x_values, eq_time_setup.clk_div);
            end

            eye_x = zeros(1, length(x_values));
            eye_y = zeros(1, length(x_values));
            
            if eq_time_setup.mode == obj.DIG_ET_MODE_NORMAL
                % Times specified in seconds
                sample_range = eq_time_setup.sampling_rate * eq_time_setup.size;
                sample_range = sample_range / 2;
                sample_delay = eq_time_setup.sampling_rate * eq_time_setup.delay;
            else
                % Times specified in UI for Eye Diagrams
                sample_range = eq_time_setup.sampling_rate * eq_time_setup.size * eq_time_setup.unit_interval;
                sample_range = sample_range / 2;
                sample_delay = eq_time_setup.sampling_rate * eq_time_setup.delay * eq_time_setup.unit_interval;
            end

            eye_ptr = 0;

            search_range_left = floor(sample_range + sample_delay);
            search_range_right = ceil(sample_range - sample_delay);
            
            for i = 1:length(x_values)    
                j = round(x_values(i));
                for k = (j - search_range_left):(j + search_range_right)
                    if k > 0 && k <= length(data_wfm)
                        delta_t = x_values(i) - k; 
                        if delta_t >= (-sample_range + sample_delay) &&...
                                delta_t <= (sample_range + sample_delay)
                            eye_ptr = eye_ptr + 1;
                            eye_x(eye_ptr) = delta_t - sample_delay;
                            eye_y(eye_ptr)= data_wfm(k);
                        end
                    end
                end    
            end

            eye_x = (eye_x) / eq_time_setup.sampling_rate;
            
            %eye_x = (eye_x - sample_delay) / eq_time_setup.sampling_rate;       
        end

%**************************************************************************

        function [  xyz_map,...
                    max_x, min_x,...
                    max_y, min_y] = GetXyzMap(  obj,...
                                                x_wfm, ...
                                                y_wfm, ...
                                                num_of_bins, ...
                                                num_of_lvls)
        
            max_x = max(x_wfm);
            min_x = min(x_wfm);
            max_y = max(y_wfm);
            min_y = min(y_wfm);

            x_wfm = obj.NormalizeFull(x_wfm);
            y_wfm = obj.NormalizeFull(y_wfm);
        
            x_wfm = obj.Quantization2 (x_wfm, 1, num_of_bins);
            y_wfm = obj.Quantization2 (y_wfm, 1, num_of_lvls);
        
            xyz_map = zeros(num_of_lvls, num_of_bins);
        
            for sample = 1:length(x_wfm)
                xyz_map(y_wfm(sample), x_wfm(sample)) = xyz_map(y_wfm(sample), x_wfm(sample)) + 1;
            end

            for x = 1:num_of_bins
                for y = 1:num_of_lvls
                    if xyz_map(y,x) == 0

                    else
                        %xyz_map(y,x) =  2 * max(xyz_map(y,x)) + xyz_map(y,x);
                        xyz_map(y,x) = 1 + log2(xyz_map(y,x));
                    end
                end
            end
        end

%**************************************************************************

        function [  optimum_jitter_rms,...
                    optimum_jitter_pp,...
                    box_1,...
                    box_2,...
                    samples_in_box_optimum] = GetJitter(    obj,...
                                                            x_wfm, ...
                                                            y_wfm, ...
                                                            box,...
                                                            optimize)   
            if optimize
                % The box moves vertically to find the minimum
                start_y     = box(2) - box(1);
                % Step Size = half of the box so there is 50% overlaping
                delta_y     = start_y / 2;
                % Starting position for the box
                start_y     = box(1) - obj.DIG_ET_JIT_SEARCH_ITER * delta_y; 
                steps_y     = obj.DIG_ET_JIT_SEARCH_ITER * 2 + 1;
            else
                % Just direct measurement in the original box
                start_y     = box(1);
                delta_y     = (box(2) - box(1)) / 2;
                steps_y     = 1;
            end
            
            % Variables to store optimum values
            optimum_step            = 0;
            optimum_jitter_rms      = 0.0;
            optimum_jitter_pp       = 0;
            samples_in_box_optimum  = 0;
            % The first non-zero reading will be taken as reference
            first_data_flag         = true;

            jitter_wfm = zeros(1, steps_y);
            
            % Steps according to optimization mode
            for step = 1:steps_y
                % box_1 and box_2 (vertical interval) is calculated for each
                % iteration
                box_1 = start_y + (step - 1) * delta_y;
                box_2 = box_1 + 2 * delta_y;
                % Time data is nitialized to empty
                time_data       = double.empty;
                samples_in_box  = 0;
        
                for i = 1:length(x_wfm)
                    % For all the waveform pairs, check if inside the current box
                    % First vertical
                    if y_wfm(i) >= box_1 && y_wfm(i) <= box_2
                        % And then horizontal
                        if x_wfm(i) >= box(3) && x_wfm(i) <= box(4)
                            % if inside the box, the number of saamples is
                            % invreased by one and the time value added to the
                            % vector for jitter calculation
                            samples_in_box              = samples_in_box + 1;
                            time_data(samples_in_box)   = x_wfm(i);
                        end
                    end
                end    
                % Only boxes with at least one sample inside will be processed for
                % jitter values
                if samples_in_box > 0
                    % Peak-to-Peak jitter = mextrema values difference
                    jitter_pp   = max(time_data) - min(time_data);
                    % RMS Jitter = stabdard deviation of the time vector
                    jitter_rms  = std(time_data);
                    % The optimum values are updates for the first non-zero
                    % iteration and when the rms jitter is lower than the previous
                    % minimum
                    if first_data_flag || jitter_rms < optimum_jitter_rms
                        % # of step if preserved for optimum box value return
                        optimum_step            = step;
                        optimum_jitter_pp       = jitter_pp;
                        optimum_jitter_rms      = jitter_rms;
                        % If this return value is zero, no valid box definition
                        samples_in_box_optimum  = samples_in_box;
                        % First time jitter data is calculated this flag goes to
                        % false so only minimum values will upfate the optimum
                        % values.
                        first_data_flag         = false;            
                    end        
                end

                %jitter_wfm(step) = jitter_rms;
            end
            % Location of the optimal box is reported so it can be used for further
            % processing or graphs
            box_1 = start_y + (optimum_step - 1) * delta_y;
            box_2 = box_1 + 2 * delta_y;            
        end

%**************************************************************************
%                       MODULATION METHODS
%**************************************************************************
        function [waveform, Fs] = GetModWfm( obj, mod_settings)

            if mod_settings.mod_type < 0
                [waveform, Fs] = obj.GetAnalogModWfm(mod_settings);
            else
                [waveform, Fs] = obj.GetQamWfm(mod_settings);
            end
        end

        function [waveform, Fs] = GetAnalogModWfm( obj, mod_settings)
            oversampling = round(mod_settings.oversampling);

            waveform_length = mod_settings.num_of_mod_cycles * oversampling;

            Fs = mod_settings.modul_freq * oversampling;

            modulating_wfm = 1:waveform_length;
            modulating_wfm = modulating_wfm - 1;

            modulating_wfm = sin(2 * pi * mod_settings.num_of_mod_cycles * modulating_wfm / waveform_length);

            switch mod_settings.mod_type 
                case obj.MOD_ANALOG_AM                    
                    waveform = 0.5 + 0.5 *  mod_settings.modul_index / 100.0 * modulating_wfm;
                    waveform = waveform / (0.5 + 0.5 * mod_settings.modul_index / 100.0 );

                case obj.MOD_ANALOG_FM
                    % Instantenous freq
                    waveform = 2 * pi * mod_settings.modul_index * modulating_wfm;
                    % Complex Modulation waveform
                    waveform = exp(1i * waveform * modulating_wfm);

                case obj.MOD_ANALOG_PM
                    % Instantenous phase
                    waveform = pi * mod_settings.modul_index * modulating_wfm / 180.0;
                    % Complex Modulation waveform
                    waveform = exp(1i * waveform);
            end        
        end

        function [waveform, Fs] = GetQamWfm(    obj,...
                                                mod_settings)           
        
            bits_per_symbol = obj.GetModParam(mod_settings.mod_type);    
            oversampling = round(mod_settings.oversampling);
        
            % Create IQ for QPSK/QAM  
        
            % Get symbols in the range 1..2^bps and Map to IQ as Complex Symbol
            data = obj.GetRandomData(mod_settings.num_of_symbols, bits_per_symbol);
            waveform = obj.GetIqMap(data, mod_settings.mod_type);
            
            % Adapt I/Q sample rate to the Oversampling parameter
            waveform =  obj.ZeroPadding(waveform, oversampling);
           
            % Calculate baseband shaping filter
            % accuracy is the length of-1 the shaping filter
            accuracy = 512;

            %filter_type = 'sqrt'; % 'normal' or 'sqrt'
            if mod_settings.filter_type == obj.MOD_BB_FILTER_SQRT
                baseband_filter = rcosdesign(   mod_settings.roll_off, ...
                                                accuracy, ...
                                                mod_settings.oversampling, ...
                                                'sqrt');
            elseif mod_settings.filter_type == obj.MOD_BB_FILTER_NORMAL
                baseband_filter = rcosdesign(   mod_settings.roll_off, ...
                                                accuracy, ...
                                                mod_settings.oversampling, ...
                                                'normal');
            end
        
            % Apply filter through circular convolution and calculate Fs
            waveform = cconv(waveform, baseband_filter, length(waveform));   
            Fs = mod_settings.symbol_rate * mod_settings.oversampling;
        end

%**************************************************************************        

        function [  bits_per_symbol,...
                    max_val,... 
                    mod_name] = GetModParam(        obj,...
                                                    mod_scheme)
            switch mod_scheme
                case obj.MOD_SCHEME_QPSK
                    bits_per_symbol = 2;
                    max_val = 3;
                    mod_name = 'QPSK';
                case obj.MOD_SCHEME_QAM16
                    bits_per_symbol = 4;
                    max_val = 6;
                    mod_name = 'QAM16';
                case obj.MOD_SCHEME_QAM32
                    bits_per_symbol = 5;
                    max_val = 9;
                    mod_name = 'QAM32';
                case obj.MOD_SCHEME_QAM64
                    bits_per_symbol = 6;
                    max_val = 12;
                    mod_name = 'QAM64';
                case obj.MOD_SCHEME_QAM128
                    bits_per_symbol = 7;
                    max_val = 20;
                    mod_name = 'QAM128';
                case obj.MOD_SCHEME_QAM256
                    bits_per_symbol = 8;
                    max_val = 25;
                    mod_name = 'QAM256';
                case obj.MOD_SCHEME_QAM512
                    bits_per_symbol = 9;
                    max_val = 35;
                    mod_name = 'QAM512';
                case obj.MOD_SCHEME_QAM1024
                    bits_per_symbol = 10;
                    max_val = 45;
                    mod_name = 'QAM1024';
            end
        end

%**************************************************************************        

        function bits_per_symbol = GetBitsPerSymbol(    obj,...
                                                        mod_scheme)
            switch mod_scheme
                case obj.MOD_SCHEME_QPSK
                    bits_per_symbol = 2;
                case obj.MOD_SCHEME_QAM16
                    bits_per_symbol = 4;
                case obj.MOD_SCHEME_QAM32
                    bits_per_symbol = 5;
                case obj.MOD_SCHEME_QAM64
                    bits_per_symbol = 6;
                case obj.MOD_SCHEME_QAM128
                    bits_per_symbol = 7;
                case obj.MOD_SCHEME_QAM256
                    bits_per_symbol = 8;
                case obj.MOD_SCHEME_QAM512
                    bits_per_symbol = 9;
                case obj.MOD_SCHEME_QAM1024
                    bits_per_symbol = 10;
            end
        end

%**************************************************************************

        function bits_per_symbol = GetSerialBitsPerSymbol(obj, serial_type)
        
            switch serial_type
                case obj.DATA_TYPE_BILVL_NRZ
                    bits_per_symbol = 1;
        
                case obj.DATA_TYPE_BILVL_RZ
                    bits_per_symbol = 1;
        
                case obj.DATA_TYPE_PAM4
                    bits_per_symbol = 2;
        
                case obj.DATA_TYPE_PAM8
                    bits_per_symbol = 3;
        
                case obj.DATA_TYPE_PAM3
                    bits_per_symbol = 3;
        
                % case obj.DATA_TYPE_PAM5
                %     bits_per_symbol = 8;
            end
        end

%**************************************************************************

        function symbols_per_symbol = GetOutSymbolsPerSymbol(obj, serial_type)
        
            switch serial_type
                case obj.DATA_TYPE_BILVL_NRZ
                    symbols_per_symbol = 1;
        
                case obj.DATA_TYPE_BILVL_RZ
                    symbols_per_symbol = 2;
        
                case obj.DATA_TYPE_PAM4
                    symbols_per_symbol = 1;
        
                case obj.DATA_TYPE_PAM8
                    symbols_per_symbol = 1;
        
                case obj.DATA_TYPE_PAM3
                    symbols_per_symbol = 2;
        
                % case obj.DATA_TYPE_PAM5
                %     symbols_per_symbol = 8;
            end
        end


%**************************************************************************

        function out_lvls = GetLevelPerSymbol(obj, serial_type, symbols)        
            
            symbols_per_symbol  = obj.GetOutSymbolsPerSymbol(serial_type);
            out_lvls = zeros(1, symbols_per_symbol * length(symbols));

            switch serial_type
                case obj.DATA_TYPE_BILVL_NRZ
                    out_lvls = symbols;
                    out_lvls = 2.0 * (out_lvls - 0.5);
        
                case obj.DATA_TYPE_BILVL_RZ
                    out_lvls(1:2:end) = symbols;
                    out_lvls(2:2:end) = 0.0;
                    out_lvls = 2.0 * (out_lvls - 0.5);
        
                case obj.DATA_TYPE_PAM4
                    out_lvls = symbols;
                    out_lvls = (out_lvls - 1.5) / 1.5;
        
                case obj.DATA_TYPE_PAM8
                    out_lvls = symbols;
                    out_lvls = (out_lvls - 3.5) / 3.5;
        
                case obj.DATA_TYPE_PAM3
                    out_lvls = obj.GetPam3Lvls(symbols);
                    a = 1;
        
                % case obj.DATA_TYPE_PAM5
                %     symbols_per_symbol = 8;
            end
        end

%**************************************************************************

        function out_lvls = GetPam3Lvls(obj, symbols)
            num_of_input_symbols = length(symbols);
            out_lvls = zeros(1,2 * num_of_input_symbols);

            for current_symbol = 1:num_of_input_symbols
                symbol_pointer = (current_symbol - 1) * 2 + 1;
                switch symbols(current_symbol)
    
                    case 0
                        out_lvls(symbol_pointer) = -1;
                        out_lvls(symbol_pointer + 1) = -1;
    
                    case 1
                        out_lvls(symbol_pointer) = -1;
                        out_lvls(symbol_pointer + 1) = 0;                  
    
                    case 2
                        out_lvls(symbol_pointer) = -1;
                        out_lvls(symbol_pointer + 1) = 1;               
    
                    case 3
                        out_lvls(symbol_pointer) = 0;
                        out_lvls(symbol_pointer + 1) = -1;               
    
                    case 4
                        out_lvls(symbol_pointer) = 0;
                        out_lvls(symbol_pointer + 1) = 1;
                   
                    case 5
                        out_lvls(symbol_pointer) = 1;
                        out_lvls(symbol_pointer + 1) = -1;
    
                    case 6
                        out_lvls(symbol_pointer) = 1;
                        out_lvls(symbol_pointer + 1) = 0; 
    
                    case 7  
                        out_lvls(symbol_pointer) = 1;
                        out_lvls(symbol_pointer + 1) = 1;
                end
            end
            a = 1;
        end

 %*************************************************************************

        function [  data_wfm_out,...
                    sample_rate_out] = GetSerialDataWfm(    obj,...
                                                            data_bits,...
                                                            pulse_setup)

            res_mult        = 1.0 / (pulse_setup.sampling_rate * pulse_setup.timing_res);
            res_mult        = round(res_mult);
            num_of_bits     = length(data_bits);
            bits_per_symbol = obj.GetSerialBitsPerSymbol(pulse_setup.data_wfm_type);             
            lvls_per_symbol = obj.GetOutSymbolsPerSymbol(pulse_setup.data_wfm_type);
            num_of_symbols  = num_of_bits / bits_per_symbol;
            out_symbols     = num_of_symbols * lvls_per_symbol;
            % Waveform length in time
            wfm_length      = pulse_setup.pulse_width * out_symbols;
            % Waveform length in samples
            wfm_length      = wfm_length * pulse_setup.sampling_rate;
            % Adjust sample rate to keep baud rate
            sample_rate_out = pulse_setup.sampling_rate * floor(wfm_length) / wfm_length;
            wfm_length      = floor(wfm_length);

            data_wfm_out = zeros(1, wfm_length);

            % Get Isolated Pulse
            isolated_pulse = obj.GetTrapezoidalPulse(   pulse_setup.pulse_width, ...
                                                        pulse_setup.edge_shape, ...
                                                        pulse_setup.rise_time,...
                                                        res_mult * sample_rate_out, ...                                                    
                                                        1, ...
                                                        1, ...
                                                        pulse_setup.quality);

            isolated_pulse  = [zeros(1,res_mult), isolated_pulse, zeros(1,res_mult)];

            symbols         = zeros(1, num_of_symbols);
            
            for current_symbol = 1:num_of_symbols
                current_value = 0;
                for bit = 1:bits_per_symbol
                    current_value = current_value +...
                        data_bits((current_symbol - 1) * bits_per_symbol + bit) * 2^(bit - 1); 
                end
                
                symbols(current_symbol) = double(current_value); % / (2^bits_per_symbol - 1);
            end

            symbols = obj.GetLevelPerSymbol(pulse_setup.data_wfm_type, symbols); 

            final_length_pulse = ceil(length(isolated_pulse) / res_mult);

            for current_symbol = 1:out_symbols                
                bit_sample      = (current_symbol - 1) * pulse_setup.pulse_width;
                bit_sample      = bit_sample * sample_rate_out;
                start_sample    = round(bit_sample);
                bit_sample      = bit_sample - start_sample;
                bit_sample      = round(bit_sample * res_mult);
                start_sample    = start_sample + 1;
                current_pulse   = isolated_pulse((res_mult - bit_sample):res_mult:end);
                final_pulse     = zeros(1, final_length_pulse);
                final_pulse(1:length(current_pulse)) = current_pulse;
                final_pulse     = final_pulse * symbols(current_symbol); 
                data_wfm_out    = obj.AddVectorCirc(data_wfm_out, final_pulse, start_sample);       
            end
        end

%**************************************************************************

        function [  data_wfm_out,...
                    sample_rate_out] = GetSerialClkWfm(     obj,...
                                                            num_of_symbols,...
                                                            clk_div,...
                                                            pulse_setup)
            
            clk_tics                = zeros(1, num_of_symbols);
            clk_tics(1:clk_div:end) = 1.0;

            res_mult        = 1.0 / (pulse_setup.sampling_rate * pulse_setup.timing_res);
            res_mult        = round(res_mult);
            % Waveform length in time
            wfm_length      = pulse_setup.pulse_width * num_of_symbols;
            % Waveform length in samples
            wfm_length      = wfm_length * pulse_setup.sampling_rate;
            % Adjust sample rate to keep baud rate
            sample_rate_out = pulse_setup.sampling_rate * floor(wfm_length) / wfm_length;
            wfm_length      = floor(wfm_length);
            data_wfm_out    = zeros(1, wfm_length);

            % Get Isolated Pulse
            isolated_pulse = obj.GetTrapezoidalPulse(   pulse_setup.pulse_width * (clk_div / 2), ...
                                                        pulse_setup.edge_shape, ...
                                                        pulse_setup.rise_time,...
                                                        res_mult * sample_rate_out, ...                                                    
                                                        1, ...
                                                        1, ...
                                                        pulse_setup.quality);

            isolated_pulse = [zeros(1,res_mult), isolated_pulse, zeros(1,res_mult)];
            final_length_pulse = ceil(length(isolated_pulse) / res_mult);

            for current_tick = 1:num_of_symbols
                if clk_tics(current_tick) == 1
                    bit_sample      = (current_tick - 1) * pulse_setup.pulse_width;
                    bit_sample      = bit_sample * sample_rate_out;
                    start_sample    = round(bit_sample);
                    bit_sample      = bit_sample - start_sample;
                    bit_sample      = round(bit_sample * res_mult);
                    start_sample    = start_sample + 1;    
                    current_pulse   = isolated_pulse((res_mult - bit_sample):res_mult:end);
                    final_pulse     = zeros(1, final_length_pulse);
                    final_pulse(1:length(current_pulse)) = current_pulse;
                    data_wfm_out    = obj.AddVectorCirc(data_wfm_out, final_pulse, start_sample);
                end
            end
        end

%**************************************************************************

        function [  jitter_profile,...
                    actual_freq,...
                    actual_ssc_freq] = GetJitterProfile(    obj,...
                                                            num_of_samples,...
                                                            pulse_setup)
            actual_freq = double.empty;
            actual_ssc_freq = 0.0;
            jitter_profile = zeros(1, num_of_samples);
            x_values = 1:num_of_samples;
            x_values = x_values - 1;
            time_window = num_of_samples / pulse_setup.sampling_rate;

            if pulse_setup.jit_unit == obj.PULSE_JITTER_UNIT_UI
                pulse_setup.jit_sine_ampl = pulse_setup.jit_sine_ampl * pulse_setup.pulse_width;
                pulse_setup.jit_rnd_ampl = pulse_setup.jit_rnd_ampl * pulse_setup.pulse_width;
                pulse_setup.jit_mtone_ampl = pulse_setup.jit_mtone_ampl * pulse_setup.pulse_width;
            end
            % SSC Injection
            % *************
            if pulse_setup.jit_enable(obj.PULSE_JITTER_CAT_SSC)
                num_of_cycles = round(time_window * pulse_setup.jit_ssc_freq);
                actual_ssc_freq = num_of_cycles / time_window;
                jitter_profile = 0:(num_of_samples - 1);

                t_period = num_of_samples / num_of_cycles;
                jitter_profile = mod(jitter_profile,t_period);
                % Trangular frequency profile
                for sample = 1:num_of_samples
                    if jitter_profile(sample) > (t_period / 4) && jitter_profile(sample) <= (t_period * 3 / 4)
                        jitter_profile(sample) = t_period / 2 - jitter_profile(sample); 
                    elseif jitter_profile(sample) > (t_period * 3 / 4)
                        jitter_profile(sample) = - t_period + jitter_profile(sample);
                    end
                end
                % Accurate Period Profile
                jitter_profile = 0.5 * jitter_profile / max(jitter_profile);
                jitter_profile = (1.0 / pulse_setup.pulse_width) * (1 + (pulse_setup.jit_ssc_dev / 1E6) * jitter_profile);                
                jitter_profile = 1.0 ./ jitter_profile;                
                jitter_profile = jitter_profile - pulse_setup.pulse_width;                
                
                % Integration to obtain TIE profile
                jitter_profile = cumsum(jitter_profile - mean(jitter_profile));
                % Normalization
                jitter_profile = jitter_profile * (1.0 / pulse_setup.pulse_width) / pulse_setup.sampling_rate;               
            end
            % Sinusoidal jitter injection
            % ***************************
            if  pulse_setup.jit_enable(obj.PULSE_JITTER_CAT_SINE) ||...
                pulse_setup.jit_enable(obj.PULSE_JITTER_CAT_MTONE)        

                if  pulse_setup.jit_enable(obj.PULSE_JITTER_CAT_MTONE)          
                    num_of_components           = pulse_setup.jit_mtone_tones;
                    mtone.num_of_tones          = num_of_components;
                    pulse_setup.jit_sine_freq   = zeros(1, num_of_components);
                    % Phase distribution for minimum peak jitter
                    mtone.phase_distr           = obj.MTONE_PHASE_NEWMAN;
                    pulse_setup.jit_sine_phase  = obj.MtonePhaseDistr(mtone);
                    pulse_setup.jit_sine_phase  = 180.0 * pulse_setup.jit_sine_phase / pi;  % Phase in sexagesimal degrees    
                    pulse_setup.jit_sine_ampl   = pulse_setup.jit_mtone_ampl;

                    for current_tone = 1:num_of_components
                        pulse_setup.jit_sine_freq(current_tone) = current_tone * pulse_setup.jit_mtone_space;                        
                    end
                end

                num_of_components = length(pulse_setup.jit_sine_freq);
                actual_freq = zeros(1, num_of_components);
                % Get minimum frequency settings
                min_freq = min(pulse_setup.jit_sine_freq);
                min_num_of_cycles = round(time_window * min_freq);
                for component = 1:num_of_components
                    num_of_cycles = round(min_num_of_cycles * pulse_setup.jit_sine_freq(component) / min_freq);
                    actual_freq(component) = num_of_cycles / time_window;
                    jitter_profile = jitter_profile +...
                        obj.GetActualElement(pulse_setup.jit_sine_ampl, component) *...
                        sin(pi * (2 * x_values * num_of_cycles / num_of_samples +...
                        obj.GetActualElement(pulse_setup.jit_sine_phase,component)/180.0));
                end    
            end
            % Random (Gaussian) Jitter Injection
            % **********************************
            if pulse_setup.jit_enable(obj.PULSE_JITTER_CAT_RAND)
                jitter_profile = jitter_profile + ...
                    pulse_setup.jit_rnd_ampl *...
                    obj.GetAwgnWfm( pulse_setup.jit_rnd_freq,...
                                    num_of_samples,...
                                    pulse_setup.sampling_rate);
            end           

            jitter_profile = jitter_profile * pulse_setup.sampling_rate;
        end

%**************************************************************************

        function jitter_wfm = ApplyJitterProfile(   obj,...
                                                    input_wfm,...
                                                    jitter_profile)
            jitter_wfm = zeros(1, length(input_wfm));

            for current_sample = 0:(length(input_wfm) - 1)
                jittered_sample = jitter_profile(current_sample + 1);
                t_offset = jittered_sample - floor(jittered_sample);
                jittered_sample = floor(jittered_sample);
                jittered_sample = current_sample + jittered_sample;
                start_sample = mod(jittered_sample, length(input_wfm));
                stop_sample = start_sample + 1;
                stop_sample = mod(stop_sample, length(input_wfm));
                start_sample = start_sample + 1;
                stop_sample = stop_sample + 1;
                jitter_wfm(int32(current_sample + 1)) = input_wfm(int32(start_sample)) *(1 - t_offset) + input_wfm(int32(stop_sample)) * t_offset; 
            end
        end

%**************************************************************************

        function [  jitter_wfm,...
                    actual_freq,...
                    actual_ssc_freq] = GetAndApplyJitter(   obj,...
                                                            input_wfm,...
                                                            pulse_setup)
            if  pulse_setup.jit_enable(obj.PULSE_JITTER_CAT_RAND) ||...
                pulse_setup.jit_enable(obj.PULSE_JITTER_CAT_SINE) ||...
                pulse_setup.jit_enable(obj.PULSE_JITTER_CAT_SSC) ||...
                pulse_setup.jit_enable(obj.PULSE_JITTER_CAT_MTONE)
                
                [   jitter_profile,...
                    actual_freq,...
                    actual_ssc_freq]    = obj.GetJitterProfile(     length(input_wfm),...
                                                                    pulse_setup);
                jitter_wfm              = obj.ApplyJitterProfile(   input_wfm,...
                                                                    jitter_profile); 
            else
                jitter_wfm  = input_wfm;
                actual_freq     = double.empty;
                actual_ssc_freq = double.empty;
            end
        end

%**************************************************************************

        function data_out = GetAwgnWfm( obj,...
                                        awgn_bw,...
                                        wfm_length,...
                                        sample_rate)

            time_window         =  wfm_length / sample_rate;
            noise_wfm_length    = round(2 * awgn_bw * time_window);
            data_out            = zeros(1, noise_wfm_length);
            data_out            = awgn(data_out, 0.0);
            data_out            = obj.ResamplingDirect(data_out, wfm_length, true);
        end

%**************************************************************************

        function data_out = GetRandomData(  obj,...
                                            num_of_symbols, ...
                                            bits_per_symbol)
            rng("default");
            max_val                         = 2 ^ bits_per_symbol;
            data_out                        = max_val * rand(1, num_of_symbols);
            data_out                        = floor(data_out);
            data_out(data_out >= max_val)   = max_val - 1;    
        end

%**************************************************************************

        function data_out = GetHadamardCode(obj, k, n, samples_per_symbol)

            if ~exist('samples_per_symbol','var')
              samples_per_symbol = 1;
            end

            h(1,1) = 1;
            
            while length(h) < k
                h = [h, h; h, -h];           
            end  
            
            n(n>k) = k;
            n(n<1) = 1;
            data_out = repelem(h(n, :), 1, samples_per_symbol);         
        end

%**************************************************************************

        function [data_out, lfsr] = GetPrbsData(    obj,...
                                                    polynomial,...
                                                    seed,...
                                                    num_of_bits)
            polynomial  = uint8(polynomial);
            seed        = uint8(seed);
            order       = length(polynomial) - 1;
            lfsr        = uint8(zeros(1,order));     

            if length(seed) >= order
                lfsr = seed(1:order);
            else
                lfsr(1:length(seed)) = seed;
            end

            data_out = uint8(zeros(1,num_of_bits));

            
            for current_bit = 1:num_of_bits
                data_out(current_bit) = lfsr(1);
                next_bit = lfsr(1);
                for current_lfsr_bit = 2:order
                    if polynomial(current_lfsr_bit) == 1
                        next_bit = xor(next_bit, lfsr(current_lfsr_bit));
                    end
                end
                lfsr        = circshift(lfsr, - 1);
                lfsr(order) = next_bit;
            end  
        end

%**************************************************************************

        function [data_out, lfsr] = GetStdPrbsData( obj,...
                                                    prbs_seq,...
                                                    seed,...
                                                    num_of_bits)
            if prbs_seq == obj.PRBS_RND
                data_out = obj.GetRandomData(   num_of_bits, ...
                                                1);
            else            
                polynomial          = obj.GetPrbsPolynomial(prbs_seq);    
                [data_out, lfsr]    = obj.GetPrbsData(  polynomial,...
                                                        seed,...
                                                        num_of_bits); 
            end
        end

%**************************************************************************

        function polynomial = GetPrbsPolynomial(obj, prbs_seq)

            % X^0, X^1,....X^N
        
            polynomial = [1,0,0,0,0,0,1,1];
        
            switch prbs_seq
                case obj.PRBS_2
                    polynomial = [1,1,1];
        
                case obj.PRBS_3 
                    polynomial = [1,0,1,1];
        
                case obj.PRBS_4 
                    polynomial = [1,0,0,1,1];
        
                case obj.PRBS_5   
                    polynomial = [1,0,0,1,0,1];
        
                case obj.PRBS_6 
                    polynomial = [1,0,0,0,0,1,1];
        
                case obj.PRBS_7
                    polynomial = [1,0,0,0,0,0,1,1];
        
                case obj.PRBS_8 
                    polynomial = [1,0,0,0,1,1,1,0,1];
        
                case obj.PRBS_9
                    polynomial = [1,0,0,0,0,1,0,0,0,1];
        
                case obj.PRBS_10
                    polynomial = [1,0,0,0,0,0,0,1,0,0,1];
                    
                case obj.PRBS_11
                    polynomial = [1,0,0,0,0,0,0,0,0,1,0,1];
                    
                case obj.PRBS_12
                    polynomial = [1,0,0,0,0,0,1,0,1,0,0,1,1];
                    
                case obj.PRBS_13
                    polynomial = [1,0,0,0,0,0,0,0,0,1,1,0,1,1];
                    
                case obj.PRBS_14
                    polynomial = [1,0,0,0,0,0,0,0,0,1,0,1,0,1,1];
                    
                case obj.PRBS_15
                    polynomial = [1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1];
                    
                case obj.PRBS_16
                    polynomial = [1,0,0,0,0,0,0,0,0,0,0,1,0,1,1,0,1];
                    
                case obj.PRBS_17
                    polynomial = [1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,1];
                    
                case obj.PRBS_18
                    polynomial = [1,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,1];
                    
                case obj.PRBS_19 
                    polynomial = [1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,1,1,1];
                    
                case obj.PRBS_20 
                    polynomial = [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,1];
                    
                case obj.PRBS_21   
                    polynomial = [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,1];
                    
                case obj.PRBS_22
                    polynomial = [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1];
                    
                case obj.PRBS_23
                    polynomial = [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,1];
                    
                case obj.PRBS_24
                    polynomial = [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,1,1];
                    
                case obj.PRBS_25
                    polynomial = [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,1];
                    
                case obj.PRBS_26 
                    polynomial = [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,1,1,1];
                    
                case obj.PRBS_27 
                    polynomial = [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,1,1,1];
                    
                case obj.PRBS_28
                    polynomial = [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,1];
                    
                case obj.PRBS_29  
                    polynomial = [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,1];
                    
                case obj.PRBS_30 
                    polynomial = [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,1,0,0,1,1];
                    
                case obj.PRBS_31 
                    polynomial = [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,1];
                    
                case obj.PRBS_32
                    polynomial = [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,1,0,1];
                    
                case obj.PRBS_33
                    polynomial = [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,1];
                    
                case obj.PRBS_34
                    polynomial = [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,1,1,0,0,1];
                    
                case obj.PRBS_35
                    polynomial = [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,1];
                    
                case obj.PRBS_36 
                    polynomial = [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,1];
                    
                case obj.PRBS_37
                    polynomial = [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,1,0,0,1,1];
                    
                case obj.PRBS_38
                    polynomial = [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,1,1];
                    
                case obj.PRBS_39
                    polynomial = [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,1];
                    
            end
        
            polynomial = uint8(polynomial);
            % X^N, X^(N-1),....X^0
            polynomial = flip(polynomial);
        end

%**************************************************************************

        function symbol = GetIqMap( obj,...
                                    data, ...
                                    mod_scheme)

            bits_per_symbol = obj.GetModParam(mod_scheme);

            switch mod_scheme

                case obj.MOD_SCHEME_QAM32
                    lev                 = 6;
                    data                = data + 1;
                    data(data > 4)      = data(data > 4) + 1;
                    data(data > 29)     = data(data > 29) + 1;

                case obj.MOD_SCHEME_QAM128
                    lev                 = 12;
                    data                = data + 2;
                    data(data > 9)      = data(data > 9) + 4;
                    data(data > 21)     = data(data > 21) + 2;
                    data(data > 119)    = data(data > 119) + 2;
                    data(data > 129)    = data(data > 129) + 4;

                case obj.MOD_SCHEME_QAM512
                    lev                 = 24;
                    data                = data + 4;
                    data(data > 19)     = data(data > 19) + 8;
                    data(data > 43)     = data(data > 43) + 8;
                    data(data > 67)     = data(data > 67) + 8;
                    data(data > 91)     = data(data > 91) + 4;
                    data(data > 479)    = data(data > 479) + 4;
                    data(data > 499)    = data(data > 499) + 8;
                    data(data > 523)    = data(data > 523) + 8;
                    data(data > 547)    = data(data > 547) + 8;

                otherwise
                    % QPSK, QAM16, QAM64, QAM256, QAM1024
                    lev                 = 2 ^ (bits_per_symbol / 2); 
            end

            symb_i  = floor(data / lev);
            symb_q  = mod(data, lev);
            lev     = lev / 2 - 0.5;   
            symb_i  = (symb_i - lev) / lev;
            symb_q  = (symb_q - lev) / lev;
            symbol  = symb_i + 1i * symb_q;
        end

%**************************************************************************

        function waveform = GetQamClock(    obj,...
                                            mod_settings, ...
                                            div_factor)    
    
            oversampling    = round(mod_settings.oversampling);
            div_factor      = round(div_factor);

            % out_wfm = WfmExpand(obj, wfm, expand_factor)
  
            % Get basic clock signal
            waveform            = zeros(1, mod_settings.num_of_symbols);
            waveform(1:2:end)   = +1.0;
            waveform(2:2:end)   = -1.0;
            waveform            = obj.WfmExpand(waveform, div_factor);            
            
            % Adapt I/Q sample rate to the Oversampling parameter
            waveform = obj.ZeroPadding(waveform, oversampling);
           
            % Calculate baseband shaping filter
            % accuracy is the length of-1 the shaping filter
            accuracy        = 512;
            baseband_filter = rcosdesign(   1.0, ...
                                            accuracy, ...
                                            mod_settings.oversampling, ...
                                            'normal');
        
            % Apply filter through circular convolution and calculate Fs
            waveform = cconv(waveform, baseband_filter, length(waveform));    
        end

%**************************************************************************

        function [waveform, Fs] = GetMultiTone( obj,...
                                                mtone_settings)

            % Compute maximum frequency component in the signal
            max_freq    = (mtone_settings.num_of_tones - 1) * mtone_settings.spacing / 2.0;
            max_freq    = max_freq + mtone_settings.spacing * mtone_settings.offset_tone;
            % Sample rate for calcualtion will be twice the maximum freq x
            % oversampling factor
            Fs          = mtone_settings.oversampling * 2.0 * max_freq;
            % Tone frequency calculation
            tone_freq   = 0:(mtone_settings.num_of_tones - 1);
            tone_freq   = tone_freq - (mtone_settings.num_of_tones - 1.0) / 2.0;
            tone_freq   = mtone_settings.spacing * tone_freq; 
            tone_freq   = tone_freq + mtone_settings.spacing * mtone_settings.offset_tone;
        
            % Time window will be the minimum one: 1 / spacing
            % It must be double when the number of tones is even for symmetrical
            % spectrum around carrier frequency.
            if mod(mtone_settings.num_of_tones,2) == 1
                time_window = 1.0 / mtone_settings.spacing;
            else
                time_window = 2.0 / mtone_settings.spacing;
            end

            time_window = time_window * mtone_settings.num_of_repeats;
        
            % Waveform length must be an integer
            wfm_length  = round(Fs * time_window);
            % Fs must be recalculated after rounding wavweform length
            Fs          = wfm_length / time_window;
            % Time values for samples
            x_data      = 0 :(wfm_length -1);
            x_data      = x_data / Fs;
            % Phase distribution for PAPR reduction is selected. Newman = 2.
            tones_phase = obj.MtonePhaseDistr(mtone_settings);
            % Waveform data is initialized to zero 
            waveform    = zeros(1, wfm_length);
            % The contribution of each tone is added to the waveform
            for k = 1 : mtone_settings.num_of_tones
                if k < mtone_settings.notch_start ||...
                        k > (mtone_settings.notch_start + mtone_settings.notch_size - 1)
                    waveform = waveform + ...
                        exp(1i * (x_data * 2 * pi * tone_freq(k) + tones_phase(k)));
                end
            end  
        end

%**************************************************************************

        function phase_table = MtonePhaseDistr(obj, mtone_settings)

            switch mtone_settings.phase_distr
                case obj.MTONE_PHASE_CONSTANT
                    phase_table = zeros(1, mtone_settings.num_of_tones);
                
                case obj.MTONE_PHASE_RANDOM
                    phase_table = 2.0 * pi .* (rand(1, mtone_settings.num_of_tones) - 0.5);
        
                case obj.MTONE_PHASE_NEWMAN
                    phase_table = 1:mtone_settings.num_of_tones;
                    phase_table = wrapToPi(-(pi / mtone_settings.num_of_tones) .* ...
                        ( 1.0 - phase_table .* phase_table));
        
                case obj.MTONE_PHASE_RUDIN
                    % Rudin (near optimal for equal amplitude tones when number of
                    % tones = 2^N)
                    num_of_steps = int16(round(log(mtone_settings.num_of_tones) / log(2)));
            
                    if 2^num_of_steps < mtone_settings.num_of_tones
                        num_of_steps = num_of_steps + 1;
                    end 
        
                    num_of_steps = num_of_steps - 1; 
                    phase_table(1:2) = 1; 
                    % Rudin sequence construction
                    for n=1:num_of_steps       
                        m           = int16(length(phase_table) / 2);
                        phase_table = [phase_table, phase_table(1 : m),...
                            -phase_table(m + 1 : 2 * m)];        
                    end 
                    % Conversion to radians
                    phase_table = -0.5 * pi .* (phase_table(1 : mtone_settings.num_of_tones) - 1);
            end
        end

%**************************************************************************

        function ddc_wfm = GetSwDdcWfm(obj, rf_wfm, mod_setup)

            ddc_wfm     = 1:length(rf_wfm);
            ddc_wfm     = ddc_wfm - 1;
            ddc_wfm     = ddc_wfm / mod_setup.sample_rate;
            % IQ carrier generation
            ddc_wfm     = exp(1i * 2 * pi * mod_setup.carrier_freq * ddc_wfm);
            % Mixing
            ddc_wfm     = ddc_wfm .* rf_wfm;

            out_length  = round(length(ddc_wfm) / mod_setup.decimation);

            ddc_wfm     = obj.ResamplingDirect( ddc_wfm, ...
                                                out_length, ...
                                                false); 
        end

%**************************************************************************
%**************************************************************************
% DEMODULATION FUNCTIONS
%**************************************************************************

        function [rxSig, sps] = QpskDemod(obj, fs, sRate, alfa, rxSig, symbolsToShow)    
            
            sps = 128;
            
            %rxSig = MyOldResampleWfm(rxSig, 5, fs, sps * sRate);
            rxSig = resample(rxSig,sps * sRate,fs);
          
            [rxFilter,...
                filterSpan]     = MyRxFilter(alfa);
            
            rxSig               = rxFilter(rxSig');
            
            rxSig               = rxSig((sps*filterSpan + 1):(length(rxSig) - sps*filterSpan));
            
            [delay, ampl]       = GetQpskSymbolDelay(rxSig, sps);
        
            rxSig               = sqrt(2.0) * rxSig / ampl;
            rxSig               = 2.0 * rxSig((delay + 1):end);
           
            [constPhase, evMin] = GetQpskPhase(sps, rxSig);   
          
            rxSig               = rxSig * exp(1i * constPhase * pi / 180.0);
            numOfSymbols        = floor(length(rxSig) / sps);
            numOfSymbols        = numOfSymbols - filterSpan;
            starS               = floor (numOfSymbols / 2 - symbolsToShow / 2);
            finalS              = starS + symbolsToShow;
            if starS < 0
                starS   = 0;
            end
            if finalS   >= numOfSymbols
                finalS  = numOfSymbols - 1;
            end
            
            starS   = starS*sps + 1; 
            finalS  = finalS*sps;   
            rxSig   = rxSig(starS:finalS);
        end

        function out_vector = AddVectorCirc(obj, vector_1, vector_2, start_sample)
            out_vector      = vector_1;
            start_sample    = start_sample - round(length(vector_2) / 2);
            out_idxs        = start_sample:(start_sample + length(vector_2) - 1);
            out_idxs        = mod(out_idxs - 1, length(vector_1)) + 1;

            out_vector...
                (out_idxs)  = vector_1(out_idxs) + vector_2;
        end

    end % public methods
    
%**************************************************************************
%**************************************************************************

    methods (Access = private) % private methods

       
    end % private methods
end