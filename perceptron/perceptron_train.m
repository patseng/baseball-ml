trainMatrix = csvread('train_matrix.out');
trainCategory = trainMatrix(:,1)';
trainMatrix(:,1) = 1; % replace training labels with intercept term
numTrainDocs = size(trainMatrix, 1);
numTokens = size(trainMatrix, 2);

% trainMatrix is now a (numTrainDocs x numTokens) matrix.
% trainCategory is a (1 x numTrainDocs) vector containing the true 
% labels for the training vectors just read in. It is represented as the 
% 1st column of the matrix in train_matrix.out

LEARNING_RATE = 0.025;
theta = zeros(numTokens, 1);
for i = 1:numTrainDocs
    x_i = trainMatrix(i,:)'; % current training vector
    if theta' * x_i >= 0
        hypothesis = 1;
    else
        hypothesis = 0;
    end
    for j = 1:numTokens
        theta(j) = theta(j) + LEARNING_RATE * (trainCategory(i) - hypothesis) * x_i(j);
    end
end