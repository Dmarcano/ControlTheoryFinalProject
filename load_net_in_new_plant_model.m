% This Matlab file takes a look at loading a neural network response that 
% I found suitable and saved as a workspace file. We load in the network
% and see how it performs under new plant conditions
load real_good_response.mat
close all 

s = tf('s'); 

figure(1) 
step(Gplant);
title("Previous Plant Step Response") 

figure(2) 
plot(t, y_total); 
title("Previous Closed Loop Step Response") 
xlabel("Time (seconds)" ) 
ylabel("Amplitude") 


%%
% change our plant as we desire
Gplant = 10/(s^2 + sqrt(1)*0.5*s + 5);

figure(3) 
step(Gplant) 
title("New Plant Step Response") 

%%
% we already have kp ki and kd from our trained network
Gpid = tf(pid(kp,ki,kd));

% create our closed loop transfer function
Gclosed = feedback(Gplant*Gpid, 1);
% parameterize time
t = 0:0.05:10.05;
% keep track of our response y, and our PID gains
y_total = zeros(202,1);
kp_vals = zeros(202,1);
ki_vals =  zeros(202,1);
kd_vals =  zeros(202,1);
learning_rate = 0.01; % for network training. 

% we run a single step response to see how a pre-trained network will
% perform as a sig
for i = 1:2:202
    % store pid gain values
    kp_vals(i) = kp; 
    ki_vals(i) = ki;
    kd_vals(i) = kd;
    % parameterize our time step we are looking at
    time = t(i: i+1);
    % get the reference signals
    u0 = heaviside(time(1)); u1 = heaviside(time(2));
    
    % get the output signals 
    yout = step(Gclosed, time);
    y0 = yout(1); y1 = yout(2); 
    
    % get the control signal 
    cout = step(Gpid/(s+10000));
    c0 = cout(1); c1 = cout(2); 
    
    % get the error signal
    err = u1 - y1; 
    total_err = total_err + err; 
    
    %net_err = [err, err, err];
    yout(i) = y0; yout(i+1) = y1; 
    
    % update the neural network
    net_input = [u0, u1, y0, y1, c0, c1, err];
    [weight_sums, activations, output] = feedforward(net_input, layer_one, bias_one, layer_two, bias_two);
    
    %update our PID from our network output
    kp = output(1); ki = output(2); kd = output(3); 
    Gpid = tf(pid(kp,ki,kd));
    Gclosed = feedback(Gplant*Gpid, 1);
    net_err = [err, err, err];
    [gradients,bias_gradients] = backprop(net_err, weight_sums, activations, layer_two);
    
    % partially update our controlelr
    [layer_one, bias_one, layer_two, bias_two] = update_weights(epoch_gradients{i},epoch_bias_grads{i}, learning_rate, layer_one, bias_one, layer_two, bias_two);
    
    y_total(i) = y0; y_total(i+1) = y1; 
end

figure(4) 
plot(t, y_total); 
title("New Closed Loop Step Response") 
xlabel("Time (seconds)" ) 
ylabel("Amplitude") 
%% 
close all 

figure(1) 
plot(t, kp_vals); 
title("Kp through step response") 
xlabel("Time (seconds)" ) 
ylabel("Gain value")

figure(2)
plot(t, ki_vals); 
title("Ki through step response") 
xlabel("Time (seconds)" ) 
ylabel("Gain value")


figure(3) 
plot(t, kd_vals); 
title("Kd through step response") 
xlabel("Time (seconds)" ) 
ylabel("Gain value")