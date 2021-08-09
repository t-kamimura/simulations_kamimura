clc
num = 51;
symbols = {'/','-','\\','|'};
for i = 1:num
    fprintf('\b\b\b\b\b\b\b\b\b\b\b\b')
    fprintf('[%6.2f %%] ',100*i/num)
    fprintf(cell2mat(symbols(1+rem(i,4))))
    pause(0.1)
end
fprintf('\n')