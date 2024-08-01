% ����������������
sigama0 = 1.6;
count = 0;
description = []; % �����洢������
index = 0; % ��������������
description_1 = cell(size(location)); % �����洢������ͨ�������ҵ�description�ж�Ӧ��������
d = []; % �洢������ÿ�������ݶȷ���
l = []; % �洢������ÿ�������ݶȷ�ֵ
f = zeros(1, 8); % �������4*4������8ά������
description_2 = []; % �������128ά������
aaa = [];

for i = 1:O+1
    [M, N] = size(gauss_pyr_img{i}{1});
    for j = 2:S+1
        description_1{i}{j-1} = zeros(M, N);
        count = count + 1;
        sigama = sigama0 * k^count;
        % r=floor((3*sigama*sqrt(2)*5+1)/2);%ȷ������������Ҫ��ͼ������뾶
        r = 8; % ������������Ҫ��ͼ������뾶
        
        for ii = r+2:M-r-1
            for jj = r+2:N-r-1
                if length{i}{j-1}(ii, jj) ~= 0
                    theta_1 = direction{i}{j-1}(ii, jj); % �������������
                    index = index + 1;
                    description_2 = [];
                    d = [];
                    l = [];
                    
                    for iii = [ii-r:1:ii-1, ii+1:1:ii+r]
                        for jjj = [jj-r:1:jj-1, jj+1:1:jj+r]
                            m = sqrt((gauss_pyr_img{i}{j}(iii+1, jjj) - gauss_pyr_img{i}{j}(iii-1, jjj))^2 + (gauss_pyr_img{i}{j}(iii, jjj+1) - gauss_pyr_img{i}{j}(iii, jjj-1))^2);
                            theta = atan((gauss_pyr_img{i}{j}(iii, jjj+1) - gauss_pyr_img{i}{j}(iii, jjj-1)) / (gauss_pyr_img{i}{j}(iii+1, jjj) - gauss_pyr_img{i}{j}(iii-1, jjj)));
                            theta = theta / pi * 180; % �����Ȼ�Ϊ�Ƕ�
                            
                            if theta < 0
                                theta = theta + 360;
                            end
                            
                            w = exp(-(iii^2 + jjj^2) / (2 * (1.5 * sigama)^2)); % �����������Ԫ�ĸ�˹Ȩ��
                            
                            if isnan(theta)
                                if gauss_pyr_img{i}{j}(iii, jjj+1) - gauss_pyr_img{i}{j}(iii, jjj-1) >= 0
                                    theta = 90;
                                else
                                    theta = 270;
                                end
                            end
                            
                            theta = theta + 360 - theta_1; % ��ʱ����ת��������
                            theta = mod(theta, 360); % ȡ��
                            d = [d, theta];
                            l = [l, m * w];
                        end
                    end
                    
                    d = reshape(d, 16, 16);
                    l = reshape(l, 16, 16); % ��һά�����Ϊ��ά����
                    
                    for r1 = 1:4
                        for c1 = 1:4
                            for iiii = 1+(r1-1)*4 : 4*r1
                                for jjjj = 1+(c1-1)*4 : 4*c1
                                    t = floor(d(iiii, jjjj) / 45 + 1); % ����
                                    f(t) = f(t) + l(iiii, jjjj);
                                end
                            end
                            description_2 = [description_2, f(:)]; % �õ�һ��128ά��������
                        end
                    end
                    
                    description_2 = description_2 ./ sqrt(sum(description_2(:))); % ��һ������
                    description = [description; description_2(:)];
                    description_1{i}{j-1}(ii, jj) = index;
                    aaa = [aaa; ii, jj];
                end
            end
        end
    end
end
