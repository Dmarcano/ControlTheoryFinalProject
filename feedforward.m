function [weighted_sums, activations, output] = feedforward(input, layer_one, bias_one, layer_two, bias_two )
%FEEDFORWARD: Feed forwards a shallow 3 layer neural network
%
%   input is a 1*N row vector, a N*M matrix of layer weights and a M*K
%   output matrix. the bias_one is a 1xM vector and bias 2 is a 1xK vector

    % calculate the network times the input
    weighted_sum1 = (input * layer_one) + bias_one;
    % apply sigmoid activation
    activation1 = arrayfun(@(x)leaky_relu(x) ,weighted_sum1);
    % propagate the previous activation
    weighted_sum2 = (activation1 * layer_two) + bias_two;
    output = arrayfun(@(x)leaky_relu(x) ,weighted_sum2);
    % store the weighted sums and activations for backpropagation
    weighted_sums = {};
    weighted_sums{1} = weighted_sum1;
    weighted_sums{2} = weighted_sum2;
    activations = {};
    activations{1} = input;
    activations{2} = activation1;

end
