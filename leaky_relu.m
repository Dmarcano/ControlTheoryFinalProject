function out = leaky_relu(x)
%LEAKY_RELU: calculates the leaky relu of an input with alpha = 0.01
%  

out = max([0.01*x, x]);
end

