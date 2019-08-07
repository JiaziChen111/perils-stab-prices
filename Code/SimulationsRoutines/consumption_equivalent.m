function ce = consumption_equivalent(WL, parameters)

% CONSUMPTION_EQUIVALENT calculates the consumption equivalent welfare loss from a quadratic welfare loss 
% Inputs: 
% WL: welfare loss calculated in utils
% parameters: the model's parameters

[alpha, betta, ~, sig, ~, ~, ~, ~, ...
            omega, ~, ~, ~, ~, ...
            ~, ~, ~, ~, ...
            ~, ~, ~, ...
            ~, ~, ~, ~, ...
            ~, ~, ~, ~, ...
            ~, ~, ~, ~, ~, ~] = translate_parameters(parameters);

ce = 100./sig*(-1+sqrt(1.+(2*sig*(1-betta)*(sig+omega)/alpha*WL./10000)));

end