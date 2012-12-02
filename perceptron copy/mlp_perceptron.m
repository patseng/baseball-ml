%{
% training
trainMatrix = csvread('train_matrix.out');
D = trainMatrix(:,1)';
trainMatrix(:,1) = []; % remove labels from training set
X = trainMatrix';
X = [X(1:41,:); X(114:132,:)];
p = size(X, 1);
H = floor((p+1)/2);
m = 1;

mu = 2.5;
alpha = .0001;
epoch = 20000;
MSEmin = 1e-20;
 
[Wx,Wy,MSE]=trainMLP(p,H,m,mu,alpha,X,D,epoch,MSEmin);
 
semilogy(MSE);
%}

% testing
testMatrix = csvread('test_matrix.out');
testLabels = testMatrix(:,1)';
testMatrix(:,1) = []; % remove labels from matrix
X = testMatrix';
X = [X(1:41,:); X(114:132,:)];

Y = runMLP(X,Wx,Wy);

disp(['Y = [' num2str(Y) ']']);


numWrongAnswers = 0;

for i=1:size(testLabels,2)
    if Y(i) >= 0.3
        guess = 1;
    else
        guess = 0;
    end
    if testLabels(i) ~= guess;
        numWrongAnswers = numWrongAnswers+1;
    end
end

1-numWrongAnswers/size(testLabels,2)