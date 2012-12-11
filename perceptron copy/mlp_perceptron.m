%{}
% training
trainMatrix = csvread('13_and_career_train_matrix.out');
D = trainMatrix(:,1)';
trainMatrix(:,1) = []; % remove labels from training set
X = trainMatrix';
p = size(X, 1);
H = 7; %floor((p+1)/2);
m = 1;

mu = 2.75;
alpha = 0 %0.001;
epoch = 5000;
MSEmin = 1e-20;
 
[Wx,Wy,MSE]=trainMLP(p,H,m,mu,alpha,X,D,epoch,MSEmin);
 
semilogy(MSE);
%}

% testing
testMatrix = csvread('13_and_career_test_matrix.out');
testLabels = testMatrix(:,1)';
testMatrix(:,1) = []; % remove labels from matrix
X = testMatrix';

Y = runMLP(X,Wx,Wy);

disp(['Y = [' num2str(Y) ']']);


numWrongAnswers = 0;

for i=1:size(testLabels,2)
    if Y(i) >= 0.5
        guess = 1;
    else
        guess = 0;
    end
    if testLabels(i) ~= guess;
        numWrongAnswers = numWrongAnswers+1;
    end
end

1-numWrongAnswers/size(testLabels,2)