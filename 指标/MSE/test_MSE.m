clear;

image1 = imread('C:\Users\93785\Desktop\ָ��\image\MRI-011.jpg');
image2 = imread('C:\Users\93785\Desktop\ָ��\image\PET-011.jpg');
I=imread('C:\Users\93785\Desktop\ָ��\image\PRO-011.jpg');
% 计算 MSE
mse1 = MSE(I, image1);
mse2 = MSE(I, image2);

% ��ʾ���
fprintf('Image I �� Image1 �� MSE: %f\n', mse1);
fprintf('Image I �� Image2 �� MSE: %f\n', mse2);
