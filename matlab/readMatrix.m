function [matrix, category] = readMatrix(filename)

fid = fopen(filename);

%Read number of training vectors (m) and tokens (n)
rowscols = fscanf(fid, '%d %d\n', 2);

% Training vector
% Each row represents a training vector (characteristics of a match-up)
matrix = sparse(1, 1, 0, rowscols(2), rowscols(1)); % the transpose!

% Vector containing the categories corresponding to each row in the
% document word matrix
% The 1st number is 1 if the home team won (or tied), and -1 otherwise.
category = matrix(rowscols(1));

%Read in the matrix and the categories
for m = 1:rowscols(1) % as many rows as number of documents
  line = fgetl(fid);
  nums = sscanf(line, '%d');
  category(m) = nums(1);
  matrix(1 + cumsum(nums(2:2:end - 1)), m) = nums(3:2:end - 1);
end

matrix = matrix'; % flip it back

fclose(fid);

