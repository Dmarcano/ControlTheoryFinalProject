% calculates the gradients for each layer
%
function [gradients, bias_gradients] = backprop(error, weighted_sums, activations, layer_two)
% calculate the derivative of the weighted sum to the output layer
    output_deriv = arrayfun(@(x) dleaky_relu(x), weighted_sums{2} );
    output_delta = error.*output_deriv;
    % the gradient is the delta times the activation
    layer_two_grad = transpose(activations{2})* output_delta;

    % calculate the derivative of the weighted sum to the hidden layer
    hidden_deriv = arrayfun(@(x) dleaky_relu(x), weighted_sums{1});

    hidden_delta = (layer_two * transpose(output_delta)).*transpose(hidden_deriv);
    layer_one_grad = hidden_delta * activations{1};

    gradients = {};
    gradients{2} = layer_two_grad;
    gradients{1} = transpose(layer_one_grad);

    bias_gradients = {};
    bias_gradients{1} = output_delta;
    bias_gradients{2} = transpose(hidden_delta);
end
