% aNN implementation
clear ; close all; clc

% setup the parameters for the aNN
input_layer_size=400;    % 20x20 pixel images
hidden_layer_size=9;  % 100 hidden units
num_classes=10;           % 2 classes   

% load Training Data
fprintf('loading data ...\n')
load('MNIST.mat');
m=size(X, 1); % number of examples

% visualize random instances of training data
sel = randperm(size(X, 1)); 
sel = sel(1:100); 
displayData(X(sel, :)); 

% randomly permute and separate into training and testing sets
index = randperm(m); 
X = X(index, :); 
y = y(index, :); 
cutoff = floor((2/3) * m); 
trainX = X(1:cutoff, :); 
testX = X(cutoff + 1:end, :); 
trainy = y(1:cutoff, :); 
testy = y(cutoff + 1:end, :); 

% randomly initialize parameter weights
fprintf('initializing parameters...\n')
epsilon_init=.12;
w1=rand(hidden_layer_size, 1 + input_layer_size)*2*epsilon_init-epsilon_init;
w2=rand(num_classes, 1 + hidden_layer_size)*2*epsilon_init-epsilon_init;

% vectorize the paramters
initial_nn_params=[w1(:) ; w2(:)];

% train neural network
fprintf('\nTraining Neural Network... \n')

% create costFunction object
lambda=1;
costFunction = @(p) get_cost_grads(p, ...
                                   input_layer_size, ...
                                   hidden_layer_size, ...
                                   num_classes, trainX, trainy, lambda);
      
% run optimization algorithm                               
options = optimset('MaxIter', 50);
[nn_params, cost] = fmincg(costFunction, initial_nn_params, options);

% Obtain Theta1 and Theta2 back from nn_params
w1=reshape(nn_params(1:hidden_layer_size * (input_layer_size + 1)), ...
                 hidden_layer_size, (input_layer_size + 1));

w2=reshape(nn_params((1 + (hidden_layer_size * (input_layer_size + 1))):end), ...
                 num_classes, (hidden_layer_size + 1));


% visualize hidden layer
fprintf('\nVisualizing Neural Network... \n')
displayData(w1(:, 2:end));

% test network
yPred = predict(w1, w2, testX); 
acc = 1 - (sum(yPred ~= testy)/size(testy, 1));
disp(['prediction accuracy of the network: ', num2str(acc)])

