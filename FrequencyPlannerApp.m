classdef FrequencyPlannerApp < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure      matlab.ui.Figure
        GridLayout    matlab.ui.container.GridLayout
        LeftPanel     matlab.ui.container.Panel
        RightPanel    matlab.ui.container.Panel
        
        % Input Components
        SignalCenterLabel matlab.ui.control.Label
        SignalCenterEdit  matlab.ui.control.NumericEditField
        SignalBWLabel     matlab.ui.control.Label
        SignalBWEdit      matlab.ui.control.NumericEditField
        SidebandLabel     matlab.ui.control.Label
        SidebandDropDown  matlab.ui.control.DropDown
        DACADCRatioLabel  matlab.ui.control.Label
        DACADCRatioEdit   matlab.ui.control.NumericEditField
        ILFactorLabel     matlab.ui.control.Label
        ILFactorEdit      matlab.ui.control.NumericEditField
        ADCRateSliderLabel matlab.ui.control.Label
        ADCRateSlider     matlab.ui.control.Slider
        ADCRateValueLabel matlab.ui.control.Label
        
        % Button
        AnalyzeButton   matlab.ui.control.Button
        
        % Output Components
        DACRateLabel      matlab.ui.control.Label
        DACRateValue      matlab.ui.control.Label
        DDCNCOLabel       matlab.ui.control.Label
        DDCNCOValue       matlab.ui.control.Label
        OverlapStatusLabel matlab.ui.control.Label
        OverlapStatusValue matlab.ui.control.Label
        
        % Plot
        FrequencyPlotAxes matlab.ui.control.UIAxes
    end

    
    % App Code
    methods (Access = private)

        % --- Component Creation ---
        function createComponents(app)
            app.UIFigure = uifigure('Visible', 'off', 'Position', [100, 100, 900, 600], 'Name', 'Frequency Planner');
            % app.GridLayout = uigridlayout(app.UIFigure, {250, '1x'}, {'1x'});
            app.GridLayout = uigridlayout(app.UIFigure, [1, 2]);
            app.GridLayout.ColumnWidth = {250, '1x'};
            app.GridLayout.RowHeight = {'1x'};
            % app.LeftPanel = uipanel(app.GridLayout, 'Layout', struct('Row',1,'Column',1));
            % app.RightPanel = uipanel(app.GridLayout, 'Layout', struct('Row',1,'Column',2));

            % Create Left Panel and assign to grid position
            app.LeftPanel = uipanel(app.GridLayout);
            app.LeftPanel.Layout.Row = 1;
            app.LeftPanel.Layout.Column = 1;
            
            % Create Right Panel and assign to grid position
            app.RightPanel = uipanel(app.GridLayout);
            app.RightPanel.Layout.Row = 1;
            app.RightPanel.Layout.Column = 2;


            leftGridLayout = uigridlayout(app.LeftPanel, [14, 2]);
            % leftGridLayout.RowHeight = [22, 22, 22, 22, 22, 22, 22, 40, 22, 22, 22, 22, '1x'];
            leftGridLayout.RowHeight = {22, 22, 22, 22, 22, 22, 22, 40, 22, 22, 22, 22, '1x'};
            
            % % uilabel(leftGridLayout, 'Text', 'Signal Center (MHz)', 'Layout', struct('Row',1,'Column',1));
            lbl = uilabel(leftGridLayout, 'Text', 'Signal Center (MHz)');
            lbl.Layout.Row = 1;
            lbl.Layout.Column = 1;

            % app.SignalCenterEdit = uieditfield(leftGridLayout, 'numeric', 'Value', 5150, 'Layout', struct('Row',1,'Column',2));
            app.SignalCenterEdit = uieditfield(leftGridLayout, 'numeric', 'Value', 5150);
            app.SignalCenterEdit.Layout.Row = 1;
            app.SignalCenterEdit.Layout.Column = 2;

            % uilabel(leftGridLayout, 'Text', 'Signal BW (MHz)', 'Layout', struct('Row',2,'Column',1));
            % app.SignalBWEdit = uieditfield(leftGridLayout, 'numeric', 'Value', 240, 'Layout', struct('Row',2,'Column',2));
            
            lblSignalBW = uilabel(leftGridLayout, 'Text', 'Signal BW (MHz)');
            lblSignalBW.Layout.Row = 2;
            lblSignalBW.Layout.Column = 1;
            
            app.SignalBWEdit = uieditfield(leftGridLayout, 'numeric', 'Value', 240);
            app.SignalBWEdit.Layout.Row = 2;
            app.SignalBWEdit.Layout.Column = 2;

            % uilabel(leftGridLayout, 'Text', 'Sideband', 'Layout', struct('Row',3,'Column',1));
           
            lblSideband = uilabel(leftGridLayout, 'Text', 'Sideband');
            lblSideband.Layout.Row = 3;
            lblSideband.Layout.Column = 1;
            
            % app.SidebandDropDown = uidropdown(leftGridLayout, 'Items', {'UPPER', 'LOWER'}, 'Layout', struct('Row',3,'Column',2));
            
            app.SidebandDropDown = uidropdown(leftGridLayout, 'Items', {'UPPER', 'LOWER'});
            app.SidebandDropDown.Layout.Row = 3;
            app.SidebandDropDown.Layout.Column = 2;

            % uilabel(leftGridLayout, 'Text', 'DAC/ADC Ratio', 'Layout', struct('Row',4,'Column',1));
            
            lblDACADCRatio = uilabel(leftGridLayout, 'Text', 'DAC/ADC Ratio');
            lblDACADCRatio.Layout.Row = 4;
            lblDACADCRatio.Layout.Column = 1;
            
            % app.DACADCRatioEdit = uieditfield(leftGridLayout, 'numeric', 'Value', 2, 'Layout', struct('Row',4,'Column',2));

            app.DACADCRatioEdit = uieditfield(leftGridLayout, 'numeric', 'Value', 2);
            app.DACADCRatioEdit.Layout.Row = 4;
            app.DACADCRatioEdit.Layout.Column = 2;

            % uilabel(leftGridLayout, 'Text', 'Interleaving Factor', 'Layout', struct('Row',5,'Column',1));
            
            lblILFactor = uilabel(leftGridLayout, 'Text', 'Interleaving Factor');
            lblILFactor.Layout.Row = 5;
            lblILFactor.Layout.Column = 1;
            
            % app.ILFactorEdit = uieditfield(leftGridLayout, 'numeric', 'Value', 4, 'Layout', struct('Row',5,'Column',2));

            app.ILFactorEdit = uieditfield(leftGridLayout, 'numeric', 'Value', 4);
            app.ILFactorEdit.Layout.Row = 5;
            app.ILFactorEdit.Layout.Column = 2;

            % app.ADCRateSliderLabel = uilabel(leftGridLayout, 'Text', 'ADC Sampling Rate', 'Layout', struct('Row',6,'Column',1));

            app.ADCRateSliderLabel = uilabel(leftGridLayout, 'Text', 'ADC Sampling Rate');
            app.ADCRateSliderLabel.Layout.Row = 6;
            app.ADCRateSliderLabel.Layout.Column = 1;
        
            % app.ADCRateSlider = uislider(leftGridLayout, 'Limits', [800, 2700], 'Value', 2354, 'Layout', struct('Row',7,'Column',1, 'ColumnSpan', 2));

            app.ADCRateSlider = uislider(leftGridLayout, 'Limits', [800, 2700], 'Value', 2354);
            app.ADCRateSlider.Layout.Row = 7;
            app.ADCRateSlider.Layout.Column = 1;
            % app.ADCRateSlider.Layout.ColumnSpan = 2;

            leftGridLayout.ColumnWidth = {'2x', '1x'};

            % app.ADCRateValueLabel = uilabel(leftGridLayout, 'Text', '2354.00 MSa/s', 'HorizontalAlignment', 'center', 'Layout', struct('Row',6,'Column',2));
            app.ADCRateValueLabel = uilabel(leftGridLayout, 'Text', '2354.00 MSa/s', 'HorizontalAlignment', 'center');
            app.ADCRateValueLabel.Layout.Row = 6;
            app.ADCRateValueLabel.Layout.Column = 2;
            
            % app.AnalyzeButton = uibutton(leftGridLayout, 'push', 'Text', 'Analyze Frequency Plan', 'Layout', struct('Row',8,'Column',1,'ColumnSpan',2));

            app.AnalyzeButton = uibutton(leftGridLayout, 'push', 'Text', 'Analyze Frequency Plan');
            app.AnalyzeButton.Layout.Row = 8;
            app.AnalyzeButton.Layout.Column = 1;
            
            % uilabel(leftGridLayout, 'Text', 'DAC Rate (Msps):', 'Layout', struct('Row',9,'Column',1));
            
            lblDACRate = uilabel(leftGridLayout, 'Text', 'DAC Rate (Msps):');
            lblDACRate.Layout.Row = 9;
            lblDACRate.Layout.Column = 1;

            % app.DACRateValue = uilabel(leftGridLayout, 'Text', '', 'Layout', struct('Row',9,'Column',2));

            app.DACRateValue = uilabel(leftGridLayout, 'Text', '');
            app.DACRateValue.Layout.Row = 9;
            app.DACRateValue.Layout.Column = 2;

            % uilabel(leftGridLayout, 'Text', 'DDC NCO (MHz):', 'Layout', struct('Row',10,'Column',1));

            lblDDCNCO = uilabel(leftGridLayout, 'Text', 'DDC NCO (MHz):');
            lblDDCNCO.Layout.Row = 10;
            lblDDCNCO.Layout.Column = 1;

            % app.DDCNCOValue = uilabel(leftGridLayout, 'Text', '', 'Layout', struct('Row',10,'Column',2));
            
            app.DDCNCOValue = uilabel(leftGridLayout, 'Text', '');
            app.DDCNCOValue.Layout.Row = 10;
            app.DDCNCOValue.Layout.Column = 2;


            % uilabel(leftGridLayout, 'Text', 'Overlap Status:', 'Layout', struct('Row',11,'Column',1));

            lblOverlapStatus = uilabel(leftGridLayout, 'Text', 'Overlap Status:');
            lblOverlapStatus.Layout.Row = 11;
            lblOverlapStatus.Layout.Column = 1;

            % app.OverlapStatusValue = uilabel(leftGridLayout, 'Text', '', 'FontWeight', 'bold', 'Layout', struct('Row',11,'Column',2));

            app.OverlapStatusValue = uilabel(leftGridLayout, 'Text', '', 'FontWeight', 'bold');
            app.OverlapStatusValue.Layout.Row = 11;
            app.OverlapStatusValue.Layout.Column = 2;

            % rightGridLayout = uigridlayout(app.RightPanel, {'1x'}, {'1x'});
            rightGridLayout.RowHeight = {'1x'};
            rightGridLayout.ColumnWidth = {'1x'};
            
            % app.FrequencyPlotAxes = uiaxes(rightGridLayout);
            app.FrequencyPlotAxes = uiaxes(app.RightPanel);

            title(app.FrequencyPlotAxes, 'Frequency Plan');
            xlabel(app.FrequencyPlotAxes, 'Frequency (Hz)');
            
            app.UIFigure.Visible = 'on';
        end

        % --- Callbacks ---
        function onADCRateSliderValueChanged(app, event)
            rate = app.ADCRateSlider.Value;
            app.ADCRateValueLabel.Text = sprintf('%.2f MSa/s', rate);
        end

        function onAnalyzeButtonPushed(app, event)
            signal_center = app.SignalCenterEdit.Value * 1e6;
            signal_bw = app.SignalBWEdit.Value * 1e6;
            sideband = app.SidebandDropDown.Value; 
            dac_adc_ratio = app.DACADCRatioEdit.Value;
            il_factor = app.ILFactorEdit.Value;
            adc_rate = app.ADCRateSlider.Value * 1e6;
            
            

            d = uiprogressdlg(app.UIFigure, 'Title', 'Analyzing...', 'Indeterminate', 'on');
            plan_details = app.analyze_frequency_plan(signal_center, signal_bw, sideband, dac_adc_ratio, il_factor, adc_rate);
            close(d);
            
            app.DACRateValue.Text = sprintf('%.2f MSa/s', plan_details.dac_sampling_rate / 1e6);
            app.DDCNCOValue.Text = sprintf('%.2f MHz', plan_details.ddc_nco / 1e6);
            app.OverlapStatusValue.Text = plan_details.status;
            if strcmp(plan_details.status, 'OK')
                app.OverlapStatusValue.FontColor = [0, 0.7, 0];
            else
                app.OverlapStatusValue.FontColor = [1, 0, 0];
            end
            app.plot_frequency_plan(app.FrequencyPlotAxes, plan_details);
        end
        
        % --- Calculation and Plotting Methods ---
        function [plan_details] = analyze_frequency_plan(app, signal_center, signal_bw, sideband, dac_adc_ratio, il_factor, adc_rate)
            dac_rate = adc_rate * dac_adc_ratio;
            [status, interferers] = app.check_frequency_overlap(signal_center, signal_bw, adc_rate, dac_rate, il_factor);
            plan_details = struct('adc_sampling_rate', adc_rate, 'dac_sampling_rate', dac_rate, 'interferers', interferers, 'status', status);
            if signal_center < (adc_rate * 0.5)
                ddc_nco = signal_center;
            else
                if strcmpi(sideband, 'UPPER'), ddc_nco = signal_center - dac_rate; else, ddc_nco = dac_rate - signal_center; end
            end
            plan_details.ddc_nco = abs(ddc_nco);
        end
        
        function [status, interferers] = check_frequency_overlap(app, signal_center, signal_bw, adc_rate, dac_rate, il_factor)
            [signal_min_aliased, signal_max_aliased] = app.alias_band(signal_center, signal_bw, adc_rate);
            interferers = struct('signal_aliased', [signal_min_aliased, signal_max_aliased]);
            [interferers.hd2(1), interferers.hd2(2)] = app.alias_band(2*signal_center, 2*signal_bw, adc_rate);
            [interferers.hd3(1), interferers.hd3(2)] = app.alias_band(3*signal_center, 3*signal_bw, adc_rate);
            [interferers.hd4(1), interferers.hd4(2)] = app.alias_band(4*signal_center, 4*signal_bw, adc_rate);
            [interferers.hd5(1), interferers.hd5(2)] = app.alias_band(5*signal_center, 5*signal_bw, adc_rate);
            [interferers.image(1), interferers.image(2)] = app.alias_band(dac_rate - signal_center, signal_bw, adc_rate);
            il_spurs = [];
            for k = 1:(il_factor-1)
                spur_freq = k * adc_rate / il_factor;
                il_spurs(k) = min(mod(spur_freq, adc_rate), adc_rate - mod(spur_freq, adc_rate));
            end
            interferers.il_spurs = il_spurs;
            if app.check_band_overlap(interferers.signal_aliased, interferers.hd2), status = 'HD2'; return; end
            if app.check_band_overlap(interferers.signal_aliased, interferers.hd3), status = 'HD3'; return; end
            if app.check_band_overlap(interferers.signal_aliased, interferers.hd4), status = 'HD4'; return; end
            if app.check_band_overlap(interferers.signal_aliased, interferers.hd5), status = 'HD5'; return; end
            if app.check_band_overlap(interferers.signal_aliased, interferers.image), status = 'Image'; return; end
            for i=1:length(il_spurs), if app.check_freq_in_band(il_spurs(i), interferers.signal_aliased), status=sprintf('IL%d',i);return; end, end
            status = 'OK';
        end
        
        function [f_min_aliased, f_max_aliased] = alias_band(app, f_center, f_bw, fs)
            f_min = f_center - f_bw / 2;
            f_max = f_center + f_bw / 2;
            points_to_check = [f_min, f_max];
            aliased_points = zeros(size(points_to_check));
            for i = 1:length(points_to_check)
                f = points_to_check(i);
                f_folded = mod(f, fs);
                aliased_points(i) = min(f_folded, fs - f_folded);
            end
            f_min_aliased = min(aliased_points);
            f_max_aliased = max(aliased_points);
            if f_bw > fs/2, f_min_aliased = 0; f_max_aliased = fs/2; end
        end

        function overlaps = check_band_overlap(app, b1, b2), overlaps = (b1(1)<=b2(2))&&(b2(1)<=b1(2)); end
        function overlaps = check_freq_in_band(app, f, b), overlaps = (f>=b(1)-1e3)&&(f<=b(2)+1e3); end

        function plot_frequency_plan(app, ax, plan_details)
            if isempty(plan_details), return; end
            cla(ax); hold(ax, 'on');
            adc_rate=plan_details.adc_sampling_rate; nyquist_freq=adc_rate/2;
            
            y_level = 10;
            h_signal = app.plot_band(ax, plan_details.interferers.signal_aliased, y_level, 'Signal', 'g'); y_level = y_level - 1;
            h_hd2 = app.plot_band(ax, plan_details.interferers.hd2, y_level, 'HD2', [1 .5 .5]); y_level = y_level - 1;
            app.plot_band(ax, plan_details.interferers.hd3, y_level, 'HD3', [1 .5 .5]); y_level = y_level - 1;
            app.plot_band(ax, plan_details.interferers.hd4, y_level, 'HD4', [1 .5 .5]); y_level = y_level - 1;
            app.plot_band(ax, plan_details.interferers.hd5, y_level, 'HD5', [1 .5 .5]); y_level = y_level - 1;
            h_image = app.plot_band(ax, plan_details.interferers.image, y_level, 'Image', 'm'); y_level = y_level - 1;
            
            h_il=[];
            for i=1:length(plan_details.interferers.il_spurs)
                h_temp = app.plot_spur(ax, plan_details.interferers.il_spurs(i), y_level, sprintf('IL%d', i), 'c');
                if ~isempty(h_temp) && isempty(h_il), h_il = h_temp; end
            end
            
            hold(ax, 'off'); xlim(ax, [0, nyquist_freq]); ylim(ax, [0, 11]); xlabel(ax, 'Frequency (Hz)');
            ax.YTick = []; title(ax, sprintf('Frequency Plan (ADC Rate = %g Msps)', adc_rate / 1e6)); grid(ax, 'on');
            
            % lh=[];ll={};
            % if ~isempty(h_signal), lh(end+1)=h_signal; ll{end+1}='Signal'; end
            % if ~isempty(h_hd2), lh(end+1)=h_hd2; ll{end+1}='Harmonics'; end
            % if ~isempty(h_image), lh(end+1)=h_image; ll{end+1}='Image'; end
            % if ~isempty(h_il), lh(end+1)=h_il; ll{end+1}='IL Spurs'; end
            % if ~isempty(lh), legend(ax, lh, ll, 'Location', 'northeast'); end

            % Helper function to check if handle is valid
            % isValidHandle = @(h) ~isempty(h) && all(ishandle(h));
            % 
            % lh = [];
            % ll = {};
            % 
            % if isValidHandle(h_signal), lh(end+1) = h_signal; ll{end+1} = 'Signal'; end
            % if isValidHandle(h_hd2), lh(end+1) = h_hd2; ll{end+1} = 'Harmonics'; end
            % if isValidHandle(h_image), lh(end+1) = h_image; ll{end+1} = 'Image'; end
            % if isValidHandle(h_il), lh(end+1) = h_il; ll{end+1} = 'IL Spurs'; end
            % if ~isempty(lh)
            %     legend(ax, lh, ll, 'Location', 'northeast');
            % end
        end
        
        function h = plot_band(app, ax, band, y_pos, label, color)
            nyquist_freq = app.ADCRateSlider.Value * 1e6 / 2;
            h=[];
            if ~isempty(band) && band(2) > band(1)
                h = rectangle(ax, 'Position', [band(1), y_pos - 0.4, band(2) - band(1), 0.8], 'FaceColor', color, 'EdgeColor', 'k');
                text(ax, band(1) - 0.02*nyquist_freq, y_pos, label, 'VerticalAlignment', 'middle', 'HorizontalAlignment', 'right', 'FontSize', 8);
            end
        end

        function h = plot_spur(app, ax, spur_freq, y_pos, label, color)
            h=[];
            if ~isempty(spur_freq)
                h = line(ax, [spur_freq, spur_freq], [y_pos - 0.5, y_pos + 0.5], 'Color', color, 'LineWidth', 2);
                text(ax, spur_freq, y_pos + 0.6, label, 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center', 'FontSize', 8, 'Color', color);
            end
        end
    end
    
    methods (Access = public) % App creation and deletion
        function app = FrequencyPlannerApp()
            createComponents(app)
            app.AnalyzeButton.ButtonPushedFcn = createCallbackFcn(app, @onAnalyzeButtonPushed, true);
            app.ADCRateSlider.ValueChangedFcn = createCallbackFcn(app, @onADCRateSliderValueChanged, true);
            if nargout == 0, clear app, end
        end
        function delete(app), delete(app.UIFigure), end
    end
end
