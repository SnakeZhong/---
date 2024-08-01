

function harris_sift()
    % ������
    clc; close all; clear;

    % �����ļ���·��
    input_folder = 'D:\ҽѧͼ���ں�\ʵ�鲿��\train_img\ct';  % ����ͼ���ļ���
    output_folder = './result2';  % ���ͼ���ļ���

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

            % ���ɸ�˹��������DoG������
            [gauss_pyr, dog_pyr] = generatePyramids(img_gray);

            % ��DoGͼ����Ӧ��Harris�ǵ���
            harris_points = harrisOnDoG(dog_pyr);

            % ʹ��SIFT�����Ӷ�Harris�ǵ������������
            [features, valid_points] = siftDescriptor(gauss_pyr, harris_points);

            % ��ʾ��⵽��������
            figure;
            imshow(img);
            hold on;
            plot(valid_points(:,2), valid_points(:,1), 'rx');
            title('Harris�ǵ��SIFT������');
            hold off;

            % �������ͼ��
            saveas(gcf, fullfile(output_folder, [name, '_result.png']));
            close(gcf);
        end
    end
end

function [gauss_pyr, dog_pyr] = generatePyramids(img_gray)
    % ���ɸ�˹������
    sigmas = [1, 2, 4];
    gauss_pyr = cell(1, length(sigmas));
    for i = 1:length(sigmas)
        gauss_pyr{i} = imgaussfilt(img_gray, sigmas(i));
    end

    % ����DoG������
    dog_pyr = cell(1, length(sigmas)-1);
    for i = 1:length(sigmas)-1
        dog_pyr{i} = gauss_pyr{i+1} - gauss_pyr{i};
    end
end

function harris_points = harrisOnDoG(dog_pyr)
    % ��DoGͼ����Ӧ��Harris�ǵ���
    harris_points = [];
    for i = 1:length(dog_pyr)
        R = harrisResponse(dog_pyr{i});
        points = nonMaxSuppression(R, 0.1);
        harris_points = [harris_points; points];
    end
end

function R = harrisResponse(img)
    % ����Harris��Ӧ����
    [Ix, Iy] = gradient(double(img));
    Ix2 = imgaussfilt(Ix.^2, 1);
    Iy2 = imgaussfilt(Iy.^2, 1);
    Ixy = imgaussfilt(Ix.*Iy, 1);

    k = 0.04;
    R = (Ix2 .* Iy2 - Ixy.^2) - k * (Ix2 + Iy2).^2;
end

function points = nonMaxSuppression(R, thresh)
    % �Ǽ���ֵ���ƺ���ֵ����
    maxR = max(R(:));
    [m, n] = size(R);
    points = [];
    neighbours = [-1,-1; -1,0; -1,1; 0,-1; 0,1; 1,-1; 1,0; 1,1];
    for i = 2:m-1
        for j = 2:n-1
            if R(i,j) > thresh * maxR
                is_max = true;
                for k = 1:size(neighbours, 1)
                    if R(i,j) < R(i+neighbours(k,1), j+neighbours(k,2))
                        is_max = false;
                        break;
                    end
                end
                if is_max
                    points = [points; i, j];
                end
            end
        end
    end
end

function [features, valid_points] = siftDescriptor(gauss_pyr, points)
    % ʹ��SIFT�����Ӷ�Harris�ǵ������������
    features = [];
    valid_points = [];
    for i = 1:size(points, 1)
        y = points(i, 1);
        x = points(i, 2);
        for j = 1:length(gauss_pyr)
            img = gauss_pyr{j};
            if y > 8 && y <= size(img, 1) - 8 && x > 8 && x <= size(img, 2) - 8
                patch = img(y-8:y+8, x-8:x+8);
                feature = extractSIFTDescriptor(patch);
                features = [features; feature'];
                valid_points = [valid_points; y, x];
            end
        end
    end
end

function descriptor = extractSIFTDescriptor(patch)
    % ��ȡSIFT������
    [Gx, Gy] = gradient(double(patch));
    magnitude = sqrt(Gx.^2 + Gy.^2);
    orientation = atan2(Gy, Gx) * 180 / pi;
    orientation(orientation < 0) = orientation(orientation < 0) + 360;

    num_bins = 8;
    bin_size = 360 / num_bins;
    descriptor = zeros(1, 128);

    for i = 1:4
        for j = 1:4
            sub_patch_mag = magnitude((i-1)*4+1:i*4, (j-1)*4+1:j*4);
            sub_patch_ori = orientation((i-1)*4+1:i*4, (j-1)*4+1:j*4);
            hist = zeros(1, num_bins);
            for k = 1:16
                bin = floor(sub_patch_ori(k) / bin_size) + 1;
                hist(bin) = hist(bin) + sub_patch_mag(k);
            end
            descriptor((i-1)*32+(j-1)*8+1:(i-1)*32+j*8) = hist;
        end
    end
    descriptor = descriptor / norm(descriptor);
end

