% Leaky Relu derivative
function out = dleaky_relu(x)
%out = sig(x)*(1 - sig(x));
if x > 0 
    out = 1; 
else 
    out = 0.01; 
end
end