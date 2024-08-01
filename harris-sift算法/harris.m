clc; close all; clear;

% �����ļ���·��
input_folder = 'D:\ҽѧͼ���ں�\ʵ�鲿��\train_img\ct';  % ����ͼ���ļ���
output_folder = './result';  % ���ͼ���ļ���

% ��������ļ��У���������ڵĻ���
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

% ��ȡ�ļ����е�ͼ���ļ�
img_files = dir(fullfile(input_folder, '*.*'));
valid_extensions = {'.jpg', '.jpeg', '.png', '.gif', '.bmp'};  % ֧�ֵ�ͼ���ʽ

for k = 1:length(img_files)
    [~, name, ext] = fileparts(img_files(k).name);
    if ismember(lower(ext), valid_extensions)
        % ��ȡͼ��
        img_path = fullfile(input_folder, img_files(k).name);
        img = imread(img_path);
        
        % ͼ����
        img_gray = img;
        if size(img, 3) == 3
            img_gray = rgb2gray(img);
        end
        
        % ��˹�˲�ȥ��������
        psf = fspecial('gaussian', [5, 5], 1.6);
        Ix = filter2([-1, 0, 1], img_gray);
        Iy = filter2([-1, 0, 1]', img_gray);
        Ix2 = filter2(psf, Ix.^2);
        Iy2 = filter2(psf, Iy.^2);
        Ixy = filter2(psf, Ix .* Iy);

        % ����ǵ����Ӧ����R
        [m, n] = size(img_gray);
        R = zeros(m, n);
        max_R = 0;
        for i = 1:m
            for j = 1:n
                M = [Ix2(i,j), Ixy(i,j); Ixy(i,j), Iy2(i,j)];  % ����ؾ���
                R(i,j) = det(M) - 0.04 * (trace(M))^2;
                if R(i,j) > max_R
                    max_R = R(i,j);
                end
            end
        end

        % ���зǼ������ƣ����ڴ�С3x3
        thresh = 0.1;
        tmp = zeros(m, n);
        neighbours = [-1,-1; -1,0; -1,1; 0,-1; 0,1; 1,-1; 1,0; 1,1];
        for i = 2:m-1
            for j = 2:n-1
                if R(i,j) > thresh * max_R
                    is_max = true;
                    for k = 1:8
                        if R(i,j) < R(i + neighbours(k,1), j + neighbours(k,2))
                            is_max = false;
                            break;
                        end
                    end
                    if is_max
                        tmp(i,j) = 1;
                    end
                end
            end
        end

        % ��ʾ���
        figure;
        subplot(1, 2, 1);
        imshow(img);
        title('ԭͼ');
        
        subplot(1, 2, 2);
        imshow(img);
        title('�ǵ���');
        hold on;
        for i = 2:m-1
            for j = 2:n-1
                if tmp(i,j) == 1
                    plot(j, i, 'rx')
                end
            end
        end
        hold off;

        % ������ͼ��
        result_path = fullfile(output_folder, [name, '_result', ext]);
        frame = getframe(gcf);
        imwrite(frame.cdata, result_path);
        close(gcf);
    end
end
