testMatrix = csvread('test_matrix.out');
testCategory = testMatrix(:,1)';
testMatrix(:,1) = 1; % replace test labels with intercept term
numTestDocs = size(testMatrix, 1);
numTokens = size(testMatrix, 2);

% testMatrix is now a (numTestDocs x numTokens) matrix.
% testCategory is a (1 x numTestDocs) vector containing the true 
% labels for the test vectors just read in. It is represented as the 
% 1st column of the matrix in test_matrix.out

numWrongAnswers = 0;

for i=1:numTestDocs
    x_i = testMatrix(i,:)'; % current test vector

    if theta' * x_i >= 0
        hypothesis = 1;
    else
        hypothesis = 0;
    end
    if testCategory(i) ~= hypothesis
        numWrongAnswers = numWrongAnswers + 1;
    end
end

error = numWrongAnswers/numTestDocs