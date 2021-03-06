function [cost, grad] = get_cost_grads(nn_params, ...
    input_layer_size, ...
    hidden_layer_size, ...
    num_classes, ...
    X, y, lambda)

% Reshape nn_params back into the parameters Theta1 and Theta2, the weight matrices
% for our 2 layer neural network
w1 = reshape(nn_params(1:hidden_layer_size * (input_layer_size + 1)), ...
    hidden_layer_size, (input_layer_size + 1));

w2 = reshape(nn_params((1 + (hidden_layer_size * (input_layer_size + 1))):end), ...
    num_classes, (hidden_layer_size + 1));

% Setup some useful variables
m = size(X, 1);

% augment X with ones
X = [ones(m, 1) ,X]; % augmented for bias

% feed forward and calculate cost function
cost = 0;
for i = 1:m % loop over all examples
    
    % create Y vector (i.e., the right answer)
    Y = zeros(num_classes, 1);
    Y(y(i), :) = 1;
    
    % feed forward
    a2 = [1, sigmoid(X(i, :) * w1')]; % augmented for bias
    a3 = sigmoid(a2 * w2'); % output layer
    
    % calculate the cost
    cost = cost + sum((-Y .* log(a3') - (ones(num_classes, 1) - Y) .* log( 1 - a3')));
    
    % calculate regularization cost
    w1_reg = 0;
    w2_reg = 0;
    for j = 1:size(w1, 1)
        w1_reg = w1_reg + w1(j, 2:end) * w1(j, 2:end)';
    end
    for j = 1:size(w2, 1)
        w2_reg = w2_reg + w2(j, 2:end) * w2(j, 2:end)';
    end
    
    % combine both
    cost = cost + (lambda / (2 * m)) * (w1_reg + w2_reg);
end

% compute average cost for all training examples
cost = cost / m;

% caclulate derivatives of weights with respect to errors
D1 = 0;
D2 = 0;
% backpropagation algorithm
for t = 1:m
    % create Y vector (i.e., the right answer)
    Y = zeros(num_classes, 1);
    Y(y(t), :) = 1;
    
    % feed forward
    a2 = [1, sigmoid(X(t, :) * w1')]';
    a3 = sigmoid(a2' * w2')';
    
    % calculate partial derivitives
    delta_3 = a3 - Y;
    delta_2 = (w2' * delta_3) .* (a2 .* (ones(size(a2)) - a2));
    
    % calculate accumulator
    D2 = D2 + delta_3 * a2';
    D1 = D1 + delta_2(2:end) * X(t, :);
    
end

% calculate average gradient for all examples
w1_grad = D1 / m;
w2_grad = D2 / m;

% add regularization to back propogation for both sets of weights
% NOTE: no regularization for bias, hence index starts at 2
for i = 2:size(w1_grad, 2)
    for j = 1:size(w1_grad, 1)
        w1_grad(j, i) = w1_grad(j, i) + (lambda / m) * w1(j, i);
    end
end
for i = 2:size(w2_grad, 2)
    for j = 1:size(w2_grad, 1)
        w2_grad(j, i) = w2_grad(j, i) + (lambda / m) * w2(j, i);
    end
end

% =========================================================================

% Unroll gradients
grad = [w1_grad(:) ; w2_grad(:)];


end
