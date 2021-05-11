function [updated_layer_1,updated_bias1, updated_layer_2, updated_bias2] = update_weights(gradients,bias_gradients, learning_rate, layer_one,layer_one_bias, layer_two, layer_two_bias)
    updated_layer_1 = layer_one - learning_rate.* gradients{1};
    updated_layer_2 = layer_two - learning_rate.*gradients{2};
    updated_bias1 = layer_one_bias - learning_rate .* bias_gradients{1};
    updated_bias2 = layer_two_bias - learning_rate .* bias_gradients{2};
end