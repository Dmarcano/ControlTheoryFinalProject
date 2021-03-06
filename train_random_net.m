% This file focuses on training a random neural network over 10 epochs or
% training methods. Since this is all hand made there are no automatic
% netowrk tuning methods to scrap and rerun the network if things get out
% of hand. Instead I manually check the network outputs and step responses 
% and get a sense of what is good. Neural Network frameworks largely
% automate that process of making random networks.

% weights from the input nodes to the hidden nodes
layer_one = randn(7,3);
bias_one = randn(1,3);
% weights from the hidden nodes to the output nodes
layer_two = randn(3, 3);
bias_two = randn(1,3);

% produce a an input vector of 1's. Perhaps random would be better
input_one = [1 1 1 1 1 1 1];


% we take an initial output from our network to get an error that is
% related to network weights later on
[weight_sums, activations, output] = feedforward(input_one, layer_one, bias_one, layer_two, bias_two);

kp = output(1); 
ki = output(2); 
kd = output(3); 

% define our control systems
s = tf('s');
Gplant = 10/(s^2 + 10*s + 10);

Gpid = tf(pid(kp,ki,kd));

Gclosed = feedback(Gplant*Gpid, 1);

t = 0:0.05:10.05;

y_total = zeros(202,1);
learning_rate = 0.0001; 

for j = 1: 10
    % train for 10 epochs
    total_err = 0;
    % keep track of our gradients of our weights and biases
    epoch_gradients = {};
    epoch_bias_grads = {};
    

for i = 1:2:202
    % run the controller
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
    
    kp = output(1); ki = output(2); kd = output(3); 
    Gpid = tf(pid(kp,ki,kd));

    Gclosed = feedback(Gplant*Gpid, 1);
    net_err = [err, err, err];
    [gradients,bias_gradients] = backprop(net_err, weight_sums, activations, layer_two);
    
    epoch_gradients{i} = gradients;
    epoch_bias_grads{i} = bias_gradients; 
    
    y_total(i) = y0; y_total(i+1) = y1; 
end

    % after the step response update the network with the error
    % we update on the first couple of "time units" of our step input as it
    % is usually the early transient response which we want to optimize for
    % also if we update on the entire step response error I tended to
    % wildly change the network. 
    
    % the network has no regularization methods so by random chance a
    % certain weight can "blow up" from the accumulation of error so it 
    % wildly change the network and makes it unstable. Regularization 
    % generally penalizes large weights so this is not as big of a problem 
    % for Machine learnign frameworks.
    for i = 1:4:20
        if j == 10
            % on our last epoch we do not update the network as we want 
            % to keep our weights so that if our response is good we
            % haven't changed it
            break
        end
        [layer_one, bias_one, layer_two, bias_two] = update_weights(epoch_gradients{i},epoch_bias_grads{i}, learning_rate, layer_one, bias_one, layer_two, bias_two);
    end
end

% now here I generally look at ki, kp, kd to see how our network has done
