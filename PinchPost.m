clc;clear;
startyear = 0; % Define the starting value for the time difference
increment = 5; % Define the increment for the time difference
endyear = 15; % Define the ending value for the time difference
fprintf('Time Difference\tCapturable CO2\tAlt Storage\tUnutilized Storage\tPinch Year\n');
fprintf('--------\t-----------\t-----------\t-------------------\t----------\n');
figure;
hold on;
xlabel('Cumulative CO₂ Load (Mt)')
ylabel('Year')
title('Cascade Table Comparison with Time Differences')
grid on;
for time_difference_scalar = startyear:increment:endyear
% Source Data (in Mt/y)
source_flowrate = [15, 5, 5, 20, 10]; % CO2 flowrate from sources in Mt/y
source_total_load = [300, 150, 150, 400, 400]; % Total CO2 load from sources in Mt
source_start_time = [0, 0, 0, 20, 30]; % Start time of sources in years
source_end_time = [20, 30, 30, 40, 70]; % End time of sources in years

% Sink Data
sink_injectivity = [20, 15, 10]; % CO2 injectivity into sinks in Mt/y
sink_storage_capacity = [900, 750, 550]; % Storage capacity of sinks in Mt
sink_earliest_time = [10, 20, 30]; % Earliest time sink is available in years
sink_end_time = [55, 70, 85]; % Characteristic end time of sinks in years

% Initialization
% Inputting time difference
time_difference=ones(1,length(sink_injectivity))*time_difference_scalar;
% Time shift in sink
sink_earliest_time=sink_earliest_time+time_difference;
sink_end_time=sink_end_time+time_difference;
% Creating cascade table
year=unique(sort([source_start_time(1,:),source_end_time(1,:),sink_earliest_time(1,:),sink_end_time(1,:)]));
num_year=length(year);
num_sources = length(source_flowrate);
num_sinks = length(sink_injectivity);
net_source=zeros(num_year,1);
net_sink=zeros(num_year,1);
net_flowrate=zeros(num_year,1);
dt=zeros(num_year,1);
infeasible=zeros(num_year,1);
feasible=zeros(num_year,1);
load=zeros(num_year,1);
sink_load=zeros(num_year,1);
source_load=zeros(num_year,1);

% Cascade calculation
for i = 1:num_year-1
    % Calculate net flow and load per time range
    current_time=year(i);
    dt(i)=year(i+1)-year(i);
    for j=1:num_sources
        if source_start_time(j)<=current_time && source_end_time(j)>current_time
        sourcetotal=source_flowrate(j);
            else
             sourcetotal=0;
        end
    net_source(i)=net_source(i)+sourcetotal;
    end
    for k=1:num_sinks
        if sink_earliest_time(k)<=current_time && sink_end_time(k)>current_time
            sinktotal=sink_injectivity(k);
        else
            sinktotal=0;
        end
        net_sink(i)=net_sink(i)+sinktotal;
    end
    net_flowrate=net_sink-net_source;
    load=net_flowrate.*dt;
    infeasible(i+1)=infeasible(i)+load(i);
    feasible(1)=min(infeasible)*-1;
    source_load(i+1)=source_load(i)+net_source(i).*dt(i);
    sink_load(2)=feasible(1);
    for l=1:num_year-2
    sink_load(l+2)=sink_load(l+1)+net_sink(l+1).*dt(l+1);
    end
end
for i=1:num_year-1
    feasible(i+1)=feasible(i)+load(i);
end
% Display results
index=(feasible==0);
pinch=year(index);
alternative_storage=feasible(1);
unutilized_storage=sink_load(num_year)-source_load(num_year);
yearsink=year-time_difference_scalar;
capturable=source_load(end)-alternative_storage;
plot(sink_load(2:end), yearsink(2:end), '-o')
fprintf('%3d\t\t%10.2f\t%10.2f\t%20.2f\t%10d\n', time_difference_scalar, capturable, alternative_storage, unutilized_storage, pinch);
end
plot(source_load, year, '-x')
hold off
